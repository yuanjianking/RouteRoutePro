//
//  EventListController.swift
//  RouteRoutePro
//
//  Created by 安齋洸也 on 2018/11/09.
//  Copyright © 2018年 安齋洸也. All rights reserved.
//

import Foundation
import UIKit

class EventListController: UITableViewController {
    var myemail:String?
    
    // sample data
    let eventlist = [(id:"e00000001",name:"Test Cycle!",detail:"This is test!",email:"hogehoge@yahoo.co.jp",latitude:"35.658581",longitude:"139.745433",date:"20181120",starttime:"1120",endtime:"1320"),(id:"e00000002",name:"Happy Cycle!",detail:"This is happy test!",email:"fugafuga@gmail.com",latitude:"12.345678",longitude:"123.456789",date:"20181224",starttime:"1020",endtime:"2020"),(id:"e00000003",name:"Horihori Cycle!",detail:"This is horihori!",email:"horifuga@yahoo.co.jp",latitude: "35.658510",longitude:"139.745420",date:"20181027",starttime:"0820",endtime:"2320")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let appDelegate:AppDelegate = UIApplication.shared.delegate as!     AppDelegate
        myemail = appDelegate.userid!
        
        let NotifMycation = NSNotification.Name(rawValue:"MyNSNotification")
        NotificationCenter.default.addObserver(self, selector: #selector(upDataChange(notif:)), name: NotifMycation, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func upDataChange(notif: NSNotification) {
        guard let text: String = notif.object as! String? else { return }
    }
    
    //route event
    @IBAction func selectRouteEvent(_ sender: Any) {
        self.performSegue(withIdentifier: "goRouteEvent", sender: self)
    }
    
    //number of section
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //number of rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventlist.count
    }
    
    //create cells
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventcell", for: indexPath)
        let eventData = eventlist[(indexPath as NSIndexPath).row]
        cell.textLabel?.text = eventData.name
        cell.detailTextLabel?.text = eventData.detail
        return cell
    }
    
    //tap cells
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let event = eventlist[indexPath.row]
        // ここで管理者か一般ユーザか分岐。今はまだ未実装
        if myemail == event.email {
            //監理者イベント
            self.performSegue(withIdentifier: "goOwnerEvent", sender: self)
        }else{
            //参加イベント
            self.performSegue(withIdentifier: "goUserEvent", sender: self)
        }
    }
    
    //data
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goOwnerEvent" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let eventData = eventlist[(indexPath as NSIndexPath).row]
                let nav = segue.destination as! UINavigationController
                let secondView = nav.topViewController as! OwnerEventController
                secondView.data = eventData
            }
        }else if segue.identifier == "goUserEvent" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let eventData = eventlist[(indexPath as NSIndexPath).row]
                let nav = segue.destination as! UINavigationController
                let secondView = nav.topViewController as! UserEventController
                secondView.data = eventData
            }
        }
    }
    
    //戻る実装
    @IBAction func myUnwindAction(segue: UIStoryboardSegue) {
        
    }

    @IBAction func backSegue(segue : UIStoryboardSegue){
        if segue.identifier == "goRouteEvent"{
            //获取返回的控制器
            let backVC = segue.source as! RouteEventController
            print(backVC.goallat)//获取返回值
        }
    }
    
}
