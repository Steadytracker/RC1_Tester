//
//  ViewControllerTableViewCell.swift
//  rolloCam1
//
//  Created by Dana Smith on 9/19/17 .
//  Copyright © 2017 Dana Smith. All rights reserved.
//

import UIKit

class ViewControllerTableViewCell: UITableViewCell {
    @IBOutlet weak var theNameLabel: UILabel!
    
    @IBOutlet weak var decButton: UIButton!
    @IBAction func decIt(_ sender: UIButton) {
        slida1.value = slida1.value - 1
        currentValue.text = String(describing: Int(slida1.value))
        ViewController.newValues1[2] = UInt16(slida1.value)
    }
    
    @IBOutlet weak var incButton: UIButton!
    
    @IBAction func incIt(_ sender: UIButton) {
        slida1.value = slida1.value + 1
        currentValue.text = String(describing: Int(slida1.value))
        ViewController.newValues1[2] = UInt16(slida1.value)
    }
    
    
    @IBOutlet weak var UUIDLabel: UILabel!
    @IBOutlet weak var currentValue: UILabel!
    @IBOutlet weak var slida1: UISlider!
    
    @IBAction func slida1(_ sender: UISlider) {
        print("tag: \(slida1.tag), function: \(ViewController.functionMode)")
        if self.isSelected == true {
            self.isSelected = false
        }

        if ViewController.functionMode == 0 {
            slida1.value = roundf(sender.value)
            currentValue.text = String(describing: Int(slida1.value))
        } else {
            if slida1.tag == 0{
                slida1.value = roundf(sender.value)
                let str = slida1.value/100
                currentValue.text = String(describing: str)
            } else {
                slida1.value = roundf(sender.value)
                currentValue.text = String(describing: Int(slida1.value))
            }
            
        }
        
        
        
        switch(ViewController.functionMode){
            case 0:
                ViewController.newValues0[slida1.tag] = UInt16(slida1.value)
            case 1:
                ViewController.newValues1[slida1.tag] = UInt16(slida1.value)
            case 2:
                ViewController.newValues2[slida1.tag] = UInt16(slida1.value)
            default:
                break
            }
    }
}
