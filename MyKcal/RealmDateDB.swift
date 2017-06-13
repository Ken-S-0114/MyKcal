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
  dynamic var id = Int()
  dynamic var date = String()
  dynamic var morning: String = "0"
  dynamic var noon : String = "0"
  dynamic var night: String = "0"
  dynamic var snack: String = "0"
  dynamic var total: String = "0"
  
  override static func primaryKey() -> String? {
    return "id"
  }
}
