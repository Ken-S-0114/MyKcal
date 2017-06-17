//
//  morningList.swift
//  MyKcal
//
//  Created by 佐藤賢 on 2017/06/16.
//  Copyright © 2017年 佐藤賢. All rights reserved.
//

import Foundation
import RealmSwift

class morningList: Object {
//  dynamic var id = Int()
  dynamic var name: String!
  dynamic var kcal = Int()
  
//  override static func primaryKey() -> String? {
//    return "id"
//  }
}
