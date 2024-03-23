import UIKit

public protocol ImageSaver: ObservableObject {
    var numberOfSavedImages: Int { get set }
    func save(_ images: [UIImage], borderSize: CGFloat, completion: @escaping () -> Void)
}
