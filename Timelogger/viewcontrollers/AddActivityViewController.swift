//
//  AddActivityViewController.swift
//  Timelogger
//
//  Created by Zulkarnain Shah on 08/02/19.
//  Copyright © 2019 BQE. All rights reserved.
//

import Foundation
import UIKit

class AddActivityViewController : BaseViewController{
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var txtCode: UITextField!
    @IBOutlet weak var txtDescription: UITextField!
    @IBOutlet weak var txtBillRate: UITextField!
    @IBOutlet weak var txtCostRate: UITextField!
    @IBOutlet weak var switchBillable: UISwitch!
    
    var activity: Activity?
    var isNewMode: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateUI()
    }
    
    func updateUI(){
        if(self.activity != nil){
            self.isNewMode = false
            lblTitle.text = "Edit Activity"
            self.txtCode.text = activity?.code
            self.txtDescription.text = activity?.description
            if let billRate = self.activity?.billRate{
                self.txtBillRate.text = String(format: "%.2f", billRate)
            }
            if let costRate = self.activity?.costRate{
               self.txtCostRate.text = String(format: "%.2f", costRate)
            }
            if let billable = self.activity?.billable{
                self.switchBillable.isOn = billable
            }
            else{
                self.switchBillable.isOn = false
            }
        }
        
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
 
    @IBAction func saveAction(_ sender: Any) {
        self.activity = self.getFilledActivity()
        if(self.activity!.isActivityValid()){
            if(self.isNewMode){
                self.createNewActivity()
            }
            else{
                self.updateActivity()
            }
        }
        else{
            let alert = UIAlertController(title: "Missing fields", message: "Code and Description are required fields", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func mainViewTapAction(_ sender: Any) {
        view.endEditing(true)
    }
    
    /** Fills Activity object from the values of text fields */
    func getFilledActivity()-> Activity{
        var activity : Activity?
        if self.activity == nil{
            activity = Activity()
        }
        else{
            activity = self.activity
        }
        
        activity?.code = self.txtCode.text
        activity?.description = self.txtDescription.text
        
        if let strBillRate = self.txtBillRate.text{
            activity?.billRate = Float(strBillRate)
        }
        
        if let strCostRate = self.txtCostRate.text{
            activity?.costRate = Float(strCostRate)
        }
        activity?.billable = switchBillable.isOn
        
        return activity!
    }
    
    /** Creates a new Activity on the Core server */
    func createNewActivity(){
        self.showLoader(message: "Saving Activity\nPlease wait...")
        ActivityManager().postActivity(activity: self.activity!) { (success, error) in
            self.hideLoader()
            
            if(success){
                self.dismiss(animated: true, completion: nil)
            }
            else{
                let alert = UIAlertController(title: "Operation Failed", message: error, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    /** Updates an already existing Activity **/
    func updateActivity(){
        self.showLoader(message: "Updating Activity\nPlease wait...")
        ActivityManager().putActivity(activity: self.activity!) { (success, error) in
            self.hideLoader()
            
            if(success){
                self.dismiss(animated: true, completion: nil)
            }
            else{
                let alert = UIAlertController(title: "Operation Failed", message: error, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}
