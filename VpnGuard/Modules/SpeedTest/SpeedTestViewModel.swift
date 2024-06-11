//
//  SpeedTestViewModel.swift
//  VpnGuard
//
//  Created by Maisternya on 04.06.2024.
//

import Foundation
import NDT7
import Combine

enum SpeedTestStatus {
    case ready
    case connecting
    case download
    case upload
    case finish
    case error
    
    var title: String {
        switch self {
        case .error, .ready:
            "GO"
        case  .finish:
            "RESTART"
        case .connecting:
            "CONNECTING"
        case .download:
            "DOWNLOAD"
        case .upload:
            "UPLOAD"
        }
    }
    
    var isEnabled: Bool {
        self == .ready || self == .error || self == .finish
    }
}

class SpeedTestViewModel: ObservableObject {
    @Published var progress: Double = 0.0
    @Published var downloadSpeed: String = "__.__"
    @Published var uploadSpeed: String = "__.__"
    @Published var error: Error?
    @Published var status: SpeedTestStatus = .ready
    var cancellable = Set<AnyCancellable>()
    
    private var ndt7Test: NDT7Test?
    private let urlInput: String = "https://github.com"
    
    init() { }
    
    func startTest() {
        status = .connecting
        let settings = NDT7Settings()
        ndt7Test = NDT7Test(settings: settings)
        ndt7Test?.delegate = self
        ndt7Test?.startTest(download: true, upload: true) { [weak self] error in
            if let error  {
                DispatchQueue.main.async {
                    self?.status = .error
                    self?.error = error
                }
            } else {
                DispatchQueue.main.async {
                    self?.status = .finish
                }
            }
        }
    }
    
    func cancelTest() {
        ndt7Test?.cancel()
    }
}

extension SpeedTestViewModel: NDT7TestInteraction {
    func test(kind: NDT7TestConstants.Kind, running: Bool) {

    }

    func measurement(origin: NDT7TestConstants.Origin, kind: NDT7TestConstants.Kind, measurement: NDT7Measurement) {
        switch kind {
        case .download:
            if let numBytes = measurement.appInfo?.numBytes, let elapsedTime = measurement.appInfo?.elapsedTime {
                var speed = (((Double(numBytes) * 8) / (Double(elapsedTime) / 1_000_000))) / 1_000_000
                speed = speed > 0.01 ? speed : Double.random(in: 0.005...0.01)
                DispatchQueue.main.async {
                    self.status = .download
                    self.downloadSpeed = String(format: "%.2f Mbps", speed)
                    self.progress = speed >= 100 ? 1 : speed / 100 + 0.05
                }
            }
        case .upload:
            if let numBytes = measurement.appInfo?.numBytes, let elapsedTime = measurement.appInfo?.elapsedTime {
                var speed = (((Double(numBytes) * 8) / (Double(elapsedTime) / 1_000_000))) / 1_000_000
                speed = speed > 0.01 ? speed : Double.random(in: 0.005...0.01)
                DispatchQueue.main.async {
                    self.status = .upload
                    self.uploadSpeed = String(format: "%.2f Mbps", speed)
                    self.progress = speed >= 100 ? 1 : speed / 100 + 0.05
                }
            }
        }
    }

    func error(kind: NDT7TestConstants.Kind, error: NSError) {
        print("NDT7 iOS Example app - Error during test: \(error.localizedDescription)")
    }
}
