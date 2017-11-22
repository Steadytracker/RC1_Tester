// 11/20 - added code in start button to turn on and off activity indicator
// 11/20 - added left and right arrows in direction View in order 
//  to control realtime left and right movements with speed
// 11/14 - adding settings view controller to manage camera settings
// 11/9 - between this and goProPeripheral, getting all the characteristics
//   want to make a change to an array of struct where struct holds all the char data
// 11/20 - added activity indicator when system as actually moving (reliant on ble mode)
// 10/19 - pause and resume AND OR the 8 bit pause button routine
// 10/18 - core data save of favorite
// 10/10 - mode now has almost all status data.  need to add direction
//  9/28 - have all the original mode values and need to just determine which ones are
//  9/30 - startbutton routine done
//  ViewController.swift
//  rolloCam1
//
//  Created by Dana Smith on 9/19/17.
//  Copyright © 2017 Dana Smith. All rights reserved.
//

import UIKit
import CoreBluetooth
import AVFoundation
import CoreData

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CBCentralManagerDelegate, CBPeripheralDelegate {

    let centralRestoreIdentifier =    "com.cobracrane.rolloCam1.CentralManager"
    let peripheralRestoreIdentifier = "com.cobracrane.rolloCam1.PeripheralManager"
    var theModeByte = 0b00000010
    var moveArray: [NSManagedObject] = []               // array containing favorites

// *************************************************************
    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        let settingsArray = [Settings]()
        let sectionArray = [
            Section(sectionName:  "Camera Setup Section",
                    sectionSettings: [Settings](),
                    sectionIsHidden: false),
            Section(sectionName:  "Connections Section",
                    sectionSettings: [Settings](),
                    sectionIsHidden: false),
            Section(sectionName:  "Video Section",
                    sectionSettings: [Settings](),
                    sectionIsHidden: false),
            Section(sectionName:  "Photo Section",
                    sectionSettings: [Settings](),
                    sectionIsHidden: false),
            Section(sectionName:  "TimeLapse Section",
                    sectionSettings: [Settings](),
                    sectionIsHidden: false),
            Section(sectionName:  "Delete Section",
                    sectionSettings: [Settings](),
                    sectionIsHidden: false)
        ]
        activityEnd()
    }
    var RcamCharNames  = [Rcam.UUID_Mode: "Mode",
                          Rcam.UUID_Dir: "direction",
                          Rcam.UUID_Speed: "speed",
                          Rcam.UUID_RampTime: "Ramp Time",
                          Rcam.UUID_Distance: "distance",
                          Rcam.UUID_TraverseFlag: "cmTraverseFlag",
                          Rcam.UUID_TravDwellTime: "cmDwellTime",
                          Rcam.UUID_Index: "smIndex",
                          Rcam.UUID_intervalLO: "intervalTime",
                          Rcam.UUID_triggerDelay: "triggerDelay"
    ]
    var RcamChars       = [Rcam.UUID_Mode: Rcam.mode,
                           Rcam.UUID_Dir: Rcam.direction,
                           Rcam.UUID_Speed: Rcam.speed,
                           Rcam.UUID_RampTime: Rcam.rampTime,
                           Rcam.UUID_Distance: Rcam.distance,
                           Rcam.UUID_TraverseFlag: Rcam.cmTraverseFlag,
                           Rcam.UUID_TravDwellTime: Rcam.cmDwellTime,
                           Rcam.UUID_Index: Rcam.smIndex,
                           Rcam.UUID_intervalLO: Rcam.intervalTime,
                           Rcam.UUID_triggerDelay: Rcam.triggerDelay
    ]
    
    @IBOutlet weak var yellowIndicator: UIImageView!
    static var newValues0 = [Rcam.speed, Rcam.rampTime,
                             Rcam.cmDistance, Rcam.cmDwellTime ]
    static var newValues1 = [Rcam.tlIndex, Rcam.tlDistance,Rcam.intervalTime,
                             Rcam.triggerDelay, Rcam.tlTravDwellTime]
    static var newValues2 = [Rcam.smIndex]
    
    @IBOutlet weak var myTableView: UITableView!
    var centralManager:CBCentralManager!
    var peripheral:CBPeripheral?
    var scanAfterDisconnecting:Bool = true

    static var functionMode = 0        // relates to which mode the user is UIing with
    var switchStatus = true
    var onOrOff = 0

// *************************************************************
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        
        if switchStatus == true {   // if there are no rows no need to show
            onOrOff = 1
        } else {
            onOrOff = 0
        }
        var numberOfItems = 0
        switch(ViewController.functionMode)
        {
            case 0:
                numberOfItems = Rcam.functionMode0Names.count - 1 + ( onOrOff * 1)
            case 1:
                numberOfItems = Rcam.functionMode1Names.count - 1 + ( onOrOff * 1)
            case 2:
                numberOfItems = 1
            default:
                break
        }
        
        return(numberOfItems)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let modeName: [String] = ["Continuous Motion Settings","Time Lapse Settings","Stop Motion Setting"]
  
        return modeName[ViewController.functionMode]
    }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        (view as! UITableViewHeaderFooterView).backgroundView?.backgroundColor = UIColor.init(red: 253, green: 161, blue: 39, alpha: 1)
            
        (view as! UITableViewHeaderFooterView).textLabel?.textColor = UIColor.black.withAlphaComponent(1)
        
        (view as! UITableViewHeaderFooterView).textLabel?.textAlignment = NSTextAlignment.center
    }
    

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat(1)
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(30)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let tvHeight    = 345
        var height      = 0
        var ss          = 1
        if switchStatus == true {
            ss = 0
        }
        
        switch (ViewController.functionMode){
        case 0:
            height      = tvHeight / (Rcam.functionMode0Names.count - ss)
        case 1:
            height      = tvHeight / (Rcam.functionMode1Names.count - ss)
        default:
            height      = tvHeight / 3
        }
        return (CGFloat(height))
    }
// *************************************************************
    @IBOutlet weak var greenIndicator: UIImageView!
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cel = tableView.dequeueReusableCell(withIdentifier: "editingCel", for: indexPath) as! ViewControllerTableViewCell
        cel.decButton.isHidden = true
        cel.incButton.isHidden = true
        switch(ViewController.functionMode){            // preps the sliders and local data
        case 0:
            cel.theNameLabel.text = Rcam.functionMode0Names[indexPath.row]
            cel.slida1.minimumValue = Float(Rcam.functionMode0ArrayMin[indexPath.row])
            cel.slida1.maximumValue = Float(Rcam.functionMode0ArrayMax[indexPath.row])
            cel.slida1.value = Float(Rcam.functionMode0ArrayValue[indexPath.row])
            cel.currentValue.text = String(describing: Rcam.functionMode0ArrayValue[indexPath.row])
            
        case 1:
            cel.theNameLabel.text = Rcam.functionMode1Names[indexPath.row]
            cel.slida1.minimumValue = Float(Rcam.functionMode1ArrayMin[indexPath.row])
            cel.slida1.maximumValue = Float(Rcam.functionMode1ArrayMax[indexPath.row])
            cel.slida1.value = Float(Rcam.functionMode1ArrayValue[indexPath.row])

            if indexPath.row == 0 {     // if the char is index, show in decimal
                let str = cel.slida1.value/100
                cel.currentValue.text = String(describing: str)
            } else {                    // show in INT form
                cel.currentValue.text = String(describing: Int(cel.slida1.value))
            }
            if indexPath.row == 2 {    // char is interval
                cel.decButton.isHidden = false
                cel.incButton.isHidden = false
            } else {
                cel.decButton.isHidden = true
                cel.incButton.isHidden = true
            }
            
        case 2:
            cel.theNameLabel.text = Rcam.functionMode2Names[indexPath.row]
            cel.slida1.minimumValue = Float(Rcam.functionMode2ArrayMin[indexPath.row])
            cel.slida1.maximumValue = Float(Rcam.functionMode2ArrayMax[indexPath.row])
            cel.slida1.value = Float(Rcam.functionMode2ArrayValue[indexPath.row])
            if indexPath.row == 0 {     // if the char is index, show in decimal
                let str = cel.slida1.value/100
                cel.currentValue.text = String(describing: str)
            } else {                    // show in INT form
                cel.currentValue.text = String(describing: Int(cel.slida1.value))
            }

        default:
            break
        }
        cel.slida1.tag = indexPath.row  // update the tags everytime we show the table

        return(cel)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    

    
    
// *************************************************************
    @IBAction func switchFunction(_ sender: UISwitch) {
        let travONMask      = 0b00000010
        let systemSoundID1: SystemSoundID = 1306
        
        if switchStatus == false {
            switchStatus = true
            Rcam.traverseFlag = 1
            AudioServicesPlaySystemSound (systemSoundID1)
            theModeByte = theModeByte | travONMask
        } else {
            switchStatus = false
            Rcam.traverseFlag = 0
            AudioServicesPlaySystemSound (systemSoundID1)
            theModeByte = theModeByte ^ travONMask
        }
        RcamChars[Rcam.UUID_Mode] = UInt16(theModeByte)       // update dictionary value for mode
        let str = String(RcamChars[Rcam.UUID_Mode]!, radix: 2)
        self.myTableView.reloadData()  // reloading with the new MODE
        print("* * * Updated modeByte to  \(str)")
    }
    
// *************************************************************
    @IBAction func modeSelector(_ sender: UISegmentedControl) {
        var counta = 0
        let modeSound: SystemSoundID = 1305
        AudioServicesPlaySystemSound (modeSound)
        
        ViewController.functionMode = sender.selectedSegmentIndex      // update the "mode" to the now selected
        
        switch(ViewController.functionMode){   // old mode, so update here
        case 0:
            for _ in Rcam.functionMode0ArrayValue{
                Rcam.functionMode0ArrayValue[counta] = ViewController.newValues0[counta]
                counta = counta + 1
            }
            pauseButton1.isHidden = false
            recallFavorit.isHidden = false
        case 1:  
            for _ in Rcam.functionMode1ArrayValue{
                Rcam.functionMode1ArrayValue[counta] = ViewController.newValues1[counta]
                counta = counta + 1
            }
            pauseButton1.isHidden = false
            recallFavorit.isHidden = false
        case 2:
            for _ in Rcam.functionMode2ArrayValue{
                Rcam.functionMode2ArrayValue[counta] = ViewController.newValues2[counta]
                counta = counta + 1
            }
            pauseButton1.isHidden = true
            recallFavorit.isHidden = true
            
        default:
            break
        
        }
        self.myTableView.reloadData()  // reloading with the new MODE
        
        // now update the modeByte
        let modeMask = [0b00000000,0b01000000,0b10000000,0b11000000, 0b11100000]
        if theModeByte > 15 {
            theModeByte = theModeByte & 0b00001111
        }
        theModeByte = theModeByte | modeMask[ViewController.functionMode]
      
        let str = String(theModeByte, radix: 2)
        print("** ** Changed Function: \(String(describing: sender.titleForSegment(at: (ViewController.functionMode)))) modeByte to  \(str)")
        
    }
// *************************************************************
// gets the updated Direction
    @IBAction func directionSelector(_ sender: UISegmentedControl) {
        let dirRIGHTMask    = 0b00000001
        Rcam.direction      = UInt16(sender.selectedSegmentIndex)
        let dirSound: SystemSoundID = 1306
        AudioServicesPlaySystemSound (dirSound)
        
        if (Rcam.direction > 0 ){
            theModeByte  = theModeByte | dirRIGHTMask
        } else {
            theModeByte  = theModeByte ^ dirRIGHTMask
        }
        let str = String(theModeByte, radix: 2)
        print("* * * Updated modeByte to  \(str)")
    }
    
// *************************************************************
    @IBOutlet weak var pauseButton1: UIButton!
    @IBAction func pauseButton(_ sender: UIButton) {
        let pauseONMask     = 0b00001000

        if startButton1.currentTitle == "Start" {       // check to make sure its ok to accept pause
            pauseButton1.setTitle("Pause",for: .normal) // if already stopped, then no need
            return
        }
    
        let modeSound: SystemSoundID = 1305
        AudioServicesPlaySystemSound (modeSound)
        
        if pauseButton1.currentTitle == "Pause"{
            pauseButton1.setTitle("Resume",for: .normal)
            theModeByte  = theModeByte | pauseONMask
            activityEnd()  // stops the activity wheel
            
        } else {
            pauseButton1.setTitle("Pause",for: .normal)
            rcActivityIndicator.isHidden = false
            activityStart()                             // starts animating the activity wheel
            theModeByte  = theModeByte ^ pauseONMask

        }
        RcamChars[Rcam.UUID_Mode] = UInt16(theModeByte) // update dictionary value for mode
        let str = String(RcamChars[Rcam.UUID_Mode]!, radix: 2)
        print("* * * Updated modeByte to  \(str)")
        updateCharacteristics()
    }
// *************************************************************
    func updateCharacteristics(){
        RcamChars[Rcam.UUID_Mode] = UInt16(theModeByte)
        if peripheral?.services != nil {
            for service in (peripheral?.services)! {  // iterate through characteristics
                if let characteristics = service.characteristics {
                    print("total characteristics: \(characteristics.count)")
                    for characteristic in characteristics {
                        if String(describing: characteristic.uuid) == Rcam.UUID_Battery || String(describing: characteristic.uuid) == Rcam.UUID_Position {
                            print("read only")
                        } else {
                            let theUUIDPart = String(describing: characteristic.uuid)
                            if  theUUIDPart == Rcam.UUID_intervalLO
                            {
                                if RcamChars[theUUIDPart] != nil {
                                    let updatedInt = RcamChars[theUUIDPart] // 16 bit send
                                    let newE = Data(from: updatedInt)
                                    peripheral?.writeValue(newE, for: characteristic, type:
                                        CBCharacteristicWriteType.withoutResponse)
                                }
                            } else {  // its 8 bit
                                
                                if RcamChars[theUUIDPart] != nil{ // 8 bit version
                                    let updatedInt = UInt8(RcamChars[theUUIDPart]!)
                                    let newE = Data(from: updatedInt)
                                    peripheral?.writeValue(newE, for: characteristic, type:CBCharacteristicWriteType.withoutResponse)
                                }
                            }
                            print("writing \(String(describing: RcamChars[theUUIDPart]!)) to \(RcamCharNames[String(describing: characteristic.uuid)]!)")
                        }
                    }
                }
            }
        }
    }
// *************************************************************
    //  *********   START BUTTON ACTIVITIES
    @IBOutlet weak var startButton1: UIButton!
    @IBAction func startButton(_ sender: UIButton) {
        let startONMask     = 0b00000100
        let modeSound: SystemSoundID = 1305
        AudioServicesPlaySystemSound (modeSound)
        if startButton1.currentTitle == "Stop"{
            pauseButton1.setTitle("Pause",for: .normal)
            print("Stop Button Sequence")
            //startFlag = false
        } else {
            //startFlag = true
            print("Start Button Sequence for mode \(ViewController.functionMode)")
            var counta = 0
            if (ViewController.functionMode < 3){
                switch(ViewController.functionMode){        // suck in all the new data
                case 0:
                    for _ in Rcam.functionMode0ArrayValue{
                        Rcam.functionMode0ArrayValue[counta] = ViewController.newValues0[counta]
                        //print("ViewController.newValues[counta] = \(ViewController.newValues0[counta])")
                        counta = counta + 1
                    }
                case 1:
                    for _ in Rcam.functionMode1ArrayValue{
                        Rcam.functionMode1ArrayValue[counta] = ViewController.newValues1[counta]
                        //print("ViewController.newValues[counta] = \(ViewController.newValues1[counta])")
                        counta = counta + 1
                    }
                case 2:
                    for _ in Rcam.functionMode2ArrayValue{
                        Rcam.functionMode2ArrayValue[counta] = ViewController.newValues2[counta]
                        //print("ViewController.newValues[counta] = \(ViewController.newValues2[counta])")
                        counta = counta + 1
                    }

                default:
                break
                }
            }
        }
       // print("Writing bytes to RolloCam") // update the dictionary with the current value for Mode

        if startButton1.currentTitle == "Stop"{
            theModeByte = theModeByte ^ startONMask
            startButton1.setTitle("Start",for: .normal)
            rcActivityIndicator.isHidden = true
            activityEnd()                             // stops animating the
        } else {
            theModeByte = theModeByte | startONMask
            startButton1.setTitle("Stop",for: .normal)
            rcActivityIndicator.isHidden = false
            activityStart()                             // starts animating the
        }
        
        switch(ViewController.functionMode){
        case 0:
            RcamChars[Rcam.UUID_Speed]         = Rcam.functionMode0ArrayValue[0]
            RcamChars[Rcam.UUID_RampTime]      = Rcam.functionMode0ArrayValue[1]
            RcamChars[Rcam.UUID_Distance]      = Rcam.functionMode0ArrayValue[2]
            RcamChars[Rcam.UUID_TravDwellTime] = Rcam.functionMode0ArrayValue[3]
            RcamChars[Rcam.UUID_TraverseFlag]  = UInt16(onOrOff)
            
        case 1:
            RcamChars[Rcam.UUID_Index]         = Rcam.functionMode1ArrayValue[0]
            RcamChars[Rcam.UUID_Distance]      = Rcam.functionMode1ArrayValue[1]
            RcamChars[Rcam.UUID_intervalLO]    = Rcam.functionMode1ArrayValue[2]
            RcamChars[Rcam.UUID_triggerDelay]  = Rcam.functionMode1ArrayValue[3]
            RcamChars[Rcam.UUID_TravDwellTime] = Rcam.functionMode1ArrayValue[4]
            RcamChars[Rcam.UUID_TraverseFlag]  = UInt16(onOrOff)
            
        case 2:
            RcamChars[Rcam.UUID_Index]         = Rcam.functionMode2ArrayValue[0]
            
        default:
            break
        }
        updateCharacteristics()
    }
    
    
    @IBOutlet weak var connectedIndicator: UIImageView!
    @IBOutlet weak var notConnectedIndicator: UIImageView!
    @IBOutlet weak var batLabel: UILabel!
    @IBOutlet weak var posLabel: UILabel!
// *************************************************************
    func indicatorOn(state: Bool){
        if state == true {
            connectedIndicator.isHidden = false
            notConnectedIndicator.isHidden = true
        } else {
            connectedIndicator.isHidden = true
            notConnectedIndicator.isHidden = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        stopScanning()
        scanAfterDisconnecting = false
        disconnect()
    }
    
// *************************************************************
// MARK: Handling User Interactions   IF USER SELECTS DISCONNECT BUTTON
    
    @IBAction func handleDisconnectButtonTapped(_ sender: AnyObject) { //  UISTUFF
        // if we are currently connected, disconnect, otherwise start scanning again
        if let _ = self.peripheral {
            scanAfterDisconnecting = false
            disconnect()
        } else {
            startScanning()
        }
    }

// *************************************************************
// MARK: Central management methods
    func stopScanning() {
        centralManager.stopScan()
    }
    func startScanning() {
        if centralManager.isScanning {
            print("Central Manager is already scanning!!")
            return;
        }
        centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey:true])
        print("Scanning Started! looking for \(Rcam.UUID_EE)")

    }

// *************************************************************
    /*  Call this when things either go wrong, or you're done with the connection.
     This cancels any subscriptions if there are any, or straight disconnects if not.
     (didUpdateNotificationStateForCharacteristic will cancel the connection if a subscription is involved) */
    func disconnect() {
        guard let peripheral = self.peripheral else {   // verify we have a peripheral
            print("Peripheral object has not been created yet.")
            return
        }
    
        if peripheral.state != .connected {             // check to see if the peripheral is connected
            print("Peripheral exists but is not connected.")
            self.peripheral = nil
            return
        }
        
        guard let services = peripheral.services else { // disconnect directly
            centralManager.cancelPeripheralConnection(peripheral)
            return
        }
        
        for service in services {                       // iterate through characteristics
            if let characteristics = service.characteristics {
                for characteristic in characteristics {
                    // find the Transfer Characteristic we defined in our Rcam struct
                    if characteristic.uuid == CBUUID.init(string: Rcam.UUID_Battery) || characteristic.uuid == CBUUID.init(string: Rcam.UUID_Position){
                        // We can return after calling CBPeripheral.setNotifyValue because CBPeripheralDelegate's
                        // didUpdateNotificationStateForCharacteristic method will be called automatically
                        print("Setting Notify to off for \(String(describing: characteristic.uuid))")
                        peripheral.setNotifyValue(false, for: characteristic)
                        return
                    } else {
                        print("chars \(String(describing:characteristic.uuid))")
                    }
                    
                }
            }
        }
        
        // We have a connection to the Rcam but we are not subscribed to the Transfer Characteristic for some reason.
        // Therefore, we will just disconnect from the peripheral
        centralManager.cancelPeripheralConnection(peripheral)
    }
    
// *************************************************************
    // MARK: CBCentralManagerDelegate Methods
    
    // State Preservation and Restoration
    // This is the FIRST delegate method that will be called when being relaunched -- not centralManagerDidUpdateState
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        
        //---------------------------------------------------------------------------
        // We don't need these, but it's good to know that they exist.
        //---------------------------------------------------------------------------
        // Retrive array of service UUIDs (represented by CBUUID objects) that
        // contains all the services the central manager was scanning for at the time
        // the app was terminated by the system.
        //
        //let scanServices = dict[CBCentralManagerRestoredStateScanServicesKey]
        
        // Retrieve dictionary containing all of the peripheral scan options that
        // were being used by the central manager at the time the app was terminated
        // by the system.
        //
        //let scanOptions = dict[CBCentralManagerRestoredStateScanOptionsKey]
        //---------------------------------------------------------------------------
        
        /*   Retrieve array of CBPeripheral objects containing all of the peripherals that were connected to the central manager
         (or that had a connection pending) at the time the app was terminated by the system.
         
         When possible, all the information about a peripheral is restored, including any discovered services, characteristics,
         characteristic descriptors, and characteristic notification states.*/
        
        if let peripheralsObject = dict[CBCentralManagerRestoredStatePeripheralsKey] {
            let peripherals = peripheralsObject as! Array<CBPeripheral>
            if peripherals.count > 0 {
                // Just grab the first one in this case. If we had maintained an array of
                // multiple peripherals then we would just add them to our array and set the delegate...
                peripheral = peripherals[0]
                peripheral?.delegate = self
            }
        }
    }
    
// *************************************************************
    /*   Invoked when the central manager’s state is updated.
     This is where we kick off the scanning if Bluetooth is turned on and is active. */
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("Central Manager State Updated: \(central.state)")
        
        // We will just handle it the easy way here: if Bluetooth is on, proceed...
        if central.state != .poweredOn {
            self.peripheral = nil
            return
        }
        startScanning()
        
        
        //--------------------------------------------------------------
        // If the app has been restored with the peripheral in centralManager(_:, willRestoreState:),
        // we start subscribing to updates again to the Transfer Characteristic.
        //--------------------------------------------------------------
        guard let peripheral = self.peripheral else {
            return
        }
        
        guard peripheral.state == .connected else { // see if that peripheral is connected
            return
        }
        
        guard peripheral.services != nil else {     // make sure the peripheral has services
            return
        }
// i think this is where we should look for "RolloCam"
        if peripheral.name == "RolloCam"{
            print(peripheral.name ?? "Rcam Information  We have the right one")
        }
        
        let serviceUUID = CBUUID(string: Rcam.UUID_TransferService)
        peripheral.discoverServices([serviceUUID])
        
    }
    
    
// *************************************************************
    /* Invoked when the central manager discovers a peripheral while scanning.
     
     The advertisement data can be accessed through the keys listed in Advertisement Data Retrieval Keys.
     You must retain a local copy of the peripheral if any command is to be performed on it.
     In use cases where it makes sense for your app to automatically connect to a peripheral that is
     located within a certain range, you can use RSSI data to determine the proximity of a discovered
     peripheral Rcam.
     
     central - The central manager providing the update.
     peripheral - The discovered peripheral.
     advertisementData - A dictionary containing any advertisement data.
     RSSI - The current received signal strength indicator (RSSI) of the peripheral, in decibels.*/
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("Discovered \(String(describing: peripheral.name)) at \(RSSI)")
        
        
        if peripheral.name == "RolloCam" { // check to see if it is the Rcam I want
            print("We found the \(String(describing: peripheral.name))")
            indicatorOn(state: true)            // show the green led
            if self.peripheral != peripheral {  // did we saved reference to peripheral
                self.peripheral = peripheral    // save a reference to the peripheral object
                print("Connecting to peripheral: \(peripheral)")
                centralManager?.connect(peripheral, options: nil)// connect to the peripheral
            }
            

        } else {
            print("not the one we want, so we are not connecting")
        }
    }

    
    
    
    
    
// *************************************************************
    /* Invoked when a connection is successfully created with a peripheral.
     This method is invoked when a call to connectPeripheral:options: is successful.
     You typically implement this method to set the peripheral’s delegate and to discover its services.  */
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("* * * didConnect peripheral   !!!")
        centralManager.stopScan()  // print(".. Scanning Stopped!")
        
        // IMPORTANT: Remember delegate property, to receive discovery callbacks
        peripheral.delegate = self // print("....delegate = self")remember peripheral for later
        
        // Now that we've successfully connected to the peripheral, let's discover the services.
        print(".....peripheral: \(String(describing: peripheral.name)) connected \(peripheral)")
        peripheral.discoverServices([CBUUID.init(string: Rcam.UUID_TransferService)])
    }
    
    
    
    
    
    
// *************************************************************
    /*   Invoked when the central manager fails to create a connection with a peripheral.
     This method is invoked when a connection initiated via the connectPeripheral:options: method fails to complete.
     Because connection attempts do not time out, a failed connection usually indicates a transient issue,
     in which case you may attempt to connect to the peripheral again.    */
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("Failed to connect to \(peripheral) (\(String(describing: error?.localizedDescription)))")
        self.disconnect()
        indicatorOn(state: false)            // show the red led
    }
    
// *************************************************************
    /*
     Invoked when an existing connection with a peripheral is torn down.
     This method is invoked when a peripheral connected via the connectPeripheral:options: method is disconnected.
     If the disconnection was not initiated by cancelPeripheralConnection:, the cause is detailed in error.
     After this method is called, no more methods are invoked on the peripheral Rcam’s CBPeripheralDelegate object.
     
     Note that when a peripheral is disconnected, all of its services, characteristics, and characteristic descriptors are invalidated.
     */
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
        print("Disconnected from Peripheral") // reference to nil .start scanning again...
        self.peripheral = nil
        indicatorOn(state: false)
        if scanAfterDisconnecting {
            startScanning()
        }
    }
    
 
    
    
    
    
    
    
    
    
// *************************************************************
    //MARK: - CBPeripheralDelegate methods
    
    /*
     Invoked when you discover the peripheral’s available services.
     
     This method is invoked when your app calls the discoverServices: method.
     If the services of the peripheral are successfully discovered, you can access them
     through the peripheral’s services property.
     
     If successful, the error parameter is nil.
     If unsuccessful, the error parameter returns the cause of the failure.
     */
 
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("\nDiscovered Services!!!")
        
        if error != nil {
            print("Error discovering services: \(String(describing: error?.localizedDescription))")
            disconnect()
            return
        }
        
        // Core Bluetooth creates an array of CBService objects —- one for each service that is discovered on the peripheral.
        
        if let services = peripheral.services {
            for service in services {
                print(".Discovered service \(service.uuid)")
                
                // If we found either the transfer service, discover the SPECIFIC transfer characteristic
                if (service.uuid == CBUUID(string: Rcam.UUID_TransferService)) {

                    var charUUID = [CBUUID.init(string: Rcam.UUID_Battery)]
                    charUUID.append(CBUUID.init(string: Rcam.UUID_Position))
                    charUUID.append(CBUUID.init(string: Rcam.UUID_Mode))
                    charUUID.append(CBUUID.init(string: Rcam.UUID_Dir))
                    charUUID.append(CBUUID.init(string: Rcam.UUID_Speed))
                    charUUID.append(CBUUID.init(string: Rcam.UUID_RampTime))
                    charUUID.append(CBUUID.init(string: Rcam.UUID_Distance))
                    charUUID.append(CBUUID.init(string: Rcam.UUID_TraverseFlag))
                    charUUID.append(CBUUID.init(string: Rcam.UUID_TravDwellTime))
                    charUUID.append(CBUUID.init(string: Rcam.UUID_Index))
                    charUUID.append(CBUUID.init(string: Rcam.UUID_intervalLO))
                    charUUID.append(CBUUID.init(string: Rcam.UUID_triggerDelay))
                    peripheral.discoverCharacteristics(charUUID, for: service)
                }
            }
        }
    }

// *************************************************************
    /*   Invoked when you discover the characteristics of a specified service.
     If the characteristics of the specified service are successfully discovered, you can access
     them through the service's characteristics property. If successful, the error parameter is nil.
     If unsuccessful, the error parameter returns the cause of the failure.   */
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if error != nil {
            print("Error discovering characteristics: \(String(describing: error?.localizedDescription))")
            return
        }
        print("* * * didDiscoverCharacteristicsFor service...register reads")
        if let characteristics = service.characteristics {
            
            for characteristic in characteristics {
              
                if characteristic.uuid == CBUUID(string: Rcam.UUID_Battery) {
                    print("Found \(String(describing: RcamCharNames[String(describing: characteristic.uuid)])) . . .  set notify to TRUE")
                    peripheral.setNotifyValue(true, for: characteristic)// subscribe to changes
                    
                } else if characteristic.uuid == CBUUID(string: Rcam.UUID_Position) {
                    print("Found  \(String(describing: RcamCharNames[String(describing: characteristic.uuid)])) . . .  set notify to TRUE")
                    peripheral.setNotifyValue(true, for: characteristic)// subscribe to changes
                    
                } else if characteristic.uuid == CBUUID(string: Rcam.UUID_Mode) {
                    print("Found \(String(describing: RcamCharNames[String(describing: characteristic.uuid)])) . . .  set notify to TRUE")
                    peripheral.setNotifyValue(true, for: characteristic)// subscribe to changes
                    
                    
                } else {
                    
                    if((characteristic.properties.contains(CBCharacteristicProperties.write)) || (characteristic.properties.contains(CBCharacteristicProperties.writeWithoutResponse))) {
                        print(characteristic.properties)
                        print("discovered! UUID: \(String(describing: RcamCharNames[String(describing:characteristic.uuid)]!))")
                    }
                }
            }
        }
    }
    
// *************************************************************
    /* This method is invoked when the peripheral notifies your app that the value of the characteristic for
     which notifications and indications are enabled has changed.
     
     If successful, the error parameter is nil.
     If unsuccessful, the error parameter returns the cause of the failure. */
    @IBOutlet weak var modeLabel: UILabel!
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("didUpdateValueForCharacteristic: \(Date())")
        
        if error != nil {  // if there was an error then print it and bail out
            print("Error updating value for characteristic: \(characteristic) - \(String(describing: error?.localizedDescription))")
            return
        }
        guard let value = characteristic.value else {  // make sure we have a characteristic value
            print("Characteristic Value is nil on this go-round")
            return
        }
        
        if characteristic.value != nil {
            var nsdataStr: Data         // make sure we have a characteristic value
            nsdataStr = characteristic.value!
            switch(String(describing: characteristic.uuid)){
            case Rcam.UUID_Mode:
                let mode = nsdataStr.to(type: UInt8.self)
                print("reading mode: \(mode)")
                modeLabel.text = String(describing: mode)
                // make the modeLabel = 
                if mode < 4 {  // we are not moving A VALID MODE and its moving
                    greenIndicator.isHidden = true
                    yellowIndicator.isHidden = true
                    activityStart()
                } else if mode == 4 { // the stop flag is thrown (by Chi)
                    greenIndicator.isHidden = false
                    yellowIndicator.isHidden = true
                    activityEnd()
                } else if mode >= 8 { // the pause flag is thrown
                    yellowIndicator.isHidden = false
                    greenIndicator.isHidden = true
                    activityStart()
                }
            case Rcam.UUID_Battery:
                let batteryLevel = nsdataStr.to(type: UInt16.self)
                batLabel.text = String(batteryLevel)
                print("updating Battery: \(batteryLevel) ...  Bytes transferred: \(value.count)")
            case Rcam.UUID_Position:
                let currentPosition = nsdataStr.to(type: Int16.self)
                posLabel.text = String(currentPosition)
                print("updating Position: \(currentPosition) ...  Bytes transferred: \(value.count)")
            default:
                break
            }
        }
    }
// *************************************************************
     /* This method is invoked when your app calls the setNotifyValue:forCharacteristic: method.
     If successful, the error parameter is nil.
     If unsuccessful, the error parameter returns the cause of the failure. */
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        // if there was an error then print it and bail out
        if error != nil {
            print("Error changing notification state: \(String(describing: error?.localizedDescription))")
            return
        }
        if characteristic.isNotifying {
            print("Notification STARTED on: \(String(describing: RcamCharNames[String(describing: characteristic.uuid)]))")
        } else {
            print("Notification STOPPED on: \(String(describing: RcamCharNames[String(describing: characteristic.uuid)]))")
        }
    }

// *************************************************************
    // these are the coreData functions to save a favorite or recall it
    func saveFavoriteMove(name: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Moves", in: managedContext)!
        let whichMove = NSManagedObject(entity: entity, insertInto: managedContext)
        
        whichMove.setValue(name, forKeyPath: "name")
        whichMove.setValue(RcamChars[Rcam.UUID_Mode] , forKeyPath: "mode")  //  ??
        whichMove.setValue(RcamChars[Rcam.UUID_Speed], forKeyPath: "speed")  //  ??
        whichMove.setValue(RcamChars[Rcam.UUID_RampTime], forKeyPath: "accel")  //  ??
        whichMove.setValue(RcamChars[Rcam.UUID_Distance], forKeyPath: "distance")  //  ??
        whichMove.setValue(RcamChars[Rcam.UUID_TravDwellTime], forKeyPath: "traverseDwell")  //  ??
        whichMove.setValue(RcamChars[Rcam.UUID_Index], forKeyPath: "index")  //  ??
        whichMove.setValue(RcamChars[Rcam.UUID_intervalLO], forKeyPath: "interval")  //  ??
        whichMove.setValue(RcamChars[Rcam.UUID_triggerDelay], forKeyPath: "trigger")  //  ??
        
        do {
            try managedContext.save()
            moveArray = [whichMove]   // blow off the append and simply replace the move
        } catch let error as NSError {
            print("Could not save Favorite. \(error), \(error.userInfo)")
        }
    }
    
// *************************************************************
    // addName is a IBFunction from a button maybe?
    func addName(){
        let alert = UIAlertController(title: "Favorite Moves",
                                      message: "Add Move to Favorites",
                                      preferredStyle: .alert)
        
        let saveFavoriteAction = UIAlertAction(title: "Save", style: .default) { [unowned self] action in
            guard let textField = alert.textFields?.first,
                let nameToSave = textField.text else {
                    return
            }
            self.saveFavoriteMove(name: nameToSave) //self.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        alert.addTextField()
        alert.addAction(saveFavoriteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
// *************************************************************
    @IBAction func makeFavorite(_ sender: UIButton) {
       addName()
    }
    
// *************************************************************
    // we can sub func this calling it recallFavorite()

    @IBOutlet weak var recallFavorit: UIButton!
    @IBAction func recallFavorit(_ sender: UIButton) {
        let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Moves")
        do {
            moveArray = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        print(moveArray) // use this move array for the write data.
    }

// *************************************************************
    @IBOutlet weak var rcActivityIndicator: UIActivityIndicatorView!
    func activityStart(){
        rcActivityIndicator.hidesWhenStopped = true
        rcActivityIndicator.center = greenIndicator.center
        rcActivityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.white
        rcActivityIndicator.isHidden = false
        rcActivityIndicator.startAnimating()
    }

    func activityEnd(){
        rcActivityIndicator.stopAnimating()
        rcActivityIndicator.isHidden = true
    }
    
}   // end of Class

extension Data {                // i use this to cast from Int to Data or from Data to Int
    
    init<T>(from value: T) {
        var value = value
        self.init(buffer: UnsafeBufferPointer(start: &value, count: 1))
    }
    
    func to<T>(type: T.Type) -> T {
        return self.withUnsafeBytes { $0.pointee }
    }
}
