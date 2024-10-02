import Testing
@testable import SGLocoNet
@testable import SGDCC

@Test func testCommandStationCommands() async throws {
  // Write your test here and use APIs like `#expect(...)` to check expected conditions.
  
  var message : SGLocoNetMessage? = SGLocoNetMessage.powerOn()
  
  #expect(message != nil)
  
  if let message {
    #expect(message.isCheckSumOK)
    #expect(message.message == [0x83, 0x7c])
    #expect(message.messageType == .pwrOn)
  }
  
  message = SGLocoNetMessage.powerOff()
  
  #expect(message != nil)
  
  if let message {
    #expect(message.isCheckSumOK)
    #expect(message.message == [0x82, 0x7d])
    #expect(message.messageType == .pwrOff)
  }
  
  message = SGLocoNetMessage.getOpSwDataAP1()
  
  #expect(message != nil)
  
  if let message {
    #expect(message.isCheckSumOK)
    #expect(message.message == [0xbb, 0x7f, 0x00, 0x3b])
    #expect(message.messageType == .getOpSwDataAP1)
  }
  
  message = SGLocoNetMessage.getOpSwDataBP1()
  
  #expect(message != nil)
  
  if let message {
    #expect(message.isCheckSumOK)
    #expect(message.message == [0xbb, 0x7e, 0x00, 0x3a])
    #expect(message.messageType == .getOpSwDataBP1)
  }
  
  var dccPacket : SGDCCPacket? = SGDCCPacket.digitalDecoderIdlePacket()
  
  message = SGLocoNetMessage.immPacket(dccPacket: dccPacket!, repeatCount: .repeatContinuous)
  
  #expect(message != nil)

  #expect(message?.dccPacket != nil)

  if let message {
    #expect(message.isCheckSumOK)
    #expect(dccPacket!.packet == message.dccPacket!.packet)
    #expect(message.messageType == .immPacket)
    #expect(message.dccPacket!.packetType == .digitalDecoderIdlePacket)
    #expect(message.immPacketRepeatCount == .repeatContinuous)
  }

  dccPacket = SGDCCPacket.speedAndDirection(longAddress: 1024, speed126Steps: 127, direction: .forward)
  
  message = SGLocoNetMessage.immPacket(dccPacket: dccPacket!, repeatCount: .repeat7)
  
  #expect(message != nil)

  #expect(message?.dccPacket != nil)

  if let message {
    #expect(message.isCheckSumOK)
    #expect(dccPacket!.packet == message.dccPacket!.packet)
    #expect(message.messageType == .immPacket)
    #expect(message.dccPacket!.packetType == .speedStepControl128)
    #expect(message.immPacketRepeatCount == .repeat7)
  }
  
  message = SGLocoNetMessage.immPacket(packet: [0x81, 0x82, 0x83, 0x84, 0x85], repeatCount: .repeat1)
  
  #expect(message != nil)

  if let message {
    #expect(message.messageType == .immPacket)
    #expect(message.isCheckSumOK)
    #expect(message.immPacketRepeatCount == .repeat1)
    #expect(message.message[5] == 0x81 & 0x7f)
    #expect(message.message[6] == 0x82 & 0x7f)
    #expect(message.message[7] == 0x83 & 0x7f)
    #expect(message.message[8] == 0x84 & 0x7f)
    #expect(message.message[9] == 0x85 & 0x7f)
    #expect(message.message[4] == 0b00011111)
    #expect(message.dccPacket!.packetType == .unknown)
  }

}

@Test func testLocomotiveControlCommands() async throws {
  
  var message = SGLocoNetMessage.getLocoSlotDataP1(address: 0)
  
  #expect(message == nil)

  message = SGLocoNetMessage.getLocoSlotDataP1(address: 20000)
  
  #expect(message == nil)
  
  for address in SGLocoNetMessage.locoNetAddressRange {
    
    message = SGLocoNetMessage.getLocoSlotDataP1(address: address)
    
    #expect(message != nil)
    
    if let message {
      #expect(message.messageType == .getLocoSlotDataAdrP1)
      #expect(message.locomotiveAddress == address)
    }

  }

  message = SGLocoNetMessage.getLocoSlotDataP2(address: 0)
  
  #expect(message == nil)

  message = SGLocoNetMessage.getLocoSlotDataP2(address: 20000)
  
  #expect(message == nil)
  
  for address in SGLocoNetMessage.locoNetAddressRange {
    
    message = SGLocoNetMessage.getLocoSlotDataP2(address: address)
    
    #expect(message != nil)
    
    if let message {
      #expect(message.messageType == .getLocoSlotDataAdrP2)
      #expect(message.locomotiveAddress == address)
    }

  }
  
  message = SGLocoNetMessage.setLocoSlotStat1P1(slotNumber: 0, stat1: 0)

  #expect(message == nil)

  message = SGLocoNetMessage.setLocoSlotStat1P1(slotNumber: 127, stat1: 0)

  #expect(message == nil)
  
  message = SGLocoNetMessage.setLocoSlotStat1P1(slotNumber: 127, stat1: 0xff)

  #expect(message == nil)
  
  for slotNumber in SGLocoNetMessage.slotRange {
    
    message = SGLocoNetMessage.setLocoSlotStat1P1(slotNumber: slotNumber, stat1: 0x5b)
    
    #expect(message != nil)
    
    if let message {
      #expect(message.messageType == .setLocoSlotStat1P1)
      #expect(message.slotNumber == slotNumber)
      #expect(message.slotStatus1 == 0x5b)
    }

  }

  message = SGLocoNetMessage.setLocoSlotStat1P2(slotBank: 4, slotNumber: 1, stat1: 0)

  #expect(message == nil)

  message = SGLocoNetMessage.setLocoSlotStat1P2(slotBank: 0, slotNumber: 0, stat1: 0)

  #expect(message == nil)
  
  message = SGLocoNetMessage.setLocoSlotStat1P2(slotBank: 0, slotNumber: 127, stat1: 0)

  #expect(message == nil)
  
  message = SGLocoNetMessage.setLocoSlotStat1P2(slotBank: 0, slotNumber: 127, stat1: 0xff)

  #expect(message == nil)

  for slotBank in SGLocoNetMessage.slotBankRange {
    
    for slotNumber in SGLocoNetMessage.slotRange {
      
      message = SGLocoNetMessage.setLocoSlotStat1P2(slotBank: slotBank, slotNumber: slotNumber, stat1: 0x6c)

      #expect(message != nil)
      
      if let message {
        #expect(message.messageType == .setLocoSlotStat1P2)
        #expect(message.slotBank == slotBank)
        #expect(message.slotNumber == slotNumber)
        #expect(message.slotStatus1 == 0x6c)
      }
      
    }
    
  }
  
  message = SGLocoNetMessage.moveSlotP1(sourceSlotNumber: 0, destinationSlotNumber: 1)

  #expect(message == nil)

  message = SGLocoNetMessage.moveSlotP1(sourceSlotNumber: 127, destinationSlotNumber: 1)

  #expect(message == nil)

  message = SGLocoNetMessage.moveSlotP1(sourceSlotNumber: 1, destinationSlotNumber: 0)

  #expect(message == nil)

  message = SGLocoNetMessage.moveSlotP1(sourceSlotNumber: 1, destinationSlotNumber: 127)

  #expect(message == nil)
  
  message = SGLocoNetMessage.moveSlotP1(sourceSlotNumber: 1, destinationSlotNumber: 1)

  #expect(message == nil)
  
  for sourceSlotNumber in SGLocoNetMessage.slotRange {
    
    for destinationSlotNumber in SGLocoNetMessage.slotRange {
      
      if sourceSlotNumber != destinationSlotNumber {
        
        message = SGLocoNetMessage.moveSlotP1(sourceSlotNumber: sourceSlotNumber, destinationSlotNumber: destinationSlotNumber)
        
        #expect(message != nil)
        
        if let message {
          #expect(message.slotNumber == nil)
          #expect(message.messageType == .moveSlotP1)
          #expect(message.sourceSlotNumber == sourceSlotNumber)
          #expect(message.destinationSlotNumber == destinationSlotNumber)
        }

      }
    
    }
    
  }

  message = SGLocoNetMessage.moveSlotP2(sourceSlotBank: 5, sourceSlotNumber: 1, destinationSlotBank: 0, destinationSlotNumber: 1)

  #expect(message == nil)

  message = SGLocoNetMessage.moveSlotP2(sourceSlotBank: 1, sourceSlotNumber: 0, destinationSlotBank: 0, destinationSlotNumber: 1)

  #expect(message == nil)

  message = SGLocoNetMessage.moveSlotP2(sourceSlotBank: 1, sourceSlotNumber: 127, destinationSlotBank: 0, destinationSlotNumber: 1)

  #expect(message == nil)

  message = SGLocoNetMessage.moveSlotP2(sourceSlotBank: 1, sourceSlotNumber: 1, destinationSlotBank: 88, destinationSlotNumber: 1)

  #expect(message == nil)

  message = SGLocoNetMessage.moveSlotP2(sourceSlotBank: 1, sourceSlotNumber: 1, destinationSlotBank: 0, destinationSlotNumber: 0)

  #expect(message == nil)
    
  message = SGLocoNetMessage.moveSlotP2(sourceSlotBank: 1, sourceSlotNumber: 1, destinationSlotBank: 0, destinationSlotNumber: 127)

  #expect(message == nil)
  
  message = SGLocoNetMessage.moveSlotP2(sourceSlotBank: 1, sourceSlotNumber: 1, destinationSlotBank: 1, destinationSlotNumber: 1)

  #expect(message == nil)
  
  for sourceSlotBank in SGLocoNetMessage.slotBankRange {
    
    for sourceSlotNumber in SGLocoNetMessage.slotRange {
      
      for destinationSlotBank in SGLocoNetMessage.slotBankRange {
        
        for destinationSlotNumber in SGLocoNetMessage.slotRange {
          
          if sourceSlotNumber != destinationSlotNumber || sourceSlotBank != destinationSlotBank {
            
            message = SGLocoNetMessage.moveSlotP2(sourceSlotBank: sourceSlotBank, sourceSlotNumber: sourceSlotNumber, destinationSlotBank: destinationSlotBank, destinationSlotNumber: destinationSlotNumber)
            
            #expect(message != nil)
            
            if let message {
              #expect(message.slotNumber == nil)
              #expect(message.messageType == .moveSlotP2)
              #expect(message.sourceSlotNumber == sourceSlotNumber)
              #expect(message.destinationSlotNumber == destinationSlotNumber)
              #expect(message.sourceSlotBank == sourceSlotBank)
              #expect(message.destinationSlotBank == destinationSlotBank)
            }
            
          }
          
        }
        
      }
      
    }
    
  }
  
  message = SGLocoNetMessage.setLocoSlotInUseP1(slotNumber: 0)
  
  #expect(message == nil)

  message = SGLocoNetMessage.setLocoSlotInUseP1(slotNumber: 127)
  
  #expect(message == nil)
  
  for slotNumber in SGLocoNetMessage.slotRange {
    
    message = SGLocoNetMessage.setLocoSlotInUseP1(slotNumber: slotNumber)
    
    #expect(message != nil)
    
    if let message {
      #expect(message.messageType == .setLocoSlotInUseP1)
      #expect(message.slotNumber == slotNumber)
    }
    
  }
  
  message = SGLocoNetMessage.setLocoSlotInUseP2(slotBank: 66, slotNumber: 1)

  #expect(message == nil)
  
  message = SGLocoNetMessage.setLocoSlotInUseP2(slotBank: 0, slotNumber: 0)

  #expect(message == nil)
  
  message = SGLocoNetMessage.setLocoSlotInUseP2(slotBank: 0, slotNumber: 127)

  #expect(message == nil)
  
  for slotBank in SGLocoNetMessage.slotBankRange {
    
    for slotNumber in SGLocoNetMessage.slotRange {
      
      message = SGLocoNetMessage.setLocoSlotInUseP2(slotBank: slotBank, slotNumber: slotNumber)
      
      #expect(message != nil)
      
      if let message {
        #expect(message.messageType == .setLocoSlotInUseP2)
        #expect(message.slotNumber == slotNumber)
        #expect(message.slotBank == slotBank)
      }
      
    }
    
  }
  
  message = SGLocoNetMessage.locoSpdP1(slotNumber: 0, speed: 0)

  #expect(message == nil)

  message = SGLocoNetMessage.locoSpdP1(slotNumber: 127, speed: 0)

  #expect(message == nil)

  message = SGLocoNetMessage.locoSpdP1(slotNumber: 1, speed: 255)

  #expect(message == nil)
  
  for slotNumber in SGLocoNetMessage.slotRange {
    
    for speed : UInt8 in 0 ... 127 {

      message = SGLocoNetMessage.locoSpdP1(slotNumber: slotNumber, speed: speed)

      #expect(message != nil)
      
      if let message {
        #expect(message.messageType == .locoSpdP1)
        #expect(message.isCheckSumOK)
        #expect(message.slotNumber == slotNumber)
        #expect(message.speed == speed)
      }

    }
    
  }
  
  message = SGLocoNetMessage.locoSpdDirP2(slotBank: 77, slotNumber: 1, speed: 0, direction: .forward, throttleID: 0)

  #expect(message == nil)

  message = SGLocoNetMessage.locoSpdDirP2(slotBank: 0, slotNumber: 0, speed: 0, direction: .forward, throttleID: 0)

  #expect(message == nil)

  message = SGLocoNetMessage.locoSpdDirP2(slotBank: 0, slotNumber: 255, speed: 0, direction: .forward, throttleID: 0)

  #expect(message == nil)
  
  message = SGLocoNetMessage.locoSpdDirP2(slotBank: 0, slotNumber: 1, speed: 255, direction: .forward, throttleID: 0)

  #expect(message == nil)
  
  for slotBank in SGLocoNetMessage.slotBankRange {
    
    for slotNumber in SGLocoNetMessage.slotRange {
      
      for speed : UInt8 in (0 ... 127) {
        
        for direction in SGLocoNetLocomotiveDirection.allCases {
          
          message = SGLocoNetMessage.locoSpdDirP2(slotBank: slotBank, slotNumber: slotNumber, speed: speed, direction: direction, throttleID: 123)
          
          #expect(message != nil)
          
          if let message {
            #expect(message.messageType == .locoSpdDirP2)
            #expect(message.isCheckSumOK)
            #expect(message.slotNumber == slotNumber)
            #expect(message.slotBank == slotBank)
            #expect(message.speed == speed)
            #expect(message.throttleID == 123)
            #expect(message.direction == direction)
          }

        }
        
      }
      
    }
    
  }
  
  var functions = [Bool](repeating: false, count: 69)
  
  message = SGLocoNetMessage.locoDirF0F4P1(slotNumber: 0, direction: .forward, functions: functions)
  
  #expect(message == nil)

  message = SGLocoNetMessage.locoDirF0F4P1(slotNumber: 127, direction: .forward, functions: functions)
  
  #expect(message == nil)

  message = SGLocoNetMessage.locoDirF0F4P1(slotNumber: 0, direction: .forward, functions: [])
  
  #expect(message == nil)

  for slotNumber in SGLocoNetMessage.slotRange {
    
    for direction in SGLocoNetLocomotiveDirection.allCases {
      
      functions = []
      for index in 0 ... 4 {
        functions.append((UInt8.random(in: 0 ... 255) % 2) == 0 ? true : false)
      }
      
      message = SGLocoNetMessage.locoDirF0F4P1(slotNumber: slotNumber, direction: direction, functions: functions)
      
      #expect(message != nil)
      
      if let message {
        #expect(message.isCheckSumOK)
        #expect(message.messageType == .locoDirF0F4P1)
        #expect(message.direction == direction)
        #expect(message.slotNumber == slotNumber)
        #expect(message.functions == functions)
      }
      
    }
    
  }
  
}


