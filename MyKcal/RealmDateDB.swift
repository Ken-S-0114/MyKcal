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
  dynamic var morning: Int = 0
  dynamic var noon : Int = 0
  dynamic var night: Int = 0
  dynamic var snack: Int = 0
  dynamic var total: Int = 0
  
  override static func primaryKey() -> String? {
    return "id"
  }
}
