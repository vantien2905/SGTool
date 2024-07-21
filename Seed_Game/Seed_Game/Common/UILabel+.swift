//
//  UILabel+.swift
//  Seed_Game
//
//  Created by Tien Dinh on 21/7/24.
//

import Foundation
import UIKit

extension UILabel {
    
    func setHighlight(text: String,
                      font: UIFont,
                      color: UIColor,
                      highlightText: String,
                      highlightFont: UIFont,
                      highlightColor: UIColor
    ) {
        let defaultStyles: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color
        ]
        let highlightStyles: [NSAttributedString.Key: Any] = [
            .font: highlightFont,
            .foregroundColor: highlightColor
        ]

        let attributedText = NSMutableAttributedString()
        attributedText.append(NSAttributedString(string: text, attributes: defaultStyles))
        
        let range: NSRange = attributedText.mutableString.range(of: highlightText, options: .caseInsensitive)
        attributedText.addAttributes(highlightStyles, range: range)

        self.attributedText = attributedText
    }
    
    func setAttributedText(text: String,
                           font: UIFont,
                           color: UIColor,
                           lineSpacing: CGFloat = 1,
                           lineHeight: CGFloat = 1,
                           alignment: NSTextAlignment? = nil,
                           underLine: Bool = false,
                           strikethrough: Bool = false) {
        let attributedString = NSMutableAttributedString(string: text, attributes: [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: color])
        
        if underLine {
            attributedString.addAttributes([NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue], range: NSMakeRange(0, attributedString.length))
        }
        
        if strikethrough {
            attributedString.addAttributes([NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue], range: NSMakeRange(0, attributedString.length))
        }
        
        let paragraphStyle = NSMutableParagraphStyle()
        if lineHeight != 1 { paragraphStyle.lineHeightMultiple = lineHeight }
        
        if lineSpacing != 1 {
            let value = lineSpacing * font.lineHeight - font.lineHeight
            paragraphStyle.lineSpacing = value
        }
        
        if let alignment = alignment { paragraphStyle.alignment = alignment }
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attributedString.length))
        
        self.attributedText = attributedString
    }
}
