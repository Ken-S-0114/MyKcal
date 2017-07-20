//
//  MenuTableView.swift
//  MyKcal
//
//  Created by 佐藤賢 on 2017/06/11.
//  Copyright © 2017年 佐藤賢. All rights reserved.
//

import UIKit
import RealmSwift

class MenuTableView: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
  
  @IBOutlet weak var menuSearch: UISearchBar!
  @IBOutlet weak var menuTableView: UITableView!
  @IBAction func kindButton(_ sender: UIButton) {
    kindSearch()
  }

  @IBAction func addMenuButton(_ sender: UIBarButtonItem) {
    performSegue(withIdentifier: "addMenuSegue", sender: nil)
  }
  
  
  var menuItem: Results<RealmMenuDB>!
  var kindItem: Results<RealmKindDB>!
  
  let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
  var selectId: [Int] = []  // 選択されたメニュー番号
  var indexTime = Int()
  
  var kindString: [String?] = []  // Pickerに格納されている文字列
  var kindSelect = String()    // Pickerで選択した文字列の格納場所
   let header: [String] = ["メニュー一覧"]
  var count = Int()
  
  var setupOnly: Bool = false
  
  let kindPicker = UIPickerView()

  override func viewDidLoad() {
    super.viewDidLoad()
    setupRealm()
    setupPickerView()
    menuSearch.enablesReturnKeyAutomatically = false
    indexTime = appDelegate.indexTime!
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    if (self.navigationController?.viewControllers) != nil {
      appDelegate.selectId = selectId
    }
    super.viewWillDisappear(animated)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    setupRealm()
    setupPickerView()
    resetupPickerView()
    selectId = appDelegate.selectId
    menuTableView.reloadData()
  }
  
  func setupRealm(){
    let realm = try! Realm()
    menuItem = realm.objects(RealmMenuDB.self).sorted(byKeyPath: "id", ascending: true)
  }
  
  func setupPickerView(){
    let realmKind = try! Realm()
    var i: Int = 0
    kindItem = realmKind.objects(RealmKindDB.self)
    
    if setupOnly == false {
      count = kindItem.count
      setupOnly = true
    }
    
    // RealmKindDBに保存してある値を配列に格納
    while count>i {
      let object = kindItem[i]
      kindString += [object.kind]
      i += 1
    }
    
    if kindString.isEmpty == false {
      kindPicker.selectRow(0, inComponent: 0, animated: true)
      kindSelect = kindString[0]!
    }
  }
  
  func resetupPickerView(){
    // 変更後の数
    let recount: Int = kindItem.count
    var i: Int = 0
    
    // 変更前の数と比べる
    if recount != count {
      // 配列の中身を初期化
      kindString = []
      // 再度格納
      while recount > i {
        let object = kindItem[i]
        kindString += [object.kind]
        i += 1
      }
      // 更新
      count = recount
      
      kindPicker.reloadAllComponents()
      kindPicker.selectRow(count-1, inComponent: 0, animated: true)
      kindSelect = kindString[count-1]!
    }
  }

  func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    let searchText: String
    if text.isEmpty {
      
      let searchBarText = searchBar.text!
      let index = searchBarText.endIndex
      searchText = searchBarText.substring(to: index)
      
    } else {
      
      let searchBarText = NSMutableString(string: searchBar.text!)
      searchBarText.insert(text, at: range.location)
      searchText = searchBarText as String
    }
    search(text: searchText)
    return true
  }
  
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    search(text: searchBar.text!)
  }
  
  func search(text: String){
    menuItem = try! Realm().objects(RealmMenuDB.self).filter("menu CONTAINS %@", text)
    menuTableView.reloadData()
  }
  
  func searchKind(text: String){
    menuItem = try! Realm().objects(RealmMenuDB.self).filter("kind CONTAINS %@", text)
    menuTableView.reloadData()
  }
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    if searchBar.text == "" {
      menuItem = try! Realm().objects(RealmMenuDB.self).sorted(byKeyPath: "id", ascending: true)
      menuTableView.reloadData()
    }
    menuSearch.endEditing(true)
  }
  
  func kindSearch() {
    let title = "性別・年齢別標準カロリー"
    let message = "あなたの性別と年齢を選択して下さい\n\n\n\n\n\n\n\n\n\n" //改行入れないとOKがかぶる
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:{
      (action: UIAlertAction!) -> Void in
      self.searchKind(text: self.kindSelect)
    })
    
    // PickerView
    kindPicker.selectRow(0, inComponent: 0, animated: true) // 初期値
    kindPicker.frame = CGRect(x: 0, y: 60, width: alert.view.bounds.width, height: 150) // 配置、サイズ
    kindPicker.autoresizingMask = [.flexibleWidth]
    kindPicker.dataSource = self
    kindPicker.delegate = self
    alert.view.addSubview(kindPicker)
    
    alert.addAction(okAction)
    present(alert, animated: true, completion: nil)

  }
  
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return kindItem.count
  }
  
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return kindString[row]
  }
  
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    if let kindString = kindString[row] {
      kindSelect = kindString
    }
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return  menuItem.count
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
    let cell = tableView.dequeueReusableCell(withIdentifier: "menuCell")
    let object = menuItem[indexPath.row]
    cell?.textLabel?.text = object.menu
    cell?.detailTextLabel?.text = ("\(String(describing: object.kcal))kcal")
    
    // 選択済みの問題にはチェックマークを初期値としてつける
    for _ in 0..<menuItem.count{
      for i in 0..<selectId.count {
        if indexPath.row == selectId[i] {
          cell?.accessoryType = .checkmark
        }
      }
    }
    
    return cell!
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return header[section]
  }
  
  // セルが選択された時に呼び出される
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let cell = tableView.cellForRow(at:indexPath)
    let object = menuItem[indexPath.row]
    if  cell?.accessoryType != .checkmark {
      // チェックマークを入れる
      cell?.accessoryType = .checkmark
      // 配列に指定した問題ID格納
      selectId.append(object.id)
    }else {
      // チェックマークを外す
      cell?.accessoryType = .none
      // 配列に指定した問題ID削除
      _ = selectId.remove(element: object.id)
    }
  }
  
}

// 削除する際に使用(選択したセルに格納されている値と一致する値のみ削除）
extension Array where Element: Equatable {
  mutating func remove(element: Element) -> Bool {
    guard let index = index(of: element) else { return false }
    remove(at: index)
    return true
  }
  
  mutating func remove(elements: [Element]) {
    for element in elements {
      _ = remove(element: element)
    }
  }
}
