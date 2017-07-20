//
//  DetailsView.swift
//  MyKcal
//
//  Created by 佐藤賢 on 2017/07/13.
//  Copyright © 2017年 佐藤賢. All rights reserved.
//

import UIKit

class DetailsView: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
  let settingScreen: [String] = ["選択時の背景色", "アニメーション"]
  let header: [String] = ["プレビュー"]
  let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
  var detailsIndex: Int = 0
  
  let animationSwitch = UISwitch()
  let animationSwitchKey = "animationValue"
  let setting = UserDefaults.standard
  
  @IBOutlet weak var detailsTableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupIndex()
    
   let animationSwitchValue = setting.bool(forKey: animationSwitchKey)
    animationSwitch.isOn = Bool(animationSwitchValue)
    // UISwitch操作時
    animationSwitch.addTarget(self, action: #selector(BorderView.setupSwitch(sender:)), for: .valueChanged)
  
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    if let indexPathForSelectedRow = detailsTableView.indexPathForSelectedRow {
      detailsTableView.deselectRow(at: indexPathForSelectedRow, animated: true)
    }
  }
  
  func setupIndex(){
    detailsIndex = appDelegate.detailsIndex!
    switch detailsIndex {
    case 0:
      self.navigationItem.title = "画面表示"
    default:
      print("時間帯が指定されていません!")
    }
  }
  
  func setupSwitch(sender:UISwitch!) {
    let kcalSwitch: Bool = self.animationSwitch.isOn
    setting.set(kcalSwitch, forKey: animationSwitchKey)
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
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
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "detailsCell")
    //    // cellの背景を透過
    //    cell?.backgroundColor = UIColor.clear
    //    // cell内のcontentViewの背景を透過
    //    cell?.contentView.backgroundColor = UIColor.clear
    switch detailsIndex {
    case 0:
      cell?.textLabel?.text = settingScreen[indexPath.row]
    default:
      break
    }
    if cell?.accessoryView == nil {
      if indexPath.row == 1 {
        // UISwitch
        cell?.accessoryView = self.animationSwitch
      }
    }
    return cell!
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 2
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return header[section]
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    switch indexPath.row {
    case 0:
      performSegue(withIdentifier: "colorSegue", sender: nil)
    default:
      break
    }
  }
}
