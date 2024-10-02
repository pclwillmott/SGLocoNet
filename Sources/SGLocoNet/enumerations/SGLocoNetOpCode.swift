// -----------------------------------------------------------------------------
// SGLocoNetOpcode.swift
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
//     20/09/2024  Paul Willmott - SGLocoNetOpcode.swift created
//     02/10/2024  Paul Willmott - renamed to SGLocoNetOpcode
// -----------------------------------------------------------------------------

import Foundation

public enum SGLocoNetOpcode : UInt8, CaseIterable, Sendable {

// MARK: Enumeration
  
  case opcUnknown     = 0x00
  case opcBusy        = 0x81
  case opcGPOff       = 0x82
  case opcGPOn        = 0x83
  case opcIdle        = 0x85
  case opcLocoReset   = 0x8a
  case opcLocoSpd     = 0xa0
  case opcLocoDirF    = 0xa1
  case opcLocoSnd     = 0xa2
  case opcLocoSnd2    = 0xa3
  case opcSwReq       = 0xb0
  case opcSwRep       = 0xb1
  case opcInputRep    = 0xb2
  case opcLongAck     = 0xb4
  case opcSlotStat1   = 0xb5
  case opcConsistFunc = 0xb6
  case opcUnlinkSlots = 0xb8
  case opcLinkSlots   = 0xb9
  case opcMoveSlots   = 0xba
  case opcRqSlData    = 0xbb
  case opcSwState     = 0xbc
  case opcSwAck       = 0xbd
  case opcLocoAdrP2   = 0xbe
  case opcLocoAdr     = 0xbf
  case opcD0Group     = 0xd0
  case opcPrMode      = 0xd3
  case opcD4Group     = 0xd4
  case opcD5Group     = 0xd5
  case opcD7Group     = 0xd7
  case opcDFGroup     = 0xdf
  case opcPeerXfer    = 0xe5
  case opcSlRdDdataP2 = 0xe6
  case opcSlRdDdata   = 0xe7
  case opcImmPacket   = 0xed
  case opcWrSlDataP2  = 0xee
  case opcWrSlData    = 0xef
  
}
