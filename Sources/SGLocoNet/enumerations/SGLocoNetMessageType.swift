// -----------------------------------------------------------------------------
// SGLocoNetMessageType.swift
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
//     19/09/2024  Paul Willmott - SGLocoNetMessageType.swift created
// -----------------------------------------------------------------------------

import Foundation

public enum SGLocoNetMessageType: CaseIterable, Sendable {
  
  // MARK: Enumeration
  
  case unknown
  case uninitialized
  case brdOpSwState
  case busy
  case consistDirF0F4
  case d4Error
  case dispatchGetP1
  case dispatchGetP2
  case dispatchPutP1
  case dispatchPutP2
  case duplexGroupChannel
  case duplexGroupData
  case duplexGroupID
  case duplexGroupPassword
  case duplexSignalStrength
  case ezRouteConfirm
  case fastClockData
  case findLoco
  case findReceiver
  case getBrdOpSwState
  case getOpSwDataAP1
  case getOpSwDataBP1
  case getOpSwDataP2
  case getDuplexGroupChannel
  case getDuplexGroupData
  case getDuplexGroupID
  case getDuplexGroupPassword
  case getDuplexSignalStrength
  case getFastClockData
  case getLocoSlotData
  case getLocoSlotDataAdrP1
  case getLocoSlotDataAdrP2
  case getQuerySlot
  case getRosterEntry
  case getRosterTableInfo
  case getRouteTableInfoA
  case getRouteTableInfoB
  case getRouteTablePage
  case getSwState
  case illegalMoveP1
  case immPacket
  case immPacketOK
  case immPacketLMOK
  case immPacketBufferFull
  case interfaceData
  case interfaceDataLB
  case interfaceDataPR3
  case interrogate
  case invalidLinkP1
  case invalidUnlinkP1
  case iplDataLoad
  case iplDevData
  case iplDiscover
  case iplEndLoad
  case iplSetAddr
  case iplSetup
  case linkSlotsP1
  case linkSlotsP2
  case lnwiData
  case locoDirF0F4P1
  case locoF0F6P2
  case locoF5F8P1
  case locoF7F13P2
  case locoF9F12IMMLAdr
  case locoF9F12IMMSAdr
  case locoF9F12P1
  case locoF12F20F28P2
  case locoF13F20IMMLAdr
  case locoF13F20IMMSAdr
  case locoF13F19P2
  case locoF14F20P2
  case locoF21F27P2
  case locoF21F28IMMLAdr
  case locoF21F28IMMSAdr
  case locoF21F28P2
  case locoRep
  case locoSlotDataP1
  case locoSlotDataP2
  case locoSpdDirP2
  case locoSpdP1
  case moveSlotP1
  case moveSlotP2
  case noFreeSlotsP1
  case noFreeSlotsP2
  case opSwDataAP1
  case opSwDataBP1
  case opSwDataP2
  case peerXfer16
  case pmRep
  case pmRepBXP88
  case prMode
  case progCmdAccepted
  case progCmdAcceptedBlind
  case progCV
  case progSlotDataP1
  case programmerBusy
  case pwrOff
  case pwrOn
  case querySlot1
  case querySlot2
  case querySlot3
  case querySlot4
  case querySlot5
  case receiverRep
  case reset
  case resetQuerySlot4
  case rosterEntry
  case rosterTableInfo
  case routeTableInfoA
  case routeTableInfoB
  case routeTablePage
  case routesDisabled
  case s7CVRW
  case s7CVState
  case s7Info
  case sensRepGenIn
  case sensRepTurnIn
  case sensRepTurnOut
  case setBrdOpSwOK
  case setBrdOpSwState
  case setOpSwDataAP1
  case setOpSwDataBP1
  case setOpSwDataP2
  case setDuplexGroupChannel
  case setDuplexGroupData
  case setDuplexGroupID
  case setDuplexGroupPassword
  case setFastClockData
  case setIdleState
  case setLocoNetID
  case setLocoSlotDataP1
  case setLocoSlotDataP2
  case setLocoSlotInUseP1
  case setLocoSlotInUseP2
  case setLocoSlotStat1P1
  case setLocoSlotStat1P2
  case setRosterEntry
  case setRouteTablePage
  case setS7BaseAddr
  case setSlotDataOKP1
  case setSlotDataOKP2
  case setSw
  case setSwAccepted
  case setSwRejected
  case setSwWithAck
  case setSwWithAckAccepted
  case setSwWithAckRejected
  case slotNotImplemented
  case swState
  case transRep
  case trkShortRep
  case unlinkSlotsP1
  case unlinkSlotsP2
  case zapped
  
  // MARK: Public Properties
  
  public var title : String {
    return SGLocoNetMessageType.titles[self]!
  }
  
  // MARK: Private Class Properties
  
  private static let titles  : [SGLocoNetMessageType:String] = [
    .unknown                 : String(localized: "Unknown"),
    .brdOpSwState            : String(localized: "Board OpSw State"),
    .busy                    : String(localized: "Busy"),
    .consistDirF0F4          : String(localized: "Consist direction and functions F0 to F4"),
    .d4Error                 : String(localized: "D4 Command error"),
    .dispatchGetP1           : String(localized: "Dispatch Get (P1)"),
    .dispatchGetP2           : String(localized: "Dispatch Get (P2)"),
    .dispatchPutP1           : String(localized: "Dispatch Put (P1)"),
    .dispatchPutP2           : String(localized: "Dispatch Put (P2)"),
    .duplexGroupChannel      : String(localized: "Duplex Group Channel"),
    .duplexGroupData         : String(localized: "Duplex Group Data"),
    .duplexGroupID           : String(localized: "Duplex Group ID"),
    .duplexGroupPassword     : String(localized: "Duplex Group Password"),
    .duplexSignalStrength    : String(localized: "Duplex Signal Strength"),
    .ezRouteConfirm          : String(localized: "EZ Route Confirmation"),
    .fastClockData           : String(localized: "Fast Clock Data"),
    .findLoco                : String(localized: "Find Locomotive"),
    .findReceiver            : String(localized: "Find Receiver"),
    .getBrdOpSwState         : String(localized: "Get Board OpSw State"),
    .getOpSwDataAP1          : String(localized: "Get OpSw Data A (P1)"),
    .getOpSwDataBP1          : String(localized: "Get OpSw Data B (P1)"),
    .getOpSwDataP2           : String(localized: "Get OpSw Data (P2)"),
    .getDuplexGroupChannel   : String(localized: "Get Duplex Group Channel"),
    .getDuplexGroupData      : String(localized: "Get Duplex Group Data"),
    .getDuplexGroupID        : String(localized: "Get Duplex Group ID"),
    .getDuplexGroupPassword  : String(localized: "Get Duplex Group Password"),
    .getDuplexSignalStrength : String(localized: "Get Duplex Signal Strength"),
    .getFastClockData        : String(localized: "Get Fast Clock Data"),
    .getLocoSlotData         : String(localized: "Get Locomotive Slot Data"),
    .getLocoSlotDataAdrP1    : String(localized: "Get Locomotive Slot Data by Address (P1)"),
    .getLocoSlotDataAdrP2    : String(localized: "Get Locomotive Slot Data by Address (P2)"),
    .getQuerySlot            : String(localized: "Get Query Slot"),
    .getRosterEntry          : String(localized: "Get Roster Entry"),
    .getRosterTableInfo      : String(localized: "Get Roster Table Information"),
    .getRouteTableInfoA      : String(localized: "Get Route Table Information A"),
    .getRouteTableInfoB      : String(localized: "Get Route Table Information B"),
    .getRouteTablePage       : String(localized: "Get Route Table Page"),
    .getSwState              : String(localized: "Get Switch State"),
    .illegalMoveP1           : String(localized: "Illegal Move (P1)"),
    .immPacket               : String(localized: "Send Packet Immediate"),
    .immPacketOK             : String(localized: "Send Packet Immediate OK"),
    .immPacketBufferFull     : String(localized: "Send Immediate Packet Buffer Full"),
    .interfaceData           : String(localized: "LocoNet Interface Data"),
    .interfaceDataLB         : String(localized: "LocoNet Interface Data - LocoBuffer"),
    .interfaceDataPR3        : String(localized: "LocoNet Interface Data - PR3"),
    .interrogate             : String(localized: "Interrogate"),
    .invalidLinkP1           : String(localized: "Invalid Link (P1)"),
    .invalidUnlinkP1         : String(localized: "Invalid Unlink (P1)"),
    .iplDataLoad             : String(localized: "IPL Data Load"),
    .iplDevData              : String(localized: "IPL Device Data"),
    .iplDiscover             : String(localized: "IPL Discover"),
    .iplEndLoad              : String(localized: "IPL End Load"),
    .iplSetAddr              : String(localized: "IPL Set Address"),
    .iplSetup                : String(localized: "IPL Setup"),
    .linkSlotsP1             : String(localized: "Link Slots (P1)"),
    .linkSlotsP2             : String(localized: "Link Slots (P2)"),
    .lnwiData                : String(localized: "LNWI Data"),
    .locoDirF0F4P1           : String(localized: "Locomotive direction and functions F0 to F4 (P1)"),
    .locoF0F6P2              : String(localized: "Locomotive functions F0 to F6 (P2)"),
    .locoF5F8P1              : String(localized: "Locomotive functions F5 to F8 (P1)"),
    .locoF7F13P2             : String(localized: "Locomotive functions F7 to F13 (P2)"),
    .locoF9F12IMMLAdr        : String(localized: "Locomotive functions F9 to F12 (dcc long address)"),
    .locoF9F12IMMSAdr        : String(localized: "Locomotive functions F9 to F12 (dcc short address)"),
    .locoF9F12P1             : String(localized: "Locomotive functions F9 to F12 (P1)"),
    .locoF12F20F28P2         : String(localized: "Locomotive functions F12 to F28 (P2)"),
    .locoF13F20IMMLAdr       : String(localized: "Locomotive functions F13 to F20 (dcc long address)"),
    .locoF13F20IMMSAdr       : String(localized: "Locomotive functions F13 to F20 (dcc short address)"),
    .locoF13F19P2            : String(localized: "Locomotive functions F13 to F19 (P2)"),
    .locoF14F20P2            : String(localized: "Locomotive functions F14 to F20 (P2)"),
    .locoF21F27P2            : String(localized: "Locomotive functions F21 to F27 (P2)"),
    .locoF21F28IMMLAdr       : String(localized: "Locomotive functions F21 to F28 (dcc long address)"),
    .locoF21F28IMMSAdr       : String(localized: "Locomotive functions F21 to F28 (dcc short address)"),
    .locoF21F28P2            : String(localized: "Locomotive functions F21 to F28 (P2)"),
    .locoRep                 : String(localized: "Locomotive Report"),
    .locoSlotDataP1          : String(localized: "Locomotive Slot Data (P1)"),
    .locoSlotDataP2          : String(localized: "Locomotive Slot Data (P2)"),
    .locoSpdDirP2            : String(localized: "Locomotive speed and direction (P2)"),
    .locoSpdP1               : String(localized: "Locomotive speed (P1)"),
    .moveSlotP1              : String(localized: "Move Slot (P1)"),
    .moveSlotP2              : String(localized: "Move Slot (P2)"),
    .noFreeSlotsP1           : String(localized: "No Free Slots (P1)"),
    .noFreeSlotsP2           : String(localized: "No Free Slots (P2)"),
    .opSwDataAP1             : String(localized: "OpSw Data A (P1)"),
    .opSwDataBP1             : String(localized: "OpSw Data B (P1)"),
    .opSwDataP2              : String(localized: "OpSw Data (P2)"),
    .peerXfer16              : String(localized: "Peer Transfer"),
    .pmRep                   : String(localized: "Power Manager Report"),
    .pmRepBXP88              : String(localized: "Power Manager Report - BXP88"),
    .prMode                  : String(localized: "Programmer Mode"),
    .progCmdAccepted         : String(localized: "Programming Command Accepted"),
    .progCmdAcceptedBlind    : String(localized: "Programming Command Accepted Blind"),
    .progCV                  : String(localized: "Program CV"),
    .progSlotDataP1          : String(localized: "Programming Slot Data (P1)"),
    .programmerBusy          : String(localized: "Programmer Busy"),
    .pwrOff                  : String(localized: "Power Off"),
    .pwrOn                   : String(localized: "Power On"),
    .querySlot1              : String(localized: "Query Slot 1 Data"),
    .querySlot2              : String(localized: "Query Slot 2 Data"),
    .querySlot3              : String(localized: "Query Slot 3 Data"),
    .querySlot4              : String(localized: "Query Slot 4 Data"),
    .querySlot5              : String(localized: "Query Slot 5 Data"),
    .receiverRep             : String(localized: "Receiver Report"),
    .reset                   : String(localized: "Reset"),
    .resetQuerySlot4         : String(localized: "Reset Query Slot 4"),
    .rosterEntry             : String(localized: "Roster Entry"),
    .rosterTableInfo         : String(localized: "Roster Table Information"),
    .routeTableInfoA         : String(localized: "Route Table Information A"),
    .routeTableInfoB         : String(localized: "Route Table Information B"),
    .routeTablePage          : String(localized: "Route Table Page"),
    .routesDisabled          : String(localized: "Routes Disabled"),
    .s7CVRW                  : String(localized: "Series 7 CV Read/Write"),
    .s7CVState               : String(localized: "Series 7 CV State"),
    .s7Info                  : String(localized: "Series 7 Information"),
    .sensRepGenIn            : String(localized: "General Sensor Input Report"),
    .sensRepTurnIn           : String(localized: "Turnout Input Report"),
    .sensRepTurnOut          : String(localized: "Turnout Output Report"),
    .setBrdOpSwOK            : String(localized: "Set Board OpSw State OK"),
    .setBrdOpSwState         : String(localized: "Set Board OpSw State"),
    .setOpSwDataAP1          : String(localized: "Set OpSw Data A (P1)"),
    .setOpSwDataBP1          : String(localized: "Set OpSw Data B (P1)"),
    .setOpSwDataP2           : String(localized: "Set OpSw Data (P2)"),
    .setDuplexGroupChannel   : String(localized: "Set Duplex Group Channel"),
    .setDuplexGroupData      : String(localized: "Set Duplex Group Data"),
    .setDuplexGroupID        : String(localized: "Set Duplex Group ID"),
    .setDuplexGroupPassword  : String(localized: "Set Duplex Group Password"),
    .setFastClockData        : String(localized: "Set Fast Clock Data"),
    .setIdleState            : String(localized: "Set Idle State"),
    .setLocoNetID            : String(localized: "Set LocoNet ID"),
    .setLocoSlotDataP1       : String(localized: "Set Locomotive Slot Data (P1)"),
    .setLocoSlotDataP2       : String(localized: "Set Locomotive Slot Data (P2)"),
    .setLocoSlotInUseP1      : String(localized: "Set Locomotive Slot In-Use (P1)"),
    .setLocoSlotInUseP2      : String(localized: "Set Locomotive Slot In-Use (P2)"),
    .setLocoSlotStat1P1      : String(localized: "Set Locomotive Slot Status (P1)"),
    .setLocoSlotStat1P2      : String(localized: "Set Locomotive Slot Status (P2)"),
    .setRosterEntry          : String(localized: "Set Roster Entry"),
    .setRouteTablePage       : String(localized: "Set Route Table Page"),
    .setS7BaseAddr           : String(localized: "Set Series 7 Base Address"),
    .setSlotDataOKP1         : String(localized: "Set Slot Data OK (P1)"),
    .setSlotDataOKP2         : String(localized: "Set Slot Data OK (P2)"),
    .setSw                   : String(localized: "Set Switch State"),
    .setSwAccepted           : String(localized: "Set Switch State Accepted"),
    .setSwRejected           : String(localized: "Set Switch State Rejected"),
    .setSwWithAck            : String(localized: "Set Switch State with Ack"),
    .setSwWithAckAccepted    : String(localized: "Set Switch State with Ack Accepted"),
    .setSwWithAckRejected    : String(localized: "Set Switch State with Ack Rejected"),
    .slotNotImplemented      : String(localized: "Slot Not Implemented"),
    .swState                 : String(localized: "Switch State"),
    .transRep                : String(localized: "Transponding Report"),
    .trkShortRep             : String(localized: "Track Short Report"),
    .unlinkSlotsP1           : String(localized: "Unlink Slots (P1)"),
    .unlinkSlotsP2           : String(localized: "Unlink Slots (P2)"),
    .zapped                  : String(localized: "Zapped"),
  ]
  
}
