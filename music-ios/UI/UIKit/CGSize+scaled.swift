import Foundation

extension CGSize {
    func scaled(toHeight height: CGFloat) -> CGSize {
        .init(
            width: self.width * height / self.height,
            height: height
        )
    }
    
    func scaled(toWidth width: CGFloat) -> CGSize {
        .init(
            width: width,
            height: self.height * width / self.width
        )
    }
}
