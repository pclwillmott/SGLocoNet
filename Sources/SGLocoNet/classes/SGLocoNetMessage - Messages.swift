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
    return SGLocoNetMessage(.opcGPOn)
  }
  
  static func powerOff() -> SGLocoNetMessage {
    return SGLocoNetMessage(.opcGPOff)
  }
  
  static func getOpSwDataAP1() -> SGLocoNetMessage {
    return SGLocoNetMessage(.opcRqSlData, data: [0x7f, 0x00])
  }
  
  static func opSwDataAP1() -> SGLocoNetMessage {
    return SGLocoNetMessage(.opcSlRdDdata, data: [0x0e, 0x7f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
  }
  
  static func opSwDataBP1() -> SGLocoNetMessage {
    return SGLocoNetMessage(.opcSlRdDdata, data: [0x0e, 0x7e, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
  }
  
  static func getOpSwDataBP1() -> SGLocoNetMessage {
    return SGLocoNetMessage(.opcRqSlData, data: [0x7e, 0x00])
  }
  
  static func getOpSwDataP2() -> SGLocoNetMessage {
    return SGLocoNetMessage(.opcRqSlData, data: [0x7f, 0x40])
  }
  
  static func getLocoSlotDataP1(slotNumber: UInt8) -> SGLocoNetMessage? {
    guard slotRange ~= slotNumber else {
      return nil
    }
    return SGLocoNetMessage(.opcRqSlData, data: [slotNumber, 0x00])
  }
  
  static func getLocoSlotDataP2(slotBank: UInt8, slotNumber: UInt8) -> SGLocoNetMessage? {
    guard slotBankRange ~= slotBank && slotRange ~= slotNumber else {
      return nil
    }
    return SGLocoNetMessage(.opcRqSlData, data: [slotNumber, slotBank | 0b01000000])
  }
  
  static func getProgSlotData() -> SGLocoNetMessage {
    return SGLocoNetMessage(.opcRqSlData, data: [0x7c, 0x00])
  }
  
  static func getFastClock() -> SGLocoNetMessage {
    return SGLocoNetMessage(.opcRqSlData, data: [0x7b, 0x00])
  }
  
  static func getQuerySlot(querySlot: UInt8) -> SGLocoNetMessage? {
    guard (1 ... 5) ~= querySlot else {
      return nil
    }
    return SGLocoNetMessage(.opcRqSlData, data: [0x77 + querySlot, 0x41])
  }


  // MARK: HELPER COMMANDS
  
  static func immPacket(packet:[UInt8], repeatCount: SGLocoNetIMMPacketRepeat) -> SGLocoNetMessage? {
    
    guard (1 ... 5) ~= packet.count else {
      return nil
    }
    
    var data : [UInt8] = [
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
      data[3] |= (byte & 0x80) != 0 ? mask : 0
      data[4 + index] = byte & 0x7f
      mask <<= 1
    }
    
    return SGLocoNetMessage(.opcImmPacket, data: data)

  }
  
  static func immPacket(dccPacket:SGDCCPacket, repeatCount: SGLocoNetIMMPacketRepeat) -> SGLocoNetMessage? {
    
    guard dccPacket.isChecksumOK else {
      return nil
    }
    
    // The DCC packet checksum is not included in the immPacket as it
    // is added by the Command Station.
    
    var data : [UInt8] = [
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
    
    return SGLocoNetMessage(.opcImmPacket, data: data)

  }
  
  // MARK: LOCOMOTIVE CONTROL COMMANDS
  
  static func getLocoSlotDataP1(address: UInt16) -> SGLocoNetMessage? {
    guard locoNetAddressRange ~= address else {
      return nil
    }
    return SGLocoNetMessage(.opcLocoAdr, data: [UInt8(address >> 7), UInt8(address & 0x7f)])
  }
  
  static func getLocoSlotDataP2(address: UInt16) -> SGLocoNetMessage?{
    guard locoNetAddressRange ~= address else {
      return nil
    }
    return SGLocoNetMessage(.opcLocoAdrP2, data: [UInt8(address >> 7), UInt8(address & 0x7f)])
  }
  
  static func setLocoSlotDataP1(baseMessage: SGLocoNetMessage = SGLocoNetMessage(.opcSlRdDdata, data: [0x0e, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])) -> SGLocoNetMessage? {
    
    guard baseMessage.messageType == .locoSlotDataP1 || baseMessage.messageType == .setLocoSlotDataP1 else {
      return nil
    }
    
    return SGLocoNetMessage(.opcWrSlData, data: baseMessage._data)

  }

  static func setLocoSlotDataP2(baseMessage: SGLocoNetMessage = SGLocoNetMessage(.opcSlRdDdataP2, data: [0x15, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])) -> SGLocoNetMessage? {
    
    guard baseMessage.messageType == .locoSlotDataP2 || baseMessage.messageType == .setLocoSlotDataP2 else {
      return nil
    }
    
    return SGLocoNetMessage(.opcWrSlDataP2, data: baseMessage._data)

  }

  static func setLocoSlotStat1P1(slotNumber:UInt8, stat1:UInt8) -> SGLocoNetMessage? {
    guard slotRange ~= slotNumber && stat1 < 0x80 else {
      return nil
    }
    return SGLocoNetMessage(.opcSlotStat1, data: [slotNumber, stat1])
  }
  
  static func setLocoSlotStat1P2(slotBank:UInt8, slotNumber:UInt8, stat1:UInt8) -> SGLocoNetMessage? {
    guard slotBankRange ~= slotBank && slotRange ~= slotNumber && stat1 < 0x80 else {
      return nil
    }
    return SGLocoNetMessage(.opcD4Group, data: [0b00111000 | slotBank, slotNumber, 0x60, stat1])
  }

  static func moveSlotP1(sourceSlotNumber: UInt8, destinationSlotNumber: UInt8) -> SGLocoNetMessage? {
    guard slotRange ~= sourceSlotNumber && slotRange ~= destinationSlotNumber && sourceSlotNumber != destinationSlotNumber else {
      return nil
    }
    return SGLocoNetMessage(.opcMoveSlots, data: [sourceSlotNumber, destinationSlotNumber])
  }
  
  static func moveSlotP2(sourceSlotBank: UInt8, sourceSlotNumber: UInt8, destinationSlotBank: UInt8, destinationSlotNumber: UInt8) -> SGLocoNetMessage? {
    guard slotBankRange ~= sourceSlotBank && slotRange ~= sourceSlotNumber && slotBankRange ~= destinationSlotBank && slotRange ~= destinationSlotNumber && (sourceSlotNumber != destinationSlotNumber || sourceSlotBank != destinationSlotBank) else {
      return nil
    }
    return SGLocoNetMessage(.opcD4Group, data: [0b00111000 | sourceSlotBank, sourceSlotNumber, destinationSlotBank, destinationSlotNumber])
  }

  static func setLocoSlotInUseP1(slotNumber: UInt8) -> SGLocoNetMessage? {
    guard slotRange ~= slotNumber else {
      return nil
    }
    return SGLocoNetMessage(.opcMoveSlots, data: [slotNumber, slotNumber])
  }
  
  static func setLocoSlotInUseP2(slotBank: UInt8, slotNumber: UInt8) -> SGLocoNetMessage? {
    guard slotBankRange ~= slotBank && slotRange ~= slotNumber else {
      return nil
    }
    return SGLocoNetMessage(.opcD4Group, data: [0b00111000 | slotBank, slotNumber, slotBank, slotNumber])
  }

  static func locoSpdP1(slotNumber: UInt8, speed: UInt8) -> SGLocoNetMessage? {
    guard slotRange ~= slotNumber && (0 ... 127) ~= speed else {
      return nil
    }
    return SGLocoNetMessage(.opcLocoSpd, data: [slotNumber, speed])
  }
  
  static func locoSpdDirP2(slotBank: UInt8, slotNumber: UInt8, speed: UInt8, direction: SGLocoNetLocomotiveDirection, throttleID: UInt16) -> SGLocoNetMessage? {
    guard slotBankRange ~= slotBank && slotRange ~= slotNumber && (0 ... 127) ~= speed else {
      return nil
    }
    return SGLocoNetMessage(.opcD5Group, data: [slotBank | (direction == .reverse ? 0b00001000 : 0), slotNumber, UInt8(throttleID & 0x7f), speed])
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
    
    return SGLocoNetMessage(.opcLocoDirF, data: [slotNumber, dirf])

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

    return SGLocoNetMessage(.opcLocoSnd, data: [slotNumber, fnx])

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

    return SGLocoNetMessage(.opcD5Group, data: [slotBank | 0b00010000, slotNumber, UInt8(throttleID & 0x7f), fnx])

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
    
    return SGLocoNetMessage(.opcD5Group, data: [slotBank | 0b00011000, slotNumber, UInt8(throttleID & 0x7f), fnx])

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

    return SGLocoNetMessage(.opcD5Group, data: [slotBank | 0b00100000, slotNumber, UInt8(throttleID & 0x7f), fnx])

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

    return SGLocoNetMessage(.opcD5Group, data: [slotBank | UInt8(functions.get(index: 28) ? 0b00110000 : 0b00101000), slotNumber, UInt8(throttleID & 0x7f), fnx])

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
  
  // MARK: Switch Commands

  func setSw(switchNumber: UInt16, state:SGLocoNetSwitchState) -> SGLocoNetMessage? {
    
    guard SGLocoNetMessage.locoNetSwitchAddressRange ~= switchNumber else {
      return nil
    }
    
    let sn = switchNumber - 1
    
    return SGLocoNetMessage(.opcSwReq, data: [UInt8(sn & 0x7f), UInt8(sn >> 7) | state.setMask])
    
  }
  
  func setSwWithAck(switchNumber: UInt16, state:SGLocoNetSwitchState) -> SGLocoNetMessage? {
    
    guard SGLocoNetMessage.locoNetSwitchAddressRange ~= switchNumber else {
      return nil
    }
    
    let sn = switchNumber - 1

    return SGLocoNetMessage(.opcSwAck, data: [UInt8(sn & 0x7f), UInt8(sn >> 7) | state.setMask])

  }

  func getSwState(switchNumber: UInt16) -> SGLocoNetMessage? {
    
    guard SGLocoNetMessage.locoNetSwitchAddressRange ~= switchNumber else {
      return nil
    }
    
    let sn = switchNumber - 1

    return SGLocoNetMessage(.opcSwState, data: [UInt8(sn & 0x7f), UInt8(sn >> 7)])

  }
  
  // MARK: Acks
  
  func ack(opCode:SGLocoNetOpcode, status:UInt8) -> SGLocoNetMessage? {
    return SGLocoNetMessage(.opcLongAck, data: [opCode.rawValue & 0x7f, status])
  }
  
  func setSwAccepted() -> SGLocoNetMessage? {
    return ack(opCode: .opcSwReq, status: 0x7f)
  }

  func setSwRejected() -> SGLocoNetMessage? {
    return ack(opCode: .opcSwReq, status: 0x00)
  }

  func setSwWithAckAccepted() -> SGLocoNetMessage? {
    return ack(opCode: .opcSwAck, status: 0x7f)
  }

  func setSwWithAckRejected() -> SGLocoNetMessage? {
    return ack(opCode: .opcSwAck, status: 0x00)
  }

  // MARK: IPL

  func iplDiscover(productCode:SGDigitraxProductCode = .allProducts) -> SGLocoNetMessage? {
    return SGLocoNetMessage(.opcPeerXfer, data: [0x14, 0x0f, 0x08, 0x00, productCode.rawValue, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
  }
  
  func getInterfaceData() -> SGLocoNetMessage? {
    return SGLocoNetMessage(.opcBusy)
  }
  
  // MARK: Tetherless Commands
  
  func findReceiver() -> SGLocoNetMessage? {
    return SGLocoNetMessage(.opcDFGroup, data: [0x00, 0x00, 0x00, 0x00])
  }

  func setLocoNetID(locoNetID: UInt8) -> SGLocoNetMessage? {
    guard SGLocoNetMessage.locoNetIDRange ~= locoNetID else {
      return nil
    }
    return SGLocoNetMessage(.opcDFGroup, data: [0x40, 0x1f, locoNetID, 0x00])
  }
  
  func getDuplexData() -> SGLocoNetMessage? {
    return SGLocoNetMessage(.opcPeerXfer, data: [0x14, 0x03, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
  }
  
  func setDuplexGroupData(groupName: String, duplexGroupChannel: UInt8 = 0, duplexGroupID: UInt8 = 0) -> SGLocoNetMessage? {
    
    var name = groupName.prefix(8).data(using: .utf8)!
    name.append(contentsOf: [UInt8](repeating: 0x20, count: 8 - name.count))
    
    var data : [UInt8] = [0x14, 0x03, 0x00, 0x00, name[0], name[1], name[2], name[3], 0, name[4], name[5], name[6], name[7], 0, 0x00, 0x00, duplexGroupChannel, duplexGroupID]
    
    if let encoded = SGLocoNetMessage.encodePeerXfer(data: data, numberOfGroups: 3, startOfFirstGroup: 3) {
      return SGLocoNetMessage(.opcPeerXfer, data: encoded)
    }
    
    return nil
    
  }
  
  func getDuplexSignalStrength(duplexGroupChannel: Int) -> SGLocoNetMessage? {
    return SGLocoNetMessage(.opcPeerXfer, data: [0x14, 0x10, 0x08, 0x00, UInt8(duplexGroupChannel & 0x7f), 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
  }
  

  
  func setDuplexChannelNumber(channelNumber: Int) -> SGLocoNetMessage? {
    
    let cn = UInt8(channelNumber)
    
    let pxct1 : UInt8 = (cn & 0b10000000) == 0b10000000 ? 0b00000001 : 0
    
    return SGLocoNetMessage(.opcPeerXfer, data: [0x14, 0x02, 0x00, pxct1, cn, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
    
  }
  
  func setDuplexGroupID(groupID: Int) -> SGLocoNetMessage? {
    
    let gid = UInt8(groupID)
    
    let pxct1 : UInt8 = (gid & 0b10000000) == 0b10000000 ? 0b00000001 : 0
    
    return SGLocoNetMessage(.opcPeerXfer, data: [0x14, 0x04, 0x00, pxct1, gid, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
    
  }
  
  func getDuplexGroupID() -> SGLocoNetMessage? {
    return SGLocoNetMessage(.opcPeerXfer, data: [0x14, 0x04, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
  }
  
  func setDuplexSignalStrength(duplexGroupChannel: Int, signalStrength:Int) -> SGLocoNetMessage? {
    
    var pxct1 : UInt8 = 0
    pxct1 |= ((duplexGroupChannel & 0b10000000) == 0b10000000) ? 0b00000001 : 0
    pxct1 |= ((signalStrength     & 0b10000000) == 0b10000000) ? 0b00000010 : 0

    return SGLocoNetMessage(.opcPeerXfer, data: [0x14, 0x10, 0x10, pxct1, UInt8(duplexGroupChannel & 0x7f), UInt8(signalStrength & 0x7f), 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
    
  }
  
  func setDuplexPassword(password: String) -> SGLocoNetMessage? {
    
    let data = String((password + "0000").prefix(4)).data(using: .ascii)!
    
    var pxct1 : UInt8 = 0
    
    pxct1 |= (data[0] & 0b10000000) == 0b10000000 ? 0b00000001 : 0
    pxct1 |= (data[1] & 0b10000000) == 0b10000000 ? 0b00000010 : 0
    pxct1 |= (data[2] & 0b10000000) == 0b10000000 ? 0b00000100 : 0
    pxct1 |= (data[3] & 0b10000000) == 0b10000000 ? 0b00001000 : 0

    return SGLocoNetMessage(.opcPeerXfer, data: [0x14, 0x07, 0x00, pxct1, data[0] & 0x7f, data[1] & 0x7f, data[2] & 0x7f, data[3] & 0x7f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
    
  }

}

