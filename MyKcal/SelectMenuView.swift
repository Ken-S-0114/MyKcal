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
  @IBAction func saveButton(_ sender: UIBarButtonItem) {
    saveRealm()
    _ = navigationController?.popViewController(animated: true)
  }
  
  var menuItem: Results<RealmMenuDB>!
  var menuItems: Results<RealmMenuDB>?
  var dateItem: Results<RealmDateDB>!
  var dateItems: Results<RealmDateDB>?
  
  
  let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
  var selectId: [Int] = []  // 選択されたメニュー番号
  var indexPath = Int()
  var selectList: [String] = []
  var sum: Int = 0
  var i: Int = 0
  var timeText = String()
  var selectDate = String()
  
  var selected: [String] = []
  var cnt: Int = 0
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupIndex()
    setupRealm()
    setKcal()
    selectDate = appDelegate.selectDate!
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    selectList = []
    selectId = appDelegate.selectId
    i = 0
    sum = 0
    setupIndex()
    resetupTableView()
    setupRealm()
    setKcal()
    selectDate = appDelegate.selectDate!
  }
  
  func setupRealm(){
    let realm = try! Realm()
    menuItem = realm.objects(RealmMenuDB.self).sorted(byKeyPath: "id", ascending: true)
    
    let realmSave = try! Realm()
    dateItem = realmSave.objects(RealmDateDB.self).sorted(byKeyPath: "id", ascending: true)
    
  }
  
  func saveRealm(){
    let realmSave = try! Realm()
    dateItem = realmSave.objects(RealmDateDB.self).sorted(byKeyPath: "id", ascending: true)
    dateItems = dateItem.filter("date == %@", selectDate)


    let newDate = RealmDateDB()
    
    if(dateItems?.isEmpty == false){
      let object = dateItems?[0]
      
      newDate.date = selectDate
      
      print(selectList)
      switch indexPath {
      case 0:
        // 朝ごはんのメニュー追加
        let menuList = List<morningList>()
        for list in selectList {
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
        var noItem = List<noonList>()
        noItem = (object?.nolist)!
        
        selected = []
        cnt = 0
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
        var niItem = List<nightList>()
        niItem = (object?.nilist)!
        
        selected = []
        cnt = 0
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
      case 1:
        // 朝ごはんのメニュー追加（コピー）
        var mItem = List<morningList>()
        mItem = (object?.mlist)!
        
        selected = []
        cnt = 0
        while cnt<(mItem.count) {
          let ob = mItem[cnt]
          selected += [(ob.name)!]
          cnt += 1
        }
        
        let menuList11 = List<morningList>()
        for list in selected {
          let newList = morningList()
          newList.name = list
          print(newList.name)
          let menuItems = menuItem.filter("menu == %@", list)
          let ob = menuItems[0]
          newList.kcal = ob.kcal
          
          menuList11.append(newList)
        }
        
        newDate.mlist.append(objectsIn: menuList11)
        
        
        newDate.morning = (object?.morning)!
        
        
        let menuList12 = List<noonList>()
        for list in selectList {
          let newList = noonList()
          newList.name = list
          let menuItems = menuItem.filter("menu == %@", list)
          let ob = menuItems[0]
          newList.kcal = ob.kcal
          
          menuList12.append(newList)
        }
        
        newDate.nolist.append(objectsIn: menuList12)

        newDate.noon = sum
        
        // 夕ごはんのメニュー追加（コピー）
        var niItem = List<nightList>()
        niItem = (object?.nilist)!
        
        selected = []
        cnt = 0
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
        
        newDate.night = (object?.night)!
        newDate.snack = (object?.snack)!
        newDate.total = (object?.morning)! + sum + (object?.night)! + (object?.snack)! + (object?.snack)!
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

        // 朝ごはんのメニュー追加（コピー）
        var mItem = List<morningList>()
        mItem = (object?.mlist)!
        
        selected = []
        cnt = 0
        while cnt<(mItem.count) {
          let ob = mItem[cnt]
          selected += [(ob.name)!]
          cnt += 1
        }
        
        let menuList21 = List<morningList>()
        for list in selected {
          let newList = morningList()
          newList.name = list
          print(newList.name)
          let menuItems = menuItem.filter("menu == %@", list)
          let ob = menuItems[0]
          newList.kcal = ob.kcal
          
          menuList21.append(newList)
        }
        
        newDate.mlist.append(objectsIn: menuList21)
        
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
        
        let menuList22 = List<noonList>()
        for list in selected {
          let newList = noonList()
          newList.name = list
          print(newList.name)
          let menuItems = menuItem.filter("menu == %@", list)
          let ob = menuItems[0]
          newList.kcal = ob.kcal
          
          menuList22.append(newList)
        }
        
        newDate.nolist.append(objectsIn: menuList22)

        newDate.noon = (object?.morning)!
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

    }else{

      newDate.date = selectDate
      
      switch indexPath {
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
    }
    //既にデータが他に作成してある場合
    if self.dateItem.count != 0 {
      if dateItems?.isEmpty != false {
        newDate.id = self.dateItem.max(ofProperty: "id")! + 1
      }
    }
    
    // 上記で代入したテキストデータを永続化
    try! realmSave.write({ () -> Void in
      realmSave.add(newDate, update: true)
    })
    
    appDelegate.selectId = []
    selectId = []
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
    
    dateItems = dateItem.filter("date == %@", selectDate)
    
    if(dateItems?.isEmpty == false){
      let object = dateItems?[0]
      switch indexPath {
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
    kcalLabel.text = ("\(timeText)  :  \(sum)kcal")
  }
  
  func setupIndex(){
    indexPath = appDelegate.index!
    switch indexPath {
    case 0:
      timeText = "朝食"
    case 1:
      timeText = "昼食"
    case 2:
      timeText = "夕食"
    case 3:
      timeText = "間食"
    default:
      print("時間帯が指定されていません!")
    }
  }
  
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return selectId.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "selectMenuCell")
    let object = menuItem[selectId[i]]
    cell?.textLabel?.text = object.menu
    cell?.detailTextLabel?.text = ("\(String(object.kcal))kcal")
    
    i += 1
    return cell!
  }
  
  
  
  
  
}
