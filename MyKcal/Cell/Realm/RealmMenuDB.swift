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
  
  @objc dynamic var id = Int()
  @objc dynamic var kind = String()
  @objc dynamic var menu = String()
  @objc dynamic var kcal = Int()
  
  override static func primaryKey() -> String? {
    return "id"
  }
}
