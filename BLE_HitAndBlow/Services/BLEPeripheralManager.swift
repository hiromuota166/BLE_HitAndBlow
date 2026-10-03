//
//  BLEPeripheralManager.swift
//  BLE_HitAndBlow
//
//  Created by 太田啓夢 on 2026/10/01.
//

import CoreBluetooth

final class BLEPeripheralManager: NSObject {
    private var peripheralManager: CBPeripheralManager!

    override init() {
        super.init()
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
}

extension BLEPeripheralManager : CBPeripheralManagerDelegate {
    // Bluetooth の状態が変わると呼ばれる（必須のメソッド）
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case .poweredOn:
            print("Bluetooth ON")
        default:
            print("まだ使えない: \(peripheral.state.rawValue)")
        }
    }
}
