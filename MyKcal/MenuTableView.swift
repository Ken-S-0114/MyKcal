//
//  MenuTableView.swift
//  MyKcal
//
//  Created by 佐藤賢 on 2017/06/11.
//  Copyright © 2017年 佐藤賢. All rights reserved.
//

import UIKit
import RealmSwift

class MenuTableView: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
  
  @IBOutlet weak var kindSearch: UISearchBar!
  @IBOutlet weak var menuSearch: UISearchBar!
  @IBOutlet weak var menuTableView: UITableView!
  
  @IBAction func addMenuButton(_ sender: UIBarButtonItem) {
    performSegue(withIdentifier: "addMenuSegue", sender: nil)
  }
  
  
  var menuItem: Results<RealmMenuDB>!
  let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
  
  var selectId: [Int] = []  // 選択されたメニュー番号
  var indexPath = Int()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupRealm()
    menuSearch.enablesReturnKeyAutomatically = false
    // Do any additional setup after loading the view.
    
    indexPath = appDelegate.indexPath!
    print(indexPath)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    setupRealm()
    menuTableView.reloadData()
  }
  
  func setupRealm(){
    let realm = try! Realm()
    menuItem = realm.objects(RealmMenuDB.self).sorted(byKeyPath: "id", ascending: true)
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
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    if (searchBar.text == ""){
      menuItem = try! Realm().objects(RealmMenuDB.self).sorted(byKeyPath: "id", ascending: true)
      menuTableView.reloadData()
    }
    menuSearch.endEditing(true)
  }
  
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return  menuItem.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "menuCell")
    let object = menuItem[indexPath.row]
    cell?.textLabel?.text = object.menu
    cell?.detailTextLabel?.text = ("\(String(describing: object.kcal))kcal")
    
    // 選択済みの問題にはチェックマークを初期値としてつける
    for _ in 0..<menuItem.count{
      for i in 0..<selectId.count {
        if (indexPath.row == selectId[i]){
          cell?.accessoryType = .checkmark
        }
      }
    }
    
    return cell!
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
  
//  // セルの選択が外れた時に呼び出される
//  func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//    let cell = tableView.cellForRow(at:indexPath)
//    let object = menuItem[indexPath.row]
//    if  cell?.accessoryType == .checkmark {
//      // チェックマークを外す
//      cell?.accessoryType = .none
//      // 配列に指定した問題ID削除
//      _ = selectId.remove(element: object.id)
//    }else {
//      // チェックマークを入れる
//      cell?.accessoryType = .checkmark
//      // 配列に指定した問題ID格納
//      selectId.append(object.id)
//    }
//  }
  
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
