import SwiftUI

public struct BackgroundBlurView: View {

    private struct Ball: Identifiable {
        var id: UUID
        var position: CGPoint
        let color: Color
    }

    @State private var balls: [Ball] = []
    @State private var frameSize: CGSize = .zero

    private let timer = Timer.publish(every: 0.5, on: .main, in: .common)
        .autoconnect()
        .receive(on: RunLoop.main)

    private let ballCount = 4
    private let ballSize = 300
    private let ballColors: [Color] = [.aquamarine]
    private let backgroundColor = Color.risdBlue

    public init() {}

    public var body: some View {
        GeometryReader { proxy in
            backgroundColor
                .scaleEffect(2)
                .ignoresSafeArea(edges: .vertical)
                .overlay {
                    ForEach(balls) { ball in
                        Circle()
                            .fill(ball.color)
                            .frame(width: CGFloat(ballSize), height: CGFloat(ballSize))
                            .position(ball.position)
                    }
                }
                .onReceive(timer) { _ in
                    withAnimation(.easeInOut(duration: 5)) {

                        for i in 0..<ballCount {
                            balls[i].position = randomPosition(in: frameSize, ballSize: .init(width: ballSize, height: ballSize))
                        }
                    }
                }
                .onAppear {
                    frameSize = proxy.size
                    balls = []
                    for _ in 0..<ballCount {
                        balls.append(.init(
                            id: UUID(),
                            position: randomPosition(in: frameSize, ballSize: .init(width: ballSize, height: ballSize)),
                            color: ballColors.randomElement() ?? .risdBlue)
                        )
                    }
                }
        }
        .blur(radius: 100)
        .overlay {
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea(.container)
        }
        .preferredColorScheme(.light)
    }

    private func randomPosition(in bounds: CGSize, ballSize: CGSize) -> CGPoint {
        let xRange = -(bounds.width/2)...bounds.width*1.5
        let yRange = -(bounds.height/2)...bounds.height*1.5

        let randomX = CGFloat.random(in: xRange)
        let randomY = CGFloat.random(in: yRange)

        let offsetX = randomX
        let offsetY = randomY

        return CGPoint(x: offsetX, y: offsetY)
    }
}

#Preview {
    BackgroundBlurView()
}
