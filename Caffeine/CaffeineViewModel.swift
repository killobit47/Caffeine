//
//  CaffeineViewModel.swift
//  Caffeine
//
//  Created by Roman on 12.06.2025.
//

import SwiftUI
import AVFoundation

@Observable
final class CaffeineViewModel: @unchecked Sendable {
    var selectedDate: Date = Calendar.current.date(bySetting: .second, value: 0, of: .now) ?? .now
    var startTime: Date?
    var remainingSeconds: Int?
    var totalDuration: Int?
    var elapsed: Int = 0
    var isRunningForever = false

    private var timer: Timer?
    private var awakeTask: Process?
    private var audioPlayer: AVAudioPlayer?

    var isRuning: Bool {
        startTime != nil
    }

    func keepSystemAwake(for seconds: Int? = nil) {
        playSound(named: "start", volume: 0.25)
        let task = Process()
        task.launchPath = "/usr/bin/env"
        task.arguments = seconds != nil ? ["caffeinate", "-dims", "-t", "\(seconds!)"] : ["caffeinate", "-dims"]
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
        playSound(named: "stop", volume: 0.05)
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

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            guard let start = self.startTime else { return }
            self.elapsed = Int(Date().timeIntervalSince(start))
            if let remaining = self.remainingSeconds {
                if self.elapsed >= remaining {
                    DispatchQueue.main.async {
                        self.stopSystemAwake()
                    }
                } else {
                    self.remainingSeconds = remaining - 1
                }
            }
        }
    }

    private func playSound(named name: String, volume: Float) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "wav") else { return }
        audioPlayer = try? AVAudioPlayer(contentsOf: url)
        audioPlayer?.volume = volume
        audioPlayer?.play()
    }

    func formatted(seconds: Int) -> String {
        let hrs = seconds / 3600
        let mins = (seconds % 3600) / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d:%02d", hrs, mins, secs)
    }

    func formatted(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        return formatter.string(from: date)
    }
}

extension EnvironmentValues {
    @Entry var caffeineViewModel = CaffeineViewModel()
}
