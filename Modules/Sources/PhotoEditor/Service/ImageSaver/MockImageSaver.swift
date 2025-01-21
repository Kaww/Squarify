import UIKit

class MockImageSaver: ImageSaver {
  @Published var numberOfSavedImages: Int = 0
  
  func save(withParams params: ImageSaverParameters, completion: @escaping () -> Void) {
    Task {
      for _ in params.images {
        try? await Task.sleep(for: .seconds(1))
        numberOfSavedImages += 1
      }
      await MainActor.run {
        completion()
        numberOfSavedImages = 0
      }
    }
  }
  
  func resetState() {
    numberOfSavedImages = 0
  }
}
