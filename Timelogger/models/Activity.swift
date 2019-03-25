//
//  Activity.swift
//  Timelogger
//
//  Created by Zulkarnain Shah on 05/02/19.
//  Copyright © 2019 BQE. All rights reserved.
//

import Foundation
import SwiftyJSON

class Activity{
    var name, description: String?
    var billable: Bool? = true
    var code: String?
    var sub: String?
    var costRate: Float? = 0
    var billRate: Float? = 0
    var tax1, tax2, tax3, overTimeBillRate, minimumHours: Float?
    var memo: String?
    var isActive: Bool? = true
    var incomeAccountId, expenseAccountId: String?
    var incomeAccount, expenseAccount: String?
    var defaultGroupId, defaultGroup: String?
    var extra: Bool?
    var id, createdOn, createdById, lastUpdated: String?
    var lastUpdatedById, version: String?
    var objectState, token :Int?
    
    init(){
    }
    
    init(jsonDictionary: [String: JSON]) {
        self.id = jsonDictionary["id"]?.string
        self.name = jsonDictionary["name"]?.string
        self.description = jsonDictionary["description"]?.string
        self.billable = jsonDictionary["billable"]?.boolValue
        self.code = jsonDictionary["code"]?.string
        self.sub = jsonDictionary["sub"]?.string
        self.costRate = jsonDictionary["costRate"]?.floatValue
        self.billRate = jsonDictionary["billRate"]?.floatValue
        self.tax1 = jsonDictionary["tax1"]?.floatValue
        self.tax2 = jsonDictionary["tax2"]?.floatValue
        self.tax3 = jsonDictionary["tax3"]?.floatValue
        self.minimumHours = jsonDictionary["minimumHours"]?.floatValue
        self.memo = jsonDictionary["memo"]?.string
        self.isActive = jsonDictionary["isActive"]?.boolValue
        self.overTimeBillRate = jsonDictionary["overTimeBillRate"]?.floatValue
        self.incomeAccountId = jsonDictionary["incomeAccountId"]?.string
        self.expenseAccountId = jsonDictionary["expenseAccountId"]?.string
        self.incomeAccount = jsonDictionary["incomeAccount"]?.string
        self.expenseAccount = jsonDictionary["expenseAccount"]?.string
        self.defaultGroupId = jsonDictionary["defaultGroupId"]?.string
        self.defaultGroup = jsonDictionary["defaultGroup"]?.string
        self.extra = jsonDictionary["extra"]?.boolValue
        self.createdOn = jsonDictionary["createdOn"]?.string
        self.createdById = jsonDictionary["createdById"]?.string
        self.lastUpdated = jsonDictionary["lastUpdated"]?.string
        self.lastUpdatedById = jsonDictionary["lastUpdatedById"]?.string
        self.version = jsonDictionary["version"]?.string
        self.objectState = jsonDictionary["objectState"]?.number as? Int
        self.token = jsonDictionary["token"]?.number as? Int
    }
    
    /** Creates dictionary from the Activity properties */
    func toDictionary()-> [String:AnyObject]{
        
        var dictionary = [String:AnyObject]()
        dictionary["code"] = self.code as AnyObject
        dictionary["description"] = self.description as AnyObject
        dictionary["costRate"] = self.costRate as AnyObject
        dictionary["billRate"] = self.billRate as AnyObject
        dictionary["billable"] = self.billable as AnyObject
        dictionary["isActive"] = self.isActive as AnyObject
        
        return dictionary
    }
    
    /** Returns True is Activity has all the required fields filled else False */
    func isActivityValid()-> Bool{
        if(self.code == nil || self.code?.count == 0){
            return false
        }
        
        if(self.description == nil || self.description?.count == 0){
            return false
        }
        return true
    }
}
