//
//  UIImage+Extension.swift
//  Spy See
//
//  Created by 楊哲維 on 2023/6/24.
//

import UIKit

enum ImageAsset: String {
    case background
    case spy
    case knife
    case normalKilled
}
extension UIImage {
    static func asset(_ asset: ImageAsset) -> UIImage? {
        return UIImage(named: asset.rawValue)
    }
}
