//
//  OwnerEventActiveController.swift
//  RouteRoutePro
//
//  Created by 安齋洸也 on 2018/11/10.
//  Copyright © 2018年 安齋洸也. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class OwnerEventController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    // data
    var data:(id:String, name:String, detail:String, email:String, latitude:String, longitude:String, date:String, starttime:String, endtime:String)!
    
    var userpositions = [ (name: "Horiuchi",email: "horihori@gmail.com",latitude: "35.658582",longitude: "139.745435"),(name: "Anzai",email: "zaizai@gmail.com",latitude: "35.668581",longitude: "139.755433"),(name: "Natsui",email: "natsu@gmail.com",latitude: "35.678583",longitude: "139.735432"),(name: "Tanaka",email: "Tanaka@gmail.com",latitude: "35.668583",longitude: "139.735432")]
    
    var annotationArray: [MKAnnotation] = []
    var annotationgoal:MKPointAnnotation = MKPointAnnotation()
    
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //title setting
        self.title = data.name
        
        //目的地
        annotationgoal.coordinate = CLLocationCoordinate2DMake(Double(data!.latitude)!, Double(data!.longitude)!)
        annotationgoal.title = "Goal"
        mapView.addAnnotation(annotationgoal)
        
        //timer処理
        timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true, block: { (timer) in
            //self.count値をコンソールへ出力
            print("aaa")
            
            // 前回の情報を削除
            if(self.annotationArray.count < 1){
                self.mapView.removeAnnotations(self.annotationArray)
                self.annotationArray.removeAll()
            }
            
            // annotaitionの準備
            for position in self.userpositions {
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2DMake(Double(position.latitude)!, Double(position.longitude)!)
                annotation.title = position.name
                self.annotationArray.append(annotation)
            }
            
            // annotationの設置
            self.mapView.addAnnotations(self.annotationArray)
            
            self.annotationArray.append(self.annotationgoal)
            self.mapView.showAnnotations(self.annotationArray, animated: true)
        })
    }
    
    @IBAction func tapQuit(_ sender: UIBarButtonItem) {
        let title = "イベントの終了"
        let message = "イベントを終了します。よろしいでしょうか？"
        
        let mapAlert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        
        mapAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            self.dismiss(animated: true, completion: nil)
        }))
        
        mapAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Handle Cancel Logic here")
        }))
        
        present(mapAlert, animated: true, completion: nil)
    }
}
