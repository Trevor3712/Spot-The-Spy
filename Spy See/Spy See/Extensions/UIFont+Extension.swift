//
//  UIFont+Extension.swift
//  Spy See
//
//  Created by 楊哲維 on 2023/6/24.
//

import UIKit

private enum FontName: String {
    case regular = "PingFangTC-Regular"
}

extension UIFont {
    
    static func regular(title: String, size: CGFloat, textColor: UIColor, letterSpacing: CGFloat) -> UIFont? {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: Font(.regular, size: size) ?? "",
            .foregroundColor: textColor,
            .kern: letterSpacing
        ]
        let attributedString = NSAttributedString(string: title, attributes: attributes)
        return attributedString.attribute(.font, at: 0, effectiveRange: nil) as? UIFont
    }
    // swiftlint:disable identifier_name
    private static func Font(_ font: FontName, size: CGFloat) -> UIFont? {
        return UIFont(name: font.rawValue, size: size)
    }
}
