//
//  ActivityListViewController.swift
//  Timelogger
//
//  Created by Zulkarnain Shah on 05/02/19.
//  Copyright © 2019 BQE. All rights reserved.
//

import Foundation
import UIKit
import Lottie

/** The ViewController for Activity list screen */
class ActivityListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyView: UIView!
    @IBOutlet weak var lblEmptyView: UILabel!
    @IBOutlet weak var lottieAnimationView: LOTAnimationView!
    @IBOutlet weak var ivEmptyImage: UIImageView!
    @IBOutlet weak var lblTotal: UILabel!
    
    var activities: [Activity] = []
    
    override func viewWillAppear(_ animated: Bool) {
        if let _ = CoreAccount.sharedInstance.accessToken{
          self.fetchActivities()
        }
        else{
            showEmptyView(title: "Please log in to your Core account from Accounts tab")
        }
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let activity = self.activities[indexPath.row]
        let xibs:[Any]? = Bundle.main.loadNibNamed("MainListCell", owner: nil, options: nil)
        var tableCell:MainListCell
        if let cell:MainListCell = (tableView.dequeueReusableCell(withIdentifier: "MainListCell") as? MainListCell){
            tableCell =  cell
        }
        else{
            tableCell = xibs?[0] as! MainListCell
        }
        tableCell.leftLabel.text = activity.code
        if let billRate = activity.billRate{
            let value = String(format: "%.2f", billRate)
            tableCell.rightLabel.text = "$\(value)"
        }
        else{
            tableCell.rightLabel.text = "$0.00"
        }
        
        if let billable = activity.billable{
            tableCell.secondLeftLabel.text = billable ? "Billable" : "Non-Billable"
            tableCell.secondLeftLabel.backgroundColor = billable ? "#4CAF50".toUIColor() : "#e57373".toUIColor()
        }
        else{
            tableCell.secondLeftLabel.text = "Non-Billable"
            tableCell.secondLeftLabel.backgroundColor = "#e57373".toUIColor()
        }
        
        return tableCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: false)
        let selectedActivity = self.activities[indexPath.row]
        self.performSegue(withIdentifier: "showAddEditActivity", sender: selectedActivity)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let selectedActivity = self.activities[indexPath.row]
        self.deleteActivity(activity: selectedActivity)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "showAddEditActivity"){
            let controller = segue.destination as? AddActivityViewController
            controller?.activity = sender as? Activity
        }
    }
    
    /** Fetches activities from Core server through ActivityManager */
    func fetchActivities(){
        self.showLoader()
        ActivityManager().getActivities { [weak self](success, error, activities) in
            self?.hideLoader()
            if(success){
                if let weakSelf = self{
                    weakSelf.activities = activities!
                    weakSelf.tableView.reloadData()
                    if(weakSelf.activities.count == 0){
                        weakSelf.showEmptyView(title: "No Activities found")
                    }
                    else{
                        weakSelf.hideEmptyView()
                    }
                }
            }
            else{
                self?.showEmptyView(title: error)
            }
        }
    }
    
    /** Attempts to delete an Activity through ActivityManager */
    func deleteActivity(activity: Activity){
        if let activity_ID = activity.id{
            ActivityManager().deleteActivity(activityID: activity_ID) { (success, error) in
                if(success == false){
                    let alert = UIAlertController(title: "Operation Failed", message: error, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                self.fetchActivities()
            }
        }
        else{
            let alert = UIAlertController(title: "Operation Failed", message: "Invalid Activity. Missing ID", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func showEmptyView(title: String?){
        var errorMessage = "Couldn't load Activities"
        if title != nil{
            errorMessage = title!
        }
        self.emptyView.isHidden = false
        self.lblEmptyView.text = errorMessage
        self.ivEmptyImage.isHidden = false
        self.lottieAnimationView.isHidden = true
    }
    
    func hideEmptyView(){
        self.emptyView.isHidden = true
        self.lblTotal.isHidden = false
        self.lblTotal.text = "\(self.activities.count) Total"
    }
    
    /** Displays a Lottie powered progress bar*/
    func showLoader(){
        self.lottieAnimationView.isHidden = false
        self.emptyView.isHidden = false
        self.lblEmptyView.text = "Loading Activities\nPlease wait..."
        self.ivEmptyImage.isHidden = true
        self.lottieAnimationView.setAnimation(named: "loading")
        self.lottieAnimationView.loopAnimation = true
        self.lottieAnimationView.play()
    }
    
    /** Hides the progress loader */
    func hideLoader(){
        self.lottieAnimationView.stop()
    }
    
}
