//
//  ColorCollectionView.swift
//  MyKcal
//
//  Created by 佐藤賢 on 2017/07/10.
//  Copyright © 2017年 佐藤賢. All rights reserved.
//

import UIKit

class ColorCollectionView: UIViewController,UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  
  let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
  
  let color: [UIColor] = [#colorLiteral(red: 1, green: 0.4932718873, blue: 0.4739984274, alpha: 1),#colorLiteral(red: 1, green: 0.8323456645, blue: 0.4732058644, alpha: 1),#colorLiteral(red: 0.9995340705, green: 0.988355577, blue: 0.4726552367, alpha: 1),#colorLiteral(red: 0.8321695924, green: 0.985483706, blue: 0.4733308554, alpha: 1),#colorLiteral(red: 0.4500938654, green: 0.9813225865, blue: 0.4743030667, alpha: 1),#colorLiteral(red: 0.4508578777, green: 0.9882974029, blue: 0.8376303315, alpha: 1),#colorLiteral(red: 0.4620226622, green: 0.8382837176, blue: 1, alpha: 1),#colorLiteral(red: 0.476841867, green: 0.5048075914, blue: 1, alpha: 1),#colorLiteral(red: 0.8446564078, green: 0.5145705342, blue: 1, alpha: 1),#colorLiteral(red: 1, green: 0.5212053061, blue: 1, alpha: 1),#colorLiteral(red: 1, green: 0.5409764051, blue: 0.8473142982, alpha: 1),#colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1),#colorLiteral(red: 0.5787474513, green: 0.3215198815, blue: 0, alpha: 1),#colorLiteral(red: 0.7540688515, green: 0.7540867925, blue: 0.7540771365, alpha: 1),#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)]
  let white: UIColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
  var saveColor: UIColor?
  var saveMarkColor: UIColor?
		
  var colorCount: Int = 0 // 適用場所の選択
  //  var checkArray:NSMutableArray = []
  var checkIndex: IndexPath = []
  var checkView:UIImageView!
  
  var blinkLabelTimer = Timer()
  var blinkCheck: Bool = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    colorCount = appDelegate.colorCount
    saveColor = appDelegate.selectColor
    selectSavedView.backgroundColor = saveColor
    saveMarkColor = appDelegate.selectMarkColor
    markSavedView.backgroundColor = saveMarkColor
    
    colorCollection.isScrollEnabled = false
//    selectLabel.backgroundColor = appDelegate.selectColor
//    markLabel.backgroundColor = appDelegate.selectMarkColor

    if blinkCheck == false {
      blinkLabelTimer = Timer.scheduledTimer(
        timeInterval: 0.8,
        target: self,
        selector: #selector(ColorCollectionView.blinkLabel),
        userInfo: nil,
        repeats: true
      )
      RunLoop.current.add(blinkLabelTimer, forMode: RunLoopMode.commonModes)
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var selectView: UIView!
  @IBOutlet weak var selectSavedView: UIView!
  @IBOutlet weak var markView: UIView!
  @IBOutlet weak var markSavedView: UIView!
  @IBOutlet weak var colorCollection: UICollectionView!
  
  @IBAction func backButton(_ sender: UIBarButtonItem) {
    if (self.navigationController?.viewControllers) != nil {
      if checkIndex.isEmpty == false {
        let alert = UIAlertController(title: "変更が確定されていませんがよろしいですか？", message: nil, preferredStyle: .alert)
        let backAction = UIAlertAction(title: "OK", style: .default, handler: {
          (action:UIAlertAction!) -> Void in
          
          // アクションシートの親となる UIView を設定
          alert.popoverPresentationController?.sourceView = self.view
          
          // 吹き出しの出現箇所を CGRect で設定 （これはナビゲーションバーから吹き出しを出す例）
          alert.popoverPresentationController?.sourceRect = (self.navigationController?.navigationBar.frame)!
          
          self.appDelegate.selectColor = self.saveColor
          self.appDelegate.selectMarkColor = self.saveMarkColor
          _ = self.navigationController?.popViewController(animated: true)
        })
        alert.addAction(backAction)
        
        
        // キャンセルボタンの設定
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        //　iPad用クラッシュさせないために
        alert.popoverPresentationController?.sourceView = self.view;
        alert.popoverPresentationController?.sourceRect = (self.navigationController?.navigationBar.frame)!
        
        // 親View表示
        present(alert, animated: true, completion: nil)
      } else {
        _ = navigationController?.popViewController(animated: true)
      }
    }

  }
  
  @IBAction func doneButton(_ sender: UIBarButtonItem) {
    if checkIndex.isEmpty == false {
      if colorCount == 0 {
        appDelegate.selectColorPre = color[checkIndex[1]]
        appDelegate.colorCount = 1
        selectView.isHidden = false
        dispatch()
      } else if colorCount == 1 {
        appDelegate.selectColor = appDelegate.selectColorPre
        appDelegate.selectMarkColor = color[checkIndex[1]]
        appDelegate.colorCount = 0
        _ = navigationController?.popViewController(animated: true)
      }
    }
  }

  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 15
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell:UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "colorCell", for: indexPath)
    cell.backgroundColor = color[indexPath.row]
    
    //    for subview in cell.contentView.subviews{
    //      subview.removeFromSuperview()
    //    }
    //
    //    if indexPath == checkIndex {
    //      checkView = UIImageView()
    //      let checkImage = UIImage(named:"checkmark128px.png")! as UIImage
    //      checkView!.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
    //      checkView!.layer.position = CGPoint(x: cell.layer.frame.width - 25.0, y: cell.layer.frame.height - 95.0)
    //      checkView!.image = checkImage
    //      cell.contentView.addSubview(checkView!)
    //    }
    
    return cell
  }
  
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let width = (self.colorCollection.frame.size.width)/3 - 5
    let height = (self.colorCollection.frame.size.height)/6 - 5
    return CGSize(width: width, height: height)
  }
  
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    return UIEdgeInsetsMake(5, 5, 5, 5)
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if indexPath != checkIndex {
      switch colorCount {
      case 0:
        selectView.backgroundColor = color[indexPath[1]]
        blinkCheck = true
      case 1:
        markView.backgroundColor = color[indexPath[1]]
      default:
        print("colorエラー")
      }
      checkIndex = indexPath
      colorCollection.reloadData()
      self.dispatch()
    }
  }
  
  @objc func blinkLabel()
  {
    switch colorCount {
    case 0:
      self.selectView.isHidden = !self.selectView.isHidden
      if self.selectView.isHidden == true {
        self.dateLabel.textColor = color[14]
      } else if self.selectView.isHidden == false{
        self.dateLabel.textColor = white
      }
    case 1:
      self.markView.isHidden = !self.markView.isHidden
    default:
      print("点滅エラー")
    }
  }
  
  func dispatch(){
    DispatchQueue.main.async {
      self.viewDidLoad()
    }
  }
  
}

extension UIView {
  @IBInspectable var cornerRadius: CGFloat {
    get {
      return layer.cornerRadius
    }
    set {
      layer.cornerRadius = newValue
      layer.masksToBounds = newValue > 0
    }
  }
  
  @IBInspectable
  var borderWidth: CGFloat {
    get {
      return self.layer.borderWidth
    }
    set {
      self.layer.borderWidth = newValue
    }
  }
  
  @IBInspectable
  var borderColor: UIColor? {
    get {
      return UIColor(cgColor: self.layer.borderColor!)
    }
    set {
      self.layer.borderColor = newValue?.cgColor
    }
  }
  
}
