import Foundation
import Alamofire

class ReachabilityObserver {

    enum Notification: String {

        case didChange = "ReachabilityObserver.DidChange"

        var name: Foundation.Notification.Name {
            return Foundation.Notification.Name(rawValue: rawValue)
        }

        enum UserInfoKey: String {
            case isReachableKey = "isReachable"
        }
    }

    static let shared = ReachabilityObserver()

    private let manager = NetworkReachabilityManager()

    private init() {
        manager?.listenerQueue = .global()
    }

    private(set) var isReachable: Bool = false

    func startObserving() {
        guard let manager = manager else {
            print("Failed to setup system observation.")
            return
        }

        guard manager.listener == nil else {
            print("Attempt to start another network reachability observation.")
            return
        }

        manager.listener = { [weak self] status in
            switch status {
            case .notReachable, .unknown:
                self?.isReachable = false
            case .reachable:
                self?.isReachable = true
            }
            self?.notify()
        }

        if !manager.startListening() {
            print("Failed to start network reachability observation.")
        }
    }

    func stopObserving() {
        manager?.stopListening()
        manager?.listener = nil
    }

    private func notify() {
        NotificationCenter.default.post(name: Notification.didChange.name,
                                        object: self,
                                        userInfo: [Notification.UserInfoKey.isReachableKey.rawValue : isReachable])
    }
}
