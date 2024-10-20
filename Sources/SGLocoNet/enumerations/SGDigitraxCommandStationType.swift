// -----------------------------------------------------------------------------
// SGDigitraxCommandStationType.swift
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
//     20/10/2024  Paul Willmott - SGDigitraxCommandStationType.swift created
// -----------------------------------------------------------------------------

import Foundation

public enum SGDigitraxCommandStationType : UInt8, Sendable, CaseIterable {
  
  // MARK: Enumeration
  
  case dcs100     = 0x78
  case db150      = 0x00
  case dcs50      = 0x08
  case dcs51      = 0x0c
  case dcs52      = 0x0d
  case dcs210     = 0x1b
  case dcs240     = 0x1c
  case dcs210Plus = 0x1a
  case dcs240Plus = 0x1d
  case dt200      = 0xff

  // MARK: Public Properties
  
  public var title : String {
    return SGDigitraxCommandStationType.titles[self]!
  }
  
  // MARK: Private Static Properties
  
  private static let titles : [SGDigitraxCommandStationType:String] = [
    .dt200      : String(localized: "Digitrax DT200"),
    .dcs100     : String(localized: "Digitrax DCS100 or DCS200"),
    .db150      : String(localized: "Digitrax DB150"),
    .dcs50      : String(localized: "Digitrax DCS50"),
    .dcs51      : String(localized: "Digitrax DCS51"),
    .dcs52      : String(localized: "Digitrax DCS52"),
    .dcs210     : String(localized: "Digitrax DCS210"),
    .dcs240     : String(localized: "Digitrax DCS240"),
    .dcs210Plus : String(localized: "Digitrax DCS210+"),
    .dcs240Plus : String(localized: "Digitrax DCS240+"),
  ]

}
