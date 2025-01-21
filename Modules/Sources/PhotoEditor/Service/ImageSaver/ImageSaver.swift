import UIKit

public protocol ImageSaver: ObservableObject {
  var numberOfSavedImages: Int { get set }
  func save(withParams params: ImageSaverParameters, completion: @escaping () -> Void)
  func resetState()
}
