//
//  AddMenuView.swift
//  MyKcal
//
//  Created by 佐藤賢 on 2017/06/11.
//  Copyright © 2017年 佐藤賢. All rights reserved.
//

import UIKit
import RealmSwift

class AddMenuView: UIViewController {
  
  var kindString: [String] = []  // Pickerに格納されている文字列
  var kindSelect = String()    // Pickerで選択した文字列の格納場所
  var count = Int()
  var setupOnly: Bool = false
  var check: Bool = true              // 同じジャンル名があるかチェックする変数
  
  struct RealmModel {
    struct realm {
      // Realmのインスタンス生成
      static var realmTry  = try!Realm()
      static var kindItem: Results<RealmKindDB>! = RealmModel.realm.realmTry.objects(RealmKindDB.self)
      static var menuItem: Results<RealmMenuDB>! = RealmModel.realm.realmTry.objects(RealmMenuDB.self)
      
    }
  }
  
  @IBOutlet weak var kindPicker: UIPickerView!
  @IBOutlet weak var menuTextField: UITextField!
  @IBOutlet weak var kcalTextField: UITextField!
  
  @IBOutlet weak var kindLabel: UILabel!
  @IBOutlet weak var menuLabel: UILabel!
  @IBOutlet weak var kcalLabel: UILabel!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupPickerView()
    kcalTextField.keyboardType = .numberPad
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    setupPickerView()
    resetupPickerView()
  }
  
  
  @IBAction func addKindButton(_ sender: UIButton) {
    addKindView()
  }
  
  @IBAction func saveMenuButton(_ sender: UIBarButtonItem) {
    saveMenu()
    _ = navigationController?.popViewController(animated: true)
  }
  
  @IBAction func tapScreen(_ sender: UITapGestureRecognizer) {
    self.view.endEditing(true)
  }
  
  
  func setupPickerView(){

    var i: Int = 0
    
    if setupOnly == false {
      count = RealmModel.realm.kindItem.count
      setupOnly = true
    }
    
    // RealmKindDBに保存してある値を配列に格納
    while count>i {
      let object = RealmModel.realm.kindItem[i]
      kindString += [object.kind]
      i += 1
    }
    
    if kindString.isEmpty == false {
      kindPicker.selectRow(0, inComponent: 0, animated: true)
      kindSelect = kindString[0]
    }
  }
  
  func resetupPickerView(){
    // 変更後の数
    let recount: Int = RealmModel.realm.kindItem.count
    var i: Int = 0
    
    // 変更前の数と比べる
    if recount != count {
      // 配列の中身を初期化
      kindString = []
      // 再度格納
      while recount > i {
        let object = RealmModel.realm.kindItem[i]
        kindString += [object.kind]
        i += 1
      }
      // 更新
      count = recount
      
      kindPicker.reloadAllComponents()
      kindPicker.selectRow(count-1, inComponent: 0, animated: true)
      kindSelect = kindString[count-1]
    }
  }
  
  
  func addKindView(){
    let alert = UIAlertController(title: "新規カテゴリー", message: nil, preferredStyle: .alert)
    
    let saveAction = UIAlertAction(title: "OK", style: .default, handler: {
      (action:UIAlertAction!) -> Void in
      
      var i: Int = 0;
      // 新しいインスタンスを生成
      let new = RealmKindDB()
      //textField等に入力したデータをnewAddCategoryに代入
      new.kind = alert.textFields![0].text!
      
      while_i: while RealmModel.realm.kindItem.count > i {
        // 同じジャンル名があるかDB上でチェック
        if new.kind == RealmModel.realm.kindItem[i].kind {
          // アクションシートの親となる UIView を設定
          alert.popoverPresentationController?.sourceView = self.view
          // 吹き出しの出現箇所を CGRect で設定 （これはナビゲーションバーから吹き出しを出す例）
          alert.popoverPresentationController?.sourceRect = (self.navigationController?.navigationBar.frame)!
          // 同じ名前のジャンルが既に存在している場合
          let alertController = UIAlertController(title: "保存失敗", message: "同じ名前が既に存在します", preferredStyle: .actionSheet)
          let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
          alertController.addAction(alertAction)
          
          //　iPad用クラッシュさせないために
          alertController.popoverPresentationController?.sourceView = self.view;
          alertController.popoverPresentationController?.sourceRect = (self.navigationController?.navigationBar.frame)!
          
          self.present(alertController, animated: true, completion: nil)
          self.check = false
          break while_i
        }
        i += 1
        self.check = true
      }
      
      if(new.kind.isEmpty == false) && (self.check == true) {
        // アクションシートの親となる UIView を設定
        alert.popoverPresentationController?.sourceView = self.view
        
        // 吹き出しの出現箇所を CGRect で設定 （これはナビゲーションバーから吹き出しを出す例）
        alert.popoverPresentationController?.sourceRect = (self.navigationController?.navigationBar.frame)!
        let alertController = UIAlertController(title: "保存しました", message: nil, preferredStyle: .actionSheet)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(alertAction)
        
        //　iPad用クラッシュさせないために
        alertController.popoverPresentationController?.sourceView = self.view;
        alertController.popoverPresentationController?.sourceRect = (self.navigationController?.navigationBar.frame)!
        
        self.present(alertController, animated: true, completion: nil)
        
        //既にデータが他に作成してある場合
        if RealmModel.realm.kindItem.count != 0 {
          new.id = RealmModel.realm.kindItem.max(ofProperty: "id")! + 1
        }
        
        //上記で代入したテキストデータを永続化
        try! RealmModel.realm.realmTry.write({ () -> Void in
          RealmModel.realm.realmTry.add(new, update: false)
        })
        self.viewWillAppear(true)
      }
      else if new.kind.isEmpty == true {
        // アクションシートの親となる UIView を設定
        alert.popoverPresentationController?.sourceView = self.view
        
        // 吹き出しの出現箇所を CGRect で設定 （これはナビゲーションバーから吹き出しを出す例）
        alert.popoverPresentationController?.sourceRect = (self.navigationController?.navigationBar.frame)!
        let alertController = UIAlertController(title: "入力されていません", message: "作成画面に戻ります", preferredStyle: .actionSheet)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(alertAction)
        
        //　iPad用クラッシュさせないために
        alertController.popoverPresentationController?.sourceView = self.view;
        alertController.popoverPresentationController?.sourceRect = (self.navigationController?.navigationBar.frame)!
        
        self.present(alertController, animated: true, completion: nil)
        
      }
    })
    alert.addAction(saveAction)
    
    // キャンセルボタンの設定
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    alert.addAction(cancelAction)
    
    
    // UIAlertControllerにtextFieldを追加
    alert.addTextField(configurationHandler: {(textField: UITextField!) -> Void in
      textField.placeholder = "カテゴリーを入力してください"
    })
    
    //　iPad用クラッシュさせないために
    alert.popoverPresentationController?.sourceView = self.view;
    alert.popoverPresentationController?.sourceRect = (self.navigationController?.navigationBar.frame)!
    
    present(alert, animated: true, completion: nil)
    
  }
  
  func saveMenu(){
    if (menuTextField.text != "") && (kcalTextField.text != "") {
      
      // 新しいインスタンスを生成
      let newMenu = RealmMenuDB()
      // textField等に入力したデータをeditRealmDBに代入
      newMenu.kind = kindSelect
      newMenu.menu = menuTextField.text!
      newMenu.kcal = Int(kcalTextField.text!)!

      //既にデータが他に作成してある場合
      if RealmModel.realm.menuItem.count != 0 {
        newMenu.id = RealmModel.realm.menuItem.max(ofProperty: "id")! + 1
      }

      // 上記で代入したテキストデータを永続化
      let realm = try! Realm()
      try! realm.write({ () -> Void in
        realm.add(newMenu, update: true)
      })
      
      // 上書き保存したことを知らせるアラート表示
      let alertController = UIAlertController(title: "保存しました", message: ("メニュー名：\(newMenu.menu)\nカロリー：\(newMenu.kcal)kcal"), preferredStyle: .alert)
      let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
      alertController.addAction(alertAction)
      
      //　iPad用クラッシュさせないために
      alertController.popoverPresentationController?.sourceView = self.view;
      alertController.popoverPresentationController?.sourceRect = (self.navigationController?.navigationBar.frame)!
      
      present(alertController, animated: true, completion: nil)
      
      menuTextField.text = ""
      kcalTextField.text = ""
    }else {
      // 未入力を知らせるアラート表示
      let alertController = UIAlertController(title: "未入力項目が存在します", message: nil, preferredStyle: .alert)
      let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
      alertController.addAction(alertAction)
      
      //　iPad用クラッシュさせないために
      alertController.popoverPresentationController?.sourceView = self.view;
      alertController.popoverPresentationController?.sourceRect = (self.navigationController?.navigationBar.frame)!
      
      present(alertController, animated: true, completion: nil)
    }

  }

  
}

extension AddMenuView: UIPickerViewDelegate {
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    if let kindString = kindString[row].first {
      kindSelect = String(kindString)
    }
  }
}

extension AddMenuView: UIPickerViewDataSource {
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return RealmModel.realm.kindItem.count
  }
  
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return kindString[row]
  }
}

extension AddMenuView: UITextFieldDelegate {
  // Doneボタンを押した際キーボードを閉じる
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
}
