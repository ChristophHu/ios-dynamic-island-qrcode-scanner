//
//  ContentView.swift
//  ios-dynamic-island-qrcode-scanner
//
//  Created by Christoph Huschenhöfer on 26.03.26.
//

import SwiftUI

struct ContentView: View {
    @State private var showScanner: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                Button("Show Scanner") {
                    showScanner.toggle()
                }
            }
            .navigationTitle("QR Scanner")
            .qrScanner(isScanning: $showScanner) { code in
                print("Scanned code:", code)
            }
        }
    }
}

#Preview {
    ContentView()
}
