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
  dynamic var date = Int()
  dynamic var morning = String()
  dynamic var noon = String()
  dynamic var night = String()
  
  override static func primaryKey() -> String? {
    return "id"
  }
}
