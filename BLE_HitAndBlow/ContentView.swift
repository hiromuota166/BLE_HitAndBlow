//
//  ContentView.swift
//  BLE_HitAndBlow
//
//  Created by 太田啓夢 on 2026/10/01.
//

import SwiftUI

// 最初の画面。練習用に Mac を Peripheral（送る側）、iPhone を Central（受け取る側）に固定している
// #if はビルド時の分岐なので、Mac 用アプリには上側、iPhone 用アプリには下側だけが入る
// iPhone 同士にするときは、ボタンなど実行時の if で役割を選ぶ形に変える
struct ContentView: View {
    // @State で持つことで body が何度呼ばれても同じインスタンスが生き続け、delegate の知らせを受け取れる
    #if os(macOS)
    @State private var manager = BLEPeripheralManager()
    #else
    @State private var manager = BLECentralManager()
    #endif
    var body: some View {
        #if os(macOS)
        Text("Mac: 送信側")
        #else
        Text(manager.receivedText)
        #endif
    }
}

#Preview {
    ContentView()
}
