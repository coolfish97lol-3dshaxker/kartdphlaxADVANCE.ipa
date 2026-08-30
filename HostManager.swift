import Foundation
import Network
import SwiftUI

final class HostManager: ObservableObject {

    @Published private(set) var status = "STOPPED"
    @Published private(set) var connectionCount = 0
    @Published private(set) var logs: [String] = []

    private var listener: NWListener?
    private let queue = DispatchQueue(label: "advance.host.queue")

    var isRunning: Bool {
        listener != nil
    }

    func start() {
        guard listener == nil else { return }

        addLog("Starting diagnostic host...")

        do {
            let parameters = NWParameters.tcp

            let listener = try NWListener(
                using: parameters,
                on: NWEndpoint.Port(rawValue: 45678)!
            )

            listener.stateUpdateHandler = { [weak self] state in
                DispatchQueue.main.async {
                    self?.handle(state)
                }
            }

            listener.newConnectionHandler = { [weak self] connection in
                self?.handle(connection)
            }

            self.listener = listener
            listener.start(queue: queue)

        } catch {
            addLog("Failed to start: \(error.localizedDescription)")
            status = "ERROR"
        }
    }

    func stop() {
        listener?.cancel()
        listener = nil

        status = "STOPPED"
        addLog("Diagnostic host stopped.")
    }

    private func handle(_ state: NWListener.State) {
        switch state {

        case .setup:
            status = "SETTING UP"
            addLog("Listener setup.")

        case .waiting(let error):
            status = "WAITING"
            addLog("Listener waiting: \(error.localizedDescription)")

        case .ready:
            status = "LISTENING"
            addLog("Listening on port 45678.")

        case .failed(let error):
            status = "FAILED"
            addLog("Listener failed: \(error.localizedDescription)")

        case .cancelled:
            status = "STOPPED"
            addLog("Listener cancelled.")

        @unknown default:
            status = "UNKNOWN"
        }
    }

    private func handle(_ connection: NWConnection) {
        DispatchQueue.main.async {
            self.connectionCount += 1
            self.addLog("Incoming connection.")
        }

        connection.stateUpdateHandler = { [weak self] state in
            switch state {

            case .ready:
                DispatchQueue.main.async {
                    self?.addLog("Connection established.")
                }

                self?.sendTestMessage(connection)

            case .failed(let error):
                DispatchQueue.main.async {
                    self?.addLog(
                        "Connection failed: \(error.localizedDescription)"
                    )
                }

            case .cancelled:
                DispatchQueue.main.async {
                    self?.addLog("Connection closed.")
                }

            default:
                break
            }
        }

        connection.start(queue: queue)
    }

    private func sendTestMessage(_ connection: NWConnection) {
        let message = Data("ADVANCE_TEST_OK\n".utf8)

        connection.send(
            content: message,
            completion: .contentProcessed { [weak self] error in

                DispatchQueue.main.async {
                    if let error {
                        self?.addLog(
                            "Send failed: \(error.localizedDescription)"
                        )
                    } else {
                        self?.addLog("Sent harmless test message.")
                    }
                }

                connection.cancel()
            }
        )
    }

    private func addLog(_ message: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"

        let timestamp = formatter.string(from: Date())

        logs.append("[\(timestamp)] \(message)")

        if logs.count > 100 {
            logs.removeFirst()
        }
    }
}
