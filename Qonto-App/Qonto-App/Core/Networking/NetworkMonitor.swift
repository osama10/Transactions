import Foundation
import Network

/// Protocol for network connectivity monitoring — enables testing with mock implementations.
@MainActor
protocol NetworkMonitoring: AnyObject, Sendable {
    var isConnected: Bool { get }
    func start()
    func stop()
}

/// Observes real-time network connectivity changes using `NWPathMonitor`.
/// Updates `isConnected` instantly when the device goes online/offline.
@MainActor
@Observable
final class NetworkMonitor: NetworkMonitoring {

    private(set) var isConnected = true
    private let monitor: NWPathMonitor
    private let queue = DispatchQueue(label: "com.qonto.networkmonitor")

    init() {
        monitor = NWPathMonitor()
    }

    func start() {
        monitor.pathUpdateHandler = { path in
            let satisfied = path.status == .satisfied
            Task { @MainActor [weak self] in
                self?.isConnected = satisfied
            }
        }
        monitor.start(queue: queue)
    }

    func stop() {
        monitor.cancel()
    }
}
