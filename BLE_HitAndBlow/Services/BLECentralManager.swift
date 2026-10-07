//
//  BLECentralManager.swift
//  BLE_HitAndBlow
//
//  Created by 太田啓夢 on 2026/10/04.
//

import CoreBluetooth
import Observation

// Central（お客さん）として動くクラス
// Service UUID で看板を探して接続し、Characteristic の通知を購読して、届いた値を receivedText に入れる
// 送るときは同じ Characteristic に Write する
// @Observable なので、receivedText が変わると SwiftUI の画面が自動で描き直される
@Observable
final class BLECentralManager: NSObject {
    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral?
    private var characteristic: CBCharacteristic?  // send() で後から使うので保持しておく

    private let serviceUUID = CBUUID(string: "811BF22E-693A-4FC4-830D-E5E3BD43EACB")
    private let characteristicUUID = CBUUID(string: "9F9239B7-7F6C-4062-AF04-CCC5C44ACD83")

    var receivedText = "受信待ち…"

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    // Write で値を送る。返事あり（withResponse）なので、届いたかどうかが分かる
    func send(_ text: String) {
        guard let peripheral, let characteristic, let data = text.data(using: .utf8) else { return }
        peripheral.writeValue(data, for: characteristic, type: .withResponse)
    }
}

// CBCentralManager（スキャン・接続の係）からの知らせを受け取る
// 流れ: poweredOn → スキャン → didDiscover → connect → didConnect → Service を探す
extension BLECentralManager: CBCentralManagerDelegate {
    // Bluetooth の状態が変わると呼ばれる（必須のメソッド）。poweredOn になったらスキャンを始める
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        guard central.state == .poweredOn else {
            print("まだ使えない: \(central.state.rawValue)")
            return
        }
        central.scanForPeripherals(withServices: [serviceUUID], options: nil)
    }

    // 看板を見つけると呼ばれる。相手を保持してスキャンを止め、接続する
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

// 接続した相手（CBPeripheral）からの知らせを受け取る
// 流れ: didDiscoverServices → Characteristic を探す → didDiscoverCharacteristicsFor → 通知を購読 → 値が届くたびに didUpdateValueFor
// send() で Write したら → Mac の返事が来て didWriteValueFor
extension BLECentralManager: CBPeripheralDelegate {
    // Service が見つかったら呼ばれる
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let service = peripheral.services?.first(where: { $0.uuid == serviceUUID }) else { return }
        peripheral.discoverCharacteristics([characteristicUUID], for: service)
    }

    // Characteristic が見つかったら呼ばれる
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristic = service.characteristics?.first(where: { $0.uuid == characteristicUUID }) else { return }
        self.characteristic = characteristic
        peripheral.setNotifyValue(true, for: characteristic)
    }

    // Write の返事が来ると呼ばれる（ラベルは補完で選ぶ）
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        print(error == nil ? "送れた" : "送れなかった: \(error!)")
    }
    
    // 通知の受け取り設定が変わると呼ばれる
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        print(error == nil ? "通知ON: \(characteristic.isNotifying)" : "通知の設定に失敗: \(error!)")
    }

    // 値が届いたら呼ばれる
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let data = characteristic.value else { return }
        receivedText = String(data: data, encoding: .utf8) ?? "文字にできませんでした"
        print("受け取った: \(receivedText)")
    }
}
