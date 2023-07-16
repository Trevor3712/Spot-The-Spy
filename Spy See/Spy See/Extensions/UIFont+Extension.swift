//
//  UIFont+Extension.swift
//  Spy See
//
//  Created by 楊哲維 on 2023/6/24.
//

import UIKit

enum FontName: String {
    case light = "PingFangTC-Ultralight"
    case regular = "PingFangTC-Regular"
    case semibold = "PingFangTC-Semibold"
    case boldItalicEN = "AvenirNextCondensed-BoldItalic"
}

extension UIFont {
    static func fontStyle(font: FontName, title: String, size: CGFloat, textColor: UIColor, letterSpacing: CGFloat, obliqueness: CGFloat = 0) -> NSAttributedString? {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: Font(font, size: size) ?? "",
            .foregroundColor: textColor,
            .kern: letterSpacing,
            .obliqueness: obliqueness
        ]
        let attributedString = NSAttributedString(string: title, attributes: attributes)
        return attributedString
    }
    // swiftlint:disable identifier_name
    private static func Font(_ font: FontName, size: CGFloat) -> UIFont? {
        return UIFont(name: font.rawValue, size: size)
    }
    // swiftlint:enable identifier_name
}
