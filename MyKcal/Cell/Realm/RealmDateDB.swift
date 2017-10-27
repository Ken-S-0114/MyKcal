//
//  RealmDateDB.swift
//  MyKcal
//
//  Created by 佐藤賢 on 2017/06/10.
//  Copyright © 2017年 佐藤賢. All rights reserved.
//

import Foundation
import RealmSwift

class RealmDateDB: Object {
  @objc dynamic var id = Int()
  @objc dynamic var date = String()
  let mlist = List<morningList>()
  @objc dynamic var morning: Int = 0
  let nolist = List<noonList>()
  @objc dynamic var noon : Int = 0
  let nilist = List<nightList>()
  @objc dynamic var night: Int = 0
  @objc dynamic var snack: Int = 0
  @objc dynamic var total: Int = 0
  
  override static func primaryKey() -> String? {
    return "id"
  }
}
