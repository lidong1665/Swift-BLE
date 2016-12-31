//
//  ViewController.swift
//  Swift-BLE
//
//  Created by lidong on 16/7/3.
//  Copyright © 2016年 李东. All rights reserved.
//

import UIKit

class ViewController: UIViewController,CBCentralManagerDelegate,CBPeripheralDelegate {

    var  myCentralManager:CBCentralManager!
    var  myPeripheral:CBPeripheral!
    var writeCharacteristic:CBCharacteristic!
    //设备名
    var DEVICENAME:String = "BLE-EMP-Ui"
    //特征名
    var CHARACTERISTIC:String = "2AF1"
    //发送获取数据的指令
    var SECRETKEY:String = "938E0400080410"
    var getbytes :[UInt8]    = [0x93, 0x8e, 0x04, 0x00, 0x08, 0x04, 0x10]
    /// 存储最终拼到一起的结果
    var result:String = ""
    
    var lable:UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myCentralManager = CBCentralManager()
        myCentralManager.delegate = self
        
        let  open:UIButton = UIButton()
        open.backgroundColor = UIColor.blue
        //设置按钮的位置和大小
        open.frame = CGRect(x: 80, y: 80, width: 150, height: 44)
        //设置按钮的文字
        open.setTitle("打开", for: UIControlState())
        //设置按钮的点击事件
        open.addTarget(self, action: #selector(ViewController.buttonTag(_:)), for: UIControlEvents.touchUpInside)
        open.tag = 10
        self.view.addSubview(open)
        
        
        let  open1:UIButton = UIButton()
        open1.backgroundColor = UIColor.blue
        //设置按钮的位置和大小
        open1.frame = CGRect(x: 80, y: 150, width: 150, height: 44)
        //设置按钮的文字
        open1.setTitle("发送读取数据指令", for: UIControlState())
        //设置按钮的点击事件
        open1.addTarget(self, action: #selector(ViewController.buttonTag(_:)), for: UIControlEvents.touchUpInside)
        open1.tag = 20
        self.view.addSubview(open1)
        
        let rect = CGRect(x: 10, y: 220, width: 280, height: 30)
        lable = UILabel(frame: rect)
        lable.text = "无数据"
        let font = UIFont(name: "宋体",size: 12)
        lable.font = font
        //设置文字的阴影颜色
        lable.shadowColor = UIColor.lightGray
        //设置标签文字的阴影在横向和纵向的偏移距离
        lable.shadowOffset = CGSize(width: 2,height: 2)
        //设置文字的对其的方式
        lable.textAlignment = NSTextAlignment.center
        //设置标签文字的颜色
        lable.textColor = UIColor.purple//紫色
        //设置标签的背景颜色为黄色
        lable.backgroundColor = UIColor.yellow
        
        self.view.addSubview(lable)

        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    func buttonTag(_ btn:UIButton) {
    
        switch btn.tag {
        case 10:
            print("扫描设备。。。。 ");
            myCentralManager.scanForPeripherals(withServices: nil, options: nil)
            break
        case 20:
            //向设备发送指令
            writeToPeripheral(getbytes)
            break
        default:
            break
        }
        
    }

    
    /**
     发送指令到设备
     */
    func writeToPeripheral(_ bytes:[UInt8]) {
        if writeCharacteristic != nil {
            let data1:Data = dataWithHexstring(bytes)
            
            self.myPeripheral.writeValue(data1, for: writeCharacteristic, type: CBCharacteristicWriteType.withResponse)
            
        } else{
        
       
        }
    }
    
    /**
     将[UInt8]数组转换为NSData
     
     - parameter bytes: <#bytes description#>
     
     - returns: <#return value description#>
     */
    
    func dataWithHexstring(_ bytes:[UInt8]) -> Data {
        let data = Data(bytes: UnsafePointer<UInt8>(bytes), count: bytes.count)
        return data
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
    /**
     <#Description#>
     
     - parameter central:    <#central description#>
     - parameter peripheral: <#peripheral description#>
     - parameter error:      <#error description#>
     */
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        switch (central.state) {
        case .poweredOn:
            print("蓝牙已打开, 请扫描外设!");
            break;
        case .poweredOff:
            print("蓝牙关闭，请先打开蓝牙");
        default:
            break;
        }
    }
    
    func isBluetoothAvailable() -> Bool {
        if #available(iOS 10.0, *) {
            return myCentralManager.state == CBManagerState.poweredOn
        } else {
            return myCentralManager.state  == .poweredOn
        }
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("-----centralManagerDidUpdateState----------")
        print(central.state)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("--didFailToConnectPeripheral--")
    }
    //发现设备
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("--didDiscoverPeripheral-")
        if peripheral.name == DEVICENAME{
            self.myPeripheral = peripheral;
            self.myCentralManager = central;
            central.connect(self.myPeripheral, options: nil)
            print(self.myPeripheral);
        }
        
    }
    
    //设备已经接成功
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("---------didConnectPeripheral-")
        print(central)
        print(peripheral)
        //关闭扫描
        self.myCentralManager.stopScan()
        self.myPeripheral.delegate = self
        self.myPeripheral.discoverServices(nil)
        print("扫描服务...");
    }
    
    
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        
        print("---------willRestoreState---------")

        
    }
    /**
     发现服务调用次方法
     
     - parameter peripheral: <#peripheral description#>
     - parameter error:      <#error description#>
     */
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("---发现服务调用次方法-")
        
        for s in peripheral.services!{
            peripheral.discoverCharacteristics(nil, for: s)
            print(s.uuid.uuidString)
        }
    }
    /**
     根据服务找特征
     
     - parameter peripheral: <#peripheral description#>
     - parameter service:    <#service description#>
     - parameter error:      <#error description#>
     */
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("----发现特征------")
        
        for c in service.characteristics! {
            
            if c.uuid.uuidString == "2AF0"{
                print(c.uuid.uuidString)
                peripheral.setNotifyValue(true, for: c)
            }
            
            
            if c.uuid.uuidString == "2AF1"{
                print(c.uuid.uuidString)
                self.writeCharacteristic = c
            }
        }
    }
    
    
    
    
    
    /**
     写入后的回掉方法
     
     - parameter peripheral:     <#peripheral description#>
     - parameter characteristic: <#characteristic description#>
     - parameter error:          <#error description#>
     */
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
       print("didWriteValueForCharacteristic")
    }
    
    /**
     <#Description#>
     
     - parameter peripheral:     <#peripheral description#>
     - parameter characteristic: <#characteristic description#>
     - parameter error:          <#error description#>
     */
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        print("-----didUpdateNotificationStateForCharacteristic-----")
        if (error != nil) {
            print(error.customMirror);
        }
        //Notification has started
        if(characteristic.isNotifying){
            peripheral.readValue(for: characteristic);
           print(characteristic.uuid.uuidString);
        }
    }
    
    /**
     获取外设的数据
     
     - parameter peripheral:     <#peripheral description#>
     - parameter characteristic: <#characteristic description#>
     - parameter error:          <#error description#>
     */

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("----didUpdateValueForCharacteristic---")
        
        if  characteristic.uuid.uuidString == "2AF0"  {
            let data:Data = characteristic.value!
            print(data)
            let  d  = Array(UnsafeBufferPointer(start: (data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count), count: data.count))
            print(d)
            
            let s:String =  HexUtil.encodeToString(d)
            if s != "00" {
                result += s
                print(result )
                print(result.characters.count )
            }
            
            if result.characters.count == 38 {
                lable.text = result
            }
            
        }
    }
    
}

