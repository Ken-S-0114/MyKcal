//
//  noonList.swift
//  MyKcal
//
//  Created by 佐藤賢 on 2017/06/17.
//  Copyright © 2017年 佐藤賢. All rights reserved.
//

import Foundation
import RealmSwift

class noonList: Object {
    
  dynamic var name: String!
  dynamic var kcal = Int()
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
}
