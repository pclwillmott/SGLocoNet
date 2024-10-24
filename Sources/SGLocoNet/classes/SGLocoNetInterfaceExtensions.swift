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
  
  public func sendMessage(message:SGLocoNetMessage) {
    addToQueue(message: message)
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
    
    let message = SGLocoNetMessage(data: [SGLocoNetOpcode.OPC_IMM_PACKET.rawValue, 0x0b, 0x7f, 0x54, high, addA, addB, mode, cv & 0x7f, val & 0x7f])
    
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
          SGLocoNetOpcode.opcWrSlData.rawValue,
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
          SGLocoNetOpcode.opcWrSlData.rawValue,
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
      
      let message = LocoNetMessage(data: [LocoNetMessageOpcode.OPC_D0_GROUP.rawValue, high, low, bt, opsw])
      
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
      
      let message = LocoNetMessage(data: [LocoNetMessageOpcode.OPC_D0_GROUP.rawValue, high, low, bt, opsw])
      
      addToQueue(message: message)

    }

  }
*/

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
  /*
  public func getRouteTableInfoA() {
    
    let message = SGLocoNetMessage(data: [SGLocoNetOpcode.opcWrSlDataP2.rawValue,
    0x10, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
    
    addToQueue(message: message)
    
  }

  public func getRouteTablePage(routeNumber: Int, pageNumber: Int, pagesPerRoute: Int ) {
    
    let shift = pagesPerRoute / 2
    
    let combined : Int = pageNumber | (routeNumber - 1) << shift
    
    let pageL = UInt8(combined & 0x7f)
    let pageH = UInt8(combined >> 7)
    
    let message = SGLocoNetMessage(data: [SGLocoNetOpcode.opcWrSlDataP2.rawValue,
    0x10, 0x01, 0x02, pageL, pageH, 0x0f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f])
    
    addToQueue(message: message)
    
  }
   */
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
      
      let message = LocoNetMessage(data: data)
      
      addToQueue(message: message)
      
    }
    
  }
*/
  /*
  public func getRosterEntry(recordNumber: Int) {
    addToQueue(message: SGLocoNetMessage(data: [SGLocoNetOpcode.opcWrSlDataP2.rawValue, 0x10, 0x00, 0x02, UInt8(recordNumber & 0x1f), 0x00, 0x0f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]))
  }
  
  public func setRosterEntry(entryNumber:Int, extendedAddress1:Int, primaryAddress1:Int,extendedAddress2:Int, primaryAddress2:Int) {
    
    let low1 = UInt8(extendedAddress1 & 0x7f)
    let high1 = UInt8(extendedAddress1 >> 7)
    let primary1 = UInt8(primaryAddress1)

    let low2 = UInt8(extendedAddress2 & 0x7f)
    let high2 = UInt8(extendedAddress2 >> 7)
    let primary2 = UInt8(primaryAddress2)
    
    let flag : UInt8 = (entryNumber & 0x01) == 0x01 ? 0x04 : 0x00

    let message = SGLocoNetMessage(data: [SGLocoNetOpcode.opcWrSlDataP2.rawValue,
    0x10, 0x00, 0x43, UInt8(entryNumber >> 1), 0x00, flag, low1, high1, primary1, 0x00, low2, high2, primary2, 0x00])
    
    addToQueue(message: message)
    
  }
  */

  
  /*
  public func setProgMode(mode: ProgrammerMode, locoNetDeviceId:LocoNetDeviceId, isStandAloneLocoNet:Bool) {
    
    var prMode = UInt8(mode.rawValue)
    
    if mode == .MS100 && (locoNetDeviceId == .PR3 || locoNetDeviceId == .PR3XTRA) && isStandAloneLocoNet {
      prMode |= 0b10
    }
    
    let message = LocoNetMessage(data: [LocoNetMessageOpcode.OPC_PR_MODE.rawValue, 0x10, prMode, 0x00, 0x00])
    
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
    
    let message = LocoNetMessage(data: [LocoNetMessageOpcode.OPC_D4_GROUP.rawValue, page, slot, 0x06, dirf])
    
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

    let message = LocoNetMessage(data: [LocoNetMessageOpcode.OPC_D4_GROUP.rawValue, page, slot, 0x07, dirf])
    
    addToQueue(message: message)
    
  }
  
  public func locoF12F20F28P2(slotNumber: Int, slotPage: Int, functions: UInt64) {
    
    let slot = UInt8(slotNumber & 0x7f)
    
    let page = 0b00100000 | UInt8(slotPage & 0x07)
    
    var dirf : UInt8 = 0
    
    dirf |= functions & maskF12 == maskF12  ? 0b00000001 : 0b00000000
    dirf |= functions & maskF20 == maskF20  ? 0b00000010 : 0b00000000
    dirf |= functions & maskF28 == maskF28  ? 0b00000100 : 0b00000000
 
    let message = LocoNetMessage(data: [LocoNetMessageOpcode.OPC_D4_GROUP.rawValue, page, slot, 0x05, dirf])
    
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

    let message = LocoNetMessage(data: [LocoNetMessageOpcode.OPC_D4_GROUP.rawValue, page, slot, 0x08, dirf])
    
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

    let message = LocoNetMessage(data: [LocoNetMessageOpcode.OPC_D4_GROUP.rawValue, page, slot, 0x09, dirf])
    
    addToQueue(message: message)
    
  }
  
  public func locoSpdP2(slotNumber: Int, slotPage: Int, speed: UInt8) {
    
    let slot = UInt8(slotNumber & 0x7f)
    
    let page = UInt8(slotPage & 0x07) | 0b00100000
    
    let spd = speed & 0x7f
    
    let message = LocoNetMessage(data: [LocoNetMessageOpcode.OPC_D4_GROUP.rawValue, page, slot, 0x04, spd])
    
    addToQueue(message: message)

  }
  */
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
    
    let message = LocoNetMessage(data: data)

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
    
    let message = LocoNetMessage(data: data)
    
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
    
    let message = LocoNetMessage(data: data)
    
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
    
    let message = LocoNetMessage(data: data)
    
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
    
    let message = LocoNetMessage(data: data)
    
    addToQueue(message: message)
    
  }
*/
}
