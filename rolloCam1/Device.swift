// TODO:        Add timer to ble scanner  turn off after ten seconeds then scan 2 , off 10

// 9/26/17 - changed the mode and direction UUID to test with phone




//  File.swift
//  rolloCam1
//
//  Created by Dana Smith on 9/19/17.
//  Copyright © 2017 Dana Smith. All rights reserved.
//

import Foundation
// import CoreBluetooth

//Settings                          # of settings   Section Head
//  App Settings
//  Connection Settings
//  Generic Camera Settings
//  Continuous Motion Settings
//  Stop Motion Settings
//  TimeLapse Settings
//  Review and Playback



struct Settings {
    let UUID: String    // the UUID of the Setting
    let val: Int16      // actual value
    let min: Int16      // minimum acceptable value
    let max: Int16      // maximum acceptable value
    let type: Int8      // type of char
    let name: String    // name of the Setting / Characteristic
}

struct Section {
    var sectionName: String!
    var sectionSettings: [Settings]!
    var sectionIsHidden: Bool!
    
    init(sectionName: String, sectionSettings: [Settings], sectionIsHidden: Bool) {
        self.sectionName = sectionName
        self.sectionSettings = sectionSettings
        self.sectionIsHidden = sectionIsHidden
    }
}



struct ModeByte: OptionSet {
    
    let rawValue: Int
    
    static let direction        = ModeByte(rawValue: 1 << 0)
    static let traverseFlag     = ModeByte(rawValue: 1 << 1)
    static let startStop        = ModeByte(rawValue: 1 << 2)
    static let pauseResume      = ModeByte(rawValue: 1 << 3)
    static let later1           = ModeByte(rawValue: 1 << 4)
    static let mode_5           = ModeByte(rawValue: 1 << 5)
    static let modeFuncLo       = ModeByte(rawValue: 1 << 6)
    static let modeFuncHi       = ModeByte(rawValue: 1 << 7)
    
    
    static let whichFunction: ModeByte = [.modeFuncLo, .modeFuncHi]
    
}








struct Rcam {
    static let UUID_EE =                "83793680-3B68-C9A4-B6B5-B09FE33D26C1"
    static let UUID_RolloCam =          "D8D975EE-ADF4-7A0D-8F98-0CD7A8887562"
    static let UUID_TransferService =   "E71EE188-279F-4ED6-8055-12D77BFD900C"
    
    static let UUID_Battery =           "2F016955-E675-49A6-9176-111E2A1CF338"
    static var batteryLevel: UInt16 =   0
//    static let UUID_Position =          "2F016955-E675-49A6-9176-111E2A1CF339"
//    static var currentPosition: Int16 = 0
    
    static let UUID_Mode =              "2F016955-E675-49A6-9176-111E2A1CF32E"
    static var mode: UInt16 =           0
//    static let UUID_Dir =               "2F016955-E675-49A6-9176-111E2A1CF32F"
//    static var direction: UInt16 =      0 // either 0 left or 1 = right
    
    static let UUID_Speed =             "2F016955-E675-49A6-9176-111E2A1CF330"
    static var speed: UInt16 =          10       // default speed
    static let speedMin =               1
    static let speedMax =               10
    //    static var speedValue: Data = Data(from: speed)
    
    static let UUID_RampTime =       "2F016955-E675-49A6-9176-111E2A1CF331"
    static var rampTime: UInt16 = 5
    static let rampTimeMin = 1
    static let rampTimeMax = 10
    
//    static let UUID_Decel =       "2F016955-E675-49A6-9176-111E2A1CF332"
//    static var decel: UInt16 = 5
//    static let decelMin = 1
//    static let decelMax = 10
    
    // this is the distance Characteristic to send
    static let UUID_Distance =    "2F016955-E675-49A6-9176-111E2A1CF3D2"
    static var distance: UInt16 = 10

    static let UUID_TraverseFlag = "2F016955-E675-49A6-9176-111E2A1CF334"
    static var traverseFlag: UInt16 = 0
    
    static let UUID_TravDwellTime = "2F016955-E675-49A6-9176-111E2A1CF333"
    static var dwellTime: UInt16 = 10
    static let dwellTimeMin = 1
    static let dwellTimeMax = 60
    
    static let UUID_Index =       "2F016955-E675-49A6-9176-111E2A1CFD2F"
    static var index: UInt16 = 1
    static let indexMin = 0
    static let indexMax = 100
    

    
    static let UUID_cmDistance =    "2F016955-E675-49A6-9176-111E2A1CFAD2"
    static var cmDistance: UInt16 = 10
    static let cmDistanceMin = 0
    static let cmDistanceMax = 255
    
    // THESE ARE THE ONES FOR USE TO SEND
    static let UUID_cmTravDwellTime = "2F016955-E675-49A6-9176-111E2A1CFA33"
    static let UUID_cmTraverseFlag = "2F016955-E675-49A6-9176-111E2A1CFA34"
    static var cmTraverseFlag: UInt16 = 0
    static var cmDwellTime: UInt16 = 10
    static let cmDwellTimeMin = 1
    static let cmDwellTimeMax = 60
    
    static let UUID_smIndex =     "2F016955-E675-49A6-9176-111E2A1CFD2F" // THE
    static var smIndex: UInt16 = 1
    static let smIndexMin = 0
    static let smIndexMax = 100
    
    static let UUID_smDistance =    "2F016955-E675-49A6-9176-111E2A1CFD33"
    static var smDistance: UInt16 = 10
    static let smDistanceMin = 0
    static let smDistanceMax = 255
    

    static let UUID_smDwellDelay =    "2F016955-E675-49A6-9176-111E2A1CFDA3"
    static var smDwellDelay: UInt16 = 10
    static let smTravDwellDelayMin = 1
    static let smTravDwellDelayMax = 60
    
    static let UUID_smTravDwellTime =  "2F016955-E675-49A6-9176-111E2A1CFD27"
    static let UUID_smTraverseFlag = "2F016955-E675-49A6-9176-111E2A1CFD27"
    static var smTraverseFlag: UInt16 = 0
    static var smTravDwellTime: UInt16 = 5
    static let smTravDwellTimeMin = 1
    static let smTravDwellTimeMax = 60
    
    static let UUID_tlIndex =       "2F016955-E675-49A6-9176-111E2A1CFD30"
    static var tlIndex: UInt16 = 1
    static let tlIndexMin = 0
    static let tlIndexMax = 100
    
    static let UUID_tlDistance =    "2F016955-E675-49A6-9176-111E2A1CFD34"
    static var tlDistance: UInt16 = 10
    static let tlDistanceMin = 0
    static let tlDistanceMax = 255
    
    static let UUID_tlTravDwellTime = "2F016955-E675-49A6-9176-111E2A1CFD27"
    static let UUID_tlTravFlag =      "2F016955-E675-49A6-9176-111E2A1CFD28"
    static var tlTraverseFlag: UInt16 = 0
    static var tlTravDwellTime: UInt16 = 5
    static let tlTravDwellTimeMin = 1
    static let tlTravDwellTimeMax = 60
    
    static let UUID_intervalLO =    "2F016955-E675-49A6-9176-111E2A1CFB2D"
    static var intervalTime: UInt16 = 10
    static let intervalTimeMin = 1
    static let intervalTimeMax = 10000
    
    static let UUID_intervalHI =    "2F016955-E675-49A6-9176-111E2A1CFDA3"
    static var intervalHI: UInt16 = 10
//    static let delayTimeMin = 1
//    static let delayTimeMax = 30000
    
    static let UUID_triggerDelay =  "2F016955-E675-49A6-9176-111E2A1CFB31"
    static var triggerDelay: UInt16 = 0
    static let triggerDelayMin = 0
    static let triggerDelayMax = 255
    
    static let functionMode0Names       = ["Speed","Ramp Time","Distance","Dwell Time"]
    static let functionMode0ArrayUUID   = [Rcam.UUID_Speed, Rcam.UUID_RampTime,
                                Rcam.UUID_cmDistance, Rcam.UUID_cmTravDwellTime]
    static let functionMode0ArrayMin    = [Rcam.speedMin, Rcam.rampTimeMin,
                                Rcam.cmDistanceMin, Rcam.cmDwellTimeMin]
    static let functionMode0ArrayMax    = [Rcam.speedMax, Rcam.rampTimeMax,
                                Rcam.cmDistanceMax, Rcam.cmDwellTimeMax]
    static var functionMode0ArrayValue  = [Rcam.speed, Rcam.rampTime,
                                Rcam.cmDistance, Rcam.cmDwellTime]

    static let functionMode2Names       = ["Index Distance"]
    static let functionMode2ArrayUUID   = [Rcam.UUID_smIndex]
    static let functionMode2ArrayMin    = [Rcam.smIndexMin]
    static let functionMode2ArrayMax    = [Rcam.smIndexMax]
    static var functionMode2ArrayValue  = [Rcam.smIndex]

    static let functionMode1Names       = ["Index Distance","Distance (inches)","Interval (seconds)","Trigger Delay (seconds)","Dwell Time (seconds)"]
    static let functionMode1ArrayUUID   = [Rcam.UUID_tlIndex, Rcam.UUID_tlDistance,
                                Rcam.UUID_intervalLO, Rcam.UUID_triggerDelay, Rcam.UUID_tlTravDwellTime]
    
    static let functionMode1ArrayMin    = [Rcam.tlIndexMin, Rcam.tlDistanceMin,
                                Rcam.intervalTimeMin,
                                Rcam.triggerDelayMin, Rcam.tlTravDwellTimeMin]
    static let functionMode1ArrayMax    = [Rcam.tlIndexMax, Rcam.tlDistanceMax,
                                Rcam.intervalTimeMax,
                                Rcam.triggerDelayMax, Rcam.tlTravDwellTimeMax]
    static var functionMode1ArrayValue  = [Rcam.tlIndex, Rcam.tlDistance, Rcam.intervalTime,
                                Rcam.triggerDelay, Rcam.tlTravDwellTime]

}

struct GoPro{
     static let UUID_goProService =      "E71EE188-279F-4ED6-8055-12D77BFD900C"
     static let UUID_PowerOnOff =        "2F016955-E675-49A6-9176-111E2A1CF32E"
     static let UUID_RecordingOnOff =    "2F016955-E675-49A6-9176-111E2A1CF338"
     static let UUID_CameraMode =        "2F016955-E675-49A6-9176-111E2A1CF339"
     static let UUID_Communication =     "2F016955-E675-49A6-9176-111E2A1CF32F"
     static let UUID_CameraName =        "2F016955-E675-49A6-9176-111E2A1CF330"
     static let UUID_Firmware =          "2F016955-E675-49A6-9176-111E2A1CF331"
     static let UUID_SpaceAvailable =    "2F016955-E675-49A6-9176-111E2A1CF332"
     static let UUID_PhotosAvailable =   "2F016955-E675-49A6-9176-111E2A1CF3D2"
     static let UUID_SSID =              "2F016955-E675-49A6-9176-111E2A1CF334"
     static let UUID_CameraBattery =     "2F016955-E675-49A6-9176-111E2A1CF333"
     static let UUID_VideoRes =          "2F016955-E675-49A6-9176-111E2A1CFD2F"
     static let UUID_FrameRate =         "2F016955-E675-49A6-9176-111E2A1CFDA3"
     static let UUID_FieldOfView =       "2F016955-E675-49A6-9176-111E2A1CFB2D"
     static let UUID_photoRes =          "2F016955-E675-49A6-9176-111E2A1CFB31"
     static let UUID_ContinuousShot =    "2F016955-E675-49A6-9176-111E2A1CFB31"
     static let UUID_BurstRate =         "2F016955-E675-49A6-9176-111E2A2CFB31"
     static let UUID_Interval =          "2F016955-E675-49A6-9176-111E2A3CFB31"
     static let UUID_UpDown =            "2F016955-E675-49A6-9176-111E2A5CFB31"
     static let UUID_SpotMeter =         "2F016955-E675-49A6-9176-111E2A6CFB31"
     static let UUID_VidPhoto =          "2F016955-E675-49A6-9176-111E2A7CFB31"
     static let UUID_Looping =           "2F016955-E675-49A6-9176-111E2A8CFB31"
     static let UUID_Exposure =          "2F016955-E675-49A6-9176-111E2A9CFB31"

    static let camSttgName: [String] = ["Power On / Off","Recording On/Off",
                                    "Camera Mode", "Communication","Camera Name",
                                    "Firmware","Space Available","Photos Available",
                                    "SSID","Battery","Video Resolution","Frame Rate",
                                    "Field of View","Photo Resolution","Continuous Shot",
                                    "Burst Rate","TimeLapse Interval",
                                    "Up/Down","Spot Meter","Video + Photo",
                                    "Looping","Exposure"]
    static let camSttgUUID = [UUID_PowerOnOff,UUID_RecordingOnOff,
                                 UUID_CameraMode, UUID_Communication, UUID_CameraName,
                                 UUID_Firmware, UUID_SpaceAvailable, UUID_PhotosAvailable,
                                 UUID_SSID, UUID_CameraBattery, UUID_VideoRes,
                                 UUID_FrameRate, UUID_FieldOfView, UUID_photoRes,
                                 UUID_ContinuousShot, UUID_BurstRate, UUID_Interval,
                                 UUID_UpDown, UUID_SpotMeter, UUID_VidPhoto,
                                 UUID_Looping, UUID_Exposure]
    
    static let camSttgType: [Int8]  = [1,1,1,1,3,0,0,0,0,0,3,3,3,3,1,3,3,1,3,1,1,3]
    static let camSttgMin: [Int16]  = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    static let camSttgMax: [Int16]  = [1,1,1,1,4,0,0,0,0,0,8,6,3,8,1,9,6,1,0,1,1,52]
    static var camSttgVal: [Int16]  = [0,0,0,0,2,0,0,0,0,0,8,6,3,8,0,4,4,1,0,1,1,50]
    static var camSttgNewVal: [Int16] = [0,0,0,0,2,0,0,0,0,0,8,6,3,8,0,4,4,1,0,1,1,50]
 
 static let cameraNames = ["Hero 6 Black","Hero 5 Black","Hero 5 Session", "Hero Session","Fusion"]
 static let videoRes    = ["5.2k","3k","4k","4K (4:3)","2.7k","2.7k (4:3)","1440p","1080p","960p","720p","WVGA"]
 static let photoRes    = ["5.2k","3k","4k","4K (4:3)","2.7k","2.7k (4:3)","1440p","1080p","960p","720p","WVGA"]
 static let burstRates  = ["Auto","30/1", "30/2", "30/3", "30/6", "10/1", "10/2","10/3", "5/1", "3/1"]
 static let timeLapseInterval = [".5","1","2","5","10","30","60"]
 static let cameraMode  = ["Photo", "Burst Mode","Night Photo","Video","Looping","TimeLapse Photo","TimeLapse Video","Night Lapse Photo","Video + Photo"]
 static let frameRate   = ["24","25","30","48","50","60","80","90","100","120","240"]
 static let fieldOfView = ["Wide","SuperWide","Medium","Linear","Narrow"]
 static let exposureOptions = [
 "1/8000",  "1/4000", "1/3200", "1/2500", "1/2000", "1/1600", "1/1250",
 "1/1000",  "1/800",  "1/640",  "1/500",  "1/400",  "1/320",  "1/250",
 "1/200",   "1/160",  "1/125",  "1/100",  "1/80",   "1/60",   "1/50",
 "1/40",    "1/30",   "1/25",   "1/20",   "1/15",   "1/13",   "1/10",
 "1/8",     "1/6",    "1/5",    "1/4",    "0@3",    "0@4",    "0@5",
 "0@6",     "0@8",    "1@0",    "1@3",    "1@6",    "2@5",    "3@2",
 "4@",      "5@",     "6@",     "8@",     "10@",    "13@",    "15@",
 "20@",     "25@",    "30@",    "BULB" ]
 
}
