// -----------------------------------------------------------------------------
// SGLocoNetSlotConsistState.swift
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
//     20/09/2024  Paul Willmott - SGLocoNetSlotConsistState.swift created
// -----------------------------------------------------------------------------

import Foundation

public enum SGLocoNetSlotConsistState : UInt8, CaseIterable, Sendable {
  
  // MARK: Enumeration
  
  case notLinked  = 0b00000000
  case subMember  = 0b01000000
  case topMember  = 0b00001000
  case midConsist = 0b01001000

  // MARK: Public Properties
  
  public var title : String {
    return SGLocoNetSlotConsistState.titles[self]!
  }
  
  // MARK: Private Class Properties
  
  private static let titles : [SGLocoNetSlotConsistState:String] = [
    .notLinked  : String(localized: "Not Linked"),
    .subMember  : String(localized: "Sub-Member"),
    .topMember  : String(localized: "Top-Member"),
    .midConsist : String(localized: "Mid-Consist"),
  ]
  
  // MARK: Public class Properties
  
  public static let protectMask : UInt8 = 0b10110111

}

