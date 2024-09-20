// -----------------------------------------------------------------------------
// SGLocoNetDecoderProtocol.swift
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
//     20/09/2024  Paul Willmott - SGLocoNetDecoderProtocol.swift created
// -----------------------------------------------------------------------------

import Foundation

public enum SGLocoNetDecoderProtocol : UInt8, CaseIterable, Sendable {
  
  // MARK: Enumeration
  
  case dcc28     = 0b00000000
  case trinary   = 0b00000001
  case dcc14     = 0b00000010
  case dcc128    = 0b00000011
  case dcc28FX   = 0b00000100
  case trinaryFX = 0b00000101
  case dcc14FX   = 0b00000110
  case dcc128FX  = 0b00000111

  // MARK: Public Properties
  
  public var setMask : UInt8 {
    return self.rawValue
  }
  
  public var title : String {
    return SGLocoNetDecoderProtocol.titles[self]!
  }
  
  // MARK: Private Class Properties
  
  private static let titles : [SGLocoNetDecoderProtocol:String] = [
    .dcc28    : String(localized: "DCC 28",           comment: "Train control protocol selection"),
    .trinary  : String(localized: "Motorola Trinary", comment: "Train control protocol selection"),
    .dcc14    : String(localized: "DCC 14",           comment: "Train control protocol selection"),
    .dcc128   : String(localized: "DCC 128",          comment: "Train control protocol selection"),
    .dcc28FX  : String(localized: "DCC 28 FX",        comment: "Train control protocol selection"),
    .dcc14FX  : String(localized: "DCC 14 FX",        comment: "Train control protocol selection"),
    .dcc128FX : String(localized: "DCC 128 FX",       comment: "Train control protocol selection"),
  ]
  
  // MARK: Public Class Properties
  
  public static let protectMask : UInt8 = 0b11111000

}
