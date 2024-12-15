import Foundation

public extension String {
  var localized: String {
    NSLocalizedString(self, bundle: Bundle.module, comment: self)
  }
}
