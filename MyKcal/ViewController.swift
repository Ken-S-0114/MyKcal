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
  
  @IBOutlet weak var kcalTableView: UITableView!
  
  var kcalItem: Results<RealmDateDB>!
  let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
  
  let formatter = DateFormatter()
  var testCalendar = Calendar.current
  
  let outsideMonthColor = UIColor.gray
  let monthColor = UIColor.white
  let selectedMonthColor = UIColor.black
  let currentDateSelectedViewColor = UIColor.cyan
  
  let timeArray: [String] = ["朝", "昼", "夜", "間食", "合計"]
  var kcalTime: [String] = ["1", "2", "3", "4", "5"]
  
  var selectDate = Date()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupCalendarView()
    setupRealmView()
    
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
    kcalItem = realm.objects(RealmDateDB.self)
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
      validCell.selectedView.layer.cornerRadius =  30
      validCell.selectedView.backgroundColor = currentDateSelectedViewColor
      selectDate = cellState.date
      print(selectDate)
      print(cellState.date)
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
    //    let cell = tableView.dequeueReusableCell(withIdentifier: "kcalCell", for: indexPath) as! CustomTableViewCell
    //
    //    cell.setCell(timeZone: timeArray[indexPath.row], kcal: kcalTime[indexPath.row])
    let cell = tableView.dequeueReusableCell(withIdentifier: "kcalCell")
    cell?.textLabel?.text = timeArray[indexPath.row]
    cell?.detailTextLabel?.text = kcalTime[indexPath.row]
    return cell!
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    appDelegate.index = indexPath.row
    performSegue(withIdentifier: "selectSegue", sender: nil)
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
    
    handleCellSelected(view: cell, cellState: cellState);
    handleCellTextColor(view: cell, cellState: cellState);
    
    return cell
  }
  
  // 日付選択時
  func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
    handleCellSelected(view: cell, cellState: cellState);
    handleCellTextColor(view: cell, cellState: cellState);
    
    //    let object = kcalItem.filter(date == cellState.date)
    //    kcalTime += [object.morning]
    //    kcalTime += [object.noon]
    //    kcalTime += [object.night]
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

