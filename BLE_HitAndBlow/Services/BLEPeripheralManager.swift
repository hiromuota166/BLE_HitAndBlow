//
//  BLEPeripheralManager.swift
//  BLE_HitAndBlow
//
//  Created by 太田啓夢 on 2026/10/01.
//

import CoreBluetooth
import Observation

// Peripheral（お店）として動くクラス
// Service と Characteristic を登録してアドバタイズ（看板）を出し、Central が来るのを待つ
// Mac → iPhone は Notify、iPhone → Mac は Write。1つの Characteristic で両方向に使う
// NSObject の継承は、Objective-C 由来の delegate プロトコルに準拠するために必要
@Observable
final class BLEPeripheralManager: NSObject {
    private var peripheralManager: CBPeripheralManager!
    private var characteristic: CBMutableCharacteristic?  // send() で後から使うので保持しておく

    var receivedText = "受信待ち…"

    private let serviceUUID = CBUUID(string: "811BF22E-693A-4FC4-830D-E5E3BD43EACB")
    private let characteristicUUID = CBUUID(string: "9F9239B7-7F6C-4062-AF04-CCC5C44ACD83")

    override init() {
        super.init()
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }

    // Characteristic（品物）を Service（売り場）に入れて登録する。poweredOn になってから呼ぶこと
    private func setupService() {
        let characteristic = CBMutableCharacteristic(
            type: characteristicUUID,
            properties: [.notify, .write],
            value: nil,
            permissions: [.readable, .writeable]  // properties は「できる操作」、permissions は「許可」。書き込みは両方に必要
        )
        self.characteristic = characteristic

        let service = CBMutableService(type: serviceUUID, primary: true)
        service.characteristics = [characteristic]

        peripheralManager.add(service)
    }

    // Notify で値を送る。購読している Central に届く
    func send(_ text: String) {
        guard let characteristic, let data = text.data(using: .utf8) else { return }
        let sent = peripheralManager.updateValue(data, for: characteristic, onSubscribedCentrals: nil)
        print(sent ? "送った: \(text)" : "送れなかった（送信待ちがいっぱい）")
    }
}

// CBPeripheralManager からの知らせを受け取る
// 流れ: poweredOn → setupService() → didAdd → startAdvertising → DidStartAdvertising →（Central が購読）→ 購読の知らせ
// iPhone から Write されたら → 受け取って返事をする
extension BLEPeripheralManager : CBPeripheralManagerDelegate {
    // Bluetooth の状態が変わると呼ばれる（必須のメソッド）。poweredOn になったら Service を登録する
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case .poweredOn:
            print("Bluetooth ON")
            setupService()
        default:
            print("まだ使えない: \(peripheral.state.rawValue)")
        }
    }

    // Service の登録が終わると呼ばれる。ここでアドバタイズを始める
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        if let error { print("登録失敗: \(error)"); return }
        peripheral.startAdvertising([
            CBAdvertisementDataLocalNameKey: "HitAndBlow",
            CBAdvertisementDataServiceUUIDsKey: [serviceUUID],
        ])
    }

    // アドバタイズが始まると呼ばれる
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        print(error == nil ? "アドバタイズ開始" : "失敗: \(error!)")
    }

    // Central が Notify を購読すると呼ばれる
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        print("購読された")
    }

    // Central から Write されると呼ばれる（ラベルは補完で選ぶ）
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        for request in requests {
            guard let data = request.value else { continue }
            receivedText = String(data: data, encoding: .utf8) ?? "文字にできませんでした"
            print("受け取った: \(receivedText)")
        }
        // 返事は最初のリクエストに1回だけ返す（まとめて全部への返事になる）
        peripheral.respond(to: requests[0], withResult: .success)
    }
}
