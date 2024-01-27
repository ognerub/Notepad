import Foundation

enum StorageKeyNames: String {
    case isFirstStart = "isFirstStart"
}

final class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    private let userDefaults = UserDefaults.standard
    
    var isFisrtStart: Bool {
        get {
            userDefaults.bool(forKey: StorageKeyNames.isFirstStart.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: StorageKeyNames.isFirstStart.rawValue)
        }
    }
}
