import Foundation
import RevenueCat

public enum ProPlanStatus {
  case pro
  case notPro
}

public enum ProPlanResult {
  case success
  case failure
}

@Observable public class ProPlanService {

  public var currentStatus: ProPlanStatus = .notPro

  public init() {
    guard let defaults = UserDefaults.squarify else {
      fatalError("Unable to init app user defaults container.")
    }
    if defaults.bool(forKey: AppStorageKeys.isUserPro) == true {
      currentStatus = .pro
    }
  }

  public func configure() {
    Purchases.configure(withAPIKey: revenueCatAPIKey)
    Purchases.logLevel = .verbose
    self.refresh()
  }

  public func refresh() {
    Purchases.shared.getCustomerInfo { [weak self] customerInfo, error in
      if error != nil { return }
      if customerInfo?.entitlements["pro"]?.isActive == true {
        self?.currentStatus = .pro
        self?.updateStatusInDefaults(.pro)
      } else {
        self?.currentStatus = .notPro
        self?.updateStatusInDefaults(.notPro)
      }
    }
  }

  private func updateStatusInDefaults(_ status: ProPlanStatus) {
    guard let defaults = UserDefaults.squarify else {
      fatalError("Unable to init app user defaults container.")
    }
    let isPro = status == .pro
    defaults.set(isPro, forKey: AppStorageKeys.isUserPro)
  }
}
