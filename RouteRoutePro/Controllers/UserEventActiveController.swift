//
//  UserEventActiveController.swift
//  RouteRoutePro
//
//  Created by 安齋洸也 on 2018/11/10.
//  Copyright © 2018年 安齋洸也. All rights reserved.
//

import UIKit
import MapKit

class UserEventController: UIViewController, MKMapViewDelegate, LocationDelegate {

    @IBOutlet weak var mapView: MKMapView!

    @IBOutlet weak var minute: UILabel!
    @IBOutlet weak var hour: UILabel!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var speed: UILabel!
    
    // map elements
    var userAnnotationImage: UIImage?
    var userAnnotation: UserAnnotation?
    var accuracyRangeCircle: MKCircle?
    var polyline: MKPolyline?
    var isZooming: Bool?
    var isBlockingAutoZoom: Bool?
    var zoomBlockingTimer: Timer?
    var didInitialZoom: Bool?
    
    // distance
    var distanceAll: Double = 0
    
    // eventendtime
    var date:Date?
    
    // goal
    var annotationgoal:MKPointAnnotation = MKPointAnnotation()
    
    // data
    var data:(id:String, name:String, detail:String, email:String, latitude:String, longitude:String, date:String, starttime:String, endtime:String)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //目的地
        annotationgoal.coordinate = CLLocationCoordinate2DMake(Double(data!.latitude)!, Double(data!.longitude)!)
        annotationgoal.title = "Goal"
        mapView.addAnnotation(annotationgoal)

        // Do any additional setup after loading the view, typically from a nib.
        //title setting
        self.title = data.name
        
        // settings
        self.mapView.delegate = self
        self.mapView.showsUserLocation = false
        
        self.userAnnotationImage = UIImage(named: "user_position_ball")!
        
        self.accuracyRangeCircle = MKCircle(center: CLLocationCoordinate2D.init(latitude: 41.887, longitude: -87.622), radius: 50)
        self.mapView.addOverlay(self.accuracyRangeCircle!)
        
        
        self.didInitialZoom = false
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(UserEventController.updateMap(_:)), name: Notification.Name(rawValue:"didUpdateLocation"), object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(UserEventController.showTurnOnLocationServiceAlert(_:)), name: Notification.Name(rawValue:"showTurnOnLocationServiceAlert"), object: nil)
        
        LocationService.sharedInstance.startUpdatingLocation()
        LocationService.sharedInstance.delegate = self;
        //LocationService.sharedInstance.useFilter = true
        
        let dateFormater = DateFormatter()
        dateFormater.locale = Locale(identifier: "ja_JP")
        dateFormater.dateFormat = "yyyy/MM/dd HH:mm:ss"
        date = dateFormater.date(from: "2018/11/22 19:12:12")
    }
    
    @objc func showTurnOnLocationServiceAlert(_ notification: NSNotification){
        let alert = UIAlertController(title: "Turn on Location Service", message: "To use location tracking feature of the app, please turn on the location service from the Settings app.", preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
            let settingsUrl = URL(string: UIApplication.openSettingsURLString)
            if let url = settingsUrl {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
        alert.addAction(settingsAction)
        alert.addAction(cancelAction)
        
        
        present(alert, animated: true, completion: nil)
        
    }
    
    @objc func updateMap(_ notification: NSNotification){
        if let userInfo = notification.userInfo{
            
            updatePolylines()
            
            if let newLocation = userInfo["location"] as? CLLocation{
                zoomTo(location: newLocation)
            }
            
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        if overlay === self.accuracyRangeCircle{
            let circleRenderer = MKCircleRenderer(circle: overlay as! MKCircle)
            circleRenderer.fillColor = UIColor(white: 0.0, alpha: 0.25)
            circleRenderer.lineWidth = 0
            return circleRenderer
        }else{
            let polylineRenderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
            polylineRenderer.strokeColor = UIColor.red
            polylineRenderer.alpha = 0.5
            polylineRenderer.lineWidth = 5.0
            return polylineRenderer
        }
    }
    
    func updatePolylines(){
        var coordinateArray = [CLLocationCoordinate2D]()
        
        for loc in LocationService.sharedInstance.locationDataArray{
            coordinateArray.append(loc.coordinate)
        }
        
        self.clearPolyline()
        
        self.polyline = MKPolyline(coordinates: coordinateArray, count: coordinateArray.count)
        self.mapView.addOverlay(polyline as! MKOverlay)
        
    }
    
    func clearPolyline(){
        if self.polyline != nil{
            self.mapView.removeOverlay(self.polyline!)
            self.polyline = nil
        }
    }
    
    func zoomTo(location: CLLocation){
        if self.didInitialZoom == false{
            let coordinate = location.coordinate
            let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 300, longitudinalMeters: 300)
            self.mapView.setRegion(region, animated: false)
            self.didInitialZoom = true
        }
        
        if self.isBlockingAutoZoom == false{
            self.isZooming = true
            self.mapView.setCenter(location.coordinate, animated: true)
        }
        
        var accuracyRadius = 50.0
        if location.horizontalAccuracy > 0{
            if location.horizontalAccuracy > accuracyRadius{
                accuracyRadius = location.horizontalAccuracy
            }
        }
        
        self.mapView.removeOverlay(self.accuracyRangeCircle!)
        self.accuracyRangeCircle = MKCircle(center: location.coordinate, radius: accuracyRadius as CLLocationDistance)
        self.mapView.addOverlay(self.accuracyRangeCircle!)
        
        if self.userAnnotation != nil{
            self.mapView.removeAnnotation(self.userAnnotation!)
        }
        
        self.userAnnotation = UserAnnotation(coordinate: location.coordinate, title: "", subtitle: "")
        self.mapView.addAnnotation(self.userAnnotation!)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation{
            return nil
        }else{
            let identifier = "UserAnnotation"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            if annotationView != nil{
                annotationView!.annotation = annotation
            }else{
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            }
            annotationView!.canShowCallout = false
            annotationView!.image = self.userAnnotationImage
            
            return annotationView
        }
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        if self.isZooming == true{
            self.isZooming = false
            self.isBlockingAutoZoom = false
        }else{
            self.isBlockingAutoZoom = true
            if let timer = self.zoomBlockingTimer{
                if timer.isValid{
                    timer.invalidate()
                }
            }
            self.zoomBlockingTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false, block: { (Timer) in
                self.zoomBlockingTimer = nil
                self.isBlockingAutoZoom = false;
            })
        }
    }
    
    func mapinfodelegate(mapspeed: CLLocationSpeed, mapdistance: CLLocationDistance) {
        let sp = round(mapspeed * 10) / 10
        speed.text = String(format:"%.1f", sp)
        distanceAll = distanceAll + (round(mapdistance / 1000 * 10) / 10)
        distance.text = String(format:"%.1f", distanceAll)
        
        let mi = (date?.minutesFrom())! % 24
        let ho = (date?.hoursFrom())! % 60
        minute.text = String(mi)
        hour.text = String(ho)
    }
    
    // tap quit
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
