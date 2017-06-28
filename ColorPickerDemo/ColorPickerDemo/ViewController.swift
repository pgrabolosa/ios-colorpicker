//
//  ViewController.swift
//  ColorPickerDemo
//
//  Created by Pierre Grabolosa on 28/06/2017.
//  Copyright © 2017 IMERIR. All rights reserved.
//

import UIKit
import ColorPicker

class ViewController: UIViewController {
  
  @IBOutlet weak var picker: ColorPicker!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    picker.setValue(from: view.tintColor)
  }

  @IBAction func pickedColor(sender: ColorPicker) {
    view.tintColor = sender.color
  }


}

