//
//  ContentView.swift
//  BLE_HitAndBlow
//
//  Created by 太田啓夢 on 2026/10/01.
//

import SwiftUI

struct ContentView: View {
    @State private var manager = BLEPeripheralManager()
    var body: some View {
        Text("BLE Hit & Blow")
    }
}

#Preview {
    ContentView()
}
