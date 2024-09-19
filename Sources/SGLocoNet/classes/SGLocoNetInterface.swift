// -----------------------------------------------------------------------------
// SGLocoNetInterface.swift
//
// This Swift source file is a part of the SGLocoNet package
// by Paul C. L. Willmott.
//
// Copyright © 2024 Paul C. L. Willmott. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy 
// of this software and associated documentation files (the “Software”), to deal 
// in the Software without restriction, including without limitation the rights 
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell 
// copies of the Software, and to permit persons to whom the Software is 
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in 
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE 
// SOFTWARE.
// -----------------------------------------------------------------------------
//
// Revision History:
//
//     19/09/2024  Paul Willmott - SGLocoNetInterface.swift created
// -----------------------------------------------------------------------------

import Foundation

public class SGLocoNetInterface : NSObject {
  
  // MARK: Private Properties
  
  private var buffer : [UInt8] = []
  
  // MARK: Public Properties
  
  public var delegate : SGLocoNetInterfaceDelegate?
  
  // MARK: Public Methods
  
  public func didReceive(data:[UInt8]) {
    
    buffer.append(contentsOf: data)

    let maskOpCode : UInt8 = 0x80
    
    while !buffer.isEmpty {
      
      // find the start of a message
      
      var opCodeFound = false
      
      while let cc = buffer.first {
        if ((cc & maskOpCode) == maskOpCode) {
          opCodeFound = true
          break
        }
        buffer.removeFirst()
      }
      
      // give up if no opcode found
      
      if !opCodeFound {
        break
      }
      
      // find the message length
      
      var length : UInt8
      
      switch buffer.first! & 0b01100000 {
      case 0b00000000 :
        length = 2
      case 0b00100000 :
        length = 4
      case 0b01000000 :
        length = 6
      default :
        length = (buffer.count > 1) ? ((buffer[1] == 0) ? 128 : buffer[1]) : 0xff
      }
      
      // give up there are not enough bytes in the buffer
      
      if length == 0xff || buffer.count < length {
        break
      }
      
      // extract the message bytes and restart if an opcode is found
      // before the end of the message
      
      var message : [UInt8] = []
       
      var restart = false
      
      for index in 1 ... length {
        
        let cc = buffer.first!
        
        if index > 1 && ((cc & maskOpCode) == maskOpCode) {
          restart = true
          break
        }
        
        message.append(cc)
        
        buffer.removeFirst()
        
      }
      
      // Process message if no high bits set in the message
        
      if !restart {
        
        let locoNetMessage = LocoNetMessage(data: message)
        locoNetMessage.timeStamp = Date.timeIntervalSinceReferenceDate
        locoNetMessage.timeSinceLastMessage = locoNetMessage.timeStamp - lastTimeStamp
        lastTimeStamp = locoNetMessage.timeStamp

        if let currentItem {
          
          if message == currentItem.message {
            stopTimeoutTimer()
            switch currentItem.messageType {
            case .immPacket:
              mode = .waitingForIMMPacketAck
              startTimeoutTimer(numberOfBytes: 4)
            case .setSwWithAck:
              mode = .waitingForSetSwAck
              startTimeoutTimer(numberOfBytes: 4)
            default:
              DispatchQueue.main.async {
                self.currentItem = nil
                self.sendNext()
              }
            }
          }
          else {
            
            switch mode {
            case .waitingForIMMPacketAck:
              switch locoNetMessage.messageType {
              case .immPacketOK:
                stopTimeoutTimer()
                DispatchQueue.main.async {
                  self.mode = .idle
                  self.currentItem = nil
                  self.sendNext()
                }
              case .immPacketBufferFull:
                stopTimeoutTimer()
                mode = .sendingMessage
                retryCount = 10
                startTimeoutTimer(numberOfBytes: currentItem.message.count)
                send(data: currentItem.message)
              default:
                break
              }
            case .waitingForSetSwAck:
              switch locoNetMessage.messageType {
              case .setSwWithAckAccepted:
                stopTimeoutTimer()
                DispatchQueue.main.async {
                  self.mode = .idle
                  self.currentItem = nil
                  self.sendNext()
                }
              case .setSwWithAckRejected:
                stopTimeoutTimer()
                mode = .sendingMessage
                retryCount = 10
                startTimeoutTimer(numberOfBytes: currentItem.message.count)
                send(data: currentItem.message)
              default:
                break
              }
            default:
              break
            }
          }
          
        }
        
        if locoNetMessage.messageType == .opSwDataAP1 {
          commandStationType = LocoNetCommandStationType(rawValue: UInt16(locoNetMessage.message[11])) ?? .standAlone
        }
      
        DispatchQueue.main.async {
          for (_, observer) in self.observers {
            observer.locoNetMessageReceived?(message: locoNetMessage)
          }
        }

      }

    }
    

  }

}
