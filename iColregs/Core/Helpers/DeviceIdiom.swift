//
//  DeviceIdiom.swift
//  iColregs
//
//  Created by Christophe Guégan on 26/10/2025.
//

import UIKit

enum DeviceIdiom: Codable {
  case iphone
  case ipad
}

extension UIDevice {
  var isPhone: Bool { userInterfaceIdiom == .phone }
  var isPad: Bool { userInterfaceIdiom == .pad }
}

struct DeviceIdiomProvider {
  static func current() -> DeviceIdiom {
    UIDevice.current.isPhone ? .iphone : .ipad
  }
}
