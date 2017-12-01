//
//  BorderView.swift
//  MyKcal
//
//  Created by 佐藤賢 on 2017/06/23.
//  Copyright © 2017年 佐藤賢. All rights reserved.
//

import UIKit

class BorderView: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
  
  var kcalCheck: Bool = true
  let header: [String] = ["目標値設定"]
  let settingDetails: [String] = ["標準カロリー検索", "目標値", "1日の理想摂取カロリー"]
  let sex: [String] = ["男性", "女性"]
  let age: [String] = ["0", "1~2", "3~5", "6~7", "8~9", "10~11", "12~14", "15~17", "18~29", "30~49", "50~69", "70~"]
  var selectSex: String?
  var selectAge: String?
  var selectKcal: String?
  var isSelect: String?
  
  let pv = UIPickerView()
  let kcalLabel = UILabel()
  let kcalSwitch = UISwitch()
  
  var border: Int = 0
  
  var alertCheck: Bool = true
  
  let settingKey = "value"
  let settingSwitchKey = "switchValue"
  
  let setting = UserDefaults.standard
  
  @IBOutlet weak var settingKcalTableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    border = setting.integer(forKey: settingKey)
    let kcalSwitchValue = setting.bool(forKey: settingSwitchKey)
    
    kcalSwitch.isOn = Bool(kcalSwitchValue)
    
    // UISwitch操作時
    kcalSwitch.addTarget(self, action: #selector(BorderView.setupSwitch(sender:)), for: .valueChanged)
    // スクロールさせない
    settingKcalTableView.isScrollEnabled = false
    
    selectSex = sex[0]
    selectAge = age[0]
    textView()
    textReload()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func setupPicker(){
    let title = "性別・年齢別標準カロリー"
    let message = "あなたの性別と年齢を選択して下さい\n\n\n\n\n\n\n\n\n\n" //改行入れないとOKがかぶる
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:{
      (action: UIAlertAction!) -> Void in
    })
    
    // PickerView
    pv.selectRow(0, inComponent: 0, animated: true) // 初期値
    pv.frame = CGRect(x: 0, y: 60, width: alert.view.bounds.width, height: 150) // 配置、サイズ
    pv.autoresizingMask = [.flexibleWidth]
    pv.dataSource = self
    pv.delegate = self
    alert.view.addSubview(pv)
    
    kcalLabel.frame = CGRect(x: 35, y: 200, width: view.bounds.width * 0.8, height: 30)
    alert.view.addSubview(kcalLabel)
    
    alert.addAction(okAction)
    present(alert, animated: true, completion: nil)
  }
  
  func setupTextField(){
    let title = "1日の理想摂取カロリー"
    let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
    // 決定ボタンの設定
    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:{
      (action: UIAlertAction!) -> Void in
      // OKを押した時入力されていたテキストを表示
      if let textFields = alert.textFields {
        // アラートに含まれるすべてのテキストフィールドを調べる
        for textField in textFields {
          if self.alertCheck == true {
            self.border = Int(textField.text!)!
          }else {
            self.border = 0
          }
          self.setting.setValue(self.border, forKey: self.settingKey)
          self.settingKcalTableView.reloadData()
        }
      }
    })
    alert.addAction(okAction)
    
    // キャンセルボタンの設定
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    alert.addAction(cancelAction)
    
    alert.addTextField(configurationHandler: {(textField: UITextField!) -> Void in
//      textField.frame = CGRect(x: 35, y: 100, width: self.view.bounds.width * 0.2, height: 30)
      textField.text = String(self.border)
      textField.keyboardType = UIKeyboardType.numberPad
      
      let myNotificationCenter = NotificationCenter.default
      myNotificationCenter.addObserver(self, selector: #selector(BorderView.changeTextField(sender:)), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
    })
    
    present(alert, animated: true, completion: nil)
    
  }
  
  // 文字入力時
  @objc func changeTextField (sender: NSNotification) {
    let textField = sender.object as! UITextField
    // 入力された文字を取得
    let InputStr = textField.text
    // 0文字でないか確認
    if InputStr?.count == 0 {
      alertCheck = false
    } else {
      alertCheck = true
    }
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = settingKcalTableView.dequeueReusableCell(withIdentifier: "settingKcalCell")
    cell?.textLabel?.text = settingDetails[indexPath.row]
    if cell?.accessoryView == nil {
      if indexPath.row == 1 {
        // UISwitch
        cell?.accessoryView = self.kcalSwitch
      }
    }
    if indexPath.row == 2 {
      cell?.detailTextLabel?.text = String("\(border)kcal")
      if kcalSwitch.isOn == false {
        cell?.isHidden = true
      } else {
        cell?.isHidden = false
      }
    } else {
      cell?.detailTextLabel?.text = nil
    }
    return cell!
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if kcalSwitch.isOn == false {
      return 2
    } else {
      return 3
    }
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if UIDevice.current.userInterfaceIdiom == .phone {
      // 使用デバイスがiPhoneの場合
      return 40
    } else if UIDevice.current.userInterfaceIdiom == .pad {
      // 使用デバイスがiPadの場合
      return 70
    } else {
      return 60
    }
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return header[section]
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if indexPath.row == 0 {
      self.setupPicker()
    }
    // 1日の理想摂取カロリーのCell
    if kcalSwitch.isOn == true {
      if indexPath.row == 2 {
        self.setupTextField()
        self.settingKcalTableView.reloadData()
      }
    }
    
    if let indexPathForSelectedRow = settingKcalTableView.indexPathForSelectedRow {
      settingKcalTableView.deselectRow(at: indexPathForSelectedRow, animated: true)
    }
    
  }
  
  @objc func setupSwitch(sender:UISwitch!) {
    let kcalSwitch: Bool = self.kcalSwitch.isOn
    setting.set(kcalSwitch, forKey: settingSwitchKey)
    dispatch()
  }
  
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 2
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    if component == 0 {
      return sex.count
    } else if component == 1 {
      return age.count
    }
    return 0
  }
  
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    if component == 0 {
      return sex[row]
    } else if component == 1 {
      return age[row]
    }
    return ""
  }
  
  
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    if component == 0 {
      selectSex = sex[row]
    }else if component == 1 {
      selectAge = age[row]
    }
    textView()
    textReload()
  }
  
  func textReload(){
    if let isSelect = self.isSelect {
      self.kcalLabel.text = ("標準カロリー値：\(String(describing: isSelect))kcal")
    }
  }
  
  func dispatch(){
    DispatchQueue.main.async {
      self.viewDidLoad()
      self.settingKcalTableView.reloadData()
    }
  }
  
  func textView(){
    if selectSex == sex[0] {
      if selectAge == age[0] {
        isSelect = "650"
      } else if selectAge == age[1] {
        isSelect = "1050"
      } else if selectAge == age[2] {
        isSelect = "1400"
      } else if selectAge == age[3] {
        isSelect = "1650"
      } else if selectAge == age[4] {
        isSelect = "1950"
      } else if selectAge == age[5] {
        isSelect = "2300"
      } else if selectAge == age[6] {
        isSelect = "2650"
      } else if selectAge == age[7] {
        isSelect = "2750"
      } else if selectAge == age[8] {
        isSelect = "2650"
      } else if selectAge == age[9] {
        isSelect = "2650"
      } else if selectAge == age[10] {
        isSelect = "2400"
      } else if selectAge == age[11] {
        isSelect = "1850"
      }
      
    } else if selectSex == sex[1] {
      if selectAge == age[0] {
        isSelect = "600"
      } else if selectAge == age[1] {
        isSelect = "950"
      } else if selectAge == age[2] {
        isSelect = "1250"
      } else if selectAge == age[3] {
        isSelect = "1450"
      } else if selectAge == age[4] {
        isSelect = "1800"
      } else if selectAge == age[5] {
        isSelect = "2150"
      } else if selectAge == age[6] {
        isSelect = "2300"
      } else if selectAge == age[7] {
        isSelect = "2200"
      } else if selectAge == age[8] {
        isSelect = "2050"
      } else if selectAge == age[9] {
        isSelect = "2000"
      } else if selectAge == age[10] {
        isSelect = "1950"
      } else if selectAge == age[11] {
        isSelect = "1550"
      }
    }
  }
  
}

