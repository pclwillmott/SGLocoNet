// -----------------------------------------------------------------------------
// SGLocoNetLocomotiveDirection.swift
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
//     20/09/2024  Paul Willmott - SGLocoNetLocomotiveDirection.swift created
// -----------------------------------------------------------------------------

import Foundation
import AppKit

public enum SGLocoNetLocomotiveDirection : UInt8, CaseIterable, Sendable {
  
  case forward = 0b00000000
  case reverse  = 0b00100000
  
  // MARK: Public Properties
  
  public var title : String {
    return SGLocoNetLocomotiveDirection.titles[self]!
  }
  
  public var setMask : UInt8 {
    return self.rawValue
  }
  
  // MARK: Private Class Properties
  
  private static let titles : [SGLocoNetLocomotiveDirection:String] = [
    .forward : String(localized: "Forward", comment: "Train is moving in the forward direction"),
    .reverse : String(localized: "Reverse", comment: "Train is moving in the reverse direction"),
  ]

  private static var map : String {
    
    var map = ""
    
    for item in SGLocoNetLocomotiveDirection.allCases {
      map += "<relation><property>\(item.rawValue)</property><value>\(item.title)</value></relation>\n"
    }

    return map
    
  }

  // MARK: Public Class Properties
  
  public static let mapPlaceholder = "%%LOCOMOTIVE_DIRECTION%%"
  
  public static let protectMask : UInt8 = 0b11011111

  // MARK: Public Class Methods
  
  @MainActor public static func populate(comboBox:NSComboBox) {
    comboBox.removeAllItems()
    for item in SGLocoNetLocomotiveDirection.allCases {
      comboBox.addItem(withObjectValue: item.title)
    }
  }
  
  public static func insertMap(cdi:String) -> String {
    return cdi.replacingOccurrences(of: mapPlaceholder, with: map)
  }

}
