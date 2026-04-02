//
//  ContentView.swift
//  ios-dynamic-island-qrcode-scanner
//
//  Created by Christoph Huschenhöfer on 26.03.26.
//

import SwiftUI

struct ContentView: View {
    @State private var showScanner: Bool = false
    @State private var scannedCode: String = ""
    
    var body: some View {
        NavigationStack {
            List {
                Button("Show Scanner") {
                    showScanner.toggle()
                }
                if !scannedCode.isEmpty {
                    Text(scannedCode)
                        .font(.body)
                        .foregroundStyle(.primary)
                }
            }
            .navigationTitle("QR Scanner")
            .scanner(isScanning: $showScanner) { code in
                print("Scanned code:", code)
                scannedCode = code
            }
        }
    }
}

#Preview {
    ContentView()
}
