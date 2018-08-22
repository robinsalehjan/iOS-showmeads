//
//  UIFont+Fonts.swift
//  ShowMeAds
//
//  Created by Saleh-Jan, Robin on 21/08/2018.
//  Copyright © 2018 Robin Saleh-Jan. All rights reserved.
//

import UIKit

public enum FINNFontType: String {
    case light = "FINNTypeWebStrippet-Light"
    case regular = "FINNTypeWebStrippet-Regular"
    case medium = "FINNTypeWebStrippet-Medium"
    case bold = "FinnTypeWebStrippet-Bold"
}

extension UIFont {
    public static func FINNFont(fontType: FINNFontType, size: CGFloat) -> UIFont? {
        switch fontType {
        case .light:
            guard let font = UIFont.init(name: FINNFontType.light.rawValue, size: size) else {
                fatalError("Could not load font: \(FINNFontType.light.rawValue)")
            }
            return font
        
        case .regular:
            guard let font = UIFont.init(name: FINNFontType.regular.rawValue, size: size) else {
                fatalError("Could not load font: \(FINNFontType.regular.rawValue)")
            }
            return font
            
        case .medium:
            guard let font = UIFont.init(name: FINNFontType.medium.rawValue, size: size) else {
                fatalError("Could not load font: \(FINNFontType.medium.rawValue)")
            }
            return font
            
        case .bold:
            guard let font = UIFont.init(name: FINNFontType.bold.rawValue, size: size) else {
                fatalError("Could not load font: \(FINNFontType.bold.rawValue)")
            }
            return font
        }
    }
    
    public static func scaledFINNFont(fontType: FINNFontType, size: CGFloat) -> UIFont? {
        if let font = FINNFont(fontType: fontType, size: size) {
            return UIFontMetrics.default.scaledFont(for: font)
        }
        return nil
    }
}
