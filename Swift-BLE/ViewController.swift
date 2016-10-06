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
        open.backgroundColor = UIColor.blueColor()
        //设置按钮的位置和大小
        open.frame = CGRectMake(80, 80, 150, 44)
        //设置按钮的文字
        open.setTitle("打开", forState: .Normal)
        //设置按钮的点击事件
        open.addTarget(self, action: #selector(ViewController.buttonTag(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        open.tag = 10
        self.view.addSubview(open)
        
        
        let  open1:UIButton = UIButton()
        open1.backgroundColor = UIColor.blueColor()
        //设置按钮的位置和大小
        open1.frame = CGRectMake(80, 150, 150, 44)
        //设置按钮的文字
        open1.setTitle("发送读取数据指令", forState: .Normal)
        //设置按钮的点击事件
        open1.addTarget(self, action: #selector(ViewController.buttonTag(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        open1.tag = 20
        self.view.addSubview(open1)
        
        let rect = CGRectMake(10, 220, 280, 30)
        lable = UILabel(frame: rect)
        lable.text = "无数据"
        let font = UIFont(name: "宋体",size: 12)
        lable.font = font
        //设置文字的阴影颜色
        lable.shadowColor = UIColor.lightGrayColor()
        //设置标签文字的阴影在横向和纵向的偏移距离
        lable.shadowOffset = CGSizeMake(2,2)
        //设置文字的对其的方式
        lable.textAlignment = NSTextAlignment.Center
        //设置标签文字的颜色
        lable.textColor = UIColor.purpleColor()//紫色
        //设置标签的背景颜色为黄色
        lable.backgroundColor = UIColor.yellowColor()
        
        self.view.addSubview(lable)

        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    func buttonTag(btn:UIButton) {
    
        switch btn.tag {
        case 10:
            print("扫描设备。。。。 ");
            myCentralManager.scanForPeripheralsWithServices(nil, options: nil)
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
    func writeToPeripheral(bytes:[UInt8]) {
        if writeCharacteristic != nil {
            let data1:NSData = dataWithHexstring(bytes)
            
            self.myPeripheral.writeValue(data1, forCharacteristic: writeCharacteristic, type: CBCharacteristicWriteType.WithResponse)
            
        } else{
        
       
        }
    }
    
    /**
     将[UInt8]数组转换为NSData
     
     - parameter bytes: <#bytes description#>
     
     - returns: <#return value description#>
     */
    
    func dataWithHexstring(bytes:[UInt8]) -> NSData {
        let data = NSData(bytes: bytes, length: bytes.count)
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
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        switch (central.state) {
        case .PoweredOn:
            print("蓝牙已打开, 请扫描外设!");
            break;
        case .PoweredOff:
            print("蓝牙关闭，请先打开蓝牙");
        default:
            break;
        }
    }
    
    func isBluetoothAvailable() -> Bool {
        if #available(iOS 10.0, *) {
            return myCentralManager.state == CBManagerState.PoweredOn
        } else {
            return myCentralManager.state  == .PoweredOn
        }
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        print("-----centralManagerDidUpdateState----------")
        print(central.state)
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("--didFailToConnectPeripheral--")
    }
    //发现设备
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        print("--didDiscoverPeripheral-")
        if peripheral.name == DEVICENAME{
            self.myPeripheral = peripheral;
            self.myCentralManager = central;
            central.connectPeripheral(self.myPeripheral, options: nil)
            print(self.myPeripheral);
        }
        
    }
    
    //设备已经接成功
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        print("---------didConnectPeripheral-")
        print(central)
        print(peripheral)
        //关闭扫描
        self.myCentralManager.stopScan()
        self.myPeripheral.delegate = self
        self.myPeripheral.discoverServices(nil)
        print("扫描服务...");
    }
    
    
    func centralManager(central: CBCentralManager, willRestoreState dict: [String : AnyObject]) {
        
        print("---------willRestoreState---------")

        
    }
    /**
     发现服务调用次方法
     
     - parameter peripheral: <#peripheral description#>
     - parameter error:      <#error description#>
     */
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        print("---发现服务调用次方法-")
        
        for s in peripheral.services!{
            peripheral.discoverCharacteristics(nil, forService: s)
            print(s.UUID.UUIDString)
        }
    }
    /**
     根据服务找特征
     
     - parameter peripheral: <#peripheral description#>
     - parameter service:    <#service description#>
     - parameter error:      <#error description#>
     */
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        print("----发现特征------")
        
        for c in service.characteristics! {
            
            if c.UUID.UUIDString == "2AF0"{
                print(c.UUID.UUIDString)
                peripheral.setNotifyValue(true, forCharacteristic: c)
            }
            
            
            if c.UUID.UUIDString == "2AF1"{
                print(c.UUID.UUIDString)
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
    func peripheral(peripheral: CBPeripheral, didWriteValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
       print("didWriteValueForCharacteristic")
    }
    
    /**
     <#Description#>
     
     - parameter peripheral:     <#peripheral description#>
     - parameter characteristic: <#characteristic description#>
     - parameter error:          <#error description#>
     */
    
    func peripheral(peripheral: CBPeripheral, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        print("-----didUpdateNotificationStateForCharacteristic-----")
        if (error != nil) {
            print(error?.code);
        }
        //Notification has started
        if(characteristic.isNotifying){
            peripheral.readValueForCharacteristic(characteristic);
           print(characteristic.UUID.UUIDString);
        }
    }
    
    /**
     获取外设的数据
     
     - parameter peripheral:     <#peripheral description#>
     - parameter characteristic: <#characteristic description#>
     - parameter error:          <#error description#>
     */

    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        print("----didUpdateValueForCharacteristic---")
        
        if  characteristic.UUID.UUIDString == "2AF0"  {
            let data:NSData = characteristic.value!
            print(data)
            let  d  = Array(UnsafeBufferPointer(start: UnsafePointer<UInt8>(data.bytes), count: data.length))
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

