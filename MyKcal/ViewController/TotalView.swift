//
//  TotalView.swift
//  MyKcal
//
//  Created by 佐藤賢 on 2017/07/06.
//  Copyright © 2017年 佐藤賢. All rights reserved.
//

import UIKit
import RealmSwift
import Charts

class TotalView: UIViewController {
  
  @IBOutlet weak var kcalLabel: UILabel!
  @IBOutlet weak var pieChartView: PieChartView!
  @IBOutlet weak var morningLabel: UILabel!
  @IBOutlet weak var noonLabel: UILabel!
  @IBOutlet weak var nightLabel: UILabel!
  
  let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
  var dateItem: Results<RealmDateDB>!
  var selectDate = String()
  var kcal: [Double] = []
  let times = ["朝", "昼", "夜"]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    selectDate = appDelegate.selectDate!
    setRealm()
    setupPieChartView(dataPoints: times, values: kcal)
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func setRealm() {
    let realm = try! Realm()
    // 選択した日のデータ
    dateItem = realm.objects(RealmDateDB.self).filter("date == %@", selectDate)
    
    let object = dateItem?[0]
    
    for index in (1...3).reversed() {
      switch index {
      case 1:
        kcal += [Double((object?.night)!)]
      case 2:
        kcal += [Double((object?.noon)!)]
      case 3:
        kcal += [Double((object?.morning)!)]
      default:
        print("indexエラー")
      }
    }
    morningLabel.text = ("朝：\(String(Int(kcal[0])))kcal")
    noonLabel.text = ("昼：\(String(Int(kcal[1])))kcal")
    nightLabel.text = ("夜：\(String(Int(kcal[2])))kcal")
    kcalLabel.text = ("\(String(Int(kcal[0] + kcal[1] + kcal[2])))kcal")
  }
  
  func setupPieChartView(dataPoints: [String], values: [Double]) {
    self.pieChartView.usePercentValuesEnabled = true
    //    self.pieChartView.descriptionText = "チャートの説明"
    pieChartView.chartDescription?.text = nil
    // 円グラフに表示するデータ
    var dataEntries = [ChartDataEntry]()
    for i in 0..<dataPoints.count {
      dataEntries.append(PieChartDataEntry(value: values[i], label: dataPoints[i], data: dataPoints[i] as AnyObject))
    }
    let pieChartDataSet = PieChartDataSet(values: dataEntries, label: nil)
    pieChartDataSet.colors = setColor()
    
    let pieChartData = PieChartData(dataSets: [pieChartDataSet])
    
    // %表示
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = NumberFormatter.Style.percent
    numberFormatter.maximumFractionDigits = 1
    numberFormatter.multiplier = NSNumber(value: 1.0)
    numberFormatter.percentSymbol = " %"
    pieChartData.setValueFormatter(DefaultValueFormatter(formatter: numberFormatter))
    
    self.pieChartView.data = pieChartData
  }
  
  public func setColor() -> [NSUIColor] {
    
    let color1: UIColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
    let color2: UIColor = #colorLiteral(red: 1, green: 0.6260269284, blue: 0.2663027048, alpha: 1)
    let color3: UIColor = #colorLiteral(red: 0.8751111627, green: 0.6838658452, blue: 1, alpha: 1)
    
    return [
      color1,
      color2,
      color3
    ]
  }
  
}

