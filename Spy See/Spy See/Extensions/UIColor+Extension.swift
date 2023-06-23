//
//  UIColor+Extension.swift
//  Spy See
//
//  Created by 楊哲維 on 2023/6/23.
//

import UIKit

private enum Color: String {
    // swiftlint:disable identifier_name
    case B1
    case B2
    case B3
    case Y
    case R
}
extension UIColor {
    static let B1 = Color(.B1)
    static let B2 = Color(.B2)
    static let B3 = Color(.B3)
    static let Y = Color(.Y)
    static let R = Color(.R)
    private static func Color(_ color: Color) -> UIColor? {
        return UIColor(named: color.rawValue)
    }
    // swiftlint:disable identifier_name
}
