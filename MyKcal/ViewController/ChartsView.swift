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
  
  @IBOutlet weak var borderLabel: UILabel!
  @IBOutlet weak var dateTextField: UITextField!
  @IBOutlet weak var barChartView: BarChartView!
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var goalLabel: UILabel!
  @IBOutlet weak var practicalLabel: UILabel!
  @IBOutlet weak var goalView: UILabel!
  @IBOutlet weak var practicalView: UILabel!
  
  var toolBar:UIToolbar!
  var myDatePicker: UIDatePicker!
  var dateItem: Results<RealmDateDB>!
  
  var kcal: [Int] = []        // 棒グラフに使用（値）
  var l = 0                   // 日付ループ用
  var plus: Int = 0
  var datePlus: String = ""   // date検索ワード（ex:20160103）
  var setCheck: Bool = false  // １回目を確認するため
  var periodIndex = Int()    // 期間の切り替え
  var labelDate: String = ""
  var dateText: String = ""
  
  var borderValue: Int = 0              // 設定値
  var kcalSwitchValue: Bool = true      // 設定値を入れるか
  var animationSwitchValue: Bool = true // アニメーション処理をするか
  
  var total: Int = 0;
  var today = Int()
  
  let image1 = UIImage(named: "figure_question")
  let image2 = UIImage(named: "figure_hand_maru")
  let image3 = UIImage(named: "figure_hand_batsu")
  let image4 = UIImage(named: "figure_zasetsu")
  
  let setting = UserDefaults.standard
  let settingKey = "value"
  let settingSwitchKey = "switchValue"
  let animationSwitchKey = "animationValue"
  
  let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setting.register(defaults: [settingKey:300])
    setting.register(defaults: [settingSwitchKey:true])
    setting.register(defaults: [animationSwitchKey:true])
    
    kcalSwitchValue = setting.bool(forKey: settingSwitchKey)
    animationSwitchValue = setting.bool(forKey: animationSwitchKey)
    
    borderLabel.text = String("1日あたりの設定カロリー：\(Int(borderValue))kcal")
    setKcal()
    setChart(y: kcal)
    settool()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    _ = displayUpdate()
    dispatch()
  }
  
  
  //  override func viewWillAppear(_ animated: Bool) {
  //    super.viewWillAppear(animated)
  //    let settings = UserDefaults.standard
  //    borderValue = settings.integer(forKey: settingKey)
  //    self.viewDidLoad()
  //  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func displayUpdate() {
    borderValue = setting.integer(forKey: settingKey)
    kcalSwitchValue = setting.bool(forKey: settingSwitchKey)
  }
  
  func dispatch(){
    //  self.loadView()
    self.viewDidLoad()
    self.dateTextField.text = self.dateText
    self.total = 0
    self.goalLabel.text = String("???kcal")
    self.practicalLabel.text = String("???kcal")
    for i in 0..<kcal.count {
      total += kcal[i]
    }
    
    imageView.image = nil
    
    if kcalSwitchValue {
      imageView.image = image1
      // アニメーション処理をするか
      if animationSwitchValue {
        // 2秒後に実行したい処理
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
          self.resultView()
        }
      } else {
        self.resultView()
      }
    }
  }
  
  func setChart(y: [Int]){
    var dataEntries = [BarChartDataEntry]()
    
    for (i, val) in y.enumerated() {
      let dataEntry = BarChartDataEntry(x: Double(i), y: Double(val)) // X軸データは、0,1,2,...
      dataEntries.append(dataEntry)
    }
    // グラフをUIViewにセット
    let chartDataSet = BarChartDataSet(values: dataEntries, label: "Kcal")
    barChartView.data = BarChartData(dataSet: chartDataSet)
    
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
    // アニメーション処理をするか
    if animationSwitchValue {
      // グラフの棒をニョキッとアニメーションさせる
      barChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
    }
    // 横に赤いボーダーラインを描く
    barChartView.rightAxis.removeAllLimitLines()
    if kcalSwitchValue {
      let ll = ChartLimitLine(limit: Double(borderValue), label: "")
      barChartView.rightAxis.addLimitLine(ll)
    }
    // グラフのタイトル
    barChartView.chartDescription?.text = nil
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
  @objc func tappedToolBarBtn(sender: UIBarButtonItem) {
    dateTextField.resignFirstResponder()
    self.dispatch()
  }
  
  
  // 「今日」を押すと今日の日付をセットする
  @objc func tappedToolBarBtnToday(_ sender: UIBarButtonItem) {
    myDatePicker.date = Date()  //<-Date型のプロパティに現在時刻を入れるなら`Date()`を渡すだけでOK
    changeLabelDate(date: Date() as NSDate)  //<-Date型の引数に現在時刻を渡すときも同じく`Date()`だけでOK
  }
  
  @objc func changedDateEvent(_ sender: UIDatePicker){
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
  
  // Viewに表示する内容
  func resultView() {
    if self.total == 0 {
      self.imageView.image = self.image4
    }else{
      if self.total/7 < self.borderValue {
        self.imageView.image = self.image2
      }else{
        self.imageView.image = self.image3
      }
    }
    // 平均値
    self.goalLabel.text = String("\(self.total/7)kcal")
    // 設定値
    self.practicalLabel.text = String("\(self.borderValue)kcal")
    
  }
  
  func setKcal(){
    let realm = try! Realm()
    kcal = []         // カロリー値蓄積
    datePlus = ""     // 日程を検索用で使う
    setCheck = false  // 初日のみ検出
    l = 0             // 日数をカウント
    plus = 0          // 日数プラス分
    
    if !(dateTextField.text?.isEmpty)! {
      todaySet()
    }
    
    dateItem = realm.objects(RealmDateDB.self).filter("date == %@", labelDate)
    
    switch periodIndex {
    case 0:
      // １週間分のtotalkcalデータ
      while l < 7 {
        if l != 0 {
          dateItem = realm.objects(RealmDateDB.self).filter("date == %@", datePlus)
        }
        if !dateItem.isEmpty {
          let ob = dateItem[0]
          kcal += [ob.total]
        }else{
          kcal += [0]
        }
        // 日付1日ずつ増やしていく
        if !setCheck {
          plus = Int(labelDate)! + 1
          setCheck = true
        }else{
          plus = Int(plus) + 1
        }
        dateCheck()
        datePlus = String(plus)
        // 次の日のデータ
        l += 1
      }
      
    case 1:
      //7週間分のtotalkcalデータ
      var memory1: Int = 0
      var memory2: Int = 0
      var memory3: Int = 0
      var memory4: Int = 0
      var memory5: Int = 0
      var memory6: Int = 0
      var memory7: Int = 0
      
      var i = 0   // １週間分
      
      while l < 49 {
        if l != 0 {
          dateItem = realm.objects(RealmDateDB.self).filter("date == %@", datePlus)
        }
        if !dateItem.isEmpty {
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
        if !setCheck {
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
        if !dateItem.isEmpty {
          let ob = dateItem[0]
          kcal += [ob.total]
        }else{
          kcal += [0]
        }
        // 日付+1日ずつ増やしていく
        if !setCheck {
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
    // 日付格納用
    var dateView = String(plus)
    
    // 月変換用
    let startDateIndex = dateView.index(dateView.startIndex, offsetBy: 4)
    let endDateIndex = dateView.index(dateView.endIndex, offsetBy: 0)
    let range = startDateIndex..<endDateIndex
    
    // 年度変換用
    let startYearIndex = dateView.index(dateView.startIndex, offsetBy: 0)
    let endYearIndex = dateView.index(dateView.endIndex, offsetBy: -4)
    let rangeYear = startYearIndex..<endYearIndex
    // 年度抽出
    var year: String = dateView
    year.removeSubrange(range)
    // 年度加算　ex) 2017 -> 2017 + 1 = 2018
    let yearPlus: String = String(Int(year)! + 1)
    
    // 最後が特定の文字で終わってる文字
    if dateView.hasSuffix("0132"){
      dateView.replaceSubrange(range, with: "0201")
    }else if dateView.hasSuffix("0229"){
      if Int(year)!/4 != 0 {
        dateView.replaceSubrange(range, with: "0301")
      }
    }else if dateView.hasSuffix("0230"){
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
      dateView.replaceSubrange(rangeYear, with: yearPlus)
      dateView.replaceSubrange(range, with: "0101")
    }
    
    plus = Int(dateView)!
  }
  
}



public class BarChartFormatter: NSObject, IAxisValueFormatter{
  
  let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate

  // x軸のラベル
  var months: [String]! = []  // 表示する日程
  var check: Bool = false     // 同じ処理を繰り返し行わないようチェックする変数
  var periodIndex: Int = 0    // 表示する間隔
  var dateView: Int = 0       // 表示する日初め
  var dateViewEnd: Int = 0    // 表示する日終わり
  var labelDate: String = ""  // Delegateから値を受け取る変数
  var intDate: Int = 0        // １週間用の終端
  var week: Bool = false      // 最初の週と最後の週のみを検出

  
  // デリゲート。TableViewのcellForRowAtで、indexで渡されたセルをレンダリングするのに似てる。
  public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
    xView()
    return months[Int(value)]
  }
  
  public func xView(){
    periodIndex = appDelegate.periodIndex
    
    if !check {
      var i = 0     // 日付カウント
      
      // 初期化
      dateView = 0
      months = []
      
      // もし日付が選択されていれば
      if !appDelegate.labelDate.isEmpty {
        labelDate = appDelegate.labelDate
        
        // Int型用にコピー
        intDate = Int(labelDate)!
      }
      
      switch periodIndex {
      // １日間隔
      case 0:
        while i < 7 {
          // 初日
          if i == 0 {
            dateView = intDate
            months.append(String(dateView))
          }
          // 最終日
          else if i == 6 {
            months.append(String(dateView))
          }else{
            months.append(String())
          }
          i += 1
          dateView += 1
          
          // 日付チェック
          dateCheck()
//          print(dateView)
        }
        check = true
      
      // １週間間隔
      case 1:
        while i < 43 {
          // 初日
          if i == 0 {
            // 週用の条件適応されるよう設定
            week = true
            
            for _ in 0..<6 {
              intDate += 1
              self.dateCheck()
            }
            months.append("\(labelDate)~\(String(intDate))")  // ex) 20170101~0107
            
            // 初日 "ex) 20170101" をdateViewに代入
            dateView = Int(labelDate)!
            
            // 条件初期化
            week = false
          }
          // 最終日
          else if i == 42 {
            // 週用の条件適応されるよう設定
            week = true
            intDate = dateView
            for l in 0..<6 {
              intDate += 1
              self.dateCheck()
              if l == 5 {
                dateViewEnd = self.intDate
              }
            }
            months.append("\(dateView)~\(String(dateViewEnd))")
            // 条件初期化
            week = false
          }else if (i == 6) || (i == 13) || (i == 20) || (i == 27) || (i == 35) {
            months.append(String())
          }
          i += 1
          dateView += 1
          dateCheck()
        }
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
    // 日付格納用
    var dateView = String()
    // 日付格納
    // 日付の終端計算用（１週間用） ex) 2017~0101~"0107"
    if week {
      dateView = String(self.intDate)
    }
    // １日間隔の場合
    else {
      dateView = String(self.dateView)
    }
    
    // 月変換用
    let startIndex = dateView.index(dateView.startIndex, offsetBy: 4)
    let endIndex = dateView.index(dateView.endIndex, offsetBy: 0)
    let range = startIndex..<endIndex
    
    // 年度変換用
    let startYearIndex = dateView.index(dateView.startIndex, offsetBy: 0)
    let endYearIndex = dateView.index(dateView.endIndex, offsetBy: -4)
    let rangeYear = startYearIndex..<endYearIndex
    // 年度抽出用
    var labelYear = appDelegate.labelDate
    labelYear.removeSubrange(range) // 20170101 -> 2017
    let year: String = labelYear
    // 年度加算　ex) 2017 -> 2017 + 1 = 2018
    let yearPlus: String = String(Int(year)! + 1)
 

    // 最後が特定の文字で終わってる文字
    if dateView.hasSuffix("0132"){
      dateView.replaceSubrange(range, with: "0201")
    }else if dateView.hasSuffix("0229"){
      if Int(year)!/4 != 0 {
      dateView.replaceSubrange(range, with: "0301")
      }
    }else if dateView.hasSuffix("0230"){
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
      dateView.replaceSubrange(rangeYear, with: yearPlus)
      dateView.replaceSubrange(range, with: "0101")
    }
   
    if week {
      self.intDate = Int(dateView)!
    }else{
      self.dateView = Int(dateView)!
    }
    
  }
}
