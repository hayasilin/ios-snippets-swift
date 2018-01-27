//
//  PinDetailsViewController.swift
//  MapKit_test
//
//  Created by Kuan-Wei Lin on 8/16/15.
//  Copyright (c) 2015 Kuan-Wei Lin. All rights reserved.
//

import UIKit
import MapKit

class PinDetailsViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var mapItemData:MKMapItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
    }
    
    func tableView(tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
            
            var cell:UITableViewCell! = tableView.dequeueReusableCellWithIdentifier("cellIdentifier");
            if cell == nil{
                cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "cellIdentifier")
                if indexPath.row == 0{
                    cell.textLabel?.text = mapItemData.name
                }
                if indexPath.row == 1{
                    cell.textLabel?.text = mapItemData.placemark.country
                    cell.detailTextLabel?.text = mapItemData.placemark.countryCode
                }
                if indexPath.row == 2{
                    cell.textLabel?.text = mapItemData.placemark.postalCode
                }
                if indexPath.row == 3{
                    cell.textLabel?.text = "Phone number"
                    cell.detailTextLabel?.text = mapItemData.phoneNumber
                }
            }
            return cell
    }
    
    func tableView(tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int{
            return 4
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
