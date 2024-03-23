import UIKit

class MockImageSaver: ImageSaver {

    @Published var numberOfSavedImages: Int = 0
    
    func save(_ images: [UIImage], borderSize: CGFloat, completion: @escaping () -> Void) {
        Task {
            for image in images {
                try? await Task.sleep(for: .seconds(0.2))
                numberOfSavedImages += 1
            }
            await MainActor.run {
                completion()
                numberOfSavedImages = 0
            }
        }
    }
}
