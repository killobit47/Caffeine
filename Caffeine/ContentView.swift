//
//  ContentView.swift
//  Caffeine
//
//  Created by Roman on 11.06.2025.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedDate: Date = Calendar.current.date(bySetting: .second, value: 0, of: .now) ?? .now
    @State private var startTime: Date?
    @State private var remainingSeconds: Int?
    @State private var totalDuration: Int?
    @State private var elapsed: Int = 0
    @State private var timer: Timer?
    @State private var isRunningForever = false
    @State private var awakeTask: Process?

    var body: some View {
        VStack(spacing: 16) {
            if let startTime = startTime {
                VStack(spacing: 16) {
                    Text("Started at: \(formatted(date: startTime))")
                        .font(.title3)
                        .bold()

                    if isRunningForever {
                        Text("Running indefinitely…")
                            .foregroundColor(.secondary)
                    } else if let remainingSeconds = remainingSeconds {
                        VStack(spacing: 4) {
                            Text("Time remaining")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(formatted(seconds: remainingSeconds))
                                .font(.title2)
                                .monospacedDigit()
                            if let total = totalDuration {
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
                        Text(formatted(seconds: elapsed))
                            .monospacedDigit()
                    }

                    Button("Stop") {
                        stopSystemAwake()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(20)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                .multilineTextAlignment(.center)
            } else {
                VStack(spacing: 20) {
                    Button("Keep Awake Forever") {
                        keepSystemAwake(for: nil)
                    }
                    .buttonStyle(.borderedProminent)

                    HStack {
                        DatePicker("Until", selection: $selectedDate, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                        Button("Keep Awake") {
                            let duration = Calendar.current.dateComponents([.second], from: Date(), to: selectedDate).second ?? 0
                            if duration > 0 {
                                keepSystemAwake(for: duration)
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding(20)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
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

    func keepSystemAwake(for seconds: Int? = nil) {
        let task = Process()
        task.launchPath = "/usr/bin/env"
        if let seconds = seconds {
            task.arguments = ["caffeinate", "-dims", "-t", "\(seconds)"]
        } else {
            task.arguments = ["caffeinate", "-dims"]
        }
        task.launch()
        awakeTask = task

        startTime = .now
        remainingSeconds = seconds
        totalDuration = seconds
        isRunningForever = seconds == nil
        elapsed = 0
        startTimer()
    }

    func stopSystemAwake() {
        awakeTask?.terminate()

        let kill = Process()
        kill.launchPath = "/usr/bin/killall"
        kill.arguments = ["caffeinate"]
        kill.launch()

        awakeTask = nil
        timer?.invalidate()
        remainingSeconds = nil
        totalDuration = nil
        startTime = nil
        elapsed = 0
        isRunningForever = false
    }

    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if let start = startTime {
                elapsed = Int(Date().timeIntervalSince(start))
                if let remainingSeconds {
                    if elapsed >= remainingSeconds {
                        stopSystemAwake()

                    } else  {
                        self.remainingSeconds = remainingSeconds - 1
                    }
                }
            }
        }
    }

    func formatted(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        return formatter.string(from: date)
    }

    func formatted(seconds: Int) -> String {
        let hrs = seconds / 3600
        let mins = (seconds % 3600) / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d:%02d", hrs, mins, secs)
    }
}

#Preview {
    ContentView()
}
