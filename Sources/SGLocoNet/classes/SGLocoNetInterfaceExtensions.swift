// -----------------------------------------------------------------------------
// SGLocoNetInterfaceExtensions.swift
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
//     20/09/2024  Paul Willmott - SGLocoNetInterfaceExtensions.swift created
// -----------------------------------------------------------------------------

import Foundation

extension SGLocoNetInterface {
  
  // MARK: COMMAND STATION COMMANDS

  public func sendMessage(message:SGLocoNetMessage) {
    addToQueue(message: message)
  }
  
  public func powerOn() {
    addToQueue(message: SGLocoNetMessage(data: [SGLocoNetMessageOpcode.opcGPOn.rawValue], appendCheckSum: true))
  }
  
  public func powerOff() {
    addToQueue(message: SGLocoNetMessage(data: [SGLocoNetMessageOpcode.opcGPOff.rawValue], appendCheckSum: true))
  }
  
  public func getOpSwDataAP1() {
    addToQueue(message: SGLocoNetMessage(data: [SGLocoNetMessageOpcode.opcRqSlData.rawValue, 0x7f, 0x00], appendCheckSum: true))
  }

  // MARK: HELPER COMMANDS
  
  public func immPacket(packet:[UInt8], repeatCount: SGLocoNetIMMPacketRepeat) {
    
    guard packet.count < 6 else {
      return
    }
    
    let param : UInt8 = ((UInt8(packet.count) << 4) | repeatCount.rawValue) & 0x7f
    
    var payload : [UInt8] = [
      SGLocoNetMessageOpcode.opcImmPacket.rawValue,
      0x0b,
      0x7f,
      param,
      0b00000000,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00
    ]
    
    var mask : UInt8 = 1
    
    for index in 0...packet.count - 1 {
      
      payload[4] |= (packet[index] & 0x80 == 0x80) ? mask : 0x00
      
      payload[5 + index] = packet[index] & 0x7f
      
      mask <<= 1
      
    }
    
    addToQueue(message: SGLocoNetMessage(data: payload, appendCheckSum: true))

  }
  
  // MARK: LOCOMOTIVE CONTROL COMMANDS
  
  public func getLocoSlotDataP1(forAddress: UInt16) {
    addToQueue(message: SGLocoNetMessage(data: [SGLocoNetMessageOpcode.opcLocoAdr.rawValue, UInt8(forAddress >> 7), UInt8(forAddress & 0x7f)], appendCheckSum: true))
  }
  
  public func getLocoSlotDataP2(forAddress: UInt16) {
    addToQueue(message: SGLocoNetMessage(data: [SGLocoNetMessageOpcode.opcLocoAdrP2.rawValue, UInt8(forAddress >> 7), UInt8(forAddress & 0x7f)], appendCheckSum: true))
  }
  /*
  public func getLocoSlotData(forAddress: UInt16) {
    if commandStationType.implementsProtocol2 {
      getLocoSlotDataP2(forAddress: forAddress)
    }
    else {
      getLocoSlotDataP1(forAddress: forAddress)
    }
  }
  */
  public func setLocoSlotStat1P1(slotNumber:UInt8, stat1:UInt8) {
    addToQueue(message: SGLocoNetMessage(data: [SGLocoNetMessageOpcode.opcSlotStat1.rawValue, UInt8(slotNumber), stat1], appendCheckSum: true))
  }
  
  public func setLocoSlotStat1P2(slotPage:UInt8, slotNumber:UInt8, stat1:UInt8) {
    addToQueue(message: SGLocoNetMessage(data: [SGLocoNetMessageOpcode.opcD4Group.rawValue, 0b00111000 | (slotPage & 0b00000111), UInt8(slotNumber & 0x7f), 0x60, stat1], appendCheckSum: true))
  }
  /*
  public func setLocoSlotStat1(slotPage:UInt8, slotNumber:UInt8, stat1:UInt8) {
    if commandStationType.implementsProtocol2 {
      setLocoSlotStat1P2(slotPage: slotPage, slotNumber: slotNumber, stat1: stat1)
    }
    else {
      setLocoSlotStat1P1(slotNumber: slotNumber, stat1: stat1)
    }
  }
  */
  public func moveSlotsP1(sourceSlotNumber: UInt8, destinationSlotNumber: UInt8) {
    addToQueue(message: SGLocoNetMessage(data: [SGLocoNetMessageOpcode.opcMoveSlots.rawValue, UInt8(sourceSlotNumber), UInt8(destinationSlotNumber)], appendCheckSum: true))
  }
  
  public func moveSlotsP2(sourceSlotNumber: UInt8, sourceSlotPage: UInt8, destinationSlotNumber: UInt8, destinationSlotPage: UInt8) {
    addToQueue(message: SGLocoNetMessage(data: [SGLocoNetMessageOpcode.opcD4Group.rawValue, (sourceSlotPage & 0b00000111) | 0b00111000, UInt8(sourceSlotNumber), destinationSlotPage & 0b00000111, UInt8(destinationSlotNumber)], appendCheckSum: true))
  }
  /*
  public func setLocomotiveState(address:UInt16, slotNumber: UInt8, slotPage: UInt8, nextState:LocoNetLocomotiveState, throttleID: UInt16) -> LocomotiveStateWithTimeStamp {
    
    var next = nextState.functions

    let timeStamp = Date.timeIntervalSinceReferenceDate
      
    if commandStationType.implementsProtocol2 {
        
      locoSpdDirP2(slotNumber: slotNumber, slotPage: slotPage, speed: nextState.speed, direction: nextState.direction, throttleID: throttleID)

      locoF0F6P2(slotNumber:   slotNumber, slotPage: slotPage, functions: next, throttleID: throttleID)
      locoF7F13P2(slotNumber:  slotNumber, slotPage: slotPage, functions: next, throttleID: throttleID)
      locoF14F20P2(slotNumber: slotNumber, slotPage: slotPage, functions: next, throttleID: throttleID)
      locoF21F28P2(slotNumber: slotNumber, slotPage: slotPage, functions: next, throttleID: throttleID)

    }
    else {
      
      locoSpdP1(slotNumber: slotNumber, speed: nextState.speed)

      locoDirF0F4P1(slotNumber: slotNumber, direction: nextState.direction, functions: next)
      
      if commandStationType.implementsProtocol1 {
        locoF5F8P1(slotNumber: slotNumber, functions: next)
      }
      else {
        dccF5F8(address: address, functions: next)
      }
      
      dccF9F12(address:  address, functions: next)
      dccF13F20(address: address, functions: next)
      dccF21F28(address: address, functions: next)
      
    }
    
    next = nextState.extendedFunctions
    
    dccF29F36(address: address, functions: next)
    dccF37F44(address: address, functions: next)
    dccF45F52(address: address, functions: next)
    dccF53F60(address: address, functions: next)
    dccF61F68(address: address, functions: next)

    return (state: nextState, timeStamp: timeStamp)

  }
  
  public func updateLocomotiveState(address:UInt16, slotNumber: UInt8, slotPage: UInt8, previousState:LocoNetLocomotiveState, nextState:LocoNetLocomotiveState, throttleID: UInt16, forceRefresh: Bool) -> LocomotiveStateWithTimeStamp {
 
    var previous = previousState.functions
    
    var next = nextState.functions

    let speedChanged = previousState.speed != nextState.speed
    
    let directionChanged = previousState.direction != nextState.direction
    
    let timeStamp = Date.timeIntervalSinceReferenceDate
    
    if commandStationType.implementsProtocol2 {
      
      if speedChanged || directionChanged || forceRefresh {
        locoSpdDirP2(slotNumber: slotNumber, slotPage: slotPage, speed: nextState.speed, direction: nextState.direction, throttleID: throttleID)
      }

      let maskF0F6   : UInt64 = 0b00000000000000000000000001111111
      let maskF7F13  : UInt64 = 0b00000000000000000011111110000000
      let maskF14F20 : UInt64 = 0b00000000000111111100000000000000
      let maskF21F28 : UInt64 = 0b00011111111000000000000000000000
      
      if previous & maskF0F6 != next & maskF0F6 {
        locoF0F6P2(slotNumber: slotNumber, slotPage: slotPage, functions: next, throttleID: throttleID)
      }
      
      if previous & maskF7F13 != next & maskF7F13 {
        locoF7F13P2(slotNumber: slotNumber, slotPage: slotPage, functions: next, throttleID: throttleID)
      }
      
      if previous & maskF14F20 != next & maskF14F20 {
        locoF14F20P2(slotNumber: slotNumber, slotPage: slotPage, functions: next, throttleID: throttleID)
      }
      
      if previous & maskF21F28 != next & maskF21F28 {
        locoF21F28P2(slotNumber: slotNumber, slotPage: slotPage, functions: next, throttleID: throttleID)
      }

    }
    else {
      
      if speedChanged || forceRefresh {
        locoSpdP1(slotNumber: slotNumber, speed: nextState.speed)
      }

      let maskF0F4   : UInt64 = 0b00000000000000000000000000011111
      let maskF5F8   : UInt64 = 0b00000000000000000000000111100000
      let maskF9F12  : UInt64 = 0b00000000000000000001111000000000
      let maskF13F20 : UInt64 = 0b00000000000111111110000000000000
      let maskF21F28 : UInt64 = 0b00011111111000000000000000000000

      if previous & maskF0F4 != next & maskF0F4 || directionChanged {
        locoDirF0F4P1(slotNumber: slotNumber, direction: nextState.direction, functions: next)
      }
      
      if previous & maskF5F8 != next & maskF5F8 {
        
        if commandStationType.implementsProtocol1 {
          locoF5F8P1(slotNumber: slotNumber, functions: next)
        }
        else {
          dccF5F8(address: address, functions: next)
        }
        
      }

      if previous & maskF9F12 != next & maskF9F12 {
        dccF9F12(address: address, functions: next)
      }
      
      if previous & maskF13F20 != next & maskF13F20 {
        dccF13F20(address: address, functions: next)
      }

      if previous & maskF21F28 != next & maskF21F28 {
        dccF21F28(address: address, functions: next)
      }

    }
    
    previous = previousState.extendedFunctions
    
    next = nextState.extendedFunctions
    
    let maskF29F36   : UInt64 = 0b0000000000000000000000000000000011111111
    let maskF37F44   : UInt64 = 0b0000000000000000000000001111111100000000
    let maskF45F52   : UInt64 = 0b0000000000000000111111110000000000000000
    let maskF53F60   : UInt64 = 0b0000000011111111000000000000000000000000
    let maskF61F68   : UInt64 = 0b1111111100000000000000000000000000000000

    if previous & maskF29F36 != next & maskF29F36 {
      dccF29F36(address: address, functions: next)
    }
    
    if previous & maskF37F44 != next & maskF37F44 {
      dccF37F44(address: address, functions: next)
    }

    if previous & maskF45F52 != next & maskF45F52 {
      dccF45F52(address: address, functions: next)
    }

    if previous & maskF53F60 != next & maskF53F60 {
      dccF53F60(address: address, functions: next)
    }

    if previous & maskF61F68 != next & maskF61F68 {
      dccF61F68(address: address, functions: next)
    }

    return (state: nextState, timeStamp: timeStamp)

  }

  public func clearLocomotiveState(address:UInt16, slotNumber: UInt8, slotPage: UInt8, previousState:LocoNetLocomotiveState, throttleID: UInt16) {
    
    let speed : UInt8 = 0
    
    let next : UInt64 = 0
    
    if commandStationType.implementsProtocol2 {
      
      locoSpdDirP2(slotNumber: slotNumber, slotPage: slotPage, speed: speed, direction: previousState.direction, throttleID: throttleID)

      locoF0F6P2(slotNumber:   slotNumber, slotPage: slotPage, functions: next, throttleID: throttleID)
      locoF7F13P2(slotNumber:  slotNumber, slotPage: slotPage, functions: next, throttleID: throttleID)
      locoF14F20P2(slotNumber: slotNumber, slotPage: slotPage, functions: next, throttleID: throttleID)
      locoF21F28P2(slotNumber: slotNumber, slotPage: slotPage, functions: next, throttleID: throttleID)

    }
    else {
      
      locoSpdP1(slotNumber: slotNumber, speed: speed)

      locoDirF0F4P1(slotNumber: slotNumber, direction: previousState.direction, functions: next)
      
      if commandStationType.implementsProtocol1 {
        locoF5F8P1(slotNumber: slotNumber, functions: next)
      }
      else {
        dccF5F8(address: address, functions: next)
      }
      
      dccF9F12(address:  address, functions: next)
      dccF13F20(address: address, functions: next)
      dccF21F28(address: address, functions: next)
      
    }
    
    dccF29F36(address: address, functions: next)
    dccF37F44(address: address, functions: next)
    dccF45F52(address: address, functions: next)
    dccF53F60(address: address, functions: next)
    dccF61F68(address: address, functions: next)

  }
  */

  public func locoSpdDirP2(slotNumber: UInt8, slotPage: UInt8, speed: UInt8, direction: SGLocoNetLocomotiveDirection, throttleID: UInt16) {
    
    let data : [UInt8] = [
      SGLocoNetMessageOpcode.opcD5Group.rawValue,
      (slotPage & 0x07) | (direction == .reverse ? 0b00001000 : 0b00000000),
      slotNumber & 0x7f,
      UInt8(throttleID & 0x7f),
      speed & 0x7f
    ]
    
    addToQueue(message: SGLocoNetMessage(data: data, appendCheckSum: true))

  }
  
  public func locoSpdP1(slotNumber: UInt8, speed: UInt8) {
    
    let data : [UInt8] = [
      SGLocoNetMessageOpcode.opcLocoSpd.rawValue,
      slotNumber & 0x7f,
      speed & 0x7f
    ]
    
    addToQueue(message: SGLocoNetMessage(data: data, appendCheckSum: true))

  }
  
  public func locoF0F6P2(slotNumber: UInt8, slotPage: UInt8, functions: [Bool], throttleID: UInt16) {
    
    guard functions.count >= 7 else {
      return
    }
    
    var fnx : UInt8 = 0
    
    fnx |= functions[0] ? 0b00010000 : 0
    fnx |= functions[1] ? 0b00000001 : 0
    fnx |= functions[2] ? 0b00000010 : 0
    fnx |= functions[3] ? 0b00000100 : 0
    fnx |= functions[4] ? 0b00001000 : 0
    fnx |= functions[5] ? 0b00100000 : 0
    fnx |= functions[6] ? 0b01000000 : 0

    let data : [UInt8] = [
      SGLocoNetMessageOpcode.opcD5Group.rawValue,
      (slotPage & 0x07) | 0b00010000,
      slotNumber & 0x7f,
      UInt8(throttleID & 0x7f),
      fnx
    ]
    
    addToQueue(message: SGLocoNetMessage(data: data, appendCheckSum: true))

  }
  
  public func locoF7F13P2(slotNumber: UInt8, slotPage: UInt8, functions: [Bool], throttleID: UInt16) {
    
    guard functions.count >= 14 else {
      return
    }
    
    var fnx : UInt8 = 0
    
    var mask : UInt8 = 0b00000001
    
    for function in 7 ... 13 {
      if functions[function] {
        fnx |= mask
      }
      mask <<= 1
    }
    
    let data : [UInt8] = [
      SGLocoNetMessageOpcode.opcD5Group.rawValue,
      (slotPage & 0x07) | 0b00011000,
      slotNumber & 0x7f,
      UInt8(throttleID & 0x7f),
      fnx
    ]

    addToQueue(message: SGLocoNetMessage(data: data, appendCheckSum: true))

  }
  
  public func locoF14F20P2(slotNumber: UInt8, slotPage: UInt8, functions: [Bool], throttleID: UInt16) {
    
    guard functions.count >= 21 else {
      return
    }
    
    var fnx : UInt8 = 0
    
    var mask : UInt8 = 0b00000001
    
    for function in 14 ... 20 {
      if functions[function] {
        fnx |= mask
      }
      mask <<= 1
    }

    let data : [UInt8] = [
      SGLocoNetMessageOpcode.opcD5Group.rawValue,
      (slotPage & 0x07) | 0b00100000,
      slotNumber & 0x7f,
      UInt8(throttleID & 0x7f),
      fnx
    ]

    addToQueue(message: SGLocoNetMessage(data: data, appendCheckSum: true))

  }
  
  public func locoF21F28P2(slotNumber: UInt8, slotPage: UInt8, functions: [Bool], throttleID: UInt16) {
    
    guard functions.count >= 29 else {
      return
    }
    
    var fnx : UInt8 = 0
    
    var mask : UInt8 = 0b00000001
    
    for function in 21 ... 27 {
      if functions[function] {
        fnx |= mask
      }
      mask <<= 1
    }

    let data : [UInt8] = [
      SGLocoNetMessageOpcode.opcD5Group.rawValue,
      (slotPage & 0x07) | UInt8(functions[28] ? 0b00110000 : 0b00101000),
      slotNumber & 0x7f,
      UInt8(throttleID & 0x7f),
      fnx]

    addToQueue(message: SGLocoNetMessage(data: data, appendCheckSum: true))

  }
  
  public func locoDirF0F4P1(slotNumber: UInt8, direction:SGLocoNetLocomotiveDirection, functions: [Bool]) {
    
    guard functions.count >= 5 else {
      return
    }
    
    var dirf : UInt8 = direction == .reverse ? 0b00100000 : 0
    
    dirf |= functions[0] ? 0b00010000 : 0
    dirf |= functions[1] ? 0b00000001 : 0
    dirf |= functions[2] ? 0b00000010 : 0
    dirf |= functions[3] ? 0b00000100 : 0
    dirf |= functions[4] ? 0b00001000 : 0
    
    let data : [UInt8] = [
      SGLocoNetMessageOpcode.opcLocoDirF.rawValue,
      slotNumber & 0x7f,
      dirf
    ]
    
    addToQueue(message: SGLocoNetMessage(data: data, appendCheckSum: true))

  }
  
  public func locoF5F8P1(slotNumber: UInt8, functions: [Bool]) {
    
    guard functions.count >= 9 else {
      return
    }
    
    var fnx : UInt8 = 0
    
    var mask : UInt8 = 0b00000001
    
    for function in 5 ... 8 {
      if functions[function] {
        fnx |= mask
      }
      mask <<= 1
    }

    let data : [UInt8] = [
      SGLocoNetMessageOpcode.opcLocoSnd.rawValue,
      slotNumber & 0x7f,
      fnx
    ]
    
    addToQueue(message: SGLocoNetMessage(data: data, appendCheckSum: true))

  }
  
  internal func dccAddress(address:UInt16) -> [UInt8] {
    
    if address < 128 {
      return [UInt8(address)]
    }
    
    let temp = Int(address) + 49152
    
    return [UInt8(temp >> 8), UInt8(temp & 0xff)]
    
  }
  
  /*
  public func dccF5F8(address:UInt16, functions: UInt64) {
    
    var fx : UInt8 = DCCPacketType.dccF5F8.rawValue
    
    fx |= functions & maskF5 == maskF5 ? 0b00000001 : 0b00000000
    fx |= functions & maskF6 == maskF6 ? 0b00000010 : 0b00000000
    fx |= functions & maskF7 == maskF7 ? 0b00000100 : 0b00000000
    fx |= functions & maskF8 == maskF8 ? 0b00001000 : 0b00000000
    
    var data : [UInt8] = dccAddress(address: address)
    
    data.append(fx)
    
    immPacket(packet: data, repeatCount: .repeat4)
    
  }

  public func dccF9F12(address:UInt16, functions: UInt64) {
    
    var fx : UInt8 = DCCPacketType.dccF9F12.rawValue
    
    fx |= functions & maskF9  == maskF9  ? 0b00000001 : 0b00000000
    fx |= functions & maskF10 == maskF10 ? 0b00000010 : 0b00000000
    fx |= functions & maskF11 == maskF11 ? 0b00000100 : 0b00000000
    fx |= functions & maskF12 == maskF12 ? 0b00001000 : 0b00000000
    
    var data : [UInt8] = dccAddress(address: address)
    
    data.append(fx)
    
    immPacket(packet: data, repeatCount: .repeat4)
    
  }

  public func dccF13F20(address:UInt16, functions: UInt64) {
    
    var fx : UInt8 = 0
    
    fx |= functions & maskF13 == maskF13 ? 0b00000001 : 0b00000000
    fx |= functions & maskF14 == maskF14 ? 0b00000010 : 0b00000000
    fx |= functions & maskF15 == maskF15 ? 0b00000100 : 0b00000000
    fx |= functions & maskF16 == maskF16 ? 0b00001000 : 0b00000000
    fx |= functions & maskF17 == maskF17 ? 0b00010000 : 0b00000000
    fx |= functions & maskF18 == maskF18 ? 0b00100000 : 0b00000000
    fx |= functions & maskF19 == maskF19 ? 0b01000000 : 0b00000000
    fx |= functions & maskF20 == maskF20 ? 0b10000000 : 0b00000000

    var data : [UInt8] = dccAddress(address: address)
    
    data.append(DCCPacketType.dccF13F20.rawValue)
    data.append(fx)
    
    immPacket(packet: data, repeatCount: .repeat4)
    
  }

  public func dccF21F28(address:UInt16, functions: UInt64) {
    
    var fx : UInt8 = 0
    
    fx |= functions & maskF21 == maskF21 ? 0b00000001 : 0b00000000
    fx |= functions & maskF22 == maskF22 ? 0b00000010 : 0b00000000
    fx |= functions & maskF23 == maskF23 ? 0b00000100 : 0b00000000
    fx |= functions & maskF24 == maskF24 ? 0b00001000 : 0b00000000
    fx |= functions & maskF25 == maskF25 ? 0b00010000 : 0b00000000
    fx |= functions & maskF26 == maskF26 ? 0b00100000 : 0b00000000
    fx |= functions & maskF27 == maskF27 ? 0b01000000 : 0b00000000
    fx |= functions & maskF28 == maskF28 ? 0b10000000 : 0b00000000

    var data : [UInt8] = dccAddress(address: address)
    
    data.append(DCCPacketType.dccF21F28.rawValue)
    data.append(fx)
    
    immPacket(packet: data, repeatCount: .repeat4)
    
  }

  public func dccF29F36(address:UInt16, functions: UInt64) {
    
    var fx : UInt8 = 0
    
    fx |= functions & maskF29 == maskF29 ? 0b00000001 : 0b00000000
    fx |= functions & maskF30 == maskF30 ? 0b00000010 : 0b00000000
    fx |= functions & maskF31 == maskF31 ? 0b00000100 : 0b00000000
    fx |= functions & maskF32 == maskF32 ? 0b00001000 : 0b00000000
    fx |= functions & maskF33 == maskF33 ? 0b00010000 : 0b00000000
    fx |= functions & maskF34 == maskF34 ? 0b00100000 : 0b00000000
    fx |= functions & maskF35 == maskF35 ? 0b01000000 : 0b00000000
    fx |= functions & maskF36 == maskF36 ? 0b10000000 : 0b00000000

    var data : [UInt8] = dccAddress(address: address)
    
    data.append(DCCPacketType.dccF29F36.rawValue)
    data.append(fx)
    
    immPacket(packet: data, repeatCount: .repeat4)
    
  }

  public func dccF37F44(address:UInt16, functions: UInt64) {
    
    var fx : UInt8 = 0
    
    fx |= functions & maskF37 == maskF37 ? 0b00000001 : 0b00000000
    fx |= functions & maskF38 == maskF38 ? 0b00000010 : 0b00000000
    fx |= functions & maskF39 == maskF39 ? 0b00000100 : 0b00000000
    fx |= functions & maskF40 == maskF40 ? 0b00001000 : 0b00000000
    fx |= functions & maskF41 == maskF41 ? 0b00010000 : 0b00000000
    fx |= functions & maskF42 == maskF42 ? 0b00100000 : 0b00000000
    fx |= functions & maskF43 == maskF43 ? 0b01000000 : 0b00000000
    fx |= functions & maskF44 == maskF44 ? 0b10000000 : 0b00000000

    var data : [UInt8] = dccAddress(address: address)
    
    data.append(DCCPacketType.dccF37F44.rawValue)
    data.append(fx)
    
    immPacket(packet: data, repeatCount: .repeat4)
    
  }

  public func dccF45F52(address:UInt16, functions: UInt64) {
    
    var fx : UInt8 = 0
    
    fx |= functions & maskF45 == maskF45 ? 0b00000001 : 0b00000000
    fx |= functions & maskF46 == maskF46 ? 0b00000010 : 0b00000000
    fx |= functions & maskF47 == maskF47 ? 0b00000100 : 0b00000000
    fx |= functions & maskF48 == maskF48 ? 0b00001000 : 0b00000000
    fx |= functions & maskF49 == maskF49 ? 0b00010000 : 0b00000000
    fx |= functions & maskF50 == maskF50 ? 0b00100000 : 0b00000000
    fx |= functions & maskF51 == maskF51 ? 0b01000000 : 0b00000000
    fx |= functions & maskF52 == maskF52 ? 0b10000000 : 0b00000000

    var data : [UInt8] = dccAddress(address: address)
    
    data.append(DCCPacketType.dccF45F52.rawValue)
    data.append(fx)
    
    immPacket(packet: data, repeatCount: .repeat4)
    
  }

  public func dccF53F60(address:UInt16, functions: UInt64) {
    
    var fx : UInt8 = 0
    
    fx |= functions & maskF53 == maskF53 ? 0b00000001 : 0b00000000
    fx |= functions & maskF54 == maskF54 ? 0b00000010 : 0b00000000
    fx |= functions & maskF55 == maskF55 ? 0b00000100 : 0b00000000
    fx |= functions & maskF56 == maskF56 ? 0b00001000 : 0b00000000
    fx |= functions & maskF57 == maskF57 ? 0b00010000 : 0b00000000
    fx |= functions & maskF58 == maskF58 ? 0b00100000 : 0b00000000
    fx |= functions & maskF59 == maskF59 ? 0b01000000 : 0b00000000
    fx |= functions & maskF60 == maskF60 ? 0b10000000 : 0b00000000

    var data : [UInt8] = dccAddress(address: address)
    
    data.append(DCCPacketType.dccF53F60.rawValue)
    data.append(fx)
    
    immPacket(packet: data, repeatCount: .repeat4)
    
  }

  public func dccF61F68(address:UInt16, functions: UInt64) {
    
    var fx : UInt8 = 0
    
    fx |= functions & maskF61 == maskF61 ? 0b00000001 : 0b00000000
    fx |= functions & maskF62 == maskF62 ? 0b00000010 : 0b00000000
    fx |= functions & maskF63 == maskF63 ? 0b00000100 : 0b00000000
    fx |= functions & maskF64 == maskF64 ? 0b00001000 : 0b00000000
    fx |= functions & maskF65 == maskF65 ? 0b00010000 : 0b00000000
    fx |= functions & maskF66 == maskF66 ? 0b00100000 : 0b00000000
    fx |= functions & maskF67 == maskF67 ? 0b01000000 : 0b00000000
    fx |= functions & maskF68 == maskF68 ? 0b10000000 : 0b00000000

    var data : [UInt8] = dccAddress(address: address)
    
    data.append(DCCPacketType.dccF61F68.rawValue)
    data.append(fx)
    
    immPacket(packet: data, repeatCount: .repeat4)
    
  }

  public func dccBinaryState(address:UInt16, binaryStateAddress:UInt16, state:DCCBinaryState) {
    
    var data : [UInt8] = dccAddress(address: address)
    
    if binaryStateAddress < 128 {
      data.append(DCCPacketType.dccBinaryStateShort.rawValue)
      data.append(state.rawValue | UInt8(binaryStateAddress & 0x7f))
    }
    else {
      data.append(DCCPacketType.dccBinaryStateLong.rawValue)
      data.append(state.rawValue | UInt8(binaryStateAddress & 0x7f))
      data.append(UInt8(binaryStateAddress >> 7))
    }
    
    immPacket(packet: data, repeatCount: .repeat4)
    
  }

  public func dccAnalogFunction(address:UInt16, analogOutput:UInt8, value:UInt8) {
    
    var data : [UInt8] = dccAddress(address: address)

    data.append(contentsOf: [
      DCCPacketType.dccAnalogFunction.rawValue,
      analogOutput,
      value
    ])
    
    immPacket(packet: data, repeatCount: .repeat4)
    
  }
  */
  
  // MARK: CV PROGRAMMING
  /*
  private func s7CVRWPacket(address:UInt16, cvNumber:UInt16, mode:DCCCVAccessMode) -> [UInt8] {

    var packet : [UInt8] = [
      0b10000000,
      0b10001000,
      0b11100000,
      0b00000000,
      0b00000000,
    ]
    
    let addr = address - 1
    
    let cv = cvNumber - 1
    
    packet[0] |= UInt8((addr >> 2) & 0b00111111)
    
    packet[1] |= UInt8((addr & 0b00000011) << 1)
    
    packet[1] |= UInt8(~(addr >> 4) & 0b01110000)
    
    packet[2] |= UInt8(cv >> 8)
    
    packet[2] |= mode.rawValue

    packet[3] |= UInt8(cv & 0xff)
    
    return packet
    
  }
  
  public func s7CVReadByte(address:UInt16, cvNumber:UInt16) {
    let packet = s7CVRWPacket(address: address, cvNumber: cvNumber, mode: .readByte)
    immPacket(packet: packet, repeatCount: .repeat4)
  }

  public func s7CVWriteByte(address:UInt16, cvNumber:UInt16, cvValue:UInt8) {
    var packet = s7CVRWPacket(address: address, cvNumber: cvNumber, mode: .writeByte)
    packet[4] = cvValue
    immPacket(packet: packet, repeatCount: .repeat4)
  }

  public func s7CVRW(boardId: Int, cvNumber:Int, isRead:Bool, value:UInt8) {
    
    let cv = UInt8((cvNumber - 1) & 0xff)
    
    let val = isRead ? 0 : value
    
    let high = (0b00000111) | ((cv & 0x80) >> 4) | ((val & 0x80) >> 3)
    
    let b = boardId - 1
    
    let c = b % 4
    
    let d = b / 4
    
    let e = d % 64
    
    let addA = UInt8(e)
    
    let g = d / 64
    
    let h = 7 - g
    
    let i = h * 16 + c * 2 + 8
    
    let addB = UInt8(i)
    
    let mode : UInt8 = 0b01100100 | (isRead ? 0 : 0b1000)
    
    let message = SGLocoNetMessage(data: [SGLocoNetMessageOpcode.OPC_IMM_PACKET.rawValue, 0x0b, 0x7f, 0x54, high, addA, addB, mode, cv & 0x7f, val & 0x7f], appendCheckSum: true)
    
    addToQueue(message: message)

  }

  public func readCVOpsMode(cv:Int, cvValue: UInt8, address:UInt16) {
    
    var cmd : UInt8 = 0b11100000
    
    let maskcvBit9 = 0b001000000000
    let maskcvBit8 = 0b000100000000
    
    cmd |= (cv & maskcvBit9) == maskcvBit9 ? 0b10 : 0
    cmd |= (cv & maskcvBit8) == maskcvBit8 ? 0b01 : 0
    
    cmd |= 0b00000100 // read

    let packet : [UInt8] = [
      cv17(address: address),
      cv18(address: address),
      cmd,
      UInt8(cv & 0xff),
      cvValue,
    ]
    
    immPacket(packet: packet, repeatCount: .repeat4)
    
  }
  
  public func cv17(address: UInt16) -> UInt8 {
    let temp = address + 49152
    return UInt8(temp >> 8)
  }
  
  public func cv18(address: UInt16) -> UInt8 {
    let temp = address + 49152
    return UInt8(temp & 0xff)
  }

  public func readCV(progMode:LocoNetProgrammingMode, cv:Int, address: UInt16) {
    
    guard let pcmd = progMode.command(isByte: true, isWrite: false) else {
      return
    }
    
    var hopsa : UInt8 = 0
    var lopsa : UInt8 = 0
    
    if progMode == .operations {
      lopsa = UInt8(address & 0x7f)
      hopsa = UInt8((address >> 7) & 0x7f)
    }
    
    let cvh : Int = ((cv & 0b0000001000000000) == 0b0000001000000000 ? 0b00100000 : 0x00) |
                    ((cv & 0b0000000100000000) == 0b0000000100000000 ? 0b00010000 : 0x00) |
                    ((cv & 0b0000000010000000) == 0b0000000010000000 ? 0b00000001 : 0x00)

    let message = SGLocoNetMessage(data:
        [
          SGLocoNetMessageOpcode.opcWrSlData.rawValue,
          0x0e,
          0x7c,
          pcmd,
          0x00,
          hopsa,
          lopsa,
          0x00,
          UInt8(cvh & 0x7f),
          UInt8(cv & 0x7f),
          0x00,
          0x00,
          0x00
        ],
        appendCheckSum: true)
    
    addToQueue(message: message)
    
  }
  
  public func writeCV(progMode: LocoNetProgrammingMode, cv:Int, address: Int, value: UInt8) {
    
    guard let pcmd = progMode.command(isByte: true, isWrite: true) else {
      return
    }
    
    var hopsa : UInt8 = 0
    var lopsa : UInt8 = 0
    
    if progMode == .operations {
      lopsa = UInt8(address & 0x7f)
      hopsa = UInt8(address >> 7)
    }
    
    let cvh : Int = ((cv & 0b0000001000000000) == 0b0000001000000000 ? 0b00100000 : 0x00) |
                    ((cv & 0b0000000100000000) == 0b0000000100000000 ? 0b00010000 : 0x00) |
                    ((cv & 0b0000000010000000) == 0b0000000010000000 ? 0b00000001 : 0x00) |
                    ((value & 0b10000000) == 0b10000000 ? 0b00000010 : 0x00)

    let message = SGLocoNetMessage(data:
        [
          SGLocoNetMessageOpcode.opcWrSlData.rawValue,
          0x0e,
          0x7c,
          pcmd,
          0x00,
          hopsa,
          lopsa,
          0x00,
          UInt8(cvh & 0x7f),
          UInt8(cv & 0x7f),
          UInt8(value & 0x7f),
          0x7f,
          0x7f
        ],
        appendCheckSum: true)

    addToQueue(message: message)
    
  }
  */
  // MARK: IPL
  
  public func iplDiscover() {
    
    let message = SGLocoNetMessage(data: [SGLocoNetMessageOpcode.opcPeerXfer.rawValue,
       0x14, 0x0f, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00], appendCheckSum: true)
    
    addToQueue(message: message)

  }

  public func iplDiscover(productCode:SGDigitraxProductCode) {
    
    let message = SGLocoNetMessage(data: [SGLocoNetMessageOpcode.opcPeerXfer.rawValue,
                                        0x14,
                                        0x0f,
                                        0x08,
                                        0x00,
                                        productCode.rawValue,
                                        0x00,
                                        0x00,
                                        0x00,
                                        0x00,
                                        0x00,
                                        0x01,
                                        0x00,
                                        0x00,
                                        0x00,
                                        0x00,
                                        0x00,
                                        0x00,
                                        0x00],
                                 appendCheckSum: true)
    
    addToQueue(message: message)

  }
/*
  public func getSwState(switchNumber: Int) {
    
    let lo = UInt8((switchNumber - 1) & 0x7f)
    
    let hi = UInt8((switchNumber - 1) >> 7)
    
    let message = SGLocoNetMessage(data: [SGLocoNetMessageOpcode.OPC_SW_STATE.rawValue, lo, hi], appendCheckSum: true)
    
    addToQueue(message: message)

  }
  
  public func setSw(switchNumber: Int, state:OptionSwitchState) {
    
    let sn = switchNumber - 1
    
    let lo = UInt8(sn & 0x7f)
    
    let bit : UInt8 = state == .closed ? 0x30 : 0x10
    
    let hi = UInt8(sn >> 7) | bit
    
    let message = SGLocoNetMessage(data: [SGLocoNetMessageOpcode.OPC_SW_REQ.rawValue, lo, hi], appendCheckSum: true)
    
    addToQueue(message: message)

  }
  
  public func setSwWithAck(switchNumber: Int, state:OptionSwitchState) {
    
    let sn = switchNumber - 1
    
    let lo = UInt8(sn & 0x7f)
    
    let bit : UInt8 = state == .closed ? 0x30 : 0x10
    
    let hi = UInt8(sn >> 7) | bit
    
    let message = SGLocoNetMessage(data: [SGLocoNetMessageOpcode.OPC_SW_ACK.rawValue, lo, hi], appendCheckSum: true)
    
    addToQueue(message: message)

  }
  */
  public func getLocoSlotDataP1(slotNumber: UInt8) {
    addToQueue(message: SGLocoNetMessage(data: [SGLocoNetMessageOpcode.opcRqSlData.rawValue, slotNumber, 0x00], appendCheckSum: true))
  }
  
  public func getLocoSlotDataP2(bankNumber: UInt8, slotNumber: UInt8) {
    addToQueue(message: SGLocoNetMessage(data: [SGLocoNetMessageOpcode.opcRqSlData.rawValue, slotNumber, bankNumber | 0b01000000], appendCheckSum: true))
  }

  public func getSwState(switchNumber: UInt16) {
    addToQueue(message: SGLocoNetMessage(data: [SGLocoNetMessageOpcode.opcSwState.rawValue, UInt8((switchNumber - 1) & 0x7f), UInt8((switchNumber - 1) >> 7)], appendCheckSum: true))
  }
  /*
  public func setSw(switchNumber: UInt16, state:DCCSwitchState) {
    
    let lo = UInt8((switchNumber - 1) & 0x7f)
    
    let hi = UInt8((switchNumber - 1) >> 7) | (state == .closed ? 0x30 : 0x10)
    
    addToQueue(message: SGLocoNetMessage(data: [SGLocoNetMessageOpcode.opcSwReq.rawValue, lo, hi], appendCheckSum: true))

  }
  
  public func setSwWithAck(switchNumber: UInt16, state:DCCSwitchState) {
    
    let lo = UInt8((switchNumber - 1) & 0x7f)
    
    let hi = UInt8((switchNumber - 1) >> 7) | (state == .closed ? 0x30 : 0x10)
    
    addToQueue(message: SGLocoNetMessage(data: [SGLocoNetMessageOpcode.opcSwAck.rawValue, lo, hi], appendCheckSum: true))

  }
  */
  /*
  public func getBrdOpSwState(locoNetDeviceId:LocoNetDeviceId, boardId:UInt16, switchNumber:Int) {
    
    let boardType : [LocoNetDeviceId:UInt8] = [
      .PM4 : 0,
      .PM42 : 0,
      .BDL16 : 1,
      .BDL162 : 1,
      .BDL168 : 1,
      .SE8C : 2,
      .DS64 : 3,
    ]
    
    if let bType = boardType[locoNetDeviceId] {

      let id : UInt8 = UInt8((boardId - 1) & 0xff)
    
      let high = 0b01100010 | (id >> 7)
      
      let low = id & 0x7f
      
      let bt = 0b01110000 | bType
      
      let opsw = UInt8(((switchNumber-1) << 1) & 0x7f)
      
      let message = LocoNetMessage(data: [LocoNetMessageOpcode.OPC_D0_GROUP.rawValue, high, low, bt, opsw], appendCheckSum: true)
      
      addToQueue(message: message)

    }

  }
  */
  /*
  public func setBrdOpSwState(locoNetDeviceId:LocoNetDeviceId, boardId:UInt16, switchNumber:Int, state:DCCSwitchState) {
    
    guard state != .unknown else {
      return
    }
    
    let boardType : [LocoNetDeviceId:UInt8] = [
      .PM4 : 0,
      .PM42 : 0,
      .BDL16 : 1,
      .BDL162 : 1,
      .BDL168 : 1,
      .SE8C : 2,
      .DS64 : 3,
    ]
    
    if let bType = boardType[locoNetDeviceId] {

      let id : UInt8 = UInt8((boardId - 1) & 0xff)
    
      let high = 0b01110010 | (id >> 7)
      
      let low = id & 0x7f
      
      let bt = 0b01110000 | bType
      
      let opsw = UInt8((switchNumber-1) << 1) | (state == .closed ? 1 : 0)
      
      let message = LocoNetMessage(data: [LocoNetMessageOpcode.OPC_D0_GROUP.rawValue, high, low, bt, opsw], appendCheckSum: true)
      
      addToQueue(message: message)

    }

  }
*/
  public func getOpSwDataBP1() {
    addToQueue(message: SGLocoNetMessage(data: [SGLocoNetMessageOpcode.opcRqSlData.rawValue, 0x7e, 0x00], appendCheckSum: true))
  }
  
  public func getOpSwDataP2() {
    addToQueue(message: SGLocoNetMessage(data: [SGLocoNetMessageOpcode.opcRqSlData.rawValue, 0x7f, 0x40], appendCheckSum: true))
  }
  
  public func getProgSlotDataP1() {
    addToQueue(message: SGLocoNetMessage(data: [SGLocoNetMessageOpcode.opcRqSlData.rawValue, 0x7c, 0x00], appendCheckSum: true))
  }
  
  public func getLocoSlotDataP2(slotPage: UInt8, slotNumber: UInt8) {
    addToQueue(message: SGLocoNetMessage(data: [SGLocoNetMessageOpcode.opcRqSlData.rawValue, slotNumber, slotPage | 0b01000000], appendCheckSum: true))
  }
  
  public func testIMM(address: Int) {
    
    let add = address - 1
    
    var adr1 = ((add & 0b11) << 1) | 0b10001000
    
    adr1 |= ((~(add >> 8) & 0x07) << 4)
    
    let payload : [UInt8] = [
      UInt8(((add >> 2) & 0b00111111) | 0b10000000),
      UInt8(adr1),
    ]
    
    immPacket(packet: payload, repeatCount: .repeat2)
    
  }
/*
  public func setSwIMM(address: Int, state:DCCSwitchState, isOutputOn:Bool) {
    
    let add = address - 1
    
    var adr1 = ((add & 0b11) << 1) | 0b10000000
    
    adr1 |= ((state == .closed) ? 1 : 0)
    
    adr1 |= (isOutputOn ? 0b1000 : 0)
    
    adr1 |= ((~(add >> 8) & 0x07) << 4)
    
    let payload : [UInt8] = [
      UInt8((((add >> 2) + 1) & 0b00111111) | 0b10000000),
      UInt8(adr1),
    ]
    
    immPacket(packet: payload, repeatCount: .repeat2)
    
  }
  */
  public func getQuerySlot(querySlot: Int) {
    
    guard querySlot > 0 && querySlot <= 5 else {
      return
    }
    
    let slotPage = 1
    let slotNumber = 0x78 + querySlot - 1
    
    let message = SGLocoNetMessage(data: [SGLocoNetMessageOpcode.opcRqSlData.rawValue, UInt8(slotNumber), UInt8(slotPage) | 0b01000000], appendCheckSum: true)
    
    addToQueue(message: message)

  }
  
  public func getRouteTableInfoA() {
    
    let message = SGLocoNetMessage(data: [SGLocoNetMessageOpcode.opcWrSlDataP2.rawValue,
    0x10, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00], appendCheckSum: true)
    
    addToQueue(message: message)
    
  }

  public func getRouteTablePage(routeNumber: Int, pageNumber: Int, pagesPerRoute: Int ) {
    
    let shift = pagesPerRoute / 2
    
    let combined : Int = pageNumber | (routeNumber - 1) << shift
    
    let pageL = UInt8(combined & 0x7f)
    let pageH = UInt8(combined >> 7)
    
    let message = SGLocoNetMessage(data: [SGLocoNetMessageOpcode.opcWrSlDataP2.rawValue,
    0x10, 0x01, 0x02, pageL, pageH, 0x0f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f], appendCheckSum: true)
    
    addToQueue(message: message)
    
  }
/*
  public func setRouteTablePages(routeNumber: Int, route: [SwitchRoute], pagesPerRoute: Int ) {
    
    let shift = pagesPerRoute / 2
    
    for pageNumber in 0...pagesPerRoute - 1 {
      
      let combined : Int = pageNumber | (routeNumber - 1) << shift
      
      let pageL = UInt8(combined & 0x7f)
      let pageH = UInt8(combined >> 7)
      
      var data : [UInt8] = [LocoNetMessageOpcode.OPC_WR_SL_DATA_P2.rawValue,
                            0x10, 0x01, 0x03, pageL, pageH, 0x0f]
      
      for entryNumber in (pageNumber * 4)...(pageNumber * 4 + 3) {
        let switchNumber = route[entryNumber].switchNumber - 1
        var part1 = switchNumber & 0x7f
        let mask = route[entryNumber].switchState == .closed ? 0b100000 : 0
        var part2 = (switchNumber >> 7) | 0b10000 | mask
        if route[entryNumber].switchNumber == 0x7f && route[entryNumber].switchState == .unknown {
          part1 = 0x7f
          part2 = 0x7f
        }
        data.append(UInt8(part1))
        data.append(UInt8(part2))
      }
      
      let message = LocoNetMessage(data: data, appendCheckSum: true)
      
      addToQueue(message: message)
      
    }
    
  }
*/
  public func getRosterEntry(recordNumber: Int) {
    addToQueue(message: SGLocoNetMessage(data: [SGLocoNetMessageOpcode.opcWrSlDataP2.rawValue, 0x10, 0x00, 0x02, UInt8(recordNumber & 0x1f), 0x00, 0x0f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00], appendCheckSum: true))
  }
  
  public func setRosterEntry(entryNumber:Int, extendedAddress1:Int, primaryAddress1:Int,extendedAddress2:Int, primaryAddress2:Int) {
    
    let low1 = UInt8(extendedAddress1 & 0x7f)
    let high1 = UInt8(extendedAddress1 >> 7)
    let primary1 = UInt8(primaryAddress1)

    let low2 = UInt8(extendedAddress2 & 0x7f)
    let high2 = UInt8(extendedAddress2 >> 7)
    let primary2 = UInt8(primaryAddress2)
    
    let flag : UInt8 = (entryNumber & 0x01) == 0x01 ? 0x04 : 0x00

    let message = SGLocoNetMessage(data: [SGLocoNetMessageOpcode.opcWrSlDataP2.rawValue,
    0x10, 0x00, 0x43, UInt8(entryNumber >> 1), 0x00, flag, low1, high1, primary1, 0x00, low2, high2, primary2, 0x00], appendCheckSum: true)
    
    addToQueue(message: message)
    
  }
  
  public func setOpSwDataAP1(state:Bool) {
    
    var data = [UInt8](repeating: 0, count: 13)
    
    data[0] = SGLocoNetMessageOpcode.opcWrSlData.rawValue
    data[1] = 14
    data[2] = 0x7f
    
    for byte in 3...13 {
      data[byte] = state ? 0x7f : 0x00
    }
    
    let message = SGLocoNetMessage(data: data, appendCheckSum: true)
    
    addToQueue(message: message)

  }

  public func setOpSwDataBP1(state:Bool) {
    
    var data = [UInt8](repeating: 0, count: 13)
    
    data[0] = SGLocoNetMessageOpcode.opcWrSlData.rawValue
    data[1] = 14
    data[2] = 0x7e
    
    for byte in 3...13 {
      data[byte] = state ? 0x7f : 0x00
    }
    
    let message = SGLocoNetMessage(data: data, appendCheckSum: true)
    
    addToQueue(message: message)

  }

  public func setLocoSlotDataP1(slotData: [UInt8]) {
    
    var data = [UInt8](repeating: 0, count: 13)
    
    data[0] = SGLocoNetMessageOpcode.opcWrSlData.rawValue
    data[1] = 14
    
    for index in 0..<slotData.count {
      data[index + 2] = slotData[index]
    }
    
    addToQueue(message: SGLocoNetMessage(data: data, appendCheckSum: true))

  }
  
  public func setLocoSlotDataP2(slotData: [UInt8]) {
    
    var data = [UInt8](repeating: 0, count: 20)
    
    data[0] = SGLocoNetMessageOpcode.opcWrSlDataP2.rawValue
    data[1] = 21
    
    for index in 0..<slotData.count {
      data[index + 2] = slotData[index]
    }
    
    addToQueue(message: SGLocoNetMessage(data: data, appendCheckSum: true))

  }
  
  public func resetQuerySlot4() {
    addToQueue(message: SGLocoNetMessage(data: [SGLocoNetMessageOpcode.opcWrSlDataP2.rawValue, 0x15, 0x19, 0x7b, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00], appendCheckSum: true))
  }

  public func clearLocoSlotDataP1(slotNumber:Int) {
    addToQueue(message: SGLocoNetMessage(data: [SGLocoNetMessageOpcode.opcWrSlData.rawValue, 0x0e, UInt8(slotNumber), 0b00000011, 0x00, 0x00, 0b00100000, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00], appendCheckSum: true))
  }
  
  public func clearLocoSlotDataP2(slotPage: Int, slotNumber:Int) {
    addToQueue(message: SGLocoNetMessage(data: [SGLocoNetMessageOpcode.opcWrSlDataP2.rawValue, 0x15, UInt8(slotPage), UInt8(slotNumber), 0b00000011, 0x00, 0x00, 0x00, 0x00, 0x00, 0b00100000, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00], appendCheckSum: true))
  }
  
  public func getInterfaceData() {
    addToQueue(message: SGLocoNetMessage(data: [SGLocoNetMessageOpcode.opcBusy.rawValue], appendCheckSum: true))
  }
  
  public func findReceiver() {
    addToQueue(message: SGLocoNetMessage(data: [SGLocoNetMessageOpcode.opcDFGroup.rawValue, 0x00, 0x00, 0x00, 0x00], appendCheckSum: true))
  }
  
  public func setLocoNetID(locoNetID: Int) {
    addToQueue(message: SGLocoNetMessage(data: [SGLocoNetMessageOpcode.opcDFGroup.rawValue, 0x40, 0x1f, UInt8(locoNetID & 0x7), 0x00], appendCheckSum: true))
  }
  
  public func getDuplexData() {
    addToQueue(message: SGLocoNetMessage(data: [SGLocoNetMessageOpcode.opcPeerXfer.rawValue, 0x14, 0x03, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00], appendCheckSum: true))
  }
  
  public func setDuplexChannelNumber(channelNumber: Int) {
    
    let cn = UInt8(channelNumber)
    
    let pxct1 : UInt8 = (cn & 0b10000000) == 0b10000000 ? 0b00000001 : 0
    
    addToQueue(message: SGLocoNetMessage(data: [SGLocoNetMessageOpcode.opcPeerXfer.rawValue, 0x14, 0x02, 0x00, pxct1, cn, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00], appendCheckSum: true))
    
  }
  
  public func setDuplexGroupID(groupID: Int) {
    
    let gid = UInt8(groupID)
    
    let pxct1 : UInt8 = (gid & 0b10000000) == 0b10000000 ? 0b00000001 : 0
    
    addToQueue(message: SGLocoNetMessage(data: [SGLocoNetMessageOpcode.opcPeerXfer.rawValue, 0x14, 0x04, 0x00, pxct1, gid, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00], appendCheckSum: true))
    
  }
  
  public func getDuplexGroupID() {
    addToQueue(message: SGLocoNetMessage(data: [SGLocoNetMessageOpcode.opcPeerXfer.rawValue, 0x14, 0x04, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00], appendCheckSum: true))
  }
  
  public func getDuplexSignalStrength(duplexGroupChannel: Int) {
    addToQueue(message: SGLocoNetMessage(data: [SGLocoNetMessageOpcode.opcPeerXfer.rawValue, 0x14, 0x10, 0x08, 0x00, UInt8(duplexGroupChannel & 0x7f), 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00], appendCheckSum: true))
  }
  
  public func setDuplexSignalStrength(duplexGroupChannel: Int, signalStrength:Int) {
    
    var pxct1 : UInt8 = 0
    pxct1 |= ((duplexGroupChannel & 0b10000000) == 0b10000000) ? 0b00000001 : 0
    pxct1 |= ((signalStrength     & 0b10000000) == 0b10000000) ? 0b00000010 : 0

    addToQueue(message: SGLocoNetMessage(data: [SGLocoNetMessageOpcode.opcPeerXfer.rawValue, 0x14, 0x10, 0x10, pxct1, UInt8(duplexGroupChannel & 0x7f), UInt8(signalStrength & 0x7f), 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00], appendCheckSum: true))
    
  }
  public func setDuplexGroupName(groupName: String) {
    
    let data = String((groupName + "        ").prefix(8)).data(using: .ascii)!
    
    var pxct1 : UInt8 = 0
    
    pxct1 |= (data[0] & 0b10000000) == 0b10000000 ? 0b00000001 : 0
    pxct1 |= (data[1] & 0b10000000) == 0b10000000 ? 0b00000010 : 0
    pxct1 |= (data[2] & 0b10000000) == 0b10000000 ? 0b00000100 : 0
    pxct1 |= (data[3] & 0b10000000) == 0b10000000 ? 0b00001000 : 0

    var pxct2 : UInt8 = 0
    
    pxct2 |= (data[4] & 0b10000000) == 0b10000000 ? 0b00000001 : 0
    pxct2 |= (data[5] & 0b10000000) == 0b10000000 ? 0b00000010 : 0
    pxct2 |= (data[6] & 0b10000000) == 0b10000000 ? 0b00000100 : 0
    pxct2 |= (data[7] & 0b10000000) == 0b10000000 ? 0b00001000 : 0
    
    addToQueue(message: SGLocoNetMessage(data: [SGLocoNetMessageOpcode.opcPeerXfer.rawValue, 0x14, 0x03, 0x00, pxct1, data[0], data[1], data[2], data[3], pxct2, data[4], data[5], data[6], data[7], 0x00, 0x00, 0x00, 0x00, 0x00], appendCheckSum: true))
    
  }
  
  public func setDuplexPassword(password: String) {
    
    let data = String((password + "0000").prefix(4)).data(using: .ascii)!
    
    var pxct1 : UInt8 = 0
    
    pxct1 |= (data[0] & 0b10000000) == 0b10000000 ? 0b00000001 : 0
    pxct1 |= (data[1] & 0b10000000) == 0b10000000 ? 0b00000010 : 0
    pxct1 |= (data[2] & 0b10000000) == 0b10000000 ? 0b00000100 : 0
    pxct1 |= (data[3] & 0b10000000) == 0b10000000 ? 0b00001000 : 0

    addToQueue(message: SGLocoNetMessage(data: [SGLocoNetMessageOpcode.opcPeerXfer.rawValue, 0x14, 0x07, 0x00, pxct1, data[0] & 0x7f, data[1] & 0x7f, data[2] & 0x7f, data[3] & 0x7f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00], appendCheckSum: true))
    
  }
  /*
  public func setProgMode(mode: ProgrammerMode, locoNetDeviceId:LocoNetDeviceId, isStandAloneLocoNet:Bool) {
    
    var prMode = UInt8(mode.rawValue)
    
    if mode == .MS100 && (locoNetDeviceId == .PR3 || locoNetDeviceId == .PR3XTRA) && isStandAloneLocoNet {
      prMode |= 0b10
    }
    
    let message = LocoNetMessage(data: [LocoNetMessageOpcode.OPC_PR_MODE.rawValue, 0x10, prMode, 0x00, 0x00], appendCheckSum: true)
    
    addToQueue(message: message)

  }
  */
  /*
  public func writeCV(progMode: LocoNetProgrammingMode, cv:Int, address: Int, value: UInt16) {
    
    guard let pcmd = progMode.command(isByte: true, isWrite: true) else {
      return
    }
    
    var hopsa : UInt8 = 0
    var lopsa : UInt8 = 0
    
    if progMode == .operations {
      lopsa = UInt8(address & 0x7f)
      hopsa = UInt8(address >> 7)
    }
    
    let cvAdjusted = cv - 1
    
    let cvh : Int = ((cvAdjusted & 0b0000001000000000) == 0b0000001000000000 ? 0b00100000 : 0x00) |
                    ((cvAdjusted & 0b0000000100000000) == 0b0000000100000000 ? 0b00010000 : 0x00) |
                    ((cvAdjusted & 0b0000000010000000) == 0b0000000010000000 ? 0b00000001 : 0x00) |
                    ((value & 0b10000000) == 0b10000000 ? 0b00000010 : 0x00)

    let message = LocoNetMessage(data:
        [
          LocoNetMessageOpcode.OPC_WR_SL_DATA.rawValue,
          0x0e,
          0x7c,
          pcmd,
          0x00,
          hopsa,
          lopsa,
          0x00,
          UInt8(cvh & 0x7f),
          UInt8(cvAdjusted & 0x7f),
          UInt8(value & 0x7f),
          0x7f,
          0x7f
        ],
        appendCheckSum: true)

    addToQueue(message: message)
    
  }
  */
  /*
  public func locoDirF0F4P2(slotNumber: Int, slotPage: Int, direction:LocomotiveDirection, functions: UInt64) {
    
    let slot = UInt8(slotNumber & 0x7f)
    
    let page = 0b00100000 | UInt8(slotPage & 0x07)
    
    var dirf : UInt8 = 0
    
    dirf |= direction == .reverse        ? 0b00100000 : 0b00000000
    dirf |= functions & maskF0 == maskF0 ? 0b00010000 : 0b00000000
    dirf |= functions & maskF1 == maskF1 ? 0b00000001 : 0b00000000
    dirf |= functions & maskF2 == maskF2 ? 0b00000010 : 0b00000000
    dirf |= functions & maskF3 == maskF3 ? 0b00000100 : 0b00000000
    dirf |= functions & maskF4 == maskF4 ? 0b00001000 : 0b00000000
    
    let message = LocoNetMessage(data: [LocoNetMessageOpcode.OPC_D4_GROUP.rawValue, page, slot, 0x06, dirf], appendCheckSum: true)
    
    addToQueue(message: message)
    
  }
  
  public func locoF5F11P2(slotNumber: Int, slotPage: Int, functions: UInt64) {
    
    let slot = UInt8(slotNumber & 0x7f)
    
    let page = 0b00100000 | UInt8(slotPage & 0x07)
    
    var dirf : UInt8 = 0
    
    dirf |= functions & maskF5  == maskF5  ? 0b00000001 : 0b00000000
    dirf |= functions & maskF6  == maskF6  ? 0b00000010 : 0b00000000
    dirf |= functions & maskF7  == maskF7  ? 0b00000100 : 0b00000000
    dirf |= functions & maskF8  == maskF8  ? 0b00001000 : 0b00000000
    dirf |= functions & maskF9  == maskF9  ? 0b00010000 : 0b00000000
    dirf |= functions & maskF10 == maskF10 ? 0b00100000 : 0b00000000
    dirf |= functions & maskF11 == maskF11 ? 0b01000000 : 0b00000000

    let message = LocoNetMessage(data: [LocoNetMessageOpcode.OPC_D4_GROUP.rawValue, page, slot, 0x07, dirf], appendCheckSum: true)
    
    addToQueue(message: message)
    
  }
  
  public func locoF12F20F28P2(slotNumber: Int, slotPage: Int, functions: UInt64) {
    
    let slot = UInt8(slotNumber & 0x7f)
    
    let page = 0b00100000 | UInt8(slotPage & 0x07)
    
    var dirf : UInt8 = 0
    
    dirf |= functions & maskF12 == maskF12  ? 0b00000001 : 0b00000000
    dirf |= functions & maskF20 == maskF20  ? 0b00000010 : 0b00000000
    dirf |= functions & maskF28 == maskF28  ? 0b00000100 : 0b00000000
 
    let message = LocoNetMessage(data: [LocoNetMessageOpcode.OPC_D4_GROUP.rawValue, page, slot, 0x05, dirf], appendCheckSum: true)
    
    addToQueue(message: message)
    
  }
  
  public func locoF13F19P2(slotNumber: Int, slotPage: Int, functions: UInt64) {
    
    let slot = UInt8(slotNumber & 0x7f)
    
    let page = 0b00100000 | UInt8(slotPage & 0x07)
    
    var dirf : UInt8 = 0
    
    dirf |= functions & maskF13 == maskF13 ? 0b00000001 : 0b00000000
    dirf |= functions & maskF14 == maskF14 ? 0b00000010 : 0b00000000
    dirf |= functions & maskF15 == maskF15 ? 0b00000100 : 0b00000000
    dirf |= functions & maskF16 == maskF16 ? 0b00001000 : 0b00000000
    dirf |= functions & maskF17 == maskF17 ? 0b00010000 : 0b00000000
    dirf |= functions & maskF18 == maskF18 ? 0b00100000 : 0b00000000
    dirf |= functions & maskF19 == maskF19 ? 0b01000000 : 0b00000000

    let message = LocoNetMessage(data: [LocoNetMessageOpcode.OPC_D4_GROUP.rawValue, page, slot, 0x08, dirf], appendCheckSum: true)
    
    addToQueue(message: message)
    
  }

  public func locoF21F27P2(slotNumber: Int, slotPage: Int, functions: UInt64) {
    
    let slot = UInt8(slotNumber & 0x7f)
    
    let page = 0b00100000 | UInt8(slotPage & 0x07)
    
    var dirf : UInt8 = 0
    
    dirf |= functions & maskF21 == maskF21 ? 0b00000001 : 0b00000000
    dirf |= functions & maskF22 == maskF22 ? 0b00000010 : 0b00000000
    dirf |= functions & maskF23 == maskF23 ? 0b00000100 : 0b00000000
    dirf |= functions & maskF24 == maskF24 ? 0b00001000 : 0b00000000
    dirf |= functions & maskF25 == maskF25 ? 0b00010000 : 0b00000000
    dirf |= functions & maskF26 == maskF26 ? 0b00100000 : 0b00000000
    dirf |= functions & maskF27 == maskF27 ? 0b01000000 : 0b00000000

    let message = LocoNetMessage(data: [LocoNetMessageOpcode.OPC_D4_GROUP.rawValue, page, slot, 0x09, dirf], appendCheckSum: true)
    
    addToQueue(message: message)
    
  }
  
  public func locoSpdP2(slotNumber: Int, slotPage: Int, speed: UInt8) {
    
    let slot = UInt8(slotNumber & 0x7f)
    
    let page = UInt8(slotPage & 0x07) | 0b00100000
    
    let spd = speed & 0x7f
    
    let message = LocoNetMessage(data: [LocoNetMessageOpcode.OPC_D4_GROUP.rawValue, page, slot, 0x04, spd], appendCheckSum: true)
    
    addToQueue(message: message)

  }
  */
  public func getFastClock() {
    addToQueue(message: SGLocoNetMessage(data: [SGLocoNetMessageOpcode.opcRqSlData.rawValue, 0x7b, 0x00], appendCheckSum: true))
  }
  /*
  public func setFastClock(date:Date, scaleFactor:SGLocoNetFastClockScaleFactor) {
    
    let comp = date.dateComponents
    
    let data : [UInt8] =
    [
      LocoNetMessageOpcode.OPC_WR_SL_DATA.rawValue,
      0x0e,
      0x7b,
      UInt8(scaleFactor.rawValue),
      0x7f,
      0x7f,
      UInt8(comp.minute! + 68),
      0b01000111,
      UInt8(comp.hour! + 104),
      0x01,
      0x40,
      0x7f,
      0x7f,
    ]
    
    let message = LocoNetMessage(data: data, appendCheckSum: true)

    addToQueue(message: message)

  }
*/
  /*
  public func iplSetup(dmf: DMF) {
  
    var pxct1 : UInt8 = 0b01000000
    
    pxct1 |= (dmf.manufacturerCode & 0b10000000) == 0 ? 0b00000000 : 0b00000001
    pxct1 |= (dmf.productCode      & 0b10000000) == 0 ? 0b00000000 : 0b00000010
    pxct1 |= (dmf.hardwareVersion  & 0b10000000) == 0 ? 0b00000000 : 0b00000100
    pxct1 |= (dmf.softwareVersion  & 0b10000000) == 0 ? 0b00000000 : 0b00001000
    
    var pxct2 : UInt8 = 0b00000000

    pxct2 |= (dmf.options               & 0b10000000) == 0 ? 0b00000000 : 0b00000001
    pxct2 |= (dmf.numberOfBlocksToErase & 0b10000000) == 0 ? 0b00000000 : 0b00000100

    let data : [UInt8] = [
      
      LocoNetMessageOpcode.OPC_PEER_XFER.rawValue,
      0x10,
      0x7f,
      0x7f,
      0x7f,
      pxct1,
      (dmf.manufacturerCode & 0x7f),
      (dmf.productCode & 0x7f),
      (dmf.hardwareVersion & 0x7f),
      (dmf.softwareVersion & 0x7f),
      pxct2,
      (dmf.options & 0x7f),
      0x00,
      (dmf.numberOfBlocksToErase & 0x7f),
      0x00
      
    ]
    
    let message = LocoNetMessage(data: data, appendCheckSum: true)
    
    addToQueue(message: message)
    
  }
  
  public func iplDataLoad(D1:UInt8, D2:UInt8, D3:UInt8, D4:UInt8, D5:UInt8, D6: UInt8, D7: UInt8, D8: UInt8) {
    
    var pxct1 : UInt8 = 0b01000000
    
    pxct1 |= (D1 & 0b10000000) == 0 ? 0b00000000 : 0b00000001
    pxct1 |= (D2 & 0b10000000) == 0 ? 0b00000000 : 0b00000010
    pxct1 |= (D3 & 0b10000000) == 0 ? 0b00000000 : 0b00000100
    pxct1 |= (D4 & 0b10000000) == 0 ? 0b00000000 : 0b00001000

    var pxct2 : UInt8 = 0b00100000
    
    pxct2 |= (D5 & 0b10000000) == 0 ? 0b00000000 : 0b00000001
    pxct2 |= (D6 & 0b10000000) == 0 ? 0b00000000 : 0b00000010
    pxct2 |= (D7 & 0b10000000) == 0 ? 0b00000000 : 0b00000100
    pxct2 |= (D8 & 0b10000000) == 0 ? 0b00000000 : 0b00001000

    let data : [UInt8] = [
    
      LocoNetMessageOpcode.OPC_PEER_XFER.rawValue,
      0x10,
      0x7f,
      0x7f,
      0x7f,
      pxct1,
      D1 & 0x7f,
      D2 & 0x7f,
      D3 & 0x7f,
      D4 & 0x7f,
      pxct2,
      D5 & 0x7f,
      D6 & 0x7f,
      D7 & 0x7f,
      D8 & 0x7f
    ]
    
    let message = LocoNetMessage(data: data, appendCheckSum: true)
    
    addToQueue(message: message)
    
  }
  
  public func iplEndLoad() {
    
    let pxct1 : UInt8 = 0b01000000
    
    let pxct2 : UInt8 = 0b01000000
    
    let data : [UInt8] = [
    
      LocoNetMessageOpcode.OPC_PEER_XFER.rawValue,
      0x10,
      0x7f,
      0x7f,
      0x7f,
      pxct1,
      0x00,
      0x00,
      0x00,
      0x00,
      pxct2,
      0x00,
      0x00,
      0x00,
      0x00
    ]
    
    let message = LocoNetMessage(data: data, appendCheckSum: true)
    
    addToQueue(message: message)
    
  }

  public func iplSetAddr(loadAddress: Int) {
    
    let high : UInt8 = UInt8(loadAddress >> 16)
    
    let mid : UInt8 = UInt8((loadAddress & 0x00ff00) >> 8)
    
    let low : UInt8 = UInt8(loadAddress & 0xff)
    
    var pxct1 : UInt8 = 0b01000000
    
    pxct1 |= (high & 0b10000000) == 0 ? 0b00000000 : 0b00000001
    pxct1 |= (mid  & 0b10000000) == 0 ? 0b00000000 : 0b00000010
    pxct1 |= (low  & 0b10000000) == 0 ? 0b00000000 : 0b00000100

    let pxct2 : UInt8 = 0b00010000
    
    let data : [UInt8] = [
    
      LocoNetMessageOpcode.OPC_PEER_XFER.rawValue,
      0x10,
      0x7f,
      0x7f,
      0x7f,
      pxct1,
      high & 0x7f,
      mid & 0x7f,
      low & 0x7f,
      0x00,
      pxct2,
      0x00,
      0x00,
      0x00,
      0x00
    ]
    
    let message = LocoNetMessage(data: data, appendCheckSum: true)
    
    addToQueue(message: message)
    
  }
*/
}
