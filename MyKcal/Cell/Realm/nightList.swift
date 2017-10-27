//
//  nightList.swift
//  MyKcal
//
//  Created by 佐藤賢 on 2017/06/17.
//  Copyright © 2017年 佐藤賢. All rights reserved.
//

import Foundation
import RealmSwift

class nightList: Object {
    
  @objc dynamic var name: String!
  @objc dynamic var kcal = Int()
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
}
