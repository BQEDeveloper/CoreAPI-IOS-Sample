//
//  CoreAccount.swift
//  Timelogger
//
//  Created by Zulkarnain Shah on 05/02/19.
//  Copyright © 2019 BQE. All rights reserved.
//

import Foundation

let CoreAccountProgressUpdateNotification = "bqe_core_account_progress_update_notification"

class CoreAccount {
    
    private(set) var accessToken: String?
    private(set) var baseURL: String?

    private(set) var error: String?
    
    private(set) var completed: Bool = false

    private init(){
        if let accessToken = self.readAccessTokenFromUserDefaults(), let baseURL = self.readBaseURLFromUserDefaults() {
            self.accessToken = accessToken
            self.baseURL = baseURL
            self.completed = true
        }
    }
    
    fileprivate static var instance: CoreAccount? = CoreAccount()
    
    public static var sharedInstance: CoreAccount {
        if(instance == nil){
            instance = CoreAccount()
        }
        return instance!
    }
    
    /** Persists access token to UserDefaults  */
    private func writeAccessTokenToUserDefaults(){
        UserDefaults.standard.set(accessToken, forKey: "accessToken")
        UserDefaults.standard.synchronize()
    }
    
    /** Persists Base URL to UserDefaults  */
    private func writeBaseURLToUserDefaults(){
        UserDefaults.standard.set(baseURL, forKey: "baseURL")
        UserDefaults.standard.synchronize()
    }

    
    /** Reads and returns the access token stored in UserDefaults */
    private func readAccessTokenFromUserDefaults()-> String?{
        return UserDefaults.standard.value(forKey: "accessToken") as? String
    }
    
    /** Reads and returns the base URL stored in UserDefaults */
    private func readBaseURLFromUserDefaults()-> String?{
        return UserDefaults.standard.value(forKey: "baseURL") as? String
    }

    
    /** Deletes the access token from the UserDefaults */
    func deleteAccessTokenFromUserDefaults(){
        UserDefaults.standard.removeObject(forKey: "accessToken")
        UserDefaults.standard.removeObject(forKey: "baseURL")
        UserDefaults.standard.synchronize()
        self.accessToken = nil
        self.error = nil
        self.completed = false
    }
    
    func handle(url:URL) -> Void {
        
        if let code = url.queryParameters?["code"] {
            
            self.completed = false
           
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: CoreAccountProgressUpdateNotification), object: self)
            
            CoreAuthManager().getAccessTokenFromCode(code: code) { [weak self](error, accessToken, baseURL) in
                self?.completed = true
                if let token = accessToken {
                    self?.accessToken = token
                    self?.baseURL = baseURL
                    self?.writeAccessTokenToUserDefaults()
                    self?.writeBaseURLToUserDefaults()
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: CoreAccountProgressUpdateNotification), object: self)
                }
                else {
                    self?.error = error
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: CoreAccountProgressUpdateNotification), object: self)
                }
            }
        }
    }
}
