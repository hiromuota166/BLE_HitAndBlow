//
//  BLEPeripheralManager.swift
//  BLE_HitAndBlow
//
//  Created by 太田啓夢 on 2026/10/01.
//

import CoreBluetooth

final class BLEPeripheralManager: NSObject {
    private var peripheralManager: CBPeripheralManager!

    private let serviceUUID = CBUUID(string: "811BF22E-693A-4FC4-830D-E5E3BD43EACB")
    private let characteristicUUID = CBUUID(string: "9F9239B7-7F6C-4062-AF04-CCC5C44ACD83")

    override init() {
        super.init()
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }

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

extension BLEPeripheralManager : CBPeripheralManagerDelegate {
    // Bluetooth の状態が変わると呼ばれる（必須のメソッド）
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case .poweredOn:
            print("Bluetooth ON")
            setupService()
        default:
            print("まだ使えない: \(peripheral.state.rawValue)")
        }
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        if let error { print("登録失敗: \(error)"); return }
        peripheral.startAdvertising([
            CBAdvertisementDataLocalNameKey: "HitAndBlow",
            CBAdvertisementDataServiceUUIDsKey: [serviceUUID],
        ])
    }

    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        print(error == nil ? "アドバタイズ開始" : "失敗: \(error!)")
    }
}
