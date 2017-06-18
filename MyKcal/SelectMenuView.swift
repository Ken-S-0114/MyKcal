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
    //    DispatchQueue.main.async {
    //      self.loadView()
    //      self.viewDidLoad()
    self.selectMenuTableView.reloadData()
    //    }
  }
  
  func setKcal(){
    //    print(String(describing: type(of: object.kcal)))
    
    // suuzigenntei
    
    var l :Int = 0
    sum = 0
    
    //    dateItems = dateItem.filter("date == %@", selectDate)
    
    if(dateItems?.isEmpty == false){
      let object = dateItems?[0]
      //      print(String(describing: type(of: object)))
      switch indexTime {
      case 0:
        sum = (object?.morning)!
      case 1:
        sum = (object?.noon)!
      case 2:
        sum = (object?.night)!
      case 3:
        sum = (object?.snack)!
      default:
        print("kcalがない!")
      }
      //      print(object?.mlist.self)
    }
    
    while (l < selectId.count){
      let object = menuItem[selectId[l]]
      selectList += [object.menu]
      sum += object.kcal
      l += 1
    }
    kcalLabel.text = ("\(sum)kcal")
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
      self.navigationItem.title = "間食"
    default:
      print("時間帯が指定されていません!")
    }
  }
  
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    //    print("selected\(selected.count)")
    //    print("selectId\(selectId.count)")
    return (selected.count + selectId.count)
  }
  
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "selectMenuCell")
    
    if (((morningItem.isEmpty == false) || (noonItem.isEmpty == false)  || (nightItem.isEmpty == false)) && (check == false)) {
      switch indexTime {
      case 0:
        print(morningItem.isEmpty)
        if (morningItem.isEmpty == false){
          
          let objMorning = morningItem[l]
          
          if (l <= morningItem.count) {
            // 既存のが終了
            if (l == morningItem.count && check == false){
              check = true
            }else{
              print(objMorning.name)
              cell?.textLabel?.text = objMorning.name
              cell?.detailTextLabel?.text = ("\(String(objMorning.kcal))kcal")
              //            print(cell?.textLabel?.text as Any)
              l += 1
            }
          }
        }
        
        
      case 1:
        if (noonItem.isEmpty == false){
          let objNoon = noonItem[l]
          
          if (l < noonItem.count) {
            // 既存のが終了
            if (l == noonItem.count && check == false){
              check = true
            }else{
              cell?.textLabel?.text = objNoon.name
              cell?.detailTextLabel?.text = ("\(String(objNoon.kcal))kcal")
              //            print(cell?.textLabel?.text as Any)
              l += 1
            }
          }
        }
        
        
      case 2:
        if (nightItem.isEmpty == false){
          let objNight  = nightItem[l]
          
          if (l < nightItem.count) {
            // 既存のが終了
            if (l == nightItem.count && check == false){
              check = true
            }else{
              cell?.textLabel?.text = objNight.name
              cell?.detailTextLabel?.text = ("\(String(objNight.kcal))kcal")
              //            print(cell?.textLabel?.text as Any)
              l += 1
            }
          }
        }
        
      default:
        print("インデックスエラー")
      }
    }else{
      check = true
    }
    
    if (selectId.isEmpty == false && check == true) {
      let objectMenu = menuItem[selectId[i]]
      cell?.textLabel?.text = objectMenu.menu
      cell?.detailTextLabel?.text = ("\(String(objectMenu.kcal))kcal")
      //      print(cell?.textLabel?.text as Any)
      i += 1
    }
    print(cell?.textLabel?.text )
    return cell!
  }
  
  
  func setMenu(){
    
    if (dateItems?.isEmpty == false){
      let object = dateItems?[0]
      reset()
      
      switch indexTime {
      case 0:
        var mItem = List<morningList>()
        mItem = (object?.mlist)!
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
        noItem = (object?.nolist)!
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
        niItem = (object?.nilist)!
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
      //    print(selected.count)
    }
  }
  
  
  func reset(){
    selected = []
    cnt = 0
  }
  
  
  func saveRealm(){
    let realmSave = try! Realm()
    //    dateItem = realmSave.objects(RealmDateDB.self).sorted(byKeyPath: "id", ascending: true)
    //    dateItems = dateItem.filter("date == %@", selectDate)
    
    
    let newDate = RealmDateDB()
    
    if(dateItems?.isEmpty == false){
      let object = dateItems?[0]
      newDate.id = (object?.id)!
      newDate.date = selectDate
      
      print(selectList)
      switch indexTime {
      // 朝ごはん選択時
      case 0:
        // 朝ごはんのメニュー追加
        let menuList = List<morningList>()
        selectedList = []
        
        // 朝ごはんのメニュー追加（既存）
        reset()
        var mItem = List<morningList>()
        mItem = (object?.mlist)!
        
        while cnt<(mItem.count) {
          let ob = mItem[cnt]
          selectedList += [(ob.name)!]
          cnt += 1
        }
        reset()
        
        // 朝ごはんのメニュー追加（新規）
        while cnt<(selectList.count) {
          selectedList += [selectList[cnt]]
          cnt += 1
        }
        
        for list in selectedList {
          let newList = morningList()
          newList.name = list
          print(newList.name)
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
        noItem = (object?.nolist)!
        
        while cnt<(noItem.count) {
          let ob = noItem[cnt]
          selected += [(ob.name)!]
          cnt += 1
        }
        
        let menuList2 = List<noonList>()
        for list in selected {
          let newList = noonList()
          newList.name = list
          print(newList.name)
          let menuItems = menuItem.filter("menu == %@", list)
          let ob = menuItems[0]
          newList.kcal = ob.kcal
          menuList2.append(newList)
        }
        newDate.nolist.append(objectsIn: menuList2)
        // 昼ごはんの合計kcal
        newDate.noon = (object?.noon)!
        
        
        // 夕ごはんのメニュー追加（コピー）
        reset()
        var niItem = List<nightList>()
        niItem = (object?.nilist)!
        
        while cnt<(niItem.count) {
          let ob = niItem[cnt]
          selected += [(ob.name)!]
          cnt += 1
        }
        
        let menuList3 = List<nightList>()
        for list in selected {
          let newList = nightList()
          newList.name = list
          print(newList.name)
          let menuItems = menuItem.filter("menu == %@", list)
          let ob = menuItems[0]
          newList.kcal = ob.kcal
          menuList3.append(newList)
        }
        newDate.nilist.append(objectsIn: menuList3)
        // 夕ごはんの合計kcal
        newDate.night = (object?.night)!
        
        newDate.snack = (object?.snack)!
        newDate.total = sum + (object?.noon)! + (object?.night)! + (object?.snack)! + (object?.snack)!
        
        
      // 昼ごはん選択時
      case 1:
        // 朝ごはんのメニュー追加（コピー）
        reset()
        var mItem = List<morningList>()
        mItem = (object?.mlist)!
        
        while cnt<(mItem.count) {
          let ob = mItem[cnt]
          selected += [(ob.name)!]
          cnt += 1
        }
        // 朝ごはんデータを格納
        let menuList = List<morningList>()
        for list in selected {
          let newList = morningList()
          newList.name = list
          print(newList.name)
          let menuItems = menuItem.filter("menu == %@", list)
          let ob = menuItems[0]
          newList.kcal = ob.kcal
          menuList.append(newList)
        }
        newDate.mlist.append(objectsIn: menuList)
        // 朝ごはんの合計kcal
        newDate.morning = (object?.morning)!
        
        
        // 昼ごはんのメニュー追加
        let menuList2 = List<noonList>()
        selectedList = []
        
        // 昼ごはんのメニュー追加（既存）
        reset()
        var noItem = List<noonList>()
        noItem = (object?.nolist)!
        
        while cnt<(noItem.count) {
          let ob = noItem[cnt]
          selectedList += [(ob.name)!]
          cnt += 1
        }
        reset()
        
        // 昼ごはんのメニュー追加（新規）
        while cnt<(selectList.count) {
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
        niItem = (object?.nilist)!
        
        while cnt<(niItem.count) {
          let ob = niItem[cnt]
          selected += [(ob.name)!]
          cnt += 1
        }
        
        let menuList3 = List<nightList>()
        for list in selected {
          let newList = nightList()
          newList.name = list
          print(newList.name)
          let menuItems = menuItem.filter("menu == %@", list)
          let ob = menuItems[0]
          newList.kcal = ob.kcal
          menuList3.append(newList)
        }
        newDate.nilist.append(objectsIn: menuList3)
        // 夕ごはんの合計kcal
        newDate.night = (object?.night)!
        
        newDate.snack = (object?.snack)!
        newDate.total = (object?.morning)! + sum + (object?.night)! + (object?.snack)! + (object?.snack)!
        
      // 夕ごはん選択時
      case 2:
        
        // 朝ごはんのメニュー追加（コピー）
        reset()
        var mItem = List<morningList>()
        mItem = (object?.mlist)!
        
        while cnt<(mItem.count) {
          let ob = mItem[cnt]
          selected += [(ob.name)!]
          cnt += 1
        }
        
        let menuList = List<morningList>()
        for list in selected {
          let newList = morningList()
          newList.name = list
          print(newList.name)
          let menuItems = menuItem.filter("menu == %@", list)
          let ob = menuItems[0]
          newList.kcal = ob.kcal
          menuList.append(newList)
        }
        newDate.mlist.append(objectsIn: menuList)
        // 朝ごはんの合計kcal
        newDate.morning = (object?.morning)!
        
        
        // 昼ごはんのメニュー追加（コピー）
        var noItem = List<noonList>()
        noItem = (object?.nolist)!
        
        selected = []
        cnt = 0
        while cnt<(noItem.count) {
          let ob = noItem[cnt]
          selected += [(ob.name)!]
          cnt += 1
        }
        // 昼ごはんデータを格納
        let menuList2 = List<noonList>()
        for list in selected {
          let newList = noonList()
          newList.name = list
          print(newList.name)
          let menuItems = menuItem.filter("menu == %@", list)
          let ob = menuItems[0]
          newList.kcal = ob.kcal
          menuList2.append(newList)
        }
        newDate.nolist.append(objectsIn: menuList2)
        // 昼ごはんの合計kcal
        newDate.noon = (object?.noon)!
        
        
        // 夕ごはんのメニュー追加
        let menuList3 = List<nightList>()
        selectedList = []
        
        // 夕ごはんのメニュー追加（既存）
        reset()
        var niItem = List<nightList>()
        niItem = (object?.nilist)!
        
        while cnt<(niItem.count) {
          let ob = niItem[cnt]
          selectedList += [(ob.name)!]
          cnt += 1
        }
        reset()
        
        // 夕ごはんのメニュー追加（新規）
        while cnt<(selectList.count) {
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
        
        newDate.snack = (object?.snack)!
        newDate.total = (object?.morning)! + (object?.noon)! + sum + (object?.snack)! + (object?.snack)!
      case 3:
        newDate.morning = (object?.morning)!
        newDate.noon = (object?.morning)!
        newDate.night = (object?.night)!
        newDate.snack = sum
        newDate.total = (object?.morning)! + (object?.noon)! + (object?.night)! + sum
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
        if dateItems?.isEmpty != false {
          newDate.id = self.dateItem.max(ofProperty: "id")! + 1
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
  
  func resetView(){
    appDelegate.selectId = []
    selectId = []
  }
  
}
