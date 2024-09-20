// -----------------------------------------------------------------------------
// SGLocoNetIMMPacketRepeat.swift
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
//     20/09/2024  Paul Willmott - SGLocoNetIMMPacketRepeat.swift created
// -----------------------------------------------------------------------------

import Foundation

public enum SGLocoNetIMMPacketRepeat : UInt8, CaseIterable, Sendable {
  
  // MARK: Enumeration
  
  case repeatNone       = 0x00
  case repeat1          = 0x01
  case repeat2          = 0x02
  case repeat3          = 0x03
  case repeat4          = 0x04
  case repeat5          = 0x05
  case repeat6          = 0x06
  case repeat7          = 0x07
  case repeatContinuous = 0x0f

}
