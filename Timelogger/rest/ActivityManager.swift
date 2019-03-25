//
//  ActivityManager.swift
//  Timelogger
//
//  Created by Zulkarnain Shah on 05/02/19.
//  Copyright © 2019 BQE. All rights reserved.
//

import Foundation
import SwiftyJSON

class ActivityManager{
    
    /** Fetches actvities from Core server */
    func getActivities(callback:@escaping(_ success: Bool, _ error: String?,_ activities:[Activity]?) -> Void){
        
        let url = "https://sandbox-api.bqecore.com/api/activity/query"
        
        if let accessToken = CoreAccount.sharedInstance.accessToken {
            let headers = [
                "accept": "application/json",
                "authorization": "Bearer \(accessToken)",
                "Content-Type":"application/json"
            ]
            
            HttpClient.getRequest(withURL: url, headers: headers) { (response) in
                var activities : [Activity] = []
                var statusCode:Int = 500
                if let headers = response.response{
                    statusCode = headers.statusCode
                }
                else if response.result.isFailure{
                    if let error = response.result.error{
                        callback(false, error.localizedDescription ,nil)
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        return
                    }
                }
                
                let json = try? JSON(data: response.data!)
                if statusCode >= 200 && statusCode < 300{
                    if let jsonArray = json?.array, jsonArray.count > 0{
                        for item in jsonArray{
                            if let jsonDict = item.dictionary{
                                let activity = Activity(jsonDictionary: jsonDict)
                                activities.append(activity)
                            }
                        }
                        callback(true,nil,activities)
                    }
                    else{
                        callback(false,"No Activities found",nil)
                    }
                }
                else if(statusCode == 401){
                    CoreAccount.sharedInstance.deleteAccessTokenFromUserDefaults()
                    callback(false,"Please log in to your Core account from Accounts tab",nil)
                }
                else{
                    callback(false,"Some error occured at server",nil)
                }
            }
        }
        else{
            callback(false,"Please log in to your Core account from Accounts tab",nil)
        }
    }
    
    /** Posts a new Activity to Core server */
    func postActivity(activity: Activity, callback:@escaping(_ success: Bool,_ error: String?)-> Void){
        let url = "https://sandbox-api.bqecore.com/api/activity"
        
        if let accessToken = CoreAccount.sharedInstance.accessToken {
            let headers = [
                "accept": "application/json",
                "authorization": "Bearer \(accessToken)",
                "Content-Type":"application/json"
            ]
            
            let activityJSON = activity.toDictionary()
            
            HttpClient.postRequest(withURL: url, parameters: activityJSON, headers: headers) { (response) in
                var statusCode:Int = 500
                if let headers = response.response{
                    statusCode = headers.statusCode
                }
                else if response.result.isFailure{
                    if let error = response.result.error{
                        callback(false, error.localizedDescription)
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        return
                    }
                }
                
                let json = try? JSON(data: response.data!)
                if statusCode == 201{
                    callback(true,nil)
                }
                else if(statusCode == 401){
                    CoreAccount.sharedInstance.deleteAccessTokenFromUserDefaults()
                    callback(false,"Please log in to your Core account from Accounts tab")
                }
                else{
                    var errorMessage = "Some error occured at server"
                    if let serverErrorMessage = json?.dictionary?["Message"]?.string{
                        errorMessage = serverErrorMessage
                    }
                    callback(false,errorMessage)
                }
            }
        }
        else{
            callback(false,"Please log in to your Core account from Accounts tab")
        }
    }
    
    /** Updates an old Activity */
    func putActivity(activity: Activity, callback:@escaping(_ success: Bool,_ error: String?)-> Void){
        guard let activity_ID = activity.id else{
            callback(false,"Invalid Activity")
            return
        }
        let url = "https://sandbox-api.bqecore.com/api/activity/\(activity_ID)"
        
        if let accessToken = CoreAccount.sharedInstance.accessToken {
            let headers = [
                "accept": "application/json",
                "authorization": "Bearer \(accessToken)",
                "Content-Type":"application/json"
            ]
            
            let activityJSON = activity.toDictionary()
            
            HttpClient.putRequest(withURL: url, parameters: activityJSON, headers: headers) { (response) in
                var statusCode:Int = 500
                if let headers = response.response{
                    statusCode = headers.statusCode
                }
                else if response.result.isFailure{
                    if let error = response.result.error{
                        callback(false, error.localizedDescription)
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        return
                    }
                }
                
                let json = try? JSON(data: response.data!)
                if statusCode == 200{
                    callback(true,nil)
                }
                else if(statusCode == 401){
                    CoreAccount.sharedInstance.deleteAccessTokenFromUserDefaults()
                    callback(false,"Please log in to your Core account from Accounts tab")
                }
                else{
                    var errorMessage = "Some error occured at server"
                    if let serverErrorMessage = json?.dictionary?["Message"]?.string{
                        errorMessage = serverErrorMessage
                    }
                    callback(false,errorMessage)
                }
            }
        }
        else{
            callback(false,"Please log in to your Core account from Accounts tab")
        }
    }
    
    /** Deletes an Activity from the Core server */
    func deleteActivity(activityID: String, callback:@escaping(_ success: Bool, _ error: String?)-> Void){
        let url = "https://sandbox-api.bqecore.com/api/activity/\(activityID)"
        
        if let accessToken = CoreAccount.sharedInstance.accessToken {
            let headers = [
                "accept": "application/json",
                "authorization": "Bearer \(accessToken)",
                "Content-Type":"application/json"
            ]
            
            HttpClient.deleteRequest(withURL: url, headers: headers) { (response) in
                var statusCode:Int = 500
                if let headers = response.response{
                    statusCode = headers.statusCode
                }
                else if response.result.isFailure{
                    if let error = response.result.error{
                        callback(false, error.localizedDescription)
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        return
                    }
                }
                
                let json = try? JSON(data: response.data!)
                if statusCode >= 200 && statusCode < 300{
                    callback(true,nil)
                }
                else if(statusCode == 401){
                    CoreAccount.sharedInstance.deleteAccessTokenFromUserDefaults()
                    callback(false,"Please log in to your Core account from Accounts tab")
                }
                else{
                    var errorMessage = "Some error occured at server"
                    if let serverErrorMessage = json?.dictionary?["Message"]?.string{
                        errorMessage = serverErrorMessage
                    }
                    callback(false,errorMessage)
                }
            }
        }
        else{
            callback(false,"Please log in to your Core account from Accounts tab")
        }
    }
}
