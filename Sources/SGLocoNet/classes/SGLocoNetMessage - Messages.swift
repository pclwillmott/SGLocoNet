// -----------------------------------------------------------------------------
// SGLocoNetMessage - Messages.swift
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
//     02/10/2024  Paul Willmott - SGLocoNetMessage - Messages.swift created
// -----------------------------------------------------------------------------

import Foundation
import SGDCC

public extension SGLocoNetMessage {
  
  // MARK: COMMAND STATION COMMANDS
  
  static func powerOn() -> SGLocoNetMessage {
    return SGLocoNetMessage(data: [SGLocoNetOpcode.opcGPOn.rawValue])
  }
  
  static func powerOff() -> SGLocoNetMessage {
    return SGLocoNetMessage(data: [SGLocoNetOpcode.opcGPOff.rawValue])
  }
  
  static func getOpSwDataAP1() -> SGLocoNetMessage {
    return SGLocoNetMessage(data: [SGLocoNetOpcode.opcRqSlData.rawValue, 0x7f, 0x00])
  }
  
  static func opSwDataAP1() -> SGLocoNetMessage {
    return SGLocoNetMessage(data: [SGLocoNetOpcode.opcSlRdDdata.rawValue, 0x0e, 0x7f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
  }
  
  static func opSwDataBP1() -> SGLocoNetMessage {
    return SGLocoNetMessage(data: [SGLocoNetOpcode.opcSlRdDdata.rawValue, 0x0e, 0x7e, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
  }
  
  static func getOpSwDataBP1() -> SGLocoNetMessage {
    return SGLocoNetMessage(data: [SGLocoNetOpcode.opcRqSlData.rawValue, 0x7e, 0x00])
  }
  
  static func getOpSwDataP2() -> SGLocoNetMessage {
    return SGLocoNetMessage(data: [SGLocoNetOpcode.opcRqSlData.rawValue, 0x7f, 0x40])
  }
  
  static func getLocoSlotDataP1(slotNumber: UInt8) -> SGLocoNetMessage? {
    guard slotRange ~= slotNumber else {
      return nil
    }
    return SGLocoNetMessage(data: [SGLocoNetOpcode.opcRqSlData.rawValue, slotNumber, 0x00])
  }
  
  static func getLocoSlotDataP2(slotBank: UInt8, slotNumber: UInt8) -> SGLocoNetMessage? {
    guard slotBankRange ~= slotBank && slotRange ~= slotNumber else {
      return nil
    }
    return SGLocoNetMessage(data: [SGLocoNetOpcode.opcRqSlData.rawValue, slotNumber, slotBank | 0b01000000])
  }
  
  static func getProgSlotData() -> SGLocoNetMessage {
    return SGLocoNetMessage(data: [SGLocoNetOpcode.opcRqSlData.rawValue, 0x7c, 0x00])
  }
  
  static func getQuerySlot(querySlot: UInt8) -> SGLocoNetMessage? {
    guard (1 ... 5) ~= querySlot else {
      return nil
    }
    return SGLocoNetMessage(data: [SGLocoNetOpcode.opcRqSlData.rawValue, 0x77 + querySlot, 0x41])
  }


  // MARK: HELPER COMMANDS
  
  static func immPacket(packet:[UInt8], repeatCount: SGLocoNetIMMPacketRepeat) -> SGLocoNetMessage? {
    
    guard (1 ... 5) ~= packet.count else {
      return nil
    }
    
    var data : [UInt8] = [
      SGLocoNetOpcode.opcImmPacket.rawValue,
      0x0b,
      0x7f,
      (UInt8(packet.count) << 4) | repeatCount.rawValue,
      0b00000000,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
    ]
    
    var mask : UInt8 = 1
    
    for index in 0 ..< packet.count {
      let byte = packet[index]
      data[4] |= (byte & 0x80) != 0 ? mask : 0
      data[5 + index] = byte & 0x7f
      mask <<= 1
    }
    
    return SGLocoNetMessage(data: data)

  }
  
  static func immPacket(dccPacket:SGDCCPacket, repeatCount: SGLocoNetIMMPacketRepeat) -> SGLocoNetMessage? {
    
    guard dccPacket.isChecksumOK else {
      return nil
    }
    
    // The DCC packet checksum is not included in the immPacket as it
    // is added by the Command Station.
    
    var data : [UInt8] = [
      SGLocoNetOpcode.opcImmPacket.rawValue,
      0x0b,
      0x7f,
      (UInt8(dccPacket.packet.count - 1) << 4) | repeatCount.rawValue,
      0b00000000,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00,
    ]
    
    var mask : UInt8 = 1

    for index in 0 ..< dccPacket.packet.count - 1 {
      let byte = dccPacket.packet[index]
      data[4] |= (byte & 0x80) != 0 ? mask : 0
      data[5 + index] = byte & 0x7f
      mask <<= 1
    }
    
    return SGLocoNetMessage(data: data)

  }
  
  // MARK: LOCOMOTIVE CONTROL COMMANDS
  
  static func getLocoSlotDataP1(address: UInt16) -> SGLocoNetMessage? {
    guard locoNetAddressRange ~= address else {
      return nil
    }
    return SGLocoNetMessage(data: [SGLocoNetOpcode.opcLocoAdr.rawValue, UInt8(address >> 7), UInt8(address & 0x7f)])
  }
  
  static func getLocoSlotDataP2(address: UInt16) -> SGLocoNetMessage?{
    guard locoNetAddressRange ~= address else {
      return nil
    }
    return SGLocoNetMessage(data: [SGLocoNetOpcode.opcLocoAdrP2.rawValue, UInt8(address >> 7), UInt8(address & 0x7f)])
  }

  static func setLocoSlotStat1P1(slotNumber:UInt8, stat1:UInt8) -> SGLocoNetMessage? {
    guard slotRange ~= slotNumber && stat1 < 0x80 else {
      return nil
    }
    return SGLocoNetMessage(data: [SGLocoNetOpcode.opcSlotStat1.rawValue, slotNumber, stat1])
  }
  
  static func setLocoSlotStat1P2(slotBank:UInt8, slotNumber:UInt8, stat1:UInt8) -> SGLocoNetMessage? {
    guard slotBankRange ~= slotBank && slotRange ~= slotNumber && stat1 < 0x80 else {
      return nil
    }
    return SGLocoNetMessage(data: [SGLocoNetOpcode.opcD4Group.rawValue, 0b00111000 | slotBank, slotNumber, 0x60, stat1])
  }

  static func moveSlotP1(sourceSlotNumber: UInt8, destinationSlotNumber: UInt8) -> SGLocoNetMessage? {
    guard slotRange ~= sourceSlotNumber && slotRange ~= destinationSlotNumber && sourceSlotNumber != destinationSlotNumber else {
      return nil
    }
    return SGLocoNetMessage(data: [SGLocoNetOpcode.opcMoveSlots.rawValue, sourceSlotNumber, destinationSlotNumber])
  }
  
  static func moveSlotP2(sourceSlotBank: UInt8, sourceSlotNumber: UInt8, destinationSlotBank: UInt8, destinationSlotNumber: UInt8) -> SGLocoNetMessage? {
    guard slotBankRange ~= sourceSlotBank && slotRange ~= sourceSlotNumber && slotBankRange ~= destinationSlotBank && slotRange ~= destinationSlotNumber && (sourceSlotNumber != destinationSlotNumber || sourceSlotBank != destinationSlotBank) else {
      return nil
    }
    return SGLocoNetMessage(data: [SGLocoNetOpcode.opcD4Group.rawValue, 0b00111000 | sourceSlotBank, sourceSlotNumber, destinationSlotBank, destinationSlotNumber])
  }

  static func setLocoSlotInUseP1(slotNumber: UInt8) -> SGLocoNetMessage? {
    guard slotRange ~= slotNumber else {
      return nil
    }
    return SGLocoNetMessage(data: [SGLocoNetOpcode.opcMoveSlots.rawValue, slotNumber, slotNumber])
  }
  
  static func setLocoSlotInUseP2(slotBank: UInt8, slotNumber: UInt8) -> SGLocoNetMessage? {
    guard slotBankRange ~= slotBank && slotRange ~= slotNumber else {
      return nil
    }
    return SGLocoNetMessage(data: [SGLocoNetOpcode.opcD4Group.rawValue, 0b00111000 | slotBank, slotNumber, slotBank, slotNumber])
  }

  static func locoSpdP1(slotNumber: UInt8, speed: UInt8) -> SGLocoNetMessage? {
    guard slotRange ~= slotNumber && (0 ... 127) ~= speed else {
      return nil
    }
    return SGLocoNetMessage(data: [SGLocoNetOpcode.opcLocoSpd.rawValue, slotNumber, speed])
  }
  
  static func locoSpdDirP2(slotBank: UInt8, slotNumber: UInt8, speed: UInt8, direction: SGLocoNetLocomotiveDirection, throttleID: UInt16) -> SGLocoNetMessage? {
    guard slotBankRange ~= slotBank && slotRange ~= slotNumber && (0 ... 127) ~= speed else {
      return nil
    }
    return SGLocoNetMessage(data: [SGLocoNetOpcode.opcD5Group.rawValue, slotBank | (direction == .reverse ? 0b00001000 : 0), slotNumber, UInt8(throttleID & 0x7f), speed])
  }

  static func locoDirF0F4P1(slotNumber: UInt8, direction:SGLocoNetLocomotiveDirection, functions: SGFunctionGroup) -> SGLocoNetMessage? {
    
    guard slotRange ~= slotNumber else {
      return nil
    }
    
    var dirf : UInt8 = (direction == .reverse ? 0b00100000 : 0) | (functions.get(index: 0) ? 0b00010000 : 0)
    
    var mask : UInt8 = 1
    for index in 1 ... 4 {
      dirf |= functions.get(index: index) ? mask : 0
      mask <<= 1
    }
    
    return SGLocoNetMessage(data: [SGLocoNetOpcode.opcLocoDirF.rawValue, slotNumber, dirf])

  }

  static func locoF5F8P1(slotNumber: UInt8, functions: SGFunctionGroup) -> SGLocoNetMessage? {
    
    guard slotRange ~= slotNumber else {
      return nil
    }
    
    var fnx : UInt8 = 0
    
    var mask : UInt8 = 1
    for index in 5 ... 8 {
      fnx |= functions.get(index: index) ? mask : 0
      mask <<= 1
    }

    return SGLocoNetMessage(data: [SGLocoNetOpcode.opcLocoSnd.rawValue, slotNumber, fnx])

  }
  
  static func locoF0F6P2(slotBank: UInt8, slotNumber: UInt8, functions: SGFunctionGroup, throttleID: UInt16) -> SGLocoNetMessage? {
    
    guard slotBankRange ~= slotBank && slotRange ~= slotNumber else {
      return nil
    }
    
    var fnx : UInt8 = 0
    
    fnx |= functions.get(index: 0) ? 0b00010000 : 0
    fnx |= functions.get(index: 1) ? 0b00000001 : 0
    fnx |= functions.get(index: 2) ? 0b00000010 : 0
    fnx |= functions.get(index: 3) ? 0b00000100 : 0
    fnx |= functions.get(index: 4) ? 0b00001000 : 0
    fnx |= functions.get(index: 5) ? 0b00100000 : 0
    fnx |= functions.get(index: 6) ? 0b01000000 : 0

    return SGLocoNetMessage(data: [SGLocoNetOpcode.opcD5Group.rawValue, slotBank | 0b00010000, slotNumber, UInt8(throttleID & 0x7f), fnx])

  }
  
  static func locoF7F13P2(slotBank: UInt8, slotNumber: UInt8, functions: SGFunctionGroup, throttleID: UInt16) -> SGLocoNetMessage? {
    
    guard slotBankRange ~= slotBank && slotRange ~= slotNumber else {
      return nil
    }
    
    var fnx : UInt8 = 0
    
    var mask : UInt8 = 0b00000001
    
    for index in 7 ... 13 {
      fnx |= functions.get(index: index) ? mask : 0
      mask <<= 1
    }
    
    return SGLocoNetMessage(data: [SGLocoNetOpcode.opcD5Group.rawValue, slotBank | 0b00011000, slotNumber, UInt8(throttleID & 0x7f), fnx])

  }
  
  static func locoF14F20P2(slotBank: UInt8, slotNumber: UInt8, functions: SGFunctionGroup, throttleID: UInt16) -> SGLocoNetMessage? {
    
    guard slotBankRange ~= slotBank && slotRange ~= slotNumber else {
      return nil
    }
    
    var fnx : UInt8 = 0
    
    var mask : UInt8 = 0b00000001
    
    for index in 14 ... 20 {
      fnx |= functions.get(index: index) ? mask : 0
      mask <<= 1
    }

    return SGLocoNetMessage(data: [SGLocoNetOpcode.opcD5Group.rawValue, slotBank | 0b00100000, slotNumber, UInt8(throttleID & 0x7f), fnx])

  }
  
  static func locoF21F28P2(slotBank: UInt8, slotNumber: UInt8, functions: SGFunctionGroup, throttleID: UInt16) -> SGLocoNetMessage? {
    
    guard slotBankRange ~= slotBank && slotRange ~= slotNumber else {
      return nil
    }
    
    var fnx : UInt8 = 0
    
    var mask : UInt8 = 0b00000001
    
    for index in 21 ... 27 {
      fnx |= functions.get(index: index) ? mask : 0
      mask <<= 1
    }

    return SGLocoNetMessage(data: [SGLocoNetOpcode.opcD5Group.rawValue, slotBank | UInt8(functions.get(index: 28) ? 0b00110000 : 0b00101000), slotNumber, UInt8(throttleID & 0x7f), fnx])

  }
  
  static func dccF13F20(address:UInt16, functions: SGFunctionGroup) -> SGLocoNetMessage? {
    
    guard locoNetAddressRange ~= address else {
      return nil
    }
    
    var packet : SGDCCPacket?
    
    if address < 128 {
      packet = SGDCCPacket.f13f20Control(shortAddress: UInt8(address), functions: functions)
    }
    else {
      packet = SGDCCPacket.f13f20Control(longAddress: address, functions: functions)
    }

    if let packet {
      return immPacket(dccPacket: packet, repeatCount: .repeat4)
    }
    
    return nil
        
  }

  static func dccF21F28(address:UInt16, functions: SGFunctionGroup) -> SGLocoNetMessage? {
    
    guard locoNetAddressRange ~= address else {
      return nil
    }
    
    var packet : SGDCCPacket?
    
    if address < 128 {
      packet = SGDCCPacket.f21f28Control(shortAddress: UInt8(address), functions: functions)
    }
    else {
      packet = SGDCCPacket.f21f28Control(longAddress: address, functions: functions)
    }

    if let packet {
      return immPacket(dccPacket: packet, repeatCount: .repeat4)
    }
    
    return nil
        
  }

  static func dccF29F36(address:UInt16, functions: SGFunctionGroup) -> SGLocoNetMessage? {
    
    guard locoNetAddressRange ~= address else {
      return nil
    }
    
    var packet : SGDCCPacket?
    
    if address < 128 {
      packet = SGDCCPacket.f29f36Control(shortAddress: UInt8(address), functions: functions)
    }
    else {
      packet = SGDCCPacket.f29f36Control(longAddress: address, functions: functions)
    }

    if let packet {
      return immPacket(dccPacket: packet, repeatCount: .repeat4)
    }
    
    return nil
        
  }

  static func dccF37F44(address:UInt16, functions: SGFunctionGroup) -> SGLocoNetMessage? {
    
    guard locoNetAddressRange ~= address else {
      return nil
    }
    
    var packet : SGDCCPacket?
    
    if address < 128 {
      packet = SGDCCPacket.f37f44Control(shortAddress: UInt8(address), functions: functions)
    }
    else {
      packet = SGDCCPacket.f37f44Control(longAddress: address, functions: functions)
    }

    if let packet {
      return immPacket(dccPacket: packet, repeatCount: .repeat4)
    }
    
    return nil
        
  }
  
  static func dccF45F52(address:UInt16, functions: SGFunctionGroup) -> SGLocoNetMessage? {
    
    guard locoNetAddressRange ~= address else {
      return nil
    }
    
    var packet : SGDCCPacket?
    
    if address < 128 {
      packet = SGDCCPacket.f45f52Control(shortAddress: UInt8(address), functions: functions)
    }
    else {
      packet = SGDCCPacket.f45f52Control(longAddress: address, functions: functions)
    }

    if let packet {
      return immPacket(dccPacket: packet, repeatCount: .repeat4)
    }
    
    return nil
        
  }
  
  static func dccF53F60(address:UInt16, functions: SGFunctionGroup) -> SGLocoNetMessage? {
    
    guard locoNetAddressRange ~= address else {
      return nil
    }
    
    var packet : SGDCCPacket?
    
    if address < 128 {
      packet = SGDCCPacket.f53f60Control(shortAddress: UInt8(address), functions: functions)
    }
    else {
      packet = SGDCCPacket.f53f60Control(longAddress: address, functions: functions)
    }

    if let packet {
      return immPacket(dccPacket: packet, repeatCount: .repeat4)
    }
    
    return nil
        
  }
  
  static func dccF61F68(address:UInt16, functions: SGFunctionGroup) -> SGLocoNetMessage? {
    
    guard locoNetAddressRange ~= address else {
      return nil
    }
    
    var packet : SGDCCPacket?
    
    if address < 128 {
      packet = SGDCCPacket.f61f68Control(shortAddress: UInt8(address), functions: functions)
    }
    else {
      packet = SGDCCPacket.f61f68Control(longAddress: address, functions: functions)
    }

    if let packet {
      return immPacket(dccPacket: packet, repeatCount: .repeat4)
    }
    
    return nil
        
  }

  
}

