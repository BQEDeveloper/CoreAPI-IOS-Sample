//
//  CoreAccountHelper.swift
//  Timelogger
//
//  Created by Zulkarnain Shah on 05/02/19.
//  Copyright © 2019 BQE. All rights reserved.
//

import Foundation

/** Defines model for holding various properties required at various levels of authentication with the BQE Core API's */
class CoreAccountHelper{
    var authURL: String
    var client_ID: String
    var redirect_URI: String
    
    var codeChallenge: String?
    var codeVerifier: String?
    var code: String?
    var clientSecret: String
    
    private init(){
        authURL = "https://sandbox-api-identity.bqecore.com/idp/connect/authorize"
        client_ID = "U5_Xfz_YddF9rK9YI0WGZAiEwGLqd4WB.apps.bqe.com"
        redirect_URI = "timelogger://timelogger.bqe.com"
        clientSecret = "aRiGVxtknrcIsVFE2V0aStoHejyqFqjm_hG8GD6alXYOVc8o_5ld7fPcVz3Kzbgk"
    }
    
    fileprivate static var instance:CoreAccountHelper? = CoreAccountHelper()
    
    public static var sharedInstance: CoreAccountHelper {
        if instance == nil {
            instance = CoreAccountHelper()
        }
        return instance!
    }
}

