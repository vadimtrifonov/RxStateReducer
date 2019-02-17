import UIKit

public extension UIImage {
    
    public static func makeImage(color: UIColor) -> UIImage {
        return UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1)).image { context in
            context.cgContext.setFillColor(color.cgColor)
            context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        }
    }
}
