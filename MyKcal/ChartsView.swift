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
  
    override func viewDidLoad() {
        super.viewDidLoad()

      let kcal = []
      
      setChart(y: kcal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
  func setChart(y: [Double]){
    
  }
  

}
