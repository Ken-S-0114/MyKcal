//
//  ChartsView.swift
//  MyKcal
//
//  Created by 佐藤賢 on 2017/06/14.
//  Copyright © 2017年 佐藤賢. All rights reserved.
//

import UIKit
import RealmSwift
import Charts

class ChartsView: UIViewController ,UIToolbarDelegate, UITextFieldDelegate{
  @IBAction func settingButton(_ sender: UIBarButtonItem) {
    performSegue(withIdentifier: "borderSegue", sender: nil)
  }
  @IBOutlet weak var periodSegmentedControl: UISegmentedControl!
  @IBAction func periodSegment(_ sender: UISegmentedControl) {
    switch sender.selectedSegmentIndex {
    case 0:
      periodIndex = 0
    case 1:
      periodIndex = 1
    case 2:
      periodIndex = 2
    default:
      print("期間が指定されていません")
    }
    appDelegate.periodIndex = periodIndex
    DispatchQueue.main.async {
      self.dispatch()
      self.periodSegmentedControl.selectedSegmentIndex = self.appDelegate.periodIndex
    }
    
  }
  var toolBar:UIToolbar!
  var myDatePicker: UIDatePicker!
  @IBOutlet weak var dateTextField: UITextField!
  @IBOutlet weak var barChartView: BarChartView!
  
  var dateItem: Results<RealmDateDB>!
  
  var kcal: [Int] = []        // 棒グラフに使用（値）
  var l = 0                   // 日付ループ用
  var plus: Int = 0
  var datePlus: String = ""   // date検索ワード（ex:20160103）
  var setCheck: Bool = false  // １回目を確認するため
  var periodIndex = Int()    // 期間の切り替え
  var labelDate: String = ""
  var dateText: String = ""
  let settingKey = "value"
  var borderValue: Int = 0
  
  var today = Int()
  
  let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
  
  override func viewDidLoad() {
    super.viewDidLoad()
//    let settings = UserDefaults.standard
//    settings.register(defaults: [settingKey:1000])
    
    setKcal()
    setChart(y: kcal)
    settool()
    
  }
  
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
//    let settings = UserDefaults.standard
//    borderValue = settings.integer(forKey: settingKey)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func dispatch(){
//    self.loadView()
    self.viewDidLoad()
    
    self.dateTextField.text = self.dateText
  }
  
  func setChart(y: [Int]){
    var dataEntries = [BarChartDataEntry]()
    
    for (i, val) in y.enumerated() {
      let dataEntry = BarChartDataEntry(x: Double(i), y: Double(val)) // X軸データは、0,1,2,...
      dataEntries.append(dataEntry)
    }
    // グラフをUIViewにセット
    let chartDataSet = BarChartDataSet(values: dataEntries, label: "Units Sold")
    barChartView.data = BarChartData(dataSet: chartDataSet)
    //     print(dataEntries)
    // X軸のラベルを設定
    let xaxis = XAxis()
    
    //    switch periodIndex {
    //    case 0:
    //       barChartView.xAxis.labelCount = Int(7)
    //    case 1:
    //      barChartView.xAxis.labelCount = Int(4)
    //    default:
    //      print("periodIndexエラー")
    //    }
    
    xaxis.valueFormatter = BarChartFormatter()
    barChartView.xAxis.valueFormatter = xaxis.valueFormatter
    
    // x軸のラベルをボトムに表示
    barChartView.xAxis.labelPosition = .bottom
    // グラフの色
    chartDataSet.colors = [UIColor(red: 230/255, green: 126/255, blue: 34/255, alpha: 1)]
    // グラフの背景色
    barChartView.backgroundColor = UIColor(red: 189/255, green: 195/255, blue: 199/255, alpha: 1)
    // グラフの棒をニョキッとアニメーションさせる
    barChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
    // 横に赤いボーダーラインを描く
    let ll = ChartLimitLine(limit: Double(borderValue), label: " ")
    barChartView.rightAxis.addLimitLine(ll)
    // グラフのタイトル
    barChartView.chartDescription?.text = "Kcal Graph!"
  }
  
  func settool(){
    // 入力欄の設定
    dateTextField.placeholder = dateToString(date: Date()) //<-`dateToString`のパラメータは`Date`型なので最初から`Date()`を渡す
    dateTextField.text        = dateToString(date: Date()) //<-同上
    self.view.addSubview(dateTextField)
    
    // UIDatePickerの設定
    myDatePicker = UIDatePicker()
    myDatePicker.addTarget(self, action: #selector(changedDateEvent), for: UIControlEvents.valueChanged)
    myDatePicker.datePickerMode = UIDatePickerMode.date
    dateTextField.inputView = myDatePicker
    
    // UIToolBarの設定
    toolBar = UIToolbar(frame: CGRect(x: 0, y: self.view.frame.size.height/6, width: self.view.frame.size.width, height: 40.0))
    
    toolBar.layer.position = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-20.0)
    toolBar.barStyle = .blackTranslucent
    toolBar.tintColor = UIColor.white
    toolBar.backgroundColor = UIColor.black
    
    let toolBarBtn      = UIBarButtonItem(title: "完了", style: .plain, target: self, action: #selector(tappedToolBarBtn))
    let toolBarBtnToday = UIBarButtonItem(title: "今日", style: .plain, target: self, action: #selector(tappedToolBarBtnToday))
    toolBarBtn.tag = 1
    toolBar.items = [toolBarBtn, toolBarBtnToday]
    dateTextField.inputAccessoryView = toolBar
  }
  
  // 「完了」を押すと閉じる
  func tappedToolBarBtn(sender: UIBarButtonItem) {
    
    dateTextField.resignFirstResponder()
    self.dispatch()
    
  }
  
  
  // 「今日」を押すと今日の日付をセットする
  func tappedToolBarBtnToday(_ sender: UIBarButtonItem) {
    myDatePicker.date = Date()  //<-Date型のプロパティに現在時刻を入れるなら`Date()`を渡すだけでOK
    changeLabelDate(date: Date() as NSDate)  //<-Date型の引数に現在時刻を渡すときも同じく`Date()`だけでOK
  }
  
  func changedDateEvent(_ sender: UIDatePicker){
    //<- `UIDatePicker`からのactionの`sender`は必ず`UIDatePicker`になる
    //`sender`を直接`UIDatePicker`として使えばいいのでキャストは不要
    self.changeLabelDate(date: sender.date as NSDate)
  }
  
  
  func changeLabelDate(date:NSDate) {
    dateText = self.dateToString(date: date as Date)
    let dateInt = (dateText.components(separatedBy: NSCharacterSet.decimalDigits.inverted))
    labelDate = dateInt.joined()
    appDelegate.labelDate = labelDate
//    print("日程：\(labelDate)")
  }
  
  func dateToString(date: Date) -> String {
    //DateFormatterは参照型なので、letが適切
    let date_formatter = DateFormatter()
    //曜日の1文字表記をしたいならweekdaysなんて配列はいらない
    
    date_formatter.locale     = Locale(identifier: "ja")
    date_formatter.dateFormat = "yyyy年MM月dd日（E） " //<-`E`は曜日出力用のフォーマット文字
    return date_formatter.string(from: date as Date)
  }
  
  func todaySet(){
    changeLabelDate(date: Date() as NSDate)  //<-Date型の引数に現在時刻を渡すときも同じく`Date()`だけでOK
  }
  
  func setKcal(){
    kcal = []         // カロリー値蓄積
    datePlus = ""     // 日程を検索用で使う
    setCheck = false  // 初日のみ検出
    l = 0             // 日数をカウント
    plus = 0          // 日数プラス分
//    let obj :Results<RealmDateDB>
    
    if dateTextField.text?.isEmpty == true {
      todaySet()
    }
    
    let realm = try! Realm()
    
    //    dateItem = realm.objects(RealmDateDB.self).sorted(byKeyPath: "date", ascending: true)
    dateItem = realm.objects(RealmDateDB.self).filter("date == %@", labelDate)
   
    switch periodIndex {
      
    case 0:
      // １週間分のtotalkcalデータ
      while l < 7 {
        if l != 0 {
          dateItem = realm.objects(RealmDateDB.self).filter("date == %@", datePlus)
        }
        if dateItem.isEmpty == false {
          let ob = dateItem[0]
          kcal += [ob.total]
        }else{
          kcal += [0]
        }
        
        // 日付+1日ずつ増やしていく
        if setCheck == false {
          plus = Int(labelDate)! + 1
          setCheck = true
        }else{
          plus = Int(plus) + 1
        }
        dateCheck()
        datePlus = String(plus)
        
        l += 1
      }
      
    case 1:
      //１ヶ月分のtotalkcalデータ
      var memory1: Int = 0
      var memory2: Int = 0
      var memory3: Int = 0
      var memory4: Int = 0
      var memory5: Int = 0
      var memory6: Int = 0
      var memory7: Int = 0
      
      var i = 0
      
      while l < 49 {
        
        if l != 0 {
          dateItem = realm.objects(RealmDateDB.self).filter("date == %@", datePlus)
        }
        if dateItem.isEmpty == false {
          let ob = dateItem[0]
          if l < 7 {
            memory1 += ob.total
          }else if (7 <= l) && (l < 14) {
            memory2 += ob.total
          }else if (14 <= l) && (l < 21) {
            memory3 += ob.total
          }else if (21 <= l) && (l < 28) {
            memory4 += ob.total
          }else if (28 <= l) && (l < 35) {
            memory5 += ob.total
          }else if (35 <= l) && (l < 42) {
            memory6 += ob.total
          }else if (42 <= l) && (l < 49) {
            memory7 += ob.total
          }
          
        }else{
          if l < 7 {
            memory1 += 0
          }else if (7 <= l) && (l < 14) {
            memory2 += 0
          }else if (14 <= l) && (l < 21) {
            memory3 += 0
          }else if (21 <= l) && (l < 28) {
            memory4 += 0
          }else if (28 <= l) && (l < 35) {
            memory5 += 0
          }else if (35 <= l) && (l < 42) {
            memory6 += 0
          }else if (42 <= l) && (l < 49) {
            memory7 += 0
          }
        }
        
        // 日付+1日ずつ増やしていく
        if setCheck == false {
          plus = Int(labelDate)! + 1
          setCheck = true
        }else{
          plus = Int(plus) + 1
        }
        
        datePlus = String(plus)
        l += 1
      }
      
      while i < 7 {
        switch i {
        case 0:
          kcal += [memory1]
        case 1:
          kcal += [memory2]
        case 2:
          kcal += [memory3]
        case 3:
          kcal += [memory4]
        case 4:
          kcal += [memory5]
        case 5:
          kcal += [memory6]
        case 6:
          kcal += [memory7]
        default:
          print("kcal未入力")
        }
        i += 1
      }
      
      
    case 2:
      // １年分のtotalkcalデータ
      while l < 365 {
        if l != 0 {
          dateItem = realm.objects(RealmDateDB.self).filter("date == %@", datePlus)
        }
        if dateItem.isEmpty == false {
          let ob = dateItem[0]
          kcal += [ob.total]
        }else{
          kcal += [0]
        }
        // 日付+1日ずつ増やしていく
        if setCheck == false {
          plus = Int(labelDate)! + 1
          setCheck = true
        }else{
          plus = Int(plus) + 1
        }
        datePlus = String(plus)
        
        l += 1
      }
      
    default:
      print("期間が指定されていません")
    }
    
  }
  
  func dateCheck(){
    var dateView = String(plus)
    let startIndex = dateView.index(dateView.startIndex, offsetBy: 4)
    let endIndex = dateView.index(dateView.endIndex, offsetBy: 0)
    let range = startIndex..<endIndex
    
    if dateView.hasSuffix("0132"){
      dateView.replaceSubrange(range, with: "0201")
    }else if dateView.hasSuffix("0229"){
      dateView.replaceSubrange(range, with: "0301")
    }else if dateView.hasSuffix("0332"){
      dateView.replaceSubrange(range, with: "0401")
    }else if dateView.hasSuffix("0431"){
      dateView.replaceSubrange(range, with: "0501")
    }else if dateView.hasSuffix("0532"){
      dateView.replaceSubrange(range, with: "0601")
    }else if dateView.hasSuffix("0631"){
      dateView.replaceSubrange(range, with: "0701")
    }else if dateView.hasSuffix("0732"){
      dateView.replaceSubrange(range, with: "0801")
    }else if dateView.hasSuffix("0832"){
      dateView.replaceSubrange(range, with: "0901")
    }else if dateView.hasSuffix("0931"){
      dateView.replaceSubrange(range, with: "1001")
    }else if dateView.hasSuffix("1032"){
      dateView.replaceSubrange(range, with: "1101")
    }else if dateView.hasSuffix("1131"){
      dateView.replaceSubrange(range, with: "1201")
    }else if dateView.hasSuffix("1232"){
      dateView.replaceSubrange(range, with: "0101")
    }
    
    plus = Int(dateView)!
  }
  
}



public class BarChartFormatter: NSObject, IAxisValueFormatter{
  
  // x軸のラベル
  //  var months: [String]! = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
  var months: [String]! = []
  var check: Bool = false
  let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
  var periodIndex: Int = 0
  var dateView: Int = 0
  var dateView2: Int = 0
  var labelDate: String = ""
  
  var week: Bool = false
  var intDate: Int = 0
  
  // デリゲート。TableViewのcellForRowAtで、indexで渡されたセルをレンダリングするのに似てる。
  public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
    xView()
//    print(months[Int(value)])
    // 0 -> Jan, 1 -> Feb...
    return months[Int(value)]
    //    return months[Int(value)]
  }
  
  public func xView(){
    periodIndex = appDelegate.periodIndex
    if check == false {
      var i = 0
      dateView = 0
      months = []
      if appDelegate.labelDate.isEmpty == false {
        labelDate = appDelegate.labelDate
        intDate = Int(labelDate)!
        print("すたーと日\(labelDate)")
      }
      switch periodIndex {
      case 0:
        while i < 7 {
          if i == 0 {
            dateView = Int(labelDate)!
            dateCheck()
            months.append(labelDate)
          }else if i == 6 {
            dateView += 1
            months.append(String(dateView))
          }else{
            dateView += 1
            dateCheck()
            months.append(String())
          }
          i += 1
        }
        check = true
        
      case 1:
        while i < 43 {
          if i == 0 {
            week = true
            for _ in 0..<6 {
              intDate += 1
              self.dateCheck()
            }
            months.append("\(labelDate)~\(String(intDate))")
            dateView = Int(labelDate)!
            dateCheck()
            week = false
          }else if i == 42 {
            week = true
            intDate = dateView
            for l in 0..<6 {
              intDate = dateView
              intDate += 1
              self.dateCheck()
              if l == 5 {
                dateView2 = self.intDate + 6
              }
            }
            dateCheck()
            months.append("\(dateView)~\(String(dateView2))")
            week = false
          }else if (i == 6) || (i == 13) || (i == 20) || (i == 27) || (i == 35) {
            dateView += 1
            dateCheck()
            months.append(String())
          }else {
            dateView += 1
            dateCheck()
          }
          i += 1
        }
//        print("X軸：\(months)")
        check = true
//      case 2:
//        while i < 365 {
//          if (i == 0){
//            let ob = dateItem[i]
//            dateView = Int(ob.date)!
//            months.append(ob.date)
//          }else if (i == 364){
//            dateView += 1
//            dateCheck()
//            months.append(String(dateView))
//          }else{
//            dateView += 1
//            dateCheck()
//            months.append(String())
//          }
//          i += 1
//        }
//        check = true
      default:
        print("期間が指定されていません")
      }
    }
  }
  
  public func dateCheck(){
    var dateView: String = ""
    if week == true {
      dateView = String(self.intDate)
    } else{
      dateView = String(self.dateView)
    }
//    print("更新：\(dateView)")
    
    let startIndex = dateView.index(dateView.startIndex, offsetBy: 4)
    let endIndex = dateView.index(dateView.endIndex, offsetBy: 0)
    let range = startIndex..<endIndex
    
    if dateView.hasSuffix("0132"){
      dateView.replaceSubrange(range, with: "0201")
    }else if dateView.hasSuffix("0229"){
      dateView.replaceSubrange(range, with: "0301")
    }else if dateView.hasSuffix("0332"){
      dateView.replaceSubrange(range, with: "0401")
    }else if dateView.hasSuffix("0431"){
      dateView.replaceSubrange(range, with: "0501")
    }else if dateView.hasSuffix("0532"){
      dateView.replaceSubrange(range, with: "0601")
    }else if dateView.hasSuffix("0631"){
      dateView.replaceSubrange(range, with: "0701")
    }else if dateView.hasSuffix("0732"){
      dateView.replaceSubrange(range, with: "0801")
    }else if dateView.hasSuffix("0832"){
      dateView.replaceSubrange(range, with: "0901")
    }else if dateView.hasSuffix("0931"){
      dateView.replaceSubrange(range, with: "1001")
    }else if dateView.hasSuffix("1032"){
      dateView.replaceSubrange(range, with: "1101")
    }else if dateView.hasSuffix("1131"){
      dateView.replaceSubrange(range, with: "1201")
    }else if dateView.hasSuffix("1232"){
      dateView.replaceSubrange(range, with: "0101")
    }
    if week == true {
      self.intDate = Int(dateView)!
    }else{
      self.dateView = Int(dateView)!
    }

  }
}
