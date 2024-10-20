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

private enum SGLocoNetInterfaceState {

  // MARK: Enumeration
  
  case idle
  case sendingMessage
  case waitingForIMMPacketAck
  case waitingForSetSwAck
  
}

public class SGLocoNetInterface : NSObject   {
  
  // MARK: Private Properties
  
  private var buffer : [UInt8] = []
  
  private var lastTimeStamp : TimeInterval = 0.0
  
  private var observers : [ObjectIdentifier:SGLocoNetInterfaceObserver] = [:]

  private var queue : [SGLocoNetMessage] = []
  
  private var sending : SGLocoNetMessage?
  
  private var timeoutTimer : Timer?
  
  private var retryCount = 0
  
  private var state : SGLocoNetInterfaceState = .idle

  // MARK: Public Properties
  
  public weak var delegate : SGLocoNetInterfaceDelegate?
  
  // MARK: Private Methods
  
  private func sendNext() {
    
    guard let delegate else {
      state = .idle
      queue.removeAll()
      return
    }
    
    guard sending == nil, !queue.isEmpty else {
      return
    }
    
    sending = queue.removeFirst()
    
    if let sending {
      state = .sendingMessage
      retryCount = 10
      startTimeoutTimer(numberOfBytes: sending.message.count)
      delegate.sendData?(interface: self, data: sending.messageWithChecksum)
    }

  }
  
  internal func addToQueue(message:SGLocoNetMessage) {
    queue.append(message)
    sendNext()
  }
  
  @objc func timeoutTimerAction() {
    
    if let sending {
      
      switch state {
      case .waitingForIMMPacketAck, .waitingForSetSwAck, .sendingMessage:
        if retryCount < 0 {
          state = .idle
          self.sending = nil
          sendNext()
        }
        else {
          state = .sendingMessage
          retryCount -= 1
          startTimeoutTimer(numberOfBytes: sending.message.count)
          delegate?.sendData?(interface: self, data: sending.messageWithChecksum)
        }
      default:
        state = .idle
        self.sending = nil
        sendNext()
      }
      
    }
    
  }
  
  private func startTimeoutTimer(numberOfBytes:Int) {
    let interval: TimeInterval = Double(numberOfBytes * 10) / 16660.0 * 3.0
    timeoutTimer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(timeoutTimerAction), userInfo: nil, repeats: false)
    RunLoop.current.add(timeoutTimer!, forMode: .common)
  }
  
  private func stopTimeoutTimer() {
    timeoutTimer?.invalidate()
    timeoutTimer = nil
  }

  // MARK: Public Methods
  
  public func addObserver(observer:SGLocoNetInterfaceObserver) {
    observers[ObjectIdentifier(observer)] = observer
  }
  
  public func removeObserver(observer:SGLocoNetInterfaceObserver) {
    observers.removeValue(forKey: ObjectIdentifier(observer))
  }
  
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
      
      var data : [UInt8] = []
       
      var restart = false
      
      for index in 1 ... length {
        
        let cc = buffer.first!
        
        if index > 1 && ((cc & maskOpCode) == maskOpCode) {
          restart = true
          break
        }
        
        data.append(cc)
        
        buffer.removeFirst()
        
      }
      
      // Process message if no high bits set in the message and the checksum
      // is OK.
        
      if !restart, var locoNetMessage = SGLocoNetMessage(dataWithCheckSum: data) {
        
        locoNetMessage.timeStamp = Date.timeIntervalSinceReferenceDate
        locoNetMessage.timeSinceLastMessage = locoNetMessage.timeStamp - lastTimeStamp
        lastTimeStamp = locoNetMessage.timeStamp
        
        if let sending, let delegate {
          
          if locoNetMessage == sending {
            stopTimeoutTimer()
            switch sending.messageType {
            case .immPacket:
              state = .waitingForIMMPacketAck
              startTimeoutTimer(numberOfBytes: 4)
            case .setSwWithAck:
              state = .waitingForSetSwAck
              startTimeoutTimer(numberOfBytes: 4)
            default:
              state = .idle
              self.sending = nil
              sendNext()
            }
          }
          else {
            
            switch state {
            case .waitingForIMMPacketAck:
              switch locoNetMessage.messageType {
              case .immPacketOK:
                stopTimeoutTimer()
                state = .idle
                self.sending = nil
                sendNext()
              case .immPacketBufferFull:
                stopTimeoutTimer()
                state = .sendingMessage
                retryCount = 10
                startTimeoutTimer(numberOfBytes: sending.message.count)
                delegate.sendData?(interface: self, data: sending.message)
              default:
                break
              }
            case .waitingForSetSwAck:
              switch locoNetMessage.messageType {
              case .setSwWithAckAccepted:
                stopTimeoutTimer()
                state = .idle
                self.sending = nil
                sendNext()
              case .setSwWithAckRejected:
                stopTimeoutTimer()
                state = .sendingMessage
                retryCount = 10
                startTimeoutTimer(numberOfBytes: sending.message.count)
                delegate.sendData?(interface: self, data: sending.message)
              default:
                break
              }
            default:
              break
            }
            
          }
          
        }
        
        for (_, observer) in observers {
          observer.locoNetInterface?(sender: self, didReceive: locoNetMessage)
        }
        
      }

    }
    
  }

}
