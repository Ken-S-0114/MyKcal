//
//  RealmKindDB.swift
//  MyKcal
//
//  Created by 佐藤賢 on 2017/06/11.
//  Copyright © 2017年 佐藤賢. All rights reserved.
//

import Foundation
import RealmSwift

class RealmKindDB: Object {
    
  dynamic var id = Int()
  dynamic var kind = String()
  
  override static func primaryKey() -> String? {
    return "id"
  }
}
