//
//  ServiceManager.swift
//  Assignment
//
//  Created by Obulisudharson on 14/08/23.
//

import UIKit

public typealias HTTPHeaders = [String: String]

public enum RequestData {
    
    case getList
    
    //Returns EndPoint for Contact APIs
    var path: String {
        
        switch self {
        case .getList:
            
            return ""
        }
    }
    
    //Return HTTP Method
    var httpMethod: String {
        
        switch self {
        case .getList:
            return "GET"
        }
    }
    
    //Return HTTPBody
    var httpBody: Data? {
        switch self {
        case .getList:
            return nil
        }
    }
    
    //Return HTTPHeader
    var headers: HTTPHeaders? {
        return nil
    }
}

class ServiceManager: NSObject {

    class func getProductList(keyWord: String, completionHandler: @escaping (Result<Data?, Error>)-> ()) {
        
        NetworkManager.requestServer(request: RequestData.getList) { (result) in
            
            completionHandler(result)
        }
    }
}
