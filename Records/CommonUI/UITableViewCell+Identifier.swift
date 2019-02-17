import UIKit

public extension UITableViewCell {
    
    public static var identifier: String {
        return String(describing: self)
    }
}
