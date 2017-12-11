//
//  VersionView.swift
//  MyKcal
//
//  Created by 佐藤賢 on 2017/07/18.
//  Copyright © 2017年 佐藤賢. All rights reserved.
//

import UIKit

class VersionView: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
  @IBOutlet weak var versionTableView: UITableView!
  
  let header: [String] = ["MyKcalについて"]
  let settingVersion: [String] = ["バージョン"]
  let version: [String] = ["1.0.0"]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    versionTableView.isScrollEnabled = false
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return settingVersion.count
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
    let cell = versionTableView.dequeueReusableCell(withIdentifier: "versionCell")
    if let cell = cell {
      cell.textLabel?.text = settingVersion[indexPath.row]
      cell.detailTextLabel?.text = version[indexPath.row]
    }
    return cell!
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return header[section]
  }
}
