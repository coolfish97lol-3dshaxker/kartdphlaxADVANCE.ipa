import SwiftUI

struct ContentView: View {
    @EnvironmentObject var hostManager: HostManager

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("KARTDLPHAX ADVANCE")
                    .font(.system(size: 28, weight: .bold, design: .monospaced))
                    .multilineTextAlignment(.center)

                Text("TEST BUILD")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                VStack(spacing: 8) {
                    Text("STATUS")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(hostManager.status)
                        .font(.system(.title3, design: .monospaced))
                }

                HStack(spacing: 12) {
                    Button("BEGIN TEST") {
                        hostManager.start()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(hostManager.isRunning)

                    Button("STOP") {
                        hostManager.stop()
                    }
                    .buttonStyle(.bordered)
                    .disabled(!hostManager.isRunning)
                }

                Text("Connections: \(hostManager.connectionCount)")
                    .font(.system(.body, design: .monospaced))

                VStack(alignment: .leading, spacing: 8) {
                    Text("EVENT LOG")
                        .font(.headline)

                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 4) {
                            ForEach(hostManager.logs, id: \.self) { entry in
                                Text(entry)
                                    .font(.system(size: 13, design: .monospaced))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                    .padding()
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Spacer()
            }
            .padding()
            .navigationTitle("ADVANCE Test")
        }
    }
}
