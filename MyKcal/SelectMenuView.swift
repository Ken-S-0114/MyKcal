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
  var dateItem: Results<RealmDateDB>!
  var dateItems: Results<RealmDateDB>?
  
  let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
  var selectId: [Int] = []  // 選択されたメニュー番号
  var indexPath = Int()
  var sum: Int = 0
  var i: Int = 0
  var timeText = String()
  var selectDate = String()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupIndex()
    setKcal()
    setupRealm()
    selectDate = appDelegate.selectDate!
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
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
      // textField等に入力したデータをeditRealmDBに代入
      newDate.date = selectDate
      switch indexPath {
      case 0:
        newDate.morning = sum
        newDate.noon = (object?.noon)!
        newDate.night = (object?.night)!
        newDate.snack = (object?.snack)!
        newDate.total = sum + (object?.noon)! + (object?.night)! + (object?.snack)! + (object?.snack)!
      case 1:
        newDate.morning = (object?.morning)!
        newDate.noon = sum
        newDate.night = (object?.night)!
        newDate.snack = (object?.snack)!
        newDate.total = (object?.morning)! + sum + (object?.night)! + (object?.snack)! + (object?.snack)!
      case 2:
        newDate.morning = (object?.morning)!
        newDate.noon = (object?.morning)!
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
    }else{
      // textField等に入力したデータをeditRealmDBに代入
      newDate.date = selectDate
      switch indexPath {
      case 0:
        newDate.morning = sum
      case 1:
        newDate.noon = sum
      case 2:
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

    while (l < selectId.count){
      let object = menuItem[selectId[l]]
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
