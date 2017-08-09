//
//  SettingView.swift
//  MyKcal
//
//  Created by 佐藤賢 on 2017/07/12.
//  Copyright © 2017年 佐藤賢. All rights reserved.


import UIKit

class SettingView: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
  @IBOutlet weak var settingTableView: UITableView!
  
  let header: [String] = ["一般"]
  let settingArray: [String] = ["画面表示", "目標値", "MyKcalについて"]
  let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    if let indexPathForSelectedRow = settingTableView.indexPathForSelectedRow {
      settingTableView.deselectRow(at: indexPathForSelectedRow, animated: true)
    }
  }
  
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 3
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
    let cell = tableView.dequeueReusableCell(withIdentifier: "settingCell")
    //    // cellの背景を透過
    //    cell?.backgroundColor = UIColor.clear
    //    // cell内のcontentViewの背景を透過
    //    cell?.contentView.backgroundColor = UIColor.clear
    
    cell?.textLabel?.text = settingArray[indexPath.row]
    
    return cell!
    
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    appDelegate.detailsIndex = indexPath.row
    switch indexPath.row {
    case 0:
      performSegue(withIdentifier: "settingScreenSegue", sender: nil)
    case 1:
      performSegue(withIdentifier: "settingKcalSegue", sender: nil)
    case 2:
      performSegue(withIdentifier: "settingVersionSegue", sender: nil)
    default:
      break
    }
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return header[section]
  }
  
}
