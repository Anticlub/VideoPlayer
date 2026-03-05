import SwiftUI
import AVKit

struct PlayerView: UIViewControllerRepresentable {
    let player: AVPlayer?
    @Binding var state: PlayerState
    let showsPlaybackControls: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(state: $state)
    }

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        
        controller.player = player
        controller.showsPlaybackControls = showsPlaybackControls

        if let player {
            context.coordinator.attachPlayer(player)
            player.play()
        }
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        uiViewController.showsPlaybackControls = showsPlaybackControls
    }

    static func dismantleUIViewController(_ uiViewController: AVPlayerViewController, coordinator: Coordinator) {
        uiViewController.player?.pause()
        uiViewController.player = nil
        coordinator.detachPlayer()
    }

    final class Coordinator {
        private var state: Binding<PlayerState>
        private var observers: [NSKeyValueObservation] = []
        private(set) var player: AVPlayer?
        private var loadingTimeoutTask: DispatchWorkItem?

        init(state: Binding<PlayerState>) {
            self.state = state
        }

        func attachPlayer(_ player: AVPlayer) {
            self.player = player

            let timeObserver = player.observe(\.timeControlStatus, options: [.initial, .new]) { [weak self] player, _ in
                guard let self else { return }

                switch player.timeControlStatus {
                case .playing:
                    self.cancelLoadingTimeout()
                    self.update(.playing)
                case .waitingToPlayAtSpecifiedRate:
                    self.update(.loading)
                    self.scheduleLoadingTimeout()
                case .paused:
                    break
                @unknown default:
                    break
                }
            }
            observers.append(timeObserver)

            if let item = player.currentItem {
                let itemObserver = item.observe(\.status, options: [.initial, .new]) { [weak self] item, _ in
                    guard let self else { return }

                    if item.status == .failed {
                        self.cancelLoadingTimeout()
                        let message = item.error?.localizedDescription ?? "Unknown playback error"
                        self.update(.error(message))
                    }
                }
                observers.append(itemObserver)
            }
        }

        func detachPlayer() {
            cancelLoadingTimeout()
            observers.removeAll()
            player = nil
        }

        func update(_ newState: PlayerState) {
            DispatchQueue.main.async {
                self.state.wrappedValue = newState
            }
        }
        
        private func scheduleLoadingTimeout(seconds: TimeInterval = 8) {
            loadingTimeoutTask?.cancel()
            
            let task = DispatchWorkItem { [weak self] in
                guard let self else {return}
                
                if case .loading = self.state.wrappedValue {
                    self.update(.error("Timeout: no se pudo cargar el streaming. Intenta nuevamente."))
                }
            }
            
            loadingTimeoutTask = task
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: task)
        }
        
        private func cancelLoadingTimeout() {
            loadingTimeoutTask?.cancel()
            loadingTimeoutTask = nil
        }
        
    
    }
}
