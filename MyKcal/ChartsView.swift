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

class ChartsView: UIViewController {
  
  @IBOutlet weak var barChartView: BarChartView!
  
  var dateItem: Results<RealmDateDB>!
  
  let kcal: [Int] = [20, 4, 6, 3, 12, 16, 4, 18, 2, 4, 5, 4]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let realm = try! Realm()
    dateItem = realm.objects(RealmDateDB.self)
    setChart(y: kcal)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
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
    
    // X軸のラベルを設定
    let xaxis = XAxis()
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
    let ll = ChartLimitLine(limit: 10.0, label: "border")
    barChartView.rightAxis.addLimitLine(ll)
    // グラフのタイトル
    barChartView.chartDescription?.text = "Kcal Graph!"
  }
  
}

public class BarChartFormatter: NSObject, IAxisValueFormatter{
  // x軸のラベル
  var months: [String]! = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
  
  // デリゲート。TableViewのcellForRowAtで、indexで渡されたセルをレンダリングするのに似てる。
  public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
    // 0 -> Jan, 1 -> Feb...
    return months[Int(value)]
  }
}
