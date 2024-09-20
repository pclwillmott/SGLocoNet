// -----------------------------------------------------------------------------
// SGDigitraxProductCode.swift
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
//     20/09/2024  Paul Willmott - SGDigitraxProductCode.swift created
// -----------------------------------------------------------------------------

import Foundation

public enum SGDigitraxProductCode : UInt8, CaseIterable, Sendable {
  
  // MARK: Enumeration
  
  case lnrp       = 0x01
  case ut4        = 0x04
  case ut6        = 0x06
  case wtl12      = 0x0c
  case db210Opto  = 0x14
  case db210      = 0x15
  case db220      = 0x16
  case dcs210Plus = 0x1a
  case dcs210     = 0x1b
  case dcs240     = 0x1c
  case dcs240Plus = 0x1d
  case pr3        = 0x23
  case pr4        = 0x24
  case dt402      = 0x2a
  case dt500      = 0x32
  case dcs51      = 0x33
  case dcs52      = 0x34
  case dt602      = 0x3e
  case se74       = 0x46
  case pm74       = 0x4a
  case bxpa1      = 0x51
  case bxp88      = 0x58
  case lnwi       = 0x63
  case ur92       = 0x5c
  case ur93       = 0x5d
  case ds74       = 0x74
  case ds78V      = 0x7c
  
  // MARK: Public Properties
  
  public var title : String {
    return SGDigitraxProductCode.titles[self]!
  }
  
  // MARK: Private Class Properties
  
  private static let titles : [SGDigitraxProductCode:String] = [
    .lnrp       : String(localized: "LNRP"),
    .ut4        : String(localized: "UT4"),
    .ut6        : String(localized: "UT6"),
    .wtl12      : String(localized: "WTL12"),
    .db210Opto  : String(localized: "DB210 Opto"),
    .db210      : String(localized: "DB210"),
    .db220      : String(localized: "DB220"),
    .dcs210Plus : String(localized: "DCS210+"),
    .dcs210     : String(localized: "DCS210"),
    .dcs240     : String(localized: "DCS240"),
    .dcs240Plus : String(localized: "DCS240+"),
    .pr3        : String(localized: "PR3"),
    .pr4        : String(localized: "PR4"),
    .dt402      : String(localized: "DT402"),
    .dt500      : String(localized: "DT500"),
    .dcs51      : String(localized: "DCS51"),
    .dcs52      : String(localized: "DCS52"),
    .dt602      : String(localized: "DT602"),
    .se74       : String(localized: "SE74"),
    .pm74       : String(localized: "PM74"),
    .bxpa1      : String(localized: "BXPA1"),
    .bxp88      : String(localized: "BXP88"),
    .lnwi       : String(localized: "LNWI"),
    .ur92       : String(localized: "UR92"),
    .ur93       : String(localized: "UR93"),
    .ds74       : String(localized: "DS74"),
    .ds78V      : String(localized: "DS78V"),
  ]
  
}
