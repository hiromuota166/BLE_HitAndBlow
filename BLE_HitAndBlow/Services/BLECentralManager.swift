//
//  BLECentralManager.swift
//  BLE_HitAndBlow
//
//  Created by 太田啓夢 on 2026/10/04.
//

import CoreBluetooth

final class BLECentralManager: NSObject {
    private var centralManager: CBCentralManager!

    private let serviceUUID = CBUUID(string: "811BF22E-693A-4FC4-830D-E5E3BD43EACB")

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
}

extension BLECentralManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        guard central.state == .poweredOn else {
            print("まだ使えない: \(central.state.rawValue)")
            return
        }
        central.scanForPeripherals(withServices: [serviceUUID], options: nil)
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any], rssi RSSI: NSNumber) {
        print("見つけた: \(peripheral.name ?? "名前なし") RSSI: \(RSSI)")
    }
}
