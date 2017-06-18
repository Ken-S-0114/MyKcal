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

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
  
  @IBOutlet weak var calendarView: JTAppleCalendarView!
  @IBOutlet weak var year: UILabel!
  @IBOutlet weak var month: UILabel!
  @IBAction func deleteButton(_ sender: UIBarButtonItem) {
    delete()
  }
  
  @IBOutlet weak var kcalTableView: UITableView!
  
  var dateItem: Results<RealmDateDB>!
  var dateItems: Results<RealmDateDB>?
  let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
  
  let formatter = DateFormatter()
  var testCalendar = Calendar.current
  
  let outsideMonthColor = UIColor.gray
  let monthColor = UIColor.white
  let selectedMonthColor = UIColor.black
  let currentDateSelectedViewColor = UIColor.cyan
  
  let timeArray: [String] = ["朝", "昼", "夜", "間食", "合計"]
  var kcalTime: [String] = ["0", "0", "0", "0", "0"]
  
  var check: Bool = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupRealmView()
    setupCalendarView()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    setupRealmView()
    setupCalendarView()
    calendarView.reloadData()
    kcalTableView.reloadData()
  }
  
  
  func setupCalendarView(){
    calendarView.minimumLineSpacing = 0
    calendarView.minimumInteritemSpacing = 0
    
    calendarView.visibleDates { (visibleDates) in
      self.setupViewOfCalendar(from: visibleDates)
    }
  }
  
  func setupViewOfCalendar(from visibleDates: DateSegmentInfo){
    let date = visibleDates.monthDates.first!.date
    self.formatter.dateFormat = "yyyy"
    self.year.text! = self.formatter.string(from: date)
    
    self.formatter.dateFormat = "MMMM"
    self.month.text! = self.formatter.string(from: date)
  }
  
  func setupRealmView(){
    let realm = try! Realm()
    dateItem = realm.objects(RealmDateDB.self)
  }
  
  func setRealmColor(view: JTAppleCell?, cellState: CellState){
    guard let validCell = view as? CustomCell else { return }
    
    formatter.dateFormat = "yyyyMMdd"
    let selectDate = formatter.string(from: cellState.date)
    appDelegate.selectDate = selectDate
    
    dateItems = dateItem.filter("date == %@", selectDate)

    
    if dateItems?.isEmpty == false {
      validCell.markView.isHidden = false
      validCell.markView.backgroundColor = UIColor.red
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
      let selectDate = formatter.string(from: cellState.date)
      appDelegate.selectDate = selectDate
      
      let realmSelect = try! Realm()
      dateItem = realmSelect.objects(RealmDateDB.self)
      dateItems = dateItem.filter("date == %@", selectDate)

//      DispatchQueue.main.async {
//        self.loadView()
//        self.viewDidLoad()
        print(dateItems.self!)
        self.kcalTableView.reloadData()
//      }
      check = true
      
    }else {
      validCell.selectedView.isHidden = true
    }
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 5
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
 
    let cell = tableView.dequeueReusableCell(withIdentifier: "kcalCell")
    cell?.textLabel?.text = timeArray[indexPath.row]
    if (dateItems?.isEmpty == false) {
      let object = dateItems?[0]
      switch indexPath.row {
      case 0:
        cell?.detailTextLabel?.text = ("\((object?.morning)!)kcal")
      case 1:
        cell?.detailTextLabel?.text = ("\((object?.noon)!)kcal")
      case 2:
        cell?.detailTextLabel?.text = ("\((object?.night)!)kcal")
      case 4:
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
    if check == true {
    appDelegate.indexTime = indexPath.row
    performSegue(withIdentifier: "selectSegue", sender: nil)
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
  
  func delete(){
    let realm = try! Realm()
    try! realm.write {
      realm.delete((self.dateItems?[0])!)
      kcalTableView.reloadData()
      calendarView.reloadData()
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
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
    
    formatter.dateFormat = "yyyy"
    year.text! = formatter.string(from: date)
    
    formatter.dateFormat = "MMMM"
    month.text! = formatter.string(from: date)
  }
}

extension UIColor {
  convenience init(colorWithHexValue value: Int, alpha: CGFloat = 1.0) {
    self.init(
      red: CGFloat((value & 0xFF0000) >> 16) / 255.0,
      green: CGFloat((value & 0x00FF00) >> 8) / 255.0,
      blue: CGFloat(value & 0x0000FF) / 255.0,
      alpha: alpha
    )
  }
}

