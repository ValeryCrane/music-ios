import Foundation
import UIKit

/*
 Цветовая гамма:
 - Ярко-синий: #5781ff
 - Бледно-синий: #8aa7ff
 - Ярко-желтый: #ffd557
 - Средне-желтый: #ffe28a
 - Бледно-желтый: #ffefbc
 */

extension UIColor {
    enum imp {
        static let primary = UIColor(hex: "#5781ffff")!
        static let secondary = UIColor(hex: "#8aa7ffff")!
        static let complementary = UIColor(hex: "#ffd557ff")!
        static let lightGray = UIColor(hex: "#f5f5f5ff")!

        static let backgroundColor = UIColor.white
        static let gridOddBeatBackgroundColor = UIColor.systemGray6
        static let gridEvenBeatBackgroundColor = UIColor.systemGray5
    }
}

extension UIColor {
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }

        return nil
    }
}
