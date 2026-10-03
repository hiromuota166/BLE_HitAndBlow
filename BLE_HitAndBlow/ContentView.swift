//
//  ContentView.swift
//  BLE_HitAndBlow
//
//  Created by 太田啓夢 on 2026/10/01.
//

import SwiftUI

struct ContentView: View {
    #if os(macOS)
    @State private var manager = BLEPeripheralManager()
    #else
    @State private var manager = BLECentralManager()
    #endif
    var body: some View {
        Text("BLE Hit & Blow")
    }
}

#Preview {
    ContentView()
}
