//
//  ViewController.swift
//  MyKcal
//
//  Created by 佐藤賢 on 2017/06/08.
//  Copyright © 2017年 佐藤賢. All rights reserved.
//

import UIKit
import RealmSwift
import JTAppleCalendar

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
  @IBOutlet weak var calendarView: JTAppleCalendarView!
  
  @IBOutlet weak var kcalTableView: UITableView!
  
  var dateItem: Results<RealmDateDB>!
  var dateItems: Results<RealmDateDB>?
  let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
  
  let formatter = DateFormatter()
  var testCalendar = Calendar.current
  
  let timeArray: [String] = ["朝", "昼", "夜", "合計"]
  var kcalTime: [String] = ["0", "0", "0", "0"]
  let header: [String] = ["時間帯"]
  
  var selectDateView: String = ""
  var selectDate: String = ""
  
  var check: Bool = false
  var naviCheck: Bool = false
  
  let backgroundColor: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
  let outsideMonthColor: UIColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
  let monthColor: UIColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
  let selectedMonthColor: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
  var currentDateSelectedViewColor: UIColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
  var realmCheckColor: UIColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupRealmView()
    setupCalendarView()
    setupLongPress()
    // Cellの高さ自動調整
    kcalTableView.rowHeight = UITableViewAutomaticDimension
    // 初期値設定
    appDelegate.selectColor = currentDateSelectedViewColor
    appDelegate.selectMarkColor = realmCheckColor
    // スクロールさせない
    kcalTableView.isScrollEnabled = false
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    //    if let indexPathForSelectedRow = kcalTableView.indexPathForSelectedRow {
    //      kcalTableView.deselectRow(at: indexPathForSelectedRow, animated: true)
    //    }
    setupRealmView()
    setupCalendarView()
    calendarView.reloadData()
    kcalTableView.reloadData()
    
    if appDelegate.selectColor != nil {
      currentDateSelectedViewColor = appDelegate.selectColor!
    }
    if appDelegate.selectMarkColor != nil {
      realmCheckColor = appDelegate.selectMarkColor!
    }
  }
  
  
  func setupCalendarView(){
    calendarView.minimumLineSpacing = 0
    calendarView.minimumInteritemSpacing = 0
    calendarView.backgroundColor = backgroundColor
    
    calendarView.visibleDates { (visibleDates) in
      self.setupViewOfCalendar(from: visibleDates)
    }
  }
  
  func setupLongPress(){
    let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.onLongPressAction))
    // 指のズレを許容する範囲 10px
    longPressRecognizer.allowableMovement = 10
    // イベントが発生するまでタップする時間
    longPressRecognizer.minimumPressDuration = 0.5
    // タップする回数 1回の場合は[0] 2回の場合は[1]を指定
    longPressRecognizer.numberOfTapsRequired = 0;
    // タップする指の数
    longPressRecognizer.numberOfTouchesRequired = 1;
    self.calendarView.addGestureRecognizer(longPressRecognizer)
  }
  
  func setupRealmView(){
    let realm = try! Realm()
    dateItem = realm.objects(RealmDateDB.self)
  }
  
  func setupViewOfCalendar(from visibleDates: DateSegmentInfo){
    let date = visibleDates.monthDates.first!.date
    
    self.formatter.dateFormat = "yyyy  MMMM"
    self.navigationItem.title = self.formatter.string(from: date)
  }
  
  func setRealmColor(view: JTAppleCell?, cellState: CellState){
    guard let validCell = view as? CustomCell else { return }
    
    formatter.dateFormat = "yyyyMMdd"
    selectDate = formatter.string(from: cellState.date)
    
    dateItems = dateItem.filter("date == %@", selectDate)
    
    
    if dateItems?.isEmpty == false {
      validCell.markView.isHidden = false
      validCell.markView.backgroundColor = realmCheckColor
    }else{
      validCell.markView.isHidden = true
    }
  }
  
  func handleCellTextColor(view: JTAppleCell?, cellState: CellState) {
    guard let validCell = view as? CustomCell else { return }
    
    if cellState.isSelected {
      validCell.dateLabel.textColor = selectedMonthColor
    } else {
      if cellState.dateBelongsTo == .thisMonth {
        validCell.dateLabel.textColor = monthColor
      } else {
        validCell.dateLabel.textColor = outsideMonthColor
      }
    }
  }
  
  func handleCellSelected(view: JTAppleCell?, cellState: CellState) {
    guard let validCell = view as? CustomCell else { return }
    
    if cellState.isSelected {
      
      validCell.selectedView.isHidden = false
      validCell.selectedView.layer.cornerRadius = 18
      validCell.selectedView.backgroundColor = currentDateSelectedViewColor
      
      formatter.dateFormat = "yyyyMMdd"
      selectDate = formatter.string(from: cellState.date)
      appDelegate.selectDate = selectDate
      
      formatter.dateFormat = "yyyy年MM月dd日"
      selectDateView = formatter.string(from: cellState.date)
      
      let realmSelect = try! Realm()
      dateItem = realmSelect.objects(RealmDateDB.self)
      dateItems = dateItem.filter("date == %@", selectDate)
      
      DispatchQueue.main.async {
        //        self.loadView()
        //        self.viewDidLoad()
        
        //      print(dateItems.self!)
        self.kcalTableView.reloadData()
        
      }
      check = true
      
    }else {
      validCell.selectedView.isHidden = true
    }
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 4
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "kcalCell")
    // cellの背景を透過
    cell?.backgroundColor = UIColor.clear
    // cell内のcontentViewの背景を透過
    cell?.contentView.backgroundColor = UIColor.clear
    
    cell?.textLabel?.text = timeArray[indexPath.row]
    if dateItems?.isEmpty == false {
      let object = dateItems?[0]
      switch indexPath.row {
      case 0:
        cell?.detailTextLabel?.text = ("\((object?.morning)!)kcal")
      case 1:
        cell?.detailTextLabel?.text = ("\((object?.noon)!)kcal")
      case 2:
        cell?.detailTextLabel?.text = ("\((object?.night)!)kcal")
      case 3:
        cell?.detailTextLabel?.text = ("\((object?.morning)!+(object?.noon)!+(object?.night)!)kcal")
      default:
        break
      }
    }else{
      cell?.detailTextLabel?.text = ("\(kcalTime[indexPath.row])kcal")
    }
    return cell!
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if indexPath.row != 3 {
      if check == true {
        appDelegate.indexTime = indexPath.row
        performSegue(withIdentifier: "selectSegue", sender: nil)
      }
    }else{
      performSegue(withIdentifier: "totalSegue", sender: nil)
    }
    
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return header[section]
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
  
  // 削除
  //  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
  //    if editingStyle == UITableViewCellEditingStyle.delete {
  //      let object = dateItems?[0]
  //      print(dateItems.self)
  //      let realm = try! Realm()
  //      tableView.reloadData()
  //      switch indexPath.row {
  //      case 0:
  //        try! realm.write {
  //          realm.delete((object?.mlist)!)
  //          tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
  //        }
  //      case 1:
  //        try! realm.write {
  //          realm.delete((object?.nolist)!)
  //          tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
  //        }
  //      case 2:
  //        try! realm.write {
  //          realm.delete((object?.nilist)!)
  //          tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
  //        }
  //      default:
  //        print("削除エラー")
  //      }
  //    }
  //  }
  
  func naviDeleteAlert(){
    let alert = UIAlertController(title: "\(selectDateView)のデータを\n削除しますか？", message: nil, preferredStyle: .alert)
    let deleteAction = UIAlertAction(title: "OK", style: .destructive, handler: {
      (action:UIAlertAction!) -> Void in
      
      // アクションシートの親となる UIView を設定
      alert.popoverPresentationController?.sourceView = self.view
      
      // 吹き出しの出現箇所を CGRect で設定 （これはナビゲーションバーから吹き出しを出す例）
      alert.popoverPresentationController?.sourceRect = (self.navigationController?.navigationBar.frame)!
      let alertController = UIAlertController(title: "削除しました", message: nil, preferredStyle: .actionSheet)
      let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
      alertController.addAction(alertAction)
      
      //　iPad用クラッシュさせないために
      alertController.popoverPresentationController?.sourceView = self.view;
      alertController.popoverPresentationController?.sourceRect = (self.navigationController?.navigationBar.frame)!
      
      self.present(alertController, animated: true, completion: nil)
      
      self.naviCheck = true
      self.delete()
    })
    alert.addAction(deleteAction)
    
    
    // キャンセルボタンの設定
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    alert.addAction(cancelAction)
    
    //　iPad用クラッシュさせないために
    alert.popoverPresentationController?.sourceView = self.view;
    alert.popoverPresentationController?.sourceRect = (self.navigationController?.navigationBar.frame)!
    
    // 親View表示
    present(alert, animated: true, completion: nil)
  }
  
  
  func naviNoDateAlert(){
    if naviCheck == false{
      let alertController = UIAlertController(title: "指定した日のデータが存在しません", message: nil, preferredStyle: .actionSheet)
      let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
      alertController.addAction(alertAction)
      
      //　iPad用クラッシュさせないために
      alertController.popoverPresentationController?.sourceView = self.view;
      alertController.popoverPresentationController?.sourceRect = (self.navigationController?.navigationBar.frame)!
      
      present(alertController, animated: true, completion: nil)
    }
    
  }
  
  func delete(){
    let realm = try! Realm()
    try! realm.write {
      realm.delete((self.dateItems?[0])!)
      kcalTableView.reloadData()
      calendarView.reloadData()
    }
  }
  
  func onLongPressAction(sender: UILongPressGestureRecognizer) {
    let point: CGPoint = sender.location(in: self.calendarView)
    let indexPath = self.calendarView.indexPathForItem(at: point)
    
    if indexPath != nil {
      switch sender.state {
      case .ended:
        if dateItems?.isEmpty == false {
          naviDeleteAlert()
        }else{
          naviCheck = false
          naviNoDateAlert()
        }
      // 例えばTimerをstopさせる
      default:
        break
      }
    }
  }
  
  
}

extension ViewController: JTAppleCalendarViewDataSource {
  func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
    
    formatter.dateFormat = "yyyy MM dd"
    formatter.timeZone = testCalendar.timeZone
    formatter.locale = testCalendar.locale
    
    
    let startDate = formatter.date(from: "2017 01 01")!
    let endDate = formatter.date(from: "2018 12 31")!
    
    let parameters = ConfigurationParameters(startDate: startDate, endDate: endDate)
    return parameters
  }
}

extension ViewController: JTAppleCalendarViewDelegate {
  func calendar(_ calendar: JTAppleCalendarView, cellForItemAt: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
    let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CustomCell", for: indexPath) as! CustomCell
    cell.dateLabel.text = cellState.text
    
    setRealmColor(view: cell, cellState: cellState);
    handleCellSelected(view: cell, cellState: cellState);
    handleCellTextColor(view: cell, cellState: cellState);
    
    return cell
  }
  
  // 日付選択時
  func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
    handleCellSelected(view: cell, cellState: cellState);
    handleCellTextColor(view: cell, cellState: cellState);
  }
  
  // 日付非選択時
  func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
    handleCellSelected(view: cell, cellState: cellState);
    handleCellTextColor(view: cell, cellState: cellState);
  }
  
  // スクロール時
  func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
    let date = visibleDates.monthDates.first!.date
    
    formatter.dateFormat = "yyyy  MMMM"
    navigationItem.title = formatter.string(from: date)
    
  }
  
  //  public func setColor() -> [UIColor] {
  //
  //    let outsideMonthColor: UIColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
  //    let monthColor: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
  //    let selectedMonthColor: UIColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
  //    let currentDateSelectedViewColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
  //    
  //  }
}


