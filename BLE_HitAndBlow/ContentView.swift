//
//  ContentView.swift
//  BLE_HitAndBlow
//
//  Created by 太田啓夢 on 2026/10/01.
//

import SwiftUI

// 最初の画面。練習用に Mac を Peripheral、iPhone を Central に固定している
// #if はビルド時の分岐なので、Mac 用アプリには上側、iPhone 用アプリには下側だけが入る
// iPhone 同士にするときは、ボタンなど実行時の if で役割を選ぶ形に変える
struct ContentView: View {
    // @State で持つことで body が何度呼ばれても同じインスタンスが生き続け、delegate の知らせを受け取れる
    #if os(macOS)
    @State private var manager = BLEPeripheralManager()
    #else
    @State private var manager = BLECentralManager()
    #endif
    @State private var text = ""

    // どちらの manager も receivedText と send(_:) を持っているので、画面は共通で書ける
    var body: some View {
        VStack {
            Text("受信: \(manager.receivedText)")
            TextField("送る文字", text: $text)
            Button("送る") { manager.send(text) }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
