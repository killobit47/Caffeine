//
//  ContentView.swift
//  Caffeine
//
//  Created by Roman on 11.06.2025.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.caffeineViewModel) private var viewModel

    var body: some View {
        VStack(spacing: 16) {
            if viewModel.isRuning {
                runningView
            } else {
                idleView
            }

            HStack {
                Spacer()
                Button("Quit") {
                    NSApp.terminate(nil)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(.top)
        .frame(maxWidth: 400)
        .padding()
    }

    @ViewBuilder
    private var runningView: some View {
        VStack(spacing: 16) {
            Text("Started at: \(viewModel.formatted(date: viewModel.startTime!))")
                .font(.title3)
                .bold()

            if viewModel.isRunningForever {
                Text("Running indefinitely…")
                    .foregroundColor(.secondary)
            } else if let remainingSeconds = viewModel.remainingSeconds {
                VStack(spacing: 4) {
                    Text("Time remaining")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(viewModel.formatted(seconds: remainingSeconds))
                        .font(.title2)
                        .monospacedDigit()
                    if let total = viewModel.totalDuration {
                        let progressValue = max(0, min(Double(total - remainingSeconds), Double(total)))
                        ProgressView(value: progressValue, total: Double(total))
                            .progressViewStyle(.linear)
                    }
                }
                .padding(.top, 4)
            }

            VStack(spacing: 4) {
                Text("Elapsed")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(viewModel.formatted(seconds: viewModel.elapsed))
                    .monospacedDigit()
            }

            Button("Stop") {
                viewModel.stopSystemAwake()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(20)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .multilineTextAlignment(.center)
    }

    @ViewBuilder
    private var idleView: some View {
        @Bindable var viewModel = viewModel
        VStack(spacing: 20) {
            Button("Keep Awake Forever") {
                viewModel.keepSystemAwake(for: nil)
            }
            .buttonStyle(.borderedProminent)

            HStack {
                DatePicker("Until", selection: $viewModel.selectedDate, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                Button("Keep Awake") {
                    let duration = Calendar.current.dateComponents([.second], from: Date(), to: viewModel.selectedDate).second ?? 0
                    if duration > 0 {
                        viewModel.keepSystemAwake(for: duration)
                    }
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(20)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

#Preview {
    ContentView()
}
