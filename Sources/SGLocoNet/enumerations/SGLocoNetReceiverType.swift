// -----------------------------------------------------------------------------
// SGLocoNetReceiverType.swift
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
//     24/10/2024  Paul Willmott - SGLocoNetReceiverType.swift created
// -----------------------------------------------------------------------------

import Foundation

public enum SGLocoNetReceiverType : UInt8, CaseIterable, Sendable {
  
  // MARK: Enumeration
  
  case ur90 = 0x17
  case ur91 = 0x1f
  case ur92 = 0x12
  case ur93 = 0x22

  // MARK: Public Properties
  
  public var title : String {
    return SGLocoNetReceiverType.titles[self]!
  }
  
  // MARK: Private static Properties
  
  private static let titles : [SGLocoNetReceiverType:String] = [
    .ur90: String(localized: "UR90"),
    .ur91: String(localized: "UR91"),
    .ur92: String(localized: "UR92"),
    .ur93: String(localized: "UR93"),
  ]
  
}
