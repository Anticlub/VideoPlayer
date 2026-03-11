import SwiftUI

struct PlayerControlsView: View {

    enum FocusTarget: Hashable {
        case prev
        case playPause
        case next
        case stop
    }

    let onPrevious: () -> Void
    let onPlayPause: () -> Void
    let onNext: () -> Void
    let onStop: () -> Void

    @FocusState private var focused: FocusTarget?

    var body: some View {
        HStack(spacing: 60) {

            Button { onPrevious() } label: {
                Image(systemName: "backward.fill")
                    .font(.title)
                    .frame(width: 80, height: 80)
            }
            .focused($focused, equals: .prev)

            Button { onPlayPause() } label: {
                Image(systemName: "playpause.fill")
                    .font(.title)
                    .frame(width: 80, height: 80)
            }
            .focused($focused, equals: .playPause)
            .prefersDefaultFocus(true, in: focusNamespace)

            Button { onStop() } label: {
                Image(systemName: "stop.fill")
                    .font(.title)
            }
            .focused($focused, equals: .stop)
            
            Button { onNext() } label: {
                Image(systemName: "forward.fill")
                    .font(.title)
                    .frame(width: 80, height: 80)
            }
            .focused($focused, equals: .next)
        }
        // Le decimos a tvOS: “estos tres botones son una sección de foco”
        .focusSection()
        .padding(30)
        .background(.black.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .onAppear {
            // fallback por si el prefersDefaultFocus no entra por timing
            focused = .playPause
        }
    }


    @Namespace private var focusNamespace
}
