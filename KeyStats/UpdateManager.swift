import Foundation

/// Keeps the update UI stable without performing any network requests.
final class UpdateManager {
    static let shared = UpdateManager()

    private var updateAvailabilityHandlers: [UUID: (Bool) -> Void] = [:]
    private(set) var hasAvailableUpdate = false

    private init() {}

    // MARK: - Updates

    func checkForUpdates() {}

    func probeForUpdateAvailability() {}

    func addUpdateAvailabilityHandler(_ handler: @escaping (Bool) -> Void) -> UUID {
        let token = UUID()
        updateAvailabilityHandlers[token] = handler
        handler(hasAvailableUpdate)
        return token
    }

    func removeUpdateAvailabilityHandler(_ token: UUID) {
        updateAvailabilityHandlers.removeValue(forKey: token)
    }
}
