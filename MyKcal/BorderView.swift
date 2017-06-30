//
//  BorderView.swift
//  MyKcal
//
//  Created by 佐藤賢 on 2017/06/23.
//  Copyright © 2017年 佐藤賢. All rights reserved.
//

import UIKit

class BorderView: UIViewController {
  
  
  @IBOutlet weak var kcalLabelView: UILabel!
  
  @IBOutlet weak var borderTextField: UITextField!

  @IBAction func saveButton(_ sender: UIBarButtonItem) {
    let border = borderTextField.text
    let settings = UserDefaults.standard
    settings.setValue(border, forKey: settingKey)
    settings.synchronize()
    _ = navigationController?.popViewController(animated: true)
  }
  
  let settingKey = "value"
  
    override func viewDidLoad() {
        super.viewDidLoad()
      _ = UserDefaults.standard
//      let timerValue = settings.integer(forKey: settingKey)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

   
}
