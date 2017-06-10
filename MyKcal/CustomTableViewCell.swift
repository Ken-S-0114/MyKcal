//
//  CustomTableViewCell.swift
//  MyKcal
//
//  Created by 佐藤賢 on 2017/06/11.
//  Copyright © 2017年 佐藤賢. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {


  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var kcalLabel: UILabel!

  
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
  
  func setCell(timeZone: String, kcal: String){
    timeLabel.text = timeZone
    kcalLabel.text = kcal
  }

}
