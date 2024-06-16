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

    public init() {}

    public func configure() {
        Purchases.configure(withAPIKey: revenueCatAPIKey)
        Purchases.logLevel = .verbose
        self.refresh()
    }

    public func refresh() {
        Purchases.shared.getCustomerInfo { [weak self] customerInfo, error in
            if customerInfo?.entitlements["pro"]?.isActive == true {
                self?.currentStatus = .pro
            } else {
                self?.currentStatus = .notPro
            }
        }
    }
}
