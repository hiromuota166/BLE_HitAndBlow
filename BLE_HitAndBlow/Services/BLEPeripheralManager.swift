//
//  BLEPeripheralManager.swift
//  BLE_HitAndBlow
//
//  Created by 太田啓夢 on 2026/10/01.
//

import CoreBluetooth

// Peripheral（送る側・お店）として動くクラス
// Service と Characteristic を登録してアドバタイズ（看板）を出し、Central が来るのを待つ
// Characteristic は作成時に value を入れているので、Read されたら CoreBluetooth が自動で返事をする
// NSObject の継承は、Objective-C 由来の delegate プロトコルに準拠するために必要
final class BLEPeripheralManager: NSObject {
    private var peripheralManager: CBPeripheralManager!

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
            properties: [.read],
            value: "Hello world".data(using: .utf8),
            permissions: [.readable]
        )

        let service = CBMutableService(type: serviceUUID, primary: true)
        service.characteristics = [characteristic]

        peripheralManager.add(service)
    }
}

// CBPeripheralManager からの知らせを受け取る
// 流れ: poweredOn → setupService() → didAdd → startAdvertising → DidStartAdvertising
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
}
