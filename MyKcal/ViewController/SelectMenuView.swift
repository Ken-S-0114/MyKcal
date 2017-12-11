//
//  SelectMenuView.swift
//  MyKcal
//
//  Created by 佐藤賢 on 2017/06/13.
//  Copyright © 2017年 佐藤賢. All rights reserved.
//

import UIKit
import RealmSwift

class SelectMenuView: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
  @IBOutlet weak var kcalLabel: UILabel!
  @IBOutlet weak var selectMenuTableView: UITableView!
  
  @IBAction func addMenuButton(_ sender: UIButton) {
    performSegue(withIdentifier: "selectMenuSegue", sender: nil)
  }
  
  @IBAction func backButton(_ sender: UIBarButtonItem) {
    resetView()
    sum = 0
    _ = navigationController?.popViewController(animated: true)
  }
  
  @IBAction func saveButton(_ sender: UIBarButtonItem) {
    saveRealm()
    _ = navigationController?.popViewController(animated: true)
  }
  
  var menuItem: Results<RealmMenuDB>!
  var menuItems: Results<RealmMenuDB>?
  var dateItem: Results<RealmDateDB>!
  var dateItems: Results<RealmDateDB>?
  
  var morningItem = List<morningList>()
  var noonItem = List<noonList>()
  var nightItem = List<nightList>()
  
  let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
  let header: [String] = ["選択済みのメニュー"]
  var selectId: [Int] = []  // 選択されたメニュー番号
  var indexTime = Int()
  var selectList: [String] = []
  var selectedList: [String] = []
  var sum: Int = 0
  var i: Int = 0
  var selectDate = String()
  
  var selected: [String] = []
  var cnt: Int = 0
  
  var l :Int = 0
  var check :Bool = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    selectDate = appDelegate.selectDate!
    setupIndex()
    setupRealm()
    setKcal()
    setMenu()
    selectMenuTableView.isScrollEnabled = false
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    selectList = []
    selectId = appDelegate.selectId
    selectDate = appDelegate.selectDate!
    l = 0
    i = 0
    sum = 0
    check = false
    setupIndex()
    resetupTableView()
    setupRealm()
    setKcal()
  }
  
  func setupRealm(){
    let realm = try! Realm()
    menuItem = realm.objects(RealmMenuDB.self).sorted(byKeyPath: "id", ascending: true)
    
    let realmSave = try! Realm()
    // 全てのDateデータ
    dateItem = realmSave.objects(RealmDateDB.self).sorted(byKeyPath: "id", ascending: true)
    
    // 選択した日のデータ
    dateItems = dateItem.filter("date == %@", selectDate)
    
  }
  
  func resetupTableView(){
    selectMenuTableView.reloadData()

  }
  
  func setKcal(){
    if let dateItems = dateItems {
      var l :Int = 0
      sum = 0
      if !dateItems.isEmpty {
        let object = dateItems[0]
        //      print(String(describing: type(of: object)))
        switch indexTime {
        case 0:
          sum = object.morning
        case 1:
          sum = object.noon
        case 2:
          sum = object.night
        case 3:
          sum = object.morning + object.noon + object.night
        default:
          print("kcalがない!")
        }
      }
      
      while l < selectId.count {
        let object = menuItem[selectId[l]]
        selectList += [object.menu]
        sum += object.kcal
        l += 1
      }
      kcalLabel.text = ("\(sum)kcal")
    }
  }
  
  
  func setupIndex(){
    indexTime = appDelegate.indexTime!
    switch indexTime {
    case 0:
      self.navigationItem.title = "朝食"
    case 1:
      self.navigationItem.title = "昼食"
    case 2:
      self.navigationItem.title = "夕食"
    case 3:
      self.navigationItem.title = "合計"
    default:
      print("時間帯が指定されていません!")
    }
  }
  
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return (selected.count + selectId.count)
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if UIDevice.current.userInterfaceIdiom == .phone {
      // 使用デバイスがiPhoneの場合
      return 40
    } else if UIDevice.current.userInterfaceIdiom == .pad {
      // 使用デバイスがiPadの場合
      return 70
    } else {
      return 60
    }
  }
  
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "selectMenuCell")
    // 既存データが存在する場合
    if (!morningItem.isEmpty || !noonItem.isEmpty || !nightItem.isEmpty) && !check {
      switch indexTime {
      case 0:
        if !morningItem.isEmpty {
          if l <= morningItem.count {
            // 既存のが終了
            if l == morningItem.count && !check {
              check = true
            }else{
              let objMorning = morningItem[l]
              cell?.textLabel?.text = objMorning.name
              cell?.detailTextLabel?.text = ("\(String(objMorning.kcal))kcal")
              l += 1
            }
          }
        }
        
      case 1:
        if !noonItem.isEmpty {
          if l <= noonItem.count {
            // 既存のが終了
            if l == noonItem.count && !check {
              check = true
            }else{
              let objNoon = noonItem[l]
              cell?.textLabel?.text = objNoon.name
              cell?.detailTextLabel?.text = ("\(String(objNoon.kcal))kcal")
              l += 1
            }
          }
        }
        
      case 2:
        if !nightItem.isEmpty {
          if l <= nightItem.count {
            // 既存のが終了
            if l == nightItem.count && !check {
              check = true
            }else{
              let objNight  = nightItem[l]
              cell?.textLabel?.text = objNight.name
              cell?.detailTextLabel?.text = ("\(String(objNight.kcal))kcal")
              l += 1
            }
          }
        }
        
      default:
        print("インデックスエラー")
      }
      // 既存データがない場合
    }else{
      check = true
    }
    // 新規データ
    if !selectId.isEmpty && check {
      let objectMenu = menuItem[selectId[i]]
      cell?.textLabel?.text = objectMenu.menu
      cell?.detailTextLabel?.text = ("\(String(objectMenu.kcal))kcal")
      i += 1
    }
    return cell!
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return header[section]
  }
  
  // 削除
  //  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
  //    if editingStyle == UITableViewCellEditingStyle.delete {
  //
  //      let realm = try! Realm()
  //      let object = dateItems?[0]
  //      let mItem = object?.mlist
  //      print(mItem?[indexPath.row] as Any)
  //      tableView.reloadData()
  //      try! realm.write {
  //        realm.delete((mItem?[indexPath.row])!)
  //        print(mItem as Any)
  ////      }
  ////      if(mItem?.count == (selected.count + selectId.count)){
  //      tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
  ////      }
  //      }
  //    }
  //  }
  
  // 選択済みのメニュー
  func setMenu(){
    if let dateItems = dateItems {
    if !dateItems.isEmpty {
      let object = dateItems[0]
      reset()
      
      switch indexTime {
      case 0:
        var mItem = List<morningList>()
        mItem = object.mlist
        morningItem = mItem
        noonItem = List<noonList>()
        nightItem = List<nightList>()
        
        while cnt<(mItem.count) {
          let ob = mItem[cnt]
          selected += [(ob.name)!]
          cnt += 1
        }
        
      case 1:
        var noItem = List<noonList>()
        noItem = object.nolist
        noonItem = noItem
        morningItem = List<morningList>()
        nightItem = List<nightList>()
        
        while cnt<(noItem.count) {
          let ob = noItem[cnt]
          selected += [(ob.name)!]
          cnt += 1
        }
        
      case 2:
        var niItem = List<nightList>()
        niItem = object.nilist
        nightItem = niItem
        morningItem = List<morningList>()
        noonItem = List<noonList>()
        
        while cnt<(niItem.count) {
          let ob = niItem[cnt]
          selected += [(ob.name)!]
          cnt += 1
        }
        
      default:
        print("インデックスエラー")
      }
     
    }
    }
  }
  
  
  func reset(){
    selected = []
    cnt = 0
  }
  
  
  func saveRealm(){
    if let dateItems = dateItems {
    let realmSave = try! Realm()
    
    let newDate = RealmDateDB()
    
    if !dateItems.isEmpty {
      let object = dateItems[0]
      newDate.id = object.id
      newDate.date = selectDate
   
      switch indexTime {
      // 朝ごはん選択時
      case 0:
        // 朝ごはんのメニュー追加
        let menuList = List<morningList>()
        selectedList = []
        
        // 朝ごはんのメニュー追加（既存）
        reset()
        var mItem = List<morningList>()
        mItem = object.mlist
        
        while cnt < mItem.count {
          let ob = mItem[cnt]
          selectedList += [ob.name]
          cnt += 1
        }
        reset()
        
        // 朝ごはんのメニュー追加（新規）
        while cnt < selectList.count {
          selectedList += [selectList[cnt]]
          cnt += 1
        }
        
        for list in selectedList {
          let newList = morningList()
          newList.name = list
          let menuItems = menuItem.filter("menu == %@", list)
          let ob = menuItems[0]
          newList.kcal = ob.kcal
          menuList.append(newList)
        }
        newDate.mlist.append(objectsIn: menuList)
        // 朝ごはんの合計kcal
        newDate.morning = sum
        
        
        // 昼ごはんのメニュー追加（コピー）
        reset()
        var noItem = List<noonList>()
        noItem = object.nolist
        
        while cnt < noItem.count {
          let ob = noItem[cnt]
          selected += [ob.name]
          cnt += 1
        }
        
        let menuList2 = List<noonList>()
        for list in selected {
          let newList = noonList()
          newList.name = list
          let menuItems = menuItem.filter("menu == %@", list)
          let ob = menuItems[0]
          newList.kcal = ob.kcal
          menuList2.append(newList)
        }
        newDate.nolist.append(objectsIn: menuList2)
        // 昼ごはんの合計kcal
        newDate.noon = object.noon
        
        
        // 夕ごはんのメニュー追加（コピー）
        reset()
        var niItem = List<nightList>()
        niItem = object.nilist
        
        while cnt < niItem.count {
          let ob = niItem[cnt]
          selected += [ob.name]
          cnt += 1
        }
        
        let menuList3 = List<nightList>()
        for list in selected {
          let newList = nightList()
          newList.name = list
          let menuItems = menuItem.filter("menu == %@", list)
          let ob = menuItems[0]
          newList.kcal = ob.kcal
          menuList3.append(newList)
        }
        newDate.nilist.append(objectsIn: menuList3)
        // 夕ごはんの合計kcal
        newDate.night = object.night
        
        newDate.snack = object.snack
        newDate.total = sum + object.noon + object.night + object.snack + object.snack
        
        
      // 昼ごはん選択時
      case 1:
        // 朝ごはんのメニュー追加（コピー）
        reset()
        var mItem = List<morningList>()
        mItem = object.mlist
        
        while cnt < mItem.count {
          let ob = mItem[cnt]
          selected += [ob.name]
          cnt += 1
        }
        // 朝ごはんデータを格納
        let menuList = List<morningList>()
        for list in selected {
          let newList = morningList()
          newList.name = list
          let menuItems = menuItem.filter("menu == %@", list)
          let ob = menuItems[0]
          newList.kcal = ob.kcal
          menuList.append(newList)
        }
        newDate.mlist.append(objectsIn: menuList)
        // 朝ごはんの合計kcal
        newDate.morning = object.morning
        
        
        // 昼ごはんのメニュー追加
        let menuList2 = List<noonList>()
        selectedList = []
        
        // 昼ごはんのメニュー追加（既存）
        reset()
        var noItem = List<noonList>()
        noItem = object.nolist
        
        while cnt<(noItem.count) {
          let ob = noItem[cnt]
          selectedList += [ob.name]
          cnt += 1
        }
        reset()
        
        // 昼ごはんのメニュー追加（新規）
        while cnt < selectList.count {
          selectedList += [selectList[cnt]]
          cnt += 1
        }
        
        
        // 昼ごはんのメニュー追加
        for list in selectedList {
          let newList = noonList()
          newList.name = list
          let menuItems = menuItem.filter("menu == %@", list)
          let ob = menuItems[0]
          newList.kcal = ob.kcal
          menuList2.append(newList)
        }
        newDate.nolist.append(objectsIn: menuList2)
        // 昼ごはんの合計kcal
        newDate.noon = sum
        
        
        // 夕ごはんのメニュー追加（コピー）
        reset()
        var niItem = List<nightList>()
        niItem = object.nilist
        
        while cnt<(niItem.count) {
          let ob = niItem[cnt]
          selected += [ob.name]
          cnt += 1
        }
        
        let menuList3 = List<nightList>()
        for list in selected {
          let newList = nightList()
          newList.name = list
          let menuItems = menuItem.filter("menu == %@", list)
          let ob = menuItems[0]
          newList.kcal = ob.kcal
          menuList3.append(newList)
        }
        newDate.nilist.append(objectsIn: menuList3)
        // 夕ごはんの合計kcal
        newDate.night = object.night
        
        newDate.snack = object.snack
        newDate.total = object.morning + sum + object.night + object.snack + object.snack
        
      // 夕ごはん選択時
      case 2:
        
        // 朝ごはんのメニュー追加（コピー）
        reset()
        var mItem = List<morningList>()
        mItem = object.mlist
        
        while cnt < mItem.count {
          let ob = mItem[cnt]
          selected += [ob.name]
          cnt += 1
        }
        
        let menuList = List<morningList>()
        for list in selected {
          let newList = morningList()
          newList.name = list
          let menuItems = menuItem.filter("menu == %@", list)
          let ob = menuItems[0]
          newList.kcal = ob.kcal
          menuList.append(newList)
        }
        newDate.mlist.append(objectsIn: menuList)
        // 朝ごはんの合計kcal
        newDate.morning = object.morning
        
        
        // 昼ごはんのメニュー追加（コピー）
        var noItem = List<noonList>()
        noItem = object.nolist
        
        selected = []
        cnt = 0
        while cnt < noItem.count {
          let ob = noItem[cnt]
          selected += [ob.name]
          cnt += 1
        }
        // 昼ごはんデータを格納
        let menuList2 = List<noonList>()
        for list in selected {
          let newList = noonList()
          newList.name = list
          let menuItems = menuItem.filter("menu == %@", list)
          let ob = menuItems[0]
          newList.kcal = ob.kcal
          menuList2.append(newList)
        }
        newDate.nolist.append(objectsIn: menuList2)
        // 昼ごはんの合計kcal
        newDate.noon = object.noon
        
        
        // 夕ごはんのメニュー追加
        let menuList3 = List<nightList>()
        selectedList = []
        
        // 夕ごはんのメニュー追加（既存）
        reset()
        var niItem = List<nightList>()
        niItem = object.nilist
        
        while cnt<(niItem.count) {
          let ob = niItem[cnt]
          selectedList += [ob.name]
          cnt += 1
        }
        reset()
        
        // 夕ごはんのメニュー追加（新規）
        while cnt < selectList.count {
          selectedList += [selectList[cnt]]
          cnt += 1
        }
        
        // 夕ごはんデータを格納
        for list in selectedList {
          let newList = nightList()
          newList.name = list
          let menuItems = menuItem.filter("menu == %@", list)
          let ob = menuItems[0]
          newList.kcal = ob.kcal
          
          menuList3.append(newList)
        }
        
        newDate.nilist.append(objectsIn: menuList3)
        // 夕ごはんの合計kcal
        newDate.night = sum
        
        newDate.snack = object.snack
        newDate.total = object.morning + object.noon + sum + object.snack + object.snack
      case 3:
        newDate.morning = object.morning
        newDate.noon = object.morning
        newDate.night = object.night
        newDate.snack = sum
        newDate.total = object.morning + object.noon + object.night + sum
      default:
        print("時間帯が指定されていません!")
      }
      
      // 新規作成
    }else{
      
      newDate.date = selectDate
      
      switch indexTime {
      case 0:
        
        let menuList = List<morningList>()
        for list in selectList {
          let newList = morningList()
          newList.name = list
          let menuItems = menuItem.filter("menu == %@", list)
          let ob = menuItems[0]
          newList.kcal = ob.kcal
          
          menuList.append(newList)
        }
        
        newDate.mlist.append(objectsIn: menuList)
        
        newDate.morning = sum
        
      case 1:
        
        let menuList = List<noonList>()
        for list in selectList {
          let newList = noonList()
          newList.name = list
          let menuItems = menuItem.filter("menu == %@", list)
          let ob = menuItems[0]
          newList.kcal = ob.kcal
          
          menuList.append(newList)
        }
        
        newDate.nolist.append(objectsIn: menuList)
        
        newDate.noon = sum
        
      case 2:
        
        let menuList = List<nightList>()
        for list in selectList {
          let newList = nightList()
          newList.name = list
          let menuItems = menuItem.filter("menu == %@", list)
          let ob = menuItems[0]
          newList.kcal = ob.kcal
          
          menuList.append(newList)
        }
        
        newDate.nilist.append(objectsIn: menuList)
        
        newDate.night = sum
      case 3:
        newDate.snack = sum
      default:
        print("時間帯が指定されていません!")
      }
      newDate.total = sum
      
      //既にデータが他に作成してある場合
      if self.dateItem.count != 0 {
        if !dateItems.isEmpty {
          newDate.id = dateItem.max(ofProperty: "id")! + 1
        }
      }
    }
    
    // 上記で代入したテキストデータを永続化
    try! realmSave.write({ () -> Void in
      realmSave.add(newDate, update: true)
    })
    
    // リセット
    resetView()
  }
  }
  
  func resetView(){
    appDelegate.selectId = []
    selectId = []
  }
  
}
