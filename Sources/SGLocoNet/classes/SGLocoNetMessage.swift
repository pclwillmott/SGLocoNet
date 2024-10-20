// -----------------------------------------------------------------------------
// SGLocoNetMessage.swift
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
//     19/09/2024  Paul Willmott - SGLocoNetMessage.swift created
// -----------------------------------------------------------------------------

import Foundation
import SGDCC

public class SGLocoNetMessage : NSObject {
  
  // MARK: Constructors
  
  public init(data:[UInt8]) {
    message = data
    super.init()
  }

  public init?(dataWithCheckSum data:[UInt8]) {
    guard SGLocoNetMessage.isCheckSumOK(message: data) else {
      return nil
    }
    message = data
    message.removeLast()
    super.init()
  }

  public init(message: SGLocoNetMessage) {
    self.message = message.message
    super.init()
  }
  
  deinit {
    message.removeAll()
  }
  
  // MARK: Private Properties
  
  private var _messageType : SGLocoNetMessageType?
  
  private var _functions : SGFunctionGroup?
  
  // MARK: Public Properties
  
  public var message : [UInt8]
  
  public var messageWithChecksum : [UInt8] {
    var data = message
    data.append(SGLocoNetMessage.checkSum(data: data))
    return data
  }
  
  public var opCode : SGLocoNetOpcode {
    return SGLocoNetOpcode(rawValue: message[0]) ?? .opcUnknown
  }
  
  public var messageLength : UInt8 {
      
    var length : UInt8
    
    switch (message[0] & 0b01100000) >> 5 {
    case 0b00 :
      length = 2
    case 0b01 :
      length = 4
    case 0b10 :
      length = 6
    default :
      length = message[1] == 0 ? 128 : message[1]
    }
    
    return length

  }
  
  public var timeStamp : TimeInterval = 0.0
  
  public var timeSinceLastMessage : TimeInterval = 0.0
  
  public var slotData : [UInt8] {
    var slotData : [UInt8] = []
    if messageType == .locoSlotDataP1 || messageType == .locoSlotDataP2 {
      for index in 2 ..< Int(messageLength) - 3 {
        slotData.append(message[index])
      }
    }
    return slotData
  }
  
  public var hex : String {
    var str : String = ""
    for byte in message {
      if !str.isEmpty {
        str += " "
      }
      str += String(format: "%02X ",byte)
    }
    return str
  }
  
  public var immPacketRepeatCount : SGLocoNetIMMPacketRepeat? {
  
    guard messageType == .immPacket else {
      return nil
    }
    
    return SGLocoNetIMMPacketRepeat(rawValue: message[3] & 0b00001111)
    
  }
  
  public var dccPacket : SGDCCPacket? {
    
    guard messageType == .immPacket else {
      return nil
    }
    
    var packet : [UInt8] = []
    
    var mask : UInt8 = 1
    
    let count = Int((message[3] & 0b01110000) >> 4)
    
    for i in 0 ..< count {
      var im : UInt8 = message[5 + i]
      im |= ((message[4] & mask) != 0) ? 0x80 : 0x00
      packet.append(im)
      mask <<= 1
    }
    
    var crc : UInt8 = 0
    
    for im in packet {
      crc ^= im
    }
    
    packet.append(crc)
    
    return SGDCCPacket(packet: packet)
    
  }
  
  public var isP2Implemented : Bool? {
  
    get {
      switch opCode {
      case .opcSlRdDdata, .opcWrSlData:
        let mask : UInt8 = 0b01000000
        return (message[7] & mask) != 0
      default:
        return nil
      }
    }
    
    set(value) {
      switch opCode {
      case .opcSlRdDdata, .opcWrSlData:
        let mask : UInt8 = 0b01000000
        message[7] &= ~mask
        message[7] |= value! ? mask : 0
      default:
        break
      }
    }
    
  }

  public var isP1Implemented : Bool? {
  
    get {
      switch opCode {
      case .opcSlRdDdata, .opcWrSlData:
        let mask : UInt8 = 0b00000100
        return (message[7] & mask) != 0
      default:
        return nil
      }
    }
    
    set(value) {
      switch opCode {
      case .opcSlRdDdata, .opcWrSlData:
        let mask : UInt8 = 0b00000100
        message[7] &= ~mask
        message[7] |= value! ? mask : 0
      default:
        break
      }
    }
    
  }

  public var isProgrammingTrackBusy : Bool? {
  
    get {
      switch opCode {
      case .opcSlRdDdata, .opcWrSlData:
        let mask : UInt8 = 0b00001000
        return (message[7] & mask) != 0
      default:
        return nil
      }
    }
    
    set(value) {
      switch opCode {
      case .opcSlRdDdata, .opcWrSlData:
        let mask : UInt8 = 0b00001000
        message[7] &= ~mask
        message[7] |= value! ? mask : 0
      default:
        break
      }
    }
    
  }

  public var isTrackPaused : Bool? {
  
    get {
      switch opCode {
      case .opcSlRdDdata, .opcWrSlData:
        let mask : UInt8 = 0b00000010
        return (message[7] & mask) != 0
      default:
        return nil
      }
    }
    
    set(value) {
      switch opCode {
      case .opcSlRdDdata, .opcWrSlData:
        let mask : UInt8 = 0b00000010
        message[7] &= ~mask
        message[7] |= value! ? mask : 0
      default:
        break
      }
    }
    
  }

  public var isPowerUp : Bool? {
  
    get {
      switch opCode {
      case .opcSlRdDdata, .opcWrSlData:
        let mask : UInt8 = 0b00000001
        return (message[7] & mask) != 0
      default:
        return nil
      }
    }
    
    set(value) {
      switch opCode {
      case .opcSlRdDdata, .opcWrSlData:
        let mask : UInt8 = 0b00000001
        message[7] &= ~mask
        message[7] |= value! ? mask : 0
      default:
        break
      }
    }
    
  }
  
  public var digitraxCommandStationType : SGDigitraxCommandStationType? {
    
    get {
      switch messageType {
      case .opSwDataAP1:
        if let cs = SGDigitraxCommandStationType(rawValue: message[11]) {
          return cs
        }
        else if let isP1Implemented, !isP1Implemented {
          return .dt200
        }
      default:
        break
      }
      return nil
    }
    
    set(value) {
      guard let value else {
        return
      }
      switch messageType {
      case .opSwDataAP1:
        switch value {
        case .dt200:
          message[11] = 0
          isP1Implemented = false
        default:
          message[11] = value.rawValue
        }
      default:
        break
      }
    }
    
  }
  
  /*
  public var cvValue : UInt8? {
    
    switch messageType {
      
    case .progSlotDataP1:

      var result = message[10]
      let mask : UInt8 = 0b00000010
      result |= (message[8] & mask) == mask ? 0b10000000 : 0
      return result

    case .immPacket, .s7CVRW:
      
      guard let packet = dccPacket, let partition = dccAddressPartition, partition == .dccBAD11 else {
        return nil
      }
      
      if (packet[1] & 0b10000000) == 0b10000000 && (packet[2] & 0b11110000) == 0b11100000 {
        return packet[4]
      }
      
    case .s7CVState:
      
      var result = message[2]
      result |= (message[1] & 0b00000011) == 0b00000001 ? 0x80 : 0x00
      return result
      
    default:
      break
    }

    return nil

  }
  
  public var cvNumber : UInt16? {

    switch messageType {
      
    case .progSlotDataP1:
      
      var result = UInt16(message[9])

      let maskCVBit9 : UInt8 = 0b00100000
      let maskCVBit8 : UInt8 = 0b00010000
      let maskCVBit7 : UInt8 = 0b00000001

      result |= (message[8] & maskCVBit9) == maskCVBit9 ? 0b01000000000 : 0
      result |= (message[8] & maskCVBit8) == maskCVBit8 ? 0b00100000000 : 0
      result |= (message[8] & maskCVBit7) == maskCVBit7 ? 0b00010000000 : 0

      return result

    case .immPacket, .s7CVRW:
      
      guard let packet = dccPacket, let partition = dccAddressPartition, partition == .dccBAD11 else {
        return nil
      }
      
      if (packet[1] & 0b10000000) == 0b10000000 && (packet[2] & 0b11110000) == 0b11100000 {
        var cvNumber : UInt16 = UInt16(packet[3])
        cvNumber |= UInt16(packet[2] & 0b00000011) << 8
        return cvNumber + 1
      }
      
    default:
      break
    }
    
    return nil
    
  }

  public var dccCVAccessMode : DCCCVAccessMode? {
    
    guard let packet = dccPacket, let partition = dccAddressPartition, partition == .dccBAD11 else {
      return nil
    }
    
    if (packet[1] & 0b10000000) == 0b10000000 && (packet[2] & 0b11110000) == 0b11100000 {
      
      return DCCCVAccessMode(rawValue: packet[2] & 0b00001100)
      
    }
    
    return nil
  }
  
  public var dccBasicAccessoryDecoderAddress : UInt16? {
    
    guard let packet = dccPacket, let partition = dccAddressPartition, partition == .dccBAD11 else {
      return nil
    }
    
    if (packet[1] & 0b10000000) == 0b10000000 {
      
      var address : UInt16 = (UInt16(packet[0]) & 0b00111111) << 2
      
      address |= (~UInt16(packet[1]) & 0b01110000) << 4
      
      address |= (UInt16(packet[1]) & 0b00000110) >> 1
      
      return address + 1
      
    }
    
    return nil
    
  }
  
  public var swState : DCCSwitchState? {
    switch messageType {
    case .swState:
      return (message[2] & 0b00110000) == 0b00110000 ? .closed : .thrown
    case .brdOpSwState:
      return (message[2] & 0b00110000) == 0b00110000 ? .closed : .thrown
    default:
      return nil
    }
  }
  
  public var dccAddressPartition : DCCAddressPartition? {
    
    guard let packet = dccPacket else {
      return nil
    }
    
    switch packet[0] {
    case 0:
      return .dccBroadcast
    case 1...127:
      return .dccMFDPA
    case 128...191:
      return .dccBAD11
    case 192...231:
      return .dccMFDEA
    case 232...252:
      return .dccReserved
    case 253...254:
      return .dccAEPF
    case 255:
      return .dccIdle
    default:
      return nil
    }
    
  }
  */
    
  public var boardId : Int? {
    switch messageType {
    case .pmRepBXP88:
      var bid = message[2]
      bid |= (message[1] & 0b00000001) == 0b00000001 ? 0b10000000 : 0
      return Int(bid) + 1
    case .iplDevData:
      var bid = message[15]
      bid |= (message[14] & 0b00000001) == 0b00000001 ? 0b10000000 : 0
      return Int(bid) + 1
    case .querySlot1, .querySlot2, .querySlot3, .querySlot4, .querySlot5:
      if productCode == .bxp88 {
        return Int(message[17]) + 1
      }
    default:
      break
    }
    return nil
  }
  
  public var baseAddress : UInt16? {
    switch messageType {
    case .s7Info, .setS7BaseAddr:
      return (UInt16(message[13]) | (UInt16(message[14]) << 7)) + 1
    default:
      return nil
    }
  }

  public var transponderZone : Int? {
    switch messageType {
    case .locoRep:
      return Int(message[6]) | (Int(message[5]) << 7)
    case .transRep:
      return Int(message[2]) | (Int(message[1] & 0b00001111) << 7)
    default:
      return nil
    }
  }
  
  public var locomotiveAddress : UInt16? {
    switch messageType {
    case .locoRep:
      let highBits = message[3] == 0x7d ? 0 : UInt16(message[3]) << 7
      return UInt16(message[4]) | highBits
    case .locoSlotDataP1:
      var address = UInt16(message[4])
      if message[9] != 0x7f {
        address |= UInt16(message[9]) << 7
      }
      return address
    case .transRep:
      return UInt16(message[4]) | (UInt16(message[3]) << 7)
    case .locoSlotDataP2:
      return UInt16(message[5]) | (UInt16(message[6]) << 7)
    case .getLocoSlotDataAdrP1, .getLocoSlotDataAdrP2:
      return UInt16(message[2]) | (UInt16(message[1]) << 7)
    default:
      return nil
    }
  }

  public var productCode : SGDigitraxProductCode? {
    var pc : UInt8?
    switch messageType {
    case .iplDevData:
      pc = message[5] | (message[4] & 0b00000001 != 0 ? 0b10000000 : 0b00000000)
    case .querySlot1:
      pc = message[14]
    case .querySlot2, .querySlot3, .querySlot4, .querySlot5:
      pc = message[16]
    case .s7Info, .setS7BaseAddr:
      pc = message[9]
    default:
      break
    }
    if let pc {
      return SGDigitraxProductCode(rawValue: pc)
    }
    return nil
  }
  
  public var querySlotNumber : UInt8? {
    switch messageType {
    case .getQuerySlot:
      return (message[1] & 0x07) + 1
    default:
      return nil
    }
  }

  public var serialNumber : UInt16? {
    switch messageType {
    case .iplDevData:
      let sn1 = message[11] | ((message[9] & 0b00000010) != 0 ? 0b10000000 : 0b00000000)
      let sn2 = message[12] | ((message[9] & 0b00000100) != 0 ? 0b10000000 : 0b00000000)
      return UInt16(sn1) | (UInt16(sn2) << 8)
    case .querySlot1, .querySlot2, .querySlot3, .querySlot4, .querySlot5:
      return UInt16(message[19] & 0b00111111) << 7 | UInt16(message[18])
    case .s7Info, .setS7BaseAddr:
      return UInt16(message[11]) | (UInt16(message[12]) << 7)
    default:
      return nil
    }
  }

  public var partialSerialNumberLow : UInt16? {
    guard let serialNumber else {
      return nil
    }
    return serialNumber & 0x7f
  }
  
  public var partialSerialNumberHigh : UInt16? {
    guard let serialNumber else {
      return nil
    }
    return (serialNumber >> 8) & 0x7f
  }
  
  public var softwareVersion : Double? {
    switch messageType {
    case .iplDevData:
      let sv = message[8] | (message[4] & 0b00001000 != 0 ? 0b10000000 : 0b00000000)
      return Double((sv & 0b11111000) >> 3) + Double (sv & 0b111) / 10.0
    case .querySlot1:
      return Double(message[16] & 0x78) / 8.0 + Double(message[16] & 0x07) / 10.0
    default:
      break
    }
    return nil
  }
  
  public var hardwareVersion : Double? {
    switch messageType {
    case .querySlot1:
      let supportedProducts : Set<SGDigitraxProductCode> = [
        .dcs210,
        .dcs240,
        .dcs210Plus,
        .dcs240Plus,
        .pr4
      ]
      if supportedProducts.contains(productCode!){
        return Double(message[17] & 0x78) / 8.0 + Double(message[17] & 0x07) / 10.0
      }
    default:
      break
    }
    return nil
  }

  public var detectionSectionShorted : [Bool]? {
    switch messageType {
    case .pmRepBXP88:
      if (message[3] & 0b01100000) == 0x20 {
        var shorted = [Bool](repeating: false, count: 8)
        var mask : UInt8 = 0b00000001
        for index in 0...3 {
          shorted[index + 4] = (message[3] & mask) == mask
          shorted[index + 0] = (message[4] & mask) == mask
          mask <<= 1
        }
        return shorted
      }
    default:
      break
    }
    return nil
  }
  
  public var transponderAddress : Int {
    var addr = Int(message[2])
    addr |= (Int(message[1] & 0b00001111) << 7)
    return addr + 1
  }
  
  public var sensorAddress : Int? {
    switch messageType {
    case .sensRepGenIn:
      var addr = Int(message[1]) << 1
      addr |= (Int(message[2] & 0b00001111) << 8)
      addr |= (Int(message[2] & 0b00100000) >> 5)
      return addr + 1
    case .sensRepTurnIn:
      var addr = Int(message[1])
      addr |= (Int(message[2] & 0b00001111) << 7)
      return addr + 1
    default:
      break
    }
    return nil
  }
  
  public var switchAddress : Int? {
    switch messageType {
    case .setSw, .setSwWithAck:
      return Int(message[1]) | (Int(message[2] & 0x0f) << 7) + 1
    default:
      break
    }
    return nil
  }
  
  public var sensorState : Bool? {
    switch messageType {
    case .sensRepGenIn, .sensRepTurnIn:
      let mask : UInt8 = 0b00010000
      return (message[2] & mask) == mask
    case .transRep:
      let mask : UInt8 = 0b00100000
      return (message[1] & mask) == mask
    default:
      break
    }
    return nil
  }
  
  public var isSlotUpdate : Bool {
    
    guard slotNumber != nil else {
      return false
    }
    
    let notSlotUpdate : Set<SGLocoNetMessageType> = [
      .locoSlotDataP1,
      .locoSlotDataP2,
      .getLocoSlotData
    ]
    
    return !notSlotUpdate.contains(messageType)
    
  }
  
  public var sourceSlotBank : UInt8? {
    let bankMask : UInt8 = 0b00000011
    switch messageType {
    case .moveSlotP2:
      return message[1] & bankMask
    default:
      return nil
    }
  }

  public var destinationSlotBank : UInt8? {
    let bankMask : UInt8 = 0b00000011
    switch messageType {
    case .moveSlotP2:
      return message[3] & bankMask
    default:
      return nil
    }
  }

  public var sourceSlotNumber : UInt8? {
    switch messageType {
    case .moveSlotP1:
      return message[1]
    case .moveSlotP2:
      return message[2]
    default:
      return nil
    }
  }

  public var destinationSlotNumber : UInt8? {
    switch messageType {
    case .moveSlotP1:
      return message[2]
    case .moveSlotP2:
      return message[4]
    default:
      return nil
    }
  }

  public var slotBank : UInt8? {
    let bankMask : UInt8 = 0b00000011
    switch messageType {
    case .locoSlotDataP2:
      return message[2] & bankMask
    case .setLocoSlotInUseP2:
      return message[3] & bankMask
    case .setLocoSlotDataP2:
      return message[2] & bankMask
    case .getLocoSlotData:
      return message[2] & bankMask
    case .locoSpdDirP2:
      return message[1] & bankMask
    case .locoF0F6P2:
      return message[1] & bankMask
    case .locoF7F13P2:
      return message[1] & bankMask
    case .locoF14F20P2:
      return message[1] & bankMask
    case .locoF21F28P2:
      return message[1] & bankMask
    case .setLocoSlotStat1P2:
      return message[1] & bankMask
    case .linkSlotsP2:
      return message[1] & bankMask
    case .unlinkSlotsP2:
      return message[1] & bankMask
    default:
      return nil
    }
  }

  public var slotNumber : UInt8? {
    switch messageType {
    case .locoSlotDataP1:
      return message[2]
    case .setLocoSlotInUseP1:
      return message[2]
    case .setLocoSlotDataP1:
      return message[2]
    case .locoSlotDataP2:
      return message[3]
    case .setLocoSlotInUseP2:
      return message[4]
    case .setLocoSlotDataP2:
      return message[3]
    case .getLocoSlotData:
      return message[1]
    case .locoSpdP1:
      return message[1]
    case .locoSpdDirP2:
      return message[2]
    case .locoDirF0F4P1:
      return message[1]
    case .locoF5F8P1:
      return message[1]
    case .locoF9F12P1:
      return message[1]
    case .locoF0F6P2:
      return message[2]
    case .locoF7F13P2:
      return message[2]
    case .locoF14F20P2:
      return message[2]
    case .locoF21F28P2:
      return message[2]
    case .setLocoSlotStat1P1:
      return message[1]
    case .setLocoSlotStat1P2:
      return message[2]
    case .linkSlotsP1:
      return message[1]
    case .unlinkSlotsP1:
      return message[1]
    case .linkSlotsP2:
      return message[2]
    case .unlinkSlotsP2:
      return message[2]
    case .consistDirF0F4:
      return message[1]
    default:
      return nil
    }
  }

  public var trackVoltage : Double? {
    switch messageType {
    case .querySlot2:
      return Double(message[4]) * 2.0 / 10.0
    default:
      break
    }
    return nil
  }
  
  public var inputVoltage : Double? {
    switch messageType {
    case .querySlot2:
      return Double(message[5]) * 2.0 / 10.0
    default:
      break
    }
    return nil
  }
  
  public var currentDrawn : Double? {
    switch messageType {
    case .querySlot2:
      return Double(message[6]) / 10.0
    default:
      break
    }
    return nil
  }
  
  public var currentLimit : Double? {
    switch messageType {
    case .querySlot2:
      return Double(message[7]) / 10.0
    default:
      break
    }
    return nil
  }
  
  public var railSyncVoltage : Double? {
    switch messageType {
    case .querySlot2:
      return Double(message[10]) * 2.0 / 10.0
    default:
      break
    }
    return nil
  }
  
  public var locoNetVoltage : Double? {
    switch messageType {
    case .querySlot2:
      return Double(message[12]) * 2.0 / 10.0
    default:
      break
    }
    return nil
  }
  
  public var slotsUsed : Int? {
    switch messageType {
    case .querySlot3:
      return Int(message[4]) | (Int(message[5] & 0b00111111) << 7)
    default:
      break
    }
    return nil
  }

  public var idleSlots : Int? {
    switch messageType {
    case .querySlot3:
      return Int(message[6]) | (Int(message[7] & 0b00111111) << 7)
    default:
      break
    }
    return nil
  }

  public var freeSlots : Int? {
    switch messageType {
    case .querySlot3:
      return Int(message[8]) | (Int(message[9] & 0b00111111) << 7)
    default:
      break
    }
    return nil
  }

  public var consists : Int? {
    switch messageType {
    case .querySlot3:
      return Int(message[10]) | (Int(message[11] & 0b00111111) << 7)
    default:
      break
    }
    return nil
  }

  public var subMembers : Int? {
    switch messageType {
    case .querySlot3:
      return Int(message[12]) | (Int(message[13] & 0b00111111) << 7)
    default:
      break
    }
    return nil
  }

  public var goodLocoNetMessages : Int? {
    switch messageType {
    case .querySlot4:
      return Int(message[4]) | Int(message[5] & 0b00111111) << 7
    default:
      break
    }
    return nil
  }

  public var badLocoNetMessages : Int? {
    switch messageType {
    case .querySlot4:
      return Int(message[6]) | Int(message[7] & 0b00111111) << 7
    default:
      break
    }
    return nil
  }

  // THIS IS A GUESS
  public var numberOfSleeps : Int? {
    switch messageType {
    case .querySlot4:
      return Int(message[8]) | Int(message[9] & 0b00111111) << 7
    default:
      break
    }
    return nil
  }

  public var trackFaults : Int? {
    switch messageType {
    case .querySlot5:
      return Int(message[4]) | Int(message[5]) << 7
    default:
      break
    }
    return nil
  }

  // THIS IS A GUESS
  public var autoReverseEvents : Int? {
    switch messageType {
    case .querySlot5:
      return Int(message[6]) | Int(message[7]) << 7
    default:
      break
    }
    return nil
  }

  // THIS IS A GUESS
  public var disturbances : Int? {
    switch messageType {
    case .querySlot5:
      return Int(message[8]) | Int(message[9]) << 7
    default:
      break
    }
    return nil
  }
  
  public var bit40 : Bool? {
    switch messageType {
    case .querySlot1:
      return message[4] & 0b00000001 == 0b00000001
    default:
      break
    }
    return nil
  }

  public var bit41 : Bool? {
    switch messageType {
    case .querySlot1:
      return message[4] & 0b00000010 == 0b00000010
    default:
      break
    }
    return nil
  }

  public var bit42 : Bool? {
    switch messageType {
    case .querySlot1:
      return message[4] & 0b00000100 == 0b00000100
    default:
      break
    }
    return nil
  }

  public var bit43 : Bool? {
    switch messageType {
    case .querySlot1:
      return message[4] & 0b00001000 == 0b00001000
    default:
      break
    }
    return nil
  }

  public var bit44 : Bool? {
    switch messageType {
    case .querySlot1:
      return message[4] & 0b00010000 == 0b00010000
    default:
      break
    }
    return nil
  }

  public var bit45 : Bool? {
    switch messageType {
    case .querySlot1:
      return message[4] & 0b00100000 == 0b00100000
    default:
      break
    }
    return nil
  }

  public var bit46 : Bool? {
    switch messageType {
    case .querySlot1:
      return message[4] & 0b01000000 == 0b01000000
    default:
      break
    }
    return nil
  }

  public var bit50 : Bool? {
    switch messageType {
    case .querySlot1:
      return message[5] & 0b00000001 == 0b00000001
    default:
      break
    }
    return nil
  }

  public var bit51 : Bool? {
    switch messageType {
    case .querySlot1:
      return message[5] & 0b00000010 == 0b00000010
    default:
      break
    }
    return nil
  }

  public var bit52 : Bool? {
    switch messageType {
    case .querySlot1:
      return message[5] & 0b00000100 == 0b00000100
    default:
      break
    }
    return nil
  }

  public var bit53 : Bool? {
    switch messageType {
    case .querySlot1:
      return message[5] & 0b00001000 == 0b00001000
    default:
      break
    }
    return nil
  }

  public var bit54 : Bool? {
    switch messageType {
    case .querySlot1:
      return message[5] & 0b00010000 == 0b00010000
    default:
      break
    }
    return nil
  }

  public var bit55 : Bool? {
    switch messageType {
    case .querySlot1:
      return message[5] & 0b00100000 == 0b00100000
    default:
      break
    }
    return nil
  }

  public var bit56 : Bool? {
    switch messageType {
    case .querySlot1:
      return message[5] & 0b01000000 == 0b01000000
    default:
      break
    }
    return nil
  }
  
  public var slotStatus1 : UInt8? {
    switch messageType {
    case .locoSlotDataP1:
      return message[3]
    case .locoSlotDataP2, .setLocoSlotStat1P2:
      return message[4]
    case .setLocoSlotStat1P1:
      return message[2]
    default:
      break
    }
    return nil
  }
  
  public var slotState : SGLocoNetSlotState? {
    guard let slotStatus1 else {
      return nil
    }
    return SGLocoNetSlotState(rawValue: slotStatus1 & ~SGLocoNetSlotState.protectMask)
  }
  
  public var consistState : SGLocoNetSlotConsistState? {
    guard let slotStatus1 else {
      return nil
    }
    return SGLocoNetSlotConsistState(rawValue: slotStatus1 & ~SGLocoNetSlotConsistState.protectMask)
  }
  
  public var decoderProtocol : SGLocoNetDecoderProtocol? {
    guard let slotStatus1 else {
      return nil
    }
    return SGLocoNetDecoderProtocol(rawValue: slotStatus1 & ~SGLocoNetDecoderProtocol.protectMask)
  }

  public var direction : SGLocoNetLocomotiveDirection?   {
    var byte : UInt8?
    switch messageType {
    case .locoSlotDataP1:
      byte = message[6]
    case .locoSlotDataP2:
      byte = message[10]
    case .locoDirF0F4P1:
      byte = message[2]
    case .locoSpdDirP2:
      return (message[1] & 0b00001000) != 0 ? .reverse : .forward
    default:
      break
    }
    if let byte  {
      return SGLocoNetLocomotiveDirection(rawValue: byte & ~SGLocoNetLocomotiveDirection.protectMask)
    }
    return nil
  }
  
  public var speed : UInt8? {
    switch messageType {
    case .locoSlotDataP1:
      return message[5]
    case .locoSlotDataP2:
      return message[8]
    case .locoSpdP1:
      return message[2]
    case .locoSpdDirP2:
      return message[4]
    default:
      return nil
    }
  }

  public var throttleID : UInt16? {
    switch messageType {
    case .locoSlotDataP1:
      var id = UInt16(message[11])
      if message[9] == 0x7f && (message[8] & 0b100) == 0b100 {
        id |= UInt16(message[12]) << 7
      }
      else {
        id |= UInt16(message[12]) << 8
      }
      return id
    case .locoSlotDataP2:
      return UInt16(message[18]) | UInt16(message[19]) << 8
    case .iplDevData:
      return partialSerialNumberHigh! << 8 | partialSerialNumberLow!
    case .zapped:
      return UInt16(message[2])
    case .locoSpdDirP2, .locoF0F6P2, .locoF7F13P2, .locoF14F20P2, .locoF21F28P2:
      return UInt16(message[3])
    default:
      return nil
    }
  }

  public var functions : SGFunctionGroup? {
    
    if _functions == nil {
      
      _functions = SGFunctionGroup()
      
      var mask : UInt8 = 0
      
      func process(byte:Int, index:Int) {
        _functions?.set(index: index, value: (message[byte] & mask) != 0)
        mask <<= 1
      }
      
      switch messageType {
       
      case .locoDirF0F4P1:
        
        mask = 0b00010000
        process(byte: 2, index: 0)
        
        mask = 0b00000001
        for index in 1 ... 4 {
          process(byte: 2, index: index)
        }

      case .locoF5F8P1:
        
        mask = 0b00000001
        for index in 5 ... 8 {
          process(byte: 2, index: index)
        }

      case .locoF0F6P2:
        
        mask = 0b00000001
        for index in 1 ... 4 {
          process(byte: 4, index: index)
        }

        process(byte: 4, index: 0)

        for index in 5 ... 6 {
          process(byte: 4, index: index)
        }

      case .locoF7F13P2:
        
        mask = 0b00000001
        for index in 7 ... 13 {
          process(byte: 4, index: index)
        }

      case .locoF14F20P2:
        
        mask = 0b00000001
        for index in 14 ... 20 {
          process(byte: 4, index: index)
        }

      case .locoF21F28P2:
        
        mask = 0b00000001
        for index in 21 ... 27 {
          process(byte: 4, index: index)
        }
        
        mask = 0b00010000
        
        _functions?.set(index: 28, value: (message[1] & mask) == mask)

      case .locoSlotDataP1:
        
        mask = 0b00010000
        process(byte: 6, index: 0)
        
        mask = 0b00000001
        for index in 1 ... 4 {
          process(byte: 6, index: index)
        }
        
        mask = 0b00000001
        for index in 5 ... 8 {
          process(byte: 10, index: index)
        }
        
      case .locoSlotDataP2:
        
        mask = 0b00010000
        process(byte: 10, index: 0)
        
        mask = 0b00000001
        for index in 1 ... 4 {
          process(byte: 10, index: index)
        }
        
        mask = 0b00000001
        for index in 5 ... 11 {
          process(byte: 11, index: index)
        }
        
        mask = 0b00010000
        process(byte: 9, index: 12)
        
        mask = 0b00000001
        for index in 13 ... 19 {
          process(byte: 12, index: index)
        }
        
        mask = 0b00100000
        process(byte: 9, index: 20)
        
        mask = 0b00000001
        for index in 21 ... 27 {
          process(byte: 13, index: index)
        }
        
        mask = 0b01000000
        process(byte: 9, index: 28)
        
      default:
        return nil
      }
      
    }
    
    return _functions
    
  }
  
  public var groupName : String? {
    switch messageType {
    case .duplexGroupData:
      
      var data : [UInt8] = []
      
      data.append(message[5] | ((message[4] & 0b00000001) == 0b00000001 ? 0x80 : 0x00))
      data.append(message[6] | ((message[4] & 0b00000010) == 0b00000010 ? 0x80 : 0x00))
      data.append(message[7] | ((message[4] & 0b00000100) == 0b00000100 ? 0x80 : 0x00))
      data.append(message[8] | ((message[4] & 0b00001000) == 0b00001000 ? 0x80 : 0x00))

      data.append(message[10] | ((message[9] & 0b00000001) == 0b00000001 ? 0x80 : 0x00))
      data.append(message[11] | ((message[9] & 0b00000010) == 0b00000010 ? 0x80 : 0x00))
      data.append(message[12] | ((message[9] & 0b00000100) == 0b00000100 ? 0x80 : 0x00))
      data.append(message[13] | ((message[9] & 0b00001000) == 0b00001000 ? 0x80 : 0x00))

      return String(bytes: data, encoding: String.Encoding.utf8)!
      
    default:
      break
    }
    return nil
  }
  
  public var groupPassword : String? {
    switch messageType {
    case .duplexGroupData:
      
      let byte1 = Int(message[15] | ((message[14] & 0b00000001) == 0b00000001 ? 0x80 : 0x00))
      let byte2 = Int(message[16] | ((message[14] & 0b00000010) == 0b00000010 ? 0x80 : 0x00))

      let char1 = byte1 >> 4
      let char2 = byte1 & 0xf
      let char3 = byte2 >> 4
      let char4 = byte2 & 0xf

      return String(format: "%01X%01X%01X%01X", char1, char2, char3, char4)

    default:
      break
    }
    return nil
  }

  public var channelNumber : Int? {
    switch messageType {
    case .duplexGroupData:
      return Int(message[17])
    default:
      break
    }
    return nil
  }
  
  public var groupID : Int? {
    switch messageType {
    case .duplexGroupData:
      return Int(message[18])
    default:
      break
    }
    return nil
  }

  public var fastClockScaleFactor : UInt8? {
    guard messageType == .fastClockData || messageType == .setFastClockData else {
      return nil
    }
    return message[3]
  }
  
  public var messageType : SGLocoNetMessageType {
    
    if _messageType == nil {
      
      _messageType = .unknown
      
      switch opCode {
        
      case .opcBusy:
        _messageType = .busy

      case .opcGPOff:
        _messageType = .pwrOff

      case .opcGPOn:
        _messageType = .pwrOn

      case .opcIdle:
        _messageType = .setIdleState

      case .opcLocoReset:
        _messageType = .reset

      case .opcLocoSpd:
        if message[1] > 0 && message[1] < 0x78 {
          _messageType = .locoSpdP1
        }

      case .opcLocoDirF:
        if message[1] > 0 && message[1] < 0x78 && (message[2] & 0b01000000) == 0x00 {
          _messageType = .locoDirF0F4P1
        }

      case .opcLocoSnd:
        if message[1] > 0 && message[1] < 0x78 && (message[2] & 0b11110000) == 0x00 {
          _messageType = .locoF5F8P1
        }

      case .opcLocoSnd2:
        if message[1] > 0 && message[1] < 0x78 && (message[2] & 0b11110000) == 0x00 {
          _messageType = .locoF9F12P1
        }

      case .opcSwReq:
        if (message[1] & 0b01111000) == 0b01111000 && (message[2] & 0b11011111) == 0b00000111 {
          _messageType = .interrogate
        }
        else if (message[2] & 0b11000000) == 0b00000000 {
          _messageType = .setSw
        }

      case .opcSwRep:
        let test = message[2] & 0b11000000
        switch test {
        case 0b01000000:
          _messageType = .sensRepTurnIn
        case 0b00000000:
          _messageType = .sensRepTurnOut
        default:
          break
        }
        
      case .opcInputRep:
        if (message[2] & 0b11000000) == 0b01000000 {
          _messageType = .sensRepGenIn
        }

      case .opcLongAck:
        switch message[1] {
        case 0x30:
          switch message[2] {
          case 0x00:
            _messageType = .setSwRejected
          case 0x7f:
            _messageType = .setSwAccepted
          default:
            break
          }
        case 0x38:
          switch message[2] {
          case 0x00:
            _messageType = .invalidUnlinkP1
          default:
            break
          }
        case 0x39:
          switch message[2] {
          case 0x00:
            _messageType = .invalidLinkP1
          default:
            break
          }
        case 0x3a:
          switch message[2] {
          case 0x00:
            _messageType = .illegalMoveP1
          default:
            break
          }
        case 0x3b:
          switch message[2] {
          case 0x00:
            _messageType = .slotNotImplemented
          default:
            break
          }
        case 0x3c:
          _messageType = .swState
        case 0x3d:
          switch message[2] {
          case 0x00:
            _messageType = .setSwWithAckRejected
          case 0x7f:
            _messageType = .setSwWithAckAccepted
          default:
            break
          }
        case 0x3e:
          switch message[2] {
          case 0x00:
            _messageType = .noFreeSlotsP2
          default:
            break
          }
        case 0x3f:
          switch message[2] {
          case 0x00:
            _messageType = .noFreeSlotsP1
          default:
            break
          }
        case 0x50:
          if (message[2] & 0b01011111) == 0b00010000 {
            _messageType = .brdOpSwState
          }
          else if message[2] == 0x7f {
            _messageType = .setBrdOpSwOK
          }
        case 0x54:
          switch message[2] {
          case 0x00:
            _messageType = .d4Error
          default:
            break
          }
        case 0x55:
          _messageType = .zapped
        case 0x6d:
          switch message[2] {
            case 0x00:
            _messageType = .immPacketBufferFull
            case 0x7f:
            _messageType = .immPacketOK
          default:
            _messageType = .s7CVState
            break
          }
        case 0x6e:
          switch message[2] {
          case 0x00:
            _messageType = .routesDisabled
          case 0x7f:
            _messageType = .setSlotDataOKP2
          default:
            _messageType = .s7CVState
            break
          }
        case 0x6f:
          switch message[2] {
          case 0x00:
            _messageType = .programmerBusy
          case 0x01:
            _messageType = .progCmdAccepted
          case 0x40:
            _messageType = .progCmdAcceptedBlind
          case 0x7f:
            _messageType = .setSlotDataOKP1
          default:
            break
          }
        case 0x7e:
          _messageType = .immPacketLMOK
       default:
          break
        }

      case .opcSlotStat1:
        if message[1] > 0 && message[1] < 0x78 {
          _messageType = .setLocoSlotStat1P1
        }

      case .opcConsistFunc:
        if message[1] > 0 && message[1] < 0x78 && (message[2] & 0b11100000) == 0 {
          _messageType = .consistDirF0F4
        }

      case .opcUnlinkSlots:
        if message[1] > 0 && message[1] < 0x78 && message[2] > 0 && message[2] < 0x78 {
          _messageType = .unlinkSlotsP1
        }

      case .opcLinkSlots:
        if message[1] > 0 && message[1] < 0x78 && message[2] > 0 && message[2] < 0x78 {
          _messageType = .linkSlotsP1
        }

      case .opcMoveSlots:
        if message[1] == 0x00 {
          _messageType = .dispatchGetP1
        }
        else if message[2] == 0x00 && message[1] > 0 && message[1] < 0x78 {
          _messageType = .dispatchPutP1
        }
        else if message[1] == message[2] && message[1] > 0 && message[1] < 0x78 {
          _messageType = .setLocoSlotInUseP1
        }
        else if message[1] < 0x78 && message[2] < 0x78 {
          _messageType = .moveSlotP1
        }

      case .opcRqSlData:
        if message[2] == 0x00 {
          
          switch message[1] {
          case 0x78:
            break
          case 0x79:
            break
          case 0x7a:
            break
          case 0x7b:
            _messageType = .getFastClockData
          case 0x7c:
            _messageType = .getProgSlotData
          case 0x7d:
            break
          case 0x7e:
            _messageType = .getOpSwDataBP1
          case 0x7f:
            _messageType = .getOpSwDataAP1
          default:
            _messageType = .getLocoSlotData
          }
          
        }
        else if message[1] >= 0x78 && message[1] <= 0x7c && message[2] == 0x41 {
          _messageType = .getQuerySlot
        }
        else if message[1] == 0x7e && message[2] == 0x40 {
          _messageType = .getOpSwDataP2
        }
        else if message[1] == 0x7f && message[2] == 0x40 {
          _messageType = .getOpSwDataP2
        }
        else if message[1] < 0x78 && (message[2] & 0b10111000) == 0 {
          _messageType = .getLocoSlotData
        }

      case .opcSwState:
        if (message[2] & 0b01000000) == 0 {
          _messageType = .getSwState
        }

      case .opcSwAck:
        if (message[2] & 0b11000000) == 0 {
          _messageType = .setSwWithAck
        }

      case .opcLocoAdrP2:
        _messageType = .getLocoSlotDataAdrP2

      case .opcLocoAdr:
        _messageType = .getLocoSlotDataAdrP1

      case .opcD0Group:
        if (message[1] & 0b11111110) == 0b01100010 && (message[3] & 0b11110000) == 0b01110000 {
          _messageType = .getBrdOpSwState
        }
        else if (message[1] & 0b11111110) == 0b01110010 && (message[3] & 0b11110000) == 0b01110000 {
          _messageType = .setBrdOpSwState
        }
        else if message[1] == 0x60 && (message[4] & 0b11111110) == 0 {
          _messageType = .trkShortRep
        }
        else if message[1] & 0b11111110 == 0b01100010 && (message[3] & 0b11110000) == 0b00110000 && (message[4] & 0b11100000) == 0 {
          _messageType = .pmRep
        }
        else if message[1] & 0b01111110 == 0b01100010 && (message[3] & 0b10010000) == 0 && (message[4] & 0b10010000) == 0 {
          _messageType = .pmRepBXP88
        }
        else if (message[1] & 0b11010000) == 0 {
          _messageType = .transRep
        }

      case .opcPrMode:
        if message[1] == 0x10 && (message[2] & 0b11111100) == 0 && message[3] == 0x00 && message[4] == 0x00 {
          _messageType = .prMode
        }

      case .opcD4Group:
        if (message[1] & 0b11111000) == 0b00100000 {
          
          let subCode = message[3]

          switch subCode {
          case 0x05 :
            _messageType = .locoF12F20F28P2
          case 0x08:
            _messageType = .locoF13F19P2
          case 0x09:
            _messageType = .locoF21F27P2
          default:
            break
          }
        }
        else if (message[1] & 0b11111000) == 0b00111000 {
          
          let subCode = message[3] & 0b11111000
          
          let srcPage = message[1] & 0b00000111
          let src = message[2]
          let dstPage = message[3] & 0b00000111
          let dst = message[4]
          
          switch subCode {
          case 0b00000000:
            
            if message[2] == 0x00 && (message[3] & 0b11111000) == 0 {
              _messageType = .dispatchGetP2
            }
            else if message[3] == 0 && dst == 0 && src > 0 && src < 0x78 {
              _messageType = .dispatchPutP2
            }
            else if srcPage == dstPage && src == dst && src > 0 && src > 0 && src < 0x78 && (message[3] & 0b11111000) == 0 {
              _messageType = .setLocoSlotInUseP2
            }
            else if src > 0 && src < 0x78 && dst > 0 && dst < 0x78 && (message[3] & 0b11111000) == 0 {
              _messageType = .moveSlotP2
            }
            
          case 0b01000000:
            
            if src > 0 && src < 0x78 && dst > 0 && dst < 0x78 {
              _messageType = .linkSlotsP2
            }
            
          case 0b01100000:
            
            if src > 0 && src < 0x78 {
              _messageType = .setLocoSlotStat1P2
            }
            
          case 0b01010000:
            
            if src > 0 && src < 0x78 && dst > 0 && dst < 0x78 {
              _messageType = .unlinkSlotsP2
            }
            
          default:
            break
          }
          
        }

      case .opcD5Group:
        if message[2] > 0 && message[2] < 0x78 {
          
          let subCode = message[1] & 0b11111000
          
          switch subCode {
          case 0b00000000, 0b00001000:
            _messageType = .locoSpdDirP2
          case 0b00010000:
            _messageType = .locoF0F6P2
          case 0b00011000:
            _messageType = .locoF7F13P2
          case 0b00100000:
            _messageType = .locoF14F20P2
          case 0b00101000, 0b00110000:
            _messageType = .locoF21F28P2
          default:
            break
          }
          
        }


      case .opcD7Group:
        if message[2] == 0 && (message[3] & 0b11110000) == 0 && (message[4] == 0x20 || message[4] == 0x7f) {
          _messageType = .receiverRep
        }

      case .opcDFGroup:
        if message[1] == 0x00 && message[2] == 0x00 && message[3] == 0x00 && message[4] == 0x00 {
          _messageType = .findReceiver
        }
        else if message[1] == 0x40 && message[2] == 0x1f && (message[3] & 0b11111000) == 0 && message[4] == 0x00 {
          _messageType = .setLocoNetID
        }

      case .opcPeerXfer:
        switch message[1] {
          
        case 0x09:
          
          if message[2] == 0x01 &&
             message[3] == 0x00 {
            _messageType = .ezRouteConfirm
          }
          else if message[2] == 0x40 &&
             message[5] == 0x00 &&
             message[6] == 0x00 &&
             message[7] == 0x00 {
            _messageType = .findLoco
          }
          else if message[2] == 0x00 &&
            (message[5] & 0b11110000) == 0 &&
             message[7] == 0x00 {
            _messageType = .locoRep
          }

        case 0x10:
          
          if message[ 2] == 0x22 &&
             message[ 3] == 0x22 &&
             message[ 4] == 0x01 &&
             message[ 5] == 0x00 &&
             (message[8] & 0b11110000) == 0b00010000 &&
             message[10] == 0x00 {
            _messageType = .interfaceData
          }
          else if message[ 2] == 0x50 &&
             message[ 3] == 0x50 &&
             message[ 4] == 0x01 &&
            (message[ 5] & 0b11110000) == 0x00 &&
            (message[10] & 0b11110000) == 0x00 {
            _messageType = .interfaceDataLB
          }
          else if message[ 2] == 0x22 &&
             message[ 3] == 0x22 &&
             message[ 4] == 0x01 &&
             message[ 5] == 0x00 &&
             message[10] == 0x00 {
            _messageType = .interfaceDataPR3
          }
          else if message[2] == 0x7f &&
             message[3] == 0x7f &&
             message[4] == 0x7f &&
            (message[5] & 0b11110000) == 0b01000000 {
            
            let subCode = message[10] & 0b11110000
            
            switch subCode {
            case 0b00000000:
              if message[12] == 0x00 &&
                 message[14] == 0x00 {
                _messageType = .iplSetup
              }
              break
            case 0b00010000:
              if message[9 ] == 0x00 &&
                 message[11] == 0x00 &&
                 message[12] == 0x00 &&
                 message[13] == 0x00 &&
                 message[14] == 0x00 {
                _messageType = .iplSetAddr
              }
            case 0b00100000:
              _messageType = .iplDataLoad
            case 0b01000000:
              if message[6 ] == 0x00 &&
                 message[7 ] == 0x00 &&
                 message[8 ] == 0x00 &&
                 message[9 ] == 0x00 &&
                 message[11] == 0x00 &&
                 message[12] == 0x00 &&
                 message[13] == 0x00 &&
                 message[14] == 0x00 {
                _messageType = .iplEndLoad
              }
            default:
              break
            }
          }
          
        case 0x14:
          
          switch message[2] {
          case 0x02:
            switch message[3] {
            case 0x00:
              if message[4 ] == 0x00 &&
                 message[6 ] == 0x00 &&
                 message[7 ] == 0x00 &&
                 message[8 ] == 0x00 &&
                 message[9 ] == 0x00 &&
                 message[10] == 0x00 &&
                 message[11] == 0x00 &&
                 message[12] == 0x00 &&
                 message[13] == 0x00 &&
                 message[14] == 0x00 &&
                 message[15] == 0x00 &&
                 message[16] == 0x00 &&
                 message[17] == 0x00 &&
                 message[18] == 0x00 {
                _messageType = .setDuplexGroupChannel
              }
            case 0x08:
              if message[4 ] == 0x00 &&
                 message[5 ] == 0x00 &&
                 message[6 ] == 0x00 &&
                 message[7 ] == 0x00 &&
                 message[8 ] == 0x00 &&
                 message[9 ] == 0x00 &&
                 message[10] == 0x00 &&
                 message[11] == 0x00 &&
                 message[12] == 0x00 &&
                 message[13] == 0x00 &&
                 message[14] == 0x00 &&
                 message[15] == 0x00 &&
                 message[16] == 0x00 &&
                 message[17] == 0x00 &&
                 message[18] == 0x00 {
                _messageType = .getDuplexGroupChannel
              }
            case 0x10:
              if message[4 ] == 0x00 &&
                 message[6 ] == 0x00 &&
                 message[7 ] == 0x00 &&
                 message[8 ] == 0x00 &&
                 message[9 ] == 0x00 &&
                 message[10] == 0x00 &&
                 message[11] == 0x00 &&
                 message[12] == 0x00 &&
                 message[13] == 0x00 &&
                 message[14] == 0x00 &&
                 message[15] == 0x00 &&
                 message[16] == 0x00 &&
                 message[17] == 0x00 &&
                 message[18] == 0x00 {
                _messageType = .duplexGroupChannel
              }
            default:
              break
            }
          case 0x03:
            switch message[3] {
            case 0x00:
              if (message[4 ] & 0b11110000) == 0 &&
                 (message[9 ] & 0b11110000) == 0 &&
                 (message[14] & 0b11110000) == 0 {
                _messageType = .setDuplexGroupData
              }
            case 0x08:
              if message[4 ] == 0x00 &&
                 message[5 ] == 0x00 &&
                 message[6 ] == 0x00 &&
                 message[7 ] == 0x00 &&
                 message[8 ] == 0x00 &&
                 message[9 ] == 0x00 &&
                 message[10] == 0x00 &&
                 message[11] == 0x00 &&
                 message[12] == 0x00 &&
                 message[13] == 0x00 &&
                 message[14] == 0x00 &&
                 message[15] == 0x00 &&
                 message[16] == 0x00 &&
                 message[17] == 0x00 &&
                 message[18] == 0x00 {
                _messageType = .getDuplexGroupData
              }
            case 0x10:
                if (message[4 ] & 0b11110000) == 0 &&
                   (message[9 ] & 0b11110000) == 0 &&
                   (message[14] & 0b11110000) == 0 {
                  _messageType = .duplexGroupData
                }
            default:
              break
            }
          case 0x04:
            switch message[3] {
            case 0x00:
              if message[4 ] == 0x00 &&
                 message[6 ] == 0x00 &&
                 message[7 ] == 0x00 &&
                 message[8 ] == 0x00 &&
                 message[9 ] == 0x00 &&
                 message[10] == 0x00 &&
                 message[11] == 0x00 &&
                 message[12] == 0x00 &&
                 message[13] == 0x00 &&
                 message[14] == 0x00 &&
                 message[15] == 0x00 &&
                 message[16] == 0x00 &&
                 message[17] == 0x00 &&
                 message[18] == 0x00 {
                _messageType = .setDuplexGroupID
              }
            case 0x08:
              if message[4 ] == 0x00 &&
                 message[5 ] == 0x00 &&
                 message[6 ] == 0x00 &&
                 message[7 ] == 0x00 &&
                 message[8 ] == 0x00 &&
                 message[9 ] == 0x00 &&
                 message[10] == 0x00 &&
                 message[11] == 0x00 &&
                 message[12] == 0x00 &&
                 message[13] == 0x00 &&
                 message[14] == 0x00 &&
                 message[15] == 0x00 &&
                 message[16] == 0x00 &&
                 message[17] == 0x00 &&
                 message[18] == 0x00 {
                _messageType = .getDuplexGroupID
              }
            case 0x10:
              if message[4 ] == 0x00 &&
                 message[6 ] == 0x00 &&
                 message[7 ] == 0x00 &&
                 message[8 ] == 0x00 &&
                 message[9 ] == 0x00 &&
                 message[10] == 0x00 &&
                 message[11] == 0x00 &&
                 message[12] == 0x00 &&
                 message[13] == 0x00 &&
                 message[14] == 0x00 &&
                 message[15] == 0x00 &&
                 message[16] == 0x00 &&
                 message[17] == 0x00 &&
                 message[18] == 0x00 {
                _messageType = .duplexGroupID
              }
            default:
              break
            }
          case 0x07:
            switch message[3] {
            case 0x00:
              if (message[4 ] & 0b11110000) == 0 &&
                  message[9 ] == 0x00 &&
                  message[10] == 0x00 &&
                  message[11] == 0x00 &&
                  message[12] == 0x00 &&
                  message[13] == 0x00 &&
                  message[14] == 0x00 &&
                  message[15] == 0x00 &&
                  message[16] == 0x00 &&
                  message[17] == 0x00 &&
                  message[18] == 0x00 {
                _messageType = .setDuplexGroupPassword
              }
            case 0x08:
              if message[4 ] == 0x00 &&
                 message[5 ] == 0x00 &&
                 message[6 ] == 0x00 &&
                 message[7 ] == 0x00 &&
                 message[8 ] == 0x00 &&
                 message[9 ] == 0x00 &&
                 message[10] == 0x00 &&
                 message[11] == 0x00 &&
                 message[12] == 0x00 &&
                 message[13] == 0x00 &&
                 message[14] == 0x00 &&
                 message[15] == 0x00 &&
                 message[16] == 0x00 &&
                 message[17] == 0x00 &&
                 message[18] == 0x00 {
                _messageType = .getDuplexGroupPassword
              }
            case 0x10:
              if message[4 ] == 0x00 &&
                 message[9 ] == 0x00 &&
                 message[10] == 0x00 &&
                 message[11] == 0x00 &&
                 message[12] == 0x00 &&
                 message[13] == 0x00 &&
                 message[14] == 0x00 &&
                 message[15] == 0x00 &&
                 message[16] == 0x00 &&
                 message[17] == 0x00 &&
                 message[18] == 0x00 {
                _messageType = .duplexGroupPassword
              }
            default:
              break
            }
          case 0x0f:
            switch message[3] {
            case 0x08:
              if message[4 ] == 0x00 &&
                 message[6 ] == 0x00 &&
                 message[7 ] == 0x00 &&
                 message[8 ] == 0x00 &&
                 message[9 ] == 0x00 &&
                 message[10] == 0x00 &&
                 message[11] == 0x01 &&
                 message[12] == 0x00 &&
                 message[13] == 0x00 &&
                 message[14] == 0x00 &&
                 message[15] == 0x00 &&
                 message[16] == 0x00 &&
                 message[17] == 0x00 &&
                 message[18] == 0x00 {
                _messageType = .iplDiscover
              }
            case 0x10:
              if (message[4 ] & 0b11110000) == 0x00 &&
                 (message[9 ] & 0b11110000) == 0x00 &&
                 (message[14] & 0b11110000) == 0x00 {
                _messageType = .iplDevData
              }
            default:
              break
            }
          case 0x10:
            switch message[3] {
            case 0x08:
              if message[4 ] == 0x00 &&
                 message[6 ] == 0x00 &&
                 message[7 ] == 0x00 &&
                 message[8 ] == 0x00 &&
                 message[9 ] == 0x00 &&
                 message[10] == 0x00 &&
                 message[11] == 0x00 &&
                 message[12] == 0x00 &&
                 message[13] == 0x00 &&
                 message[14] == 0x00 &&
                 message[15] == 0x00 &&
                 message[16] == 0x00 &&
                 message[17] == 0x00 &&
                 message[18] == 0x00 {
                _messageType = .getDuplexSignalStrength
              }
            case 0x10:
              if (message[4 ] & 0b11110000) == 0 &&
                  message[9 ] == 0x00 &&
                  message[10] == 0x00 &&
                  message[11] == 0x00 &&
                  message[12] == 0x00 &&
                  message[13] == 0x00 &&
                  message[14] == 0x00 &&
                  message[15] == 0x00 &&
                  message[16] == 0x00 &&
                  message[17] == 0x00 &&
                  message[18] == 0x00 {
                _messageType = .duplexSignalStrength
              }
              else if (message[4 ] & 0b11110000) == 0 &&
                  message[ 5] != 0x00 &&
                  message[ 6] != 0x00 &&
                  message[ 7] != 0x00 &&
                  message[ 8] != 0x00 &&
                  (message[9] & 0b11110000) == 0x00 &&
                  message[10] != 0x00 &&
                  message[11] != 0x00 &&
                  message[12] != 0x00 &&
                  message[13] != 0x00 &&
                 (message[14] & 0b11110000) == 0x00 {
                _messageType = .lnwiData
              }

            default:
              break
            }
            
          default:
            break
          }

        default:
          break
        }

      case .opcSlRdDdataP2:
        if message[1] == 0x15 && (message[2] & 0b11111000) == 0 {
          
          if message[3] > 0 && message[3] < 0x78 && (message[7] & 0b10110000) == 00 {
            _messageType = .locoSlotDataP2
          }
          else if message[3] >= 0x78 && message[3] <= 0x7c && message[2] == 0x01 {
            switch message[3] {
            case 0x78:
              _messageType = .querySlot1
            case 0x79:
              _messageType = .querySlot2
            case 0x7a:
              _messageType = .querySlot3
            case 0x7b:
              _messageType = .querySlot4
            case 0x7c:
              _messageType = .querySlot5
            default:
              break
            }
          }
          else if message[3] == 0x7f && message[2] == 0x00 {
            _messageType = .opSwDataP2
          }
          
        }
        else if message[1] == 0x10 {
          
          if message[2] == 0x00 {
            
            // 0xe6 0x10 0x00 0x00 0x20 0x00 0x0b 0x02 0x02 0x7f 0x00 0x00 0x00 0x00 0x00 0x5d

            if message[3] == 0x00 &&
               message[10] == 0x00 &&
               message[11] == 0x00 &&
               message[12] == 0x00 &&
               message[13] == 0x00 &&
               message[14] == 0x00 {
              _messageType = .rosterTableInfo
            }
           else if message[ 3] == 0x02 &&
               (message[4] & 0b11100000) == 0x00 &&
               message[ 5] == 0x00 &&
               message[ 6] == 0x0f &&
               message[10] == 0x00 &&
               message[14] == 0x00 {
              _messageType = .rosterEntry
            }
            
          }
          else if message[2] == 0x01 {
            
            if message[3] == 0x00 &&
               message[10] == 0x00 &&
               message[11] == 0x00 &&
               message[12] == 0x00 &&
               message[13] == 0x00 &&
               message[14] == 0x00 {
              _messageType = .routeTableInfoA
            }
            else if message[3] == 0x02 &&
              (message[5] & 0b11111110) == 0x00 &&
               message[6] == 0x0f {
              _messageType = .routeTablePage
            }
            
          }
          else if message[2] == 0x02 {
            
            if message[ 3] == 0x00 &&
               message[ 5] == 0x00 &&
               message[ 6] == 0x00 &&
               message[ 7] == 0x02 &&
               (message[12] & 0b11000000) == 0x00 &&
               (message[14] & 0b11110000) == 0x00 {
              _messageType = .s7Info
            }

          }
          
        }

      case .opcSlRdDdata:
        if message[ 1] == 0x0e &&
          (message[ 7] &  0b00110000) == 0x00 /* TRK */ {
          
          switch message[2] {
          case 0x78:
            break
          case 0x79:
            break
          case 0x7a:
            break
          case 0x7b:
            _messageType = .fastClockData
          case 0x7c:
            if (message[ 4] & 0b11110000) == 0 {
              _messageType = .progSlotDataP1
            }
          case 0x7d:
            break
          case 0x7e:
            _messageType = .opSwDataBP1
          case 0x7f:
            _messageType = .opSwDataAP1
          default:
            if message[ 2] > 0 && message[2] < 0x78 &&
          //    (message[ 6] & 0b11000000) == 0 && /* DIRF */
              (message[ 7] & 0b10110000) == 0 &&
              (message[ 8] & 0b11110010) == 0 && /* SS@  */
              (message[10] & 0b11110000) == 0    /* SND  */ {
              _messageType = .locoSlotDataP1
            }
          }
          
        }

      case .opcImmPacket:
        if message[1] == 0x0b && message[2] == 0x7f {
            _messageType = .immPacket
        }

      case .opcWrSlDataP2:
        if message[1] == 0x15 {
          if message[2] == 0 && message[3] == 0x7f {
            _messageType = .setOpSwDataP2
          }
          else if message[2] == 0x19 && message[3] == 0x7b {
            _messageType = .resetQuerySlot4
          }
          else if message[3] > 0 && message[3] < 0x78 {
            _messageType = .setLocoSlotDataP2
          }
        }
        else if message[1] == 0x10 {
  // 0xee 0x10 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x01
          
          if message[2] == 0x00 {
  
            if message[ 3] == 0x00 &&
               message[ 4] == 0x00 &&
               message[ 5] == 0x00 &&
               message[ 6] == 0x00 &&
               message[ 7] == 0x00 &&
               message[ 8] == 0x00 &&
               message[ 9] == 0x00 &&
               message[10] == 0x00 &&
               message[11] == 0x00 &&
               message[12] == 0x00 &&
               message[13] == 0x00 {
              _messageType = .getRosterTableInfo
            }
            else if message[ 3] == 0x02 &&
               (message[4] & 0b11100000) == 0x00 &&
               message[ 5] == 0x00 &&
               message[10] == 0x00 &&
               message[14] == 0x00 {
              _messageType = .getRosterEntry
            }
            else if message[ 3] == 0x43 &&
                    message[ 5] == 0x00 &&
                    message[10] == 0x00 &&
                    message[14] == 0x00 {
                   _messageType = .setRosterEntry
            }

          }
          else if message[2] == 0x01 {
            
            if message[ 3] == 0x00 &&
               message[ 4] == 0x00 &&
               message[ 5] == 0x00 &&
               message[ 6] == 0x00 &&
               message[ 7] == 0x00 &&
               message[ 8] == 0x00 &&
               message[ 9] == 0x00 &&
               message[10] == 0x00 &&
               message[11] == 0x00 &&
               message[12] == 0x00 &&
               message[13] == 0x00 {
              _messageType = .getRouteTableInfoA
            }
            else if message[ 3] == 0x02 &&
                      (message[5] & 0b11111110) == 0x00 { // &&
           //    message[ 6] == 0x00 &&
           //    message[ 7] == 0x00 &&
           //    message[ 8] == 0x00 &&
           //    message[ 9] == 0x00 &&
           //    message[10] == 0x00 &&
           //    message[11] == 0x00 &&
           //    message[12] == 0x00 &&
           //    message[13] == 0x00 {
              _messageType = .getRouteTablePage
            }
            else if message[ 3] == 0x03 &&
               (message[5] & 0b11111110) == 0x00 {
              _messageType = .setRouteTablePage
            }

          }
          else if message[2] == 0x02 {
            
            if message[ 3] == 0x00 &&
               message[ 4] == 0x00 &&
               message[ 5] == 0x00 &&
               message[ 6] == 0x00 &&
               message[ 7] == 0x00 &&
               message[ 8] == 0x00 &&
               message[ 9] == 0x00 &&
               message[10] == 0x00 &&
               message[11] == 0x00 &&
               message[12] == 0x00 &&
               message[13] == 0x00 &&
               message[14] == 0x00 {
              _messageType = .getRouteTableInfoB
            }
            else if message[3] == 0x0f &&
               message[ 4] == 0x00 &&
               message[ 5] == 0x00 &&
               message[ 6] == 0x00 &&
               message[ 7] == 0x00 &&
               message[ 8] == 0x00 &&
               (message[12] & 0b11000000) == 0x00 &&
               (message[14] & 0b11110000) == 0x00 {
              _messageType = .setS7BaseAddr
            }

          }
          
        }

      case .opcWrSlData:
        if message[1] == 0x0e {
          
          if message[2] > 0 && message[ 2] <  0x78 && /* SLOT */
     //       (message[ 6] &  0b11000000) == 0x00 && /* DIRF */
            (message[ 7] &  0b10110000) == 0x00 && /* TRK  */
            (message[ 8] &  0b11110010) == 0x00 && /* SS@  */
            (message[10] &  0b11110000) == 0x00    /* SND  */ {
            _messageType = .setLocoSlotDataP1
          }
          else if message[ 2] == 0x7b {
            _messageType = .setFastClockData
          }
          else if message[ 2] == 0x7c &&                /* PROG SLOT */
                  message[ 4] == 0x00 &&
                  message[ 7] == 0x00 &&
                 (message[ 8] &  0b11001100) == 0x00 {
            _messageType = .progCV
          }
          else if message[2] == 0x7e {
            _messageType = .setOpSwDataBP1
          }
          else if message[2] == 0x7f {
            _messageType = .setOpSwDataAP1
          }
          
        }

      default:
        break
      }
      
    }
    
    return _messageType!

  }
  
  // MARK: Public Methods
  
  public func getOpSwState(opSwNumber:Int) -> Bool? {
    switch messageType {
    case .opSwDataAP1:
      guard (1 ... 64) ~= opSwNumber else {
        return nil
      }
      let index = opSwNumber - 1
      return message[index / 8 + (index < 4 ? 3 : 4)] & (1 << (index % 8)) != 0
    case .opSwDataBP1:
      guard (65 ... 128) ~= opSwNumber else {
        return nil
      }
      let index = opSwNumber - 65
      return message[index / 8 + (index < 4 ? 3 : 4)] & (1 << (index % 8)) != 0
    default:
      break
    }
    return nil
  }
  
  public func setOpSwState(opSwNumber:Int, opSwState:Bool) {
    switch messageType {
    case .opSwDataAP1:
      guard (1 ... 64) ~= opSwNumber else {
        return
      }
      let index = opSwNumber - 1
      let byte = index / 8 + (index < 4 ? 3 : 4)
      let bit = index % 8
      let mask : UInt8 = (bit == 7) ? 0 : (1 << bit)
      message[byte] &= ~mask
      message[byte] |=  opSwState ? mask : 0
    case .opSwDataBP1:
      guard (65 ... 128) ~= opSwNumber else {
        return
      }
      let index = opSwNumber - 65
      let byte = index / 8 + (index < 4 ? 3 : 4)
      let bit = index % 8
      let mask : UInt8 = (bit == 7) ? 0 : (1 << bit)
      message[byte] &= ~mask
      message[byte] |=  opSwState ? mask : 0
    default:
      break
    }
  }

  // MARK: Public Static Properties
  
  public static let locoNetAddressRange = UInt16(1) ... UInt16(10239)
  
  public static let slotBankRange = UInt8(0) ... UInt8(3)

  public static let slotRange = UInt8(1) ... UInt8(119)

  // MARK: Public Class Methods
  
  public static func checkSum(data: [UInt8]) -> UInt8 {
    var cs : UInt8 = 0xff
    for byte in data {
      cs ^= byte
    }
    return cs
  }
  
  public static func isCheckSumOK(message: [UInt8]) -> Bool {
    var cs : UInt8 = 0xff
    for byte in message {
      cs ^= byte
    }
    return cs == 0
  }
  
  // MARK: Operators
  
  public static func ==(lhs:SGLocoNetMessage, rhs:SGLocoNetMessage) -> Bool {
    return lhs.message == rhs.message
  }

  public static func !=(lhs:SGLocoNetMessage, rhs:SGLocoNetMessage) -> Bool {
    return lhs.message != rhs.message
  }

}
