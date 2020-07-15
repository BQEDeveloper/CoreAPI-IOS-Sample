//
//  CoreAuthManager.swift
//  Timelogger
//
//  Created by Zulkarnain Shah on 05/02/19.
//  Copyright © 2019 BQE. All rights reserved.
//

import Foundation
import SwiftyJSON

/** This class manages communication with the authentication API's */
class CoreAuthManager{
    
    /** Requests Core access-token using the authorization code received from the Core auth screen */
    func getAccessTokenFromCode(code: String,callback:@escaping (_ error: String?, _ accessToken: String?, _ baseURl: String?)-> Void){
        let coreAccountHelper = CoreAccountHelper.sharedInstance
        
        let url = "https://sandbox-api-identity.bqecore.com/idp/connect/token"
        let params = [
            "code": code,
            "grant_type":"authorization_code",
            "redirect_uri":coreAccountHelper.redirect_URI,
            "client_id":coreAccountHelper.client_ID,
            "client_secret":coreAccountHelper.clientSecret,
            "code_verifier":coreAccountHelper.codeVerifier
            ] as [String: AnyObject]
        
        HttpClient.postURLEncodingRequest(withURL: url, parameters: params, headers: ["Content-Type":"application/x-www-form-urlencoded"]) { (response) in
            var statusCode:Int = 500
            if let headers = response.response{
                statusCode = headers.statusCode
            }
            else if response.result.isFailure{
                if let error = response.result.error{
                    callback(error.localizedDescription ,nil,nil)
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    return
                }
            }
            
            let json = try? JSON(data: response.data!)
            if statusCode == 200{
                if let jsonDict = json?.dictionary{
                    let accessToken = jsonDict["access_token"]?.string
                    let endpoint = jsonDict["endpoint"]?.string
                    callback(nil,accessToken,endpoint)
                }
                else{
                    callback("Some error occured",nil,nil)
                }
            }
            else{
                callback("Some error occured while getting access token from Core server",nil,nil)
            }
        }
    }
    
    /** Requests Core to revoke the access-token. Used for logging out the client */
    func revokeAccessToken(callback:@escaping (_ success:Bool, _ error: String?)-> Void){
        let coreAccountHelper = CoreAccountHelper.sharedInstance
        
        if let accessToken = CoreAccount.sharedInstance.accessToken{
            let url = "https://sandbox-api-identity.bqecore.com/idp/connect/revocation"
            let params = [
                "token": accessToken,
                "client_id":coreAccountHelper.client_ID,
                "client_secret":coreAccountHelper.clientSecret
                ] as [String: AnyObject]
            
            HttpClient.postURLEncodingRequest(withURL: url, parameters: params, headers: ["Content-Type":"application/x-www-form-urlencoded"]) { (response) in
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
                
                if statusCode == 200{
                    callback(true,nil)
                }
                else{
                    callback(false, "Some error occured while revoking access token from Core server")
                }
            }
        }
        
        else{
            callback(false,"Access token not found")
        }
        
        
    }
}
