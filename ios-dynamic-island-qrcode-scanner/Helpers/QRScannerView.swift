//
//  QRScannerView.swift
//  ios-dynamic-island-qrcode-scanner
//
//  Created by Christoph Huschenhöfer on 26.03.26.
//

import SwiftUI

extension View {
    @ViewBuilder
    func qrScanner(isScanning: Binding<Bool>, onScan: @escaping (String) -> Void) -> some View {
        self
            .modifier(QRScannerViewModifier(isScanning: isScanning, onScan: onScan))
    }
}

fileprivate struct QRScannerViewModifier: ViewModifier {
    @Binding var isScanning: Bool
    var onScan: (String) -> Void
    
    @State private var showFullScreenCover: Bool = false
    
    func body(content: Content) -> some View {
        content
            .fullScreenCover(isPresented: $showFullScreenCover) {
                QRScannerView {
                    isScanning = false
                    Task { @MainActor in
                        showFullScreenCoverWithAnimation(false)
                    }
                } onScan: { code in
                    onScan(code)
                }
                .presentationBackground(.clear)
            }
            .onChange(of: isScanning) {
                oldValue, newValue in
                if newValue {
                    showFullScreenCoverWithAnimation(true)
                }
            }
    }
    
    private func showFullScreenCoverWithAnimation(_ status: Bool) {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            showFullScreenCover = status
        }
    }
}

fileprivate struct QRScannerView: View {
    var onClose: () -> ()
    var onScan: (String) -> Void
    @State private var isInitialized: Bool = false
    @State private var showContent: Bool = false
    @State private var isExpanding: Bool = false
    var body: some View {
        // Button("Close", action: onClose)
        GeometryReader {
            let size = $0.size
            let safeArea = $0.safeAreaInsets
            
            let haveDynamicIsland: Bool = safeArea.top > 59
            let dynamicIslandWidth: CGFloat = 120
            let dynamicIslandHeight: CGFloat = 36
            let topOffset: CGFloat = (11 + max((safeArea.top - 59), 0))

            let expandedWidth: CGFloat = size.width - 30
            let expandedHeight: CGFloat = expandedWidth
            
            ZStack(alignment: .top) {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .overlay {
                        GeometryReader {
                            let cameraSize = $0.size
                            
                            ScannerView(cameraSize)
                        }
                        .overlay(alignment: .bottom) {
                            Text("Scanning for QR Code...")
                                .font(.caption2)
                                .foregroundStyle(.white.secondary)
                                .lineLimit(1)
                                .fixedSize()
                                .offset(x: 15)
                        }
                        .padding(80)
                        .compositingGroup()
                        .blur(radius: isExpanding ? 0 : 20)
                        .opacity(isExpanding ? 1 : 0)
                        .geometryGroup()
                    }
                    .contentShape(.rect)
                    .opacity(isExpanding ? 1 : 0)
                    .onTapGesture {
                        toggle(false)
                    }
                
                if showContent {
                    ConcentricRectangle(corners: .concentric(minimum: .fixed(30)), isUniform: true)
                        .frame(
                            width: isExpanding ? expandedWidth : dynamicIslandWidth,
                            height: isExpanding ? expandedHeight : dynamicIslandHeight
                        )
                        .offset(y: topOffset)
                        .background {
                            if isExpanding {
                                Rectangle()
                                    .fill(.clear)
                                    .onDisappear {
                                        showContent = false
                                    }
                            }
                        }
                        .transition(.identity)
                        .onDisappear {
                            onClose()
                        }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .ignoresSafeArea()
            .task {
                guard !isInitialized else { return }
                isInitialized = true
                showContent = true
                try? await Task.sleep(for: .seconds(0.05))
                toggle(true)
            }
        }
    }
    
    @ViewBuilder
    private func ScannerView(_ size: CGSize) -> some View {
        let shape = RoundedRectangle(cornerRadius: size.width * 0.05, style: .continuous)
        
        ZStack {
            shape
                .stroke(.white, lineWidth: 2)
        }
        .frame(width: size.width, height: size.height)
    }
    
    private func toggle(_ status: Bool) {
        withAnimation(.interpolatingSpring(duration: 0.3, bounce: 0, initialVelocity: 0)) {
            isExpanding = status
        }
    }
}

#Preview {
    ContentView()
}
