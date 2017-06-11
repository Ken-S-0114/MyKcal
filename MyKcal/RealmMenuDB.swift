//
//  RealmMenuDB.swift
//  MyKcal
//
//  Created by 佐藤賢 on 2017/06/11.
//  Copyright © 2017年 佐藤賢. All rights reserved.
//

import Foundation
import RealmSwift

class RealmMenuDB: Object {
  
  dynamic var id = Int()
  dynamic var menu = String()
  dynamic var kcal = String()
  
  override static func primaryKey() -> String? {
    return "id"
  }
}
