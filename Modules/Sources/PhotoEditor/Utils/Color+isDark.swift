import UIKit
import Foundation
import SwiftUI
import Utils

extension UIColor {
    func isDark() -> Bool {
        // algorithm from: http://www.w3.org/WAI/ER/WD-AERT/#color-contrast
        let components = self.cgColor.components ?? []
        guard
            let first = components[safe: 0],
            let second = components[safe: 1],
            let third = components[safe: 2]
        else { return false }
        
        let brightness: CGFloat = ((first * 299) + (second * 587) + (third * 114)) / 1000
        print("brightness is \(brightness)")
        
        return brightness < 0.1 ? true : false
    }
}

extension Color {
    func isDark() -> Bool {
        UIColor(self).isDark()
    }
}
