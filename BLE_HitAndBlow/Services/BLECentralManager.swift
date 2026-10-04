//
//  BLECentralManager.swift
//  BLE_HitAndBlow
//
//  Created by 太田啓夢 on 2026/10/04.
//

import CoreBluetooth
import Observation

@Observable
final class BLECentralManager: NSObject {
    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral?

    private let serviceUUID = CBUUID(string: "811BF22E-693A-4FC4-830D-E5E3BD43EACB")
    private let characteristicUUID = CBUUID(string: "9F9239B7-7F6C-4062-AF04-CCC5C44ACD83")

    var receivedText = "受信待ち…"

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
        self.peripheral = peripheral  // 保持しておかないとperipheralが消えてしまう
        central.stopScan()
        central.connect(peripheral, options: nil)
    }

    // 接続できたら呼ばれる
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("接続した")
        peripheral.delegate = self
        peripheral.discoverServices([serviceUUID])
    }

    // 接続に失敗したら呼ばれる
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("接続失敗: \(String(describing: error))")
    }
}

extension BLECentralManager: CBPeripheralDelegate {
    // Service が見つかったら呼ばれる
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let service = peripheral.services?.first(where: { $0.uuid == serviceUUID }) else { return }
        peripheral.discoverCharacteristics([characteristicUUID], for: service)
    }

    // Characteristic が見つかったら呼ばれる
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristic = service.characteristics?.first(where: { $0.uuid == characteristicUUID }) else { return }
        peripheral.readValue(for: characteristic)
    }

    // 値が届いたら呼ばれる
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let data = characteristic.value else { return }
        receivedText = String(data: data, encoding: .utf8) ?? "文字にできませんでした"
        print("受け取った: \(receivedText)")
    }
}
