//
//  HttpClient.swift
//  Galaxy
//
//  Created by Aadil Majeed on 10/20/16.
//  Copyright © 2016 BQE Software. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

public class MultiPartData {
    public var fileURL: URL!
    public var name: String!
    public var mimeType: String?
    
    init(fileURL: URL, name: String, mimeType: String? = nil) {
        self.fileURL = fileURL
        self.name = name
        self.mimeType = mimeType
    }
}

public struct BQEDataResponse {
    /// The URL request sent to the server.
    public let request: URLRequest?
    
    /// The server's response to the URL request.
    public let response: HTTPURLResponse?
    
    /// The data returned by the server.
    public let data: Data?

    /// Serilized result of data. Api can return both array/dictionary
    public let dictionaryResult:[String:AnyObject]?
    
    /// Serilized result of data. Api can return both array/dictionary
    public let arrayResult:[AnyObject]?

    
    /// The Error in request or data serilization
    public let error : NSError?
    
    /// Creates a `DataResponse` instance with the specified parameters derived from response serialization.
    ///
    /// - parameter request:  The URL request sent to the server.
    /// - parameter response: The server's response to the URL request.
    /// - parameter data:     The data returned by the server.
    /// - parameter dictionaryResult:     Serilized result of data. Api can return both array/dictionary.
    /// - parameter data:     Serilized result of data. Api can return both array/dictionary

    ///
    /// - returns: The new `BQEDataResponse` instance.
    public init(
        request: URLRequest?,
        response: HTTPURLResponse?,
        data: Data?, dictionaryResult: [String:AnyObject]?,arrayResult: [AnyObject]?, error:NSError?)
    {
        self.request = request
        self.response = response
        self.data = data
        self.dictionaryResult = dictionaryResult
        self.error = error
        self.arrayResult = arrayResult
    }
    
    public func dataDescription() -> String {
        var jsonString = ""
        if let jData = self.data{
            jsonString = String(data: jData, encoding: String.Encoding.utf8)!
        }
        return jsonString
    }
}

public enum RequestMethod: Int {
    case eGET = 0
    case ePUT
    case ePOST
    case eDELETE
    
    var description:String{
        switch self {
        case .eGET:
            return "GET"
        case .ePUT:
            return "PUT"
        case .ePOST:
            return "POST"
        case .eDELETE:
            return "DELETE"
        }
    }
}

public enum RequestEncoding: Int {
    case eJson = 0
    case eDefault
}

fileprivate class Manager {
    public static var `default`: Manager { return defaultManager}
    private static var defaultManager:Manager = Manager()
    let sessionManager:SessionManager
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 60
        configuration.timeoutIntervalForResource = 60
        configuration.allowsCellularAccess = true
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        sessionManager = Alamofire.SessionManager(configuration: configuration)
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
    }
}


class HttpClient {
    
    class func getRequest(withURL url: String, parameters: [String : AnyObject]? = nil, headers: [String: String]? = nil , completionHandler: @escaping (DataResponse<Any>) -> Void) -> Void {
        
        Manager.default.sessionManager.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: headers).responseJSON { (response) -> Void in
            completionHandler(response)
        }
    }
    
    class func postRequest(withURL url: String, parameters: [String : AnyObject]? = nil, headers: [String: String]? = nil , completionHandler: @escaping (DataResponse<Any>) -> Void) -> Void {
        Manager.default.sessionManager.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) -> Void in
            completionHandler(response)
        }
    }
    
    class func putRequest(withURL url: String, parameters: [String : AnyObject]? = nil, headers: [String: String]? = nil , completionHandler: @escaping (DataResponse<Any>) -> Void) -> Void {
        Manager.default.sessionManager.request(url, method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) -> Void in
            completionHandler(response)
        }

    }

    class func deleteRequest(withURL url: String, parameters: [String : AnyObject]? = nil, headers: [String: String]? = nil , completionHandler: @escaping (DataResponse<Any>) -> Void) -> Void {
        Manager.default.sessionManager.request(url, method: .delete, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) -> Void in
            completionHandler(response)
        }

    }
    
    class func addRequest(request: URLRequest, completionHandler: @escaping (DataResponse<Any>) -> Void) -> Void {
        
        Manager.default.sessionManager.request(request).responseJSON { (response) in
            completionHandler(response)
        }
    }
    
    class func addRequest(withURL url: String, method: HTTPMethod, parameters: [String : AnyObject]? = nil, headers: [String: String]? = nil , completionHandler: @escaping (DataResponse<Any>) -> Void) -> Void {
        Manager.default.sessionManager.request(url, method: method , parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response) -> Void in
            completionHandler(response)
        }
        
    }

    class func postURLEncodingRequest(withURL url: String, parameters: [String : AnyObject]? = nil, headers: [String: String]? = nil , completionHandler: @escaping (DataResponse<Any>) -> Void) -> Void {
        Manager.default.sessionManager.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers).responseJSON { (response) -> Void in
            completionHandler(response)
        }
    }

    class func uploadFileRequest(withURL url: String, metaData: [String : AnyObject], headers: [String: String]? = nil, multiPartData: MultiPartData , completionHandler: @escaping (_ response: DataResponse<Any>?, _ error: Error?) -> Void) -> Void {
        Manager.default.sessionManager.upload(multipartFormData: { multipartFormData in
            for (key, value) in metaData {
                if let dictionary = value as? [String : AnyObject] {
                    if let data = try? JSONSerialization.data(withJSONObject: dictionary, options: []) {
                        multipartFormData.append(data, withName: key)
                    }
                }
                else if let array = value as? [AnyObject] {
                    if let data = try? JSONSerialization.data(withJSONObject: array, options: []) {
                        multipartFormData.append(data, withName: key)
                    }
                }
                else {
                    multipartFormData.append(value.data(using: String.Encoding.utf8.rawValue)!, withName: key)
                }
            }
            multipartFormData.append(multiPartData.fileURL, withName: multiPartData.name)

        }, to: url, method: HTTPMethod.post, headers: headers) { (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    completionHandler(response, nil)
                }
                break
            case .failure(let encodingError):
                completionHandler(nil, encodingError)
                break
            }
        }
    }
    class func uploadFileData(withURL url: String, data: Data, headers: [String: String]? = nil, multiPartData: MultiPartData , completionHandler: @escaping (_ response: DataResponse<Any>?, _ error: Error?) -> Void) -> Void {
        Manager.default.sessionManager.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(data, withName: "file",fileName: multiPartData.name, mimeType: multiPartData.mimeType!)
            
        }, to: url, method: HTTPMethod.post, headers: headers) { (result) in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    completionHandler(response, nil)
                }
                break
            case .failure(let encodingError):
                completionHandler(nil, encodingError)
                break
            }
        }
    }
    
    // Make Code independent of Third Party
    class func request(withURL url: String, method:RequestMethod, parameters: [String : AnyObject]? = nil, headers: [String: String]? = nil , completionHandler: @escaping (BQEDataResponse) -> Void) -> Void {
        
        var requestMethod = HTTPMethod.get
        
        switch method {
        case .eGET:
            requestMethod = .get
            break
        case .ePOST:
            requestMethod = .post
            break
        case .ePUT:
            requestMethod = .put
            break
        case .eDELETE:
            requestMethod = .delete
            break
        }
        
        Alamofire.request(url, method: requestMethod, parameters: parameters, encoding: URLEncoding.default, headers: headers).responseJSON { (response) -> Void in
            
            var serverError:NSError? = nil
            
            var dictionary:[String:AnyObject]? = nil

            var array:[AnyObject]? = nil

            if response.result.isFailure{
                if let error = response.result.error{
                    serverError = error as NSError?
                }
            }
            if let data = response.data{
                let json = try? JSON(data: data)
                dictionary = json?.dictionaryObject as [String : AnyObject]? // api can return both array as well as dictionary so need to think on this
                array = json?.arrayObject as [AnyObject]?
            }
            let serverResponse = BQEDataResponse(request: response.request, response: response.response, data: response.data, dictionaryResult: dictionary, arrayResult: array, error: serverError)
            completionHandler(serverResponse)
            
        }
    }

    class func requestImageData(withURL url: String, method:RequestMethod, parameters: [String : AnyObject]? = nil, headers: [String: String]? = nil , encoding:RequestEncoding, completionHandler: @escaping (DownloadResponse<Any>) -> Void, downloadProgress: @escaping (_ progress: Double) -> Void) {
        
        var requestMethod = HTTPMethod.get

        switch method {
        case .eGET:
            requestMethod = .get
            break
        case .ePOST:
            requestMethod = .post
            break
        case .ePUT:
            requestMethod = .put
            break
        case .eDELETE:
            requestMethod = .delete
            break
        }
        
        var requestEncoding: ParameterEncoding = URLEncoding.default
        
        switch encoding {
        case .eJson:
            requestEncoding = JSONEncoding.default
        default:
            requestEncoding = URLEncoding.default

        }

        let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)
        
        Alamofire.download(
            url,
            method: .get,
            parameters: parameters,
            encoding: JSONEncoding.default,
            headers: nil,
            to: destination).downloadProgress(closure: { (progress) in
                //progress closure
            }).response(completionHandler: { (DefaultDownloadResponse) in
                //here you able to access the DefaultDownloadResponse
                //result closure
            })
        
        Alamofire.download(url, method: requestMethod, parameters: parameters, encoding: requestEncoding, headers: headers, to: nil).downloadProgress(closure: { (progress) in
            let downloadedBytes = progress.fractionCompleted
            downloadProgress(downloadedBytes)
        }).responseJSON { (response) in
            completionHandler(response)
        }
    }
  
    class func stopAllRequestsWithCompletionHandler(handler:@escaping (_ success:Bool)->()){
        let sessionManager = Manager.default.sessionManager
        sessionManager.session.getTasksWithCompletionHandler { dataTasks, uploadTasks, downloadTasks in
            dataTasks.forEach { $0.cancel() }
            uploadTasks.forEach { $0.cancel() }
            downloadTasks.forEach { $0.cancel()}
            handler(true)
        }
    }
}
