//
//  NetworkManager.swift
//  Assignment
//
//  Created by Obulisudharson on 14/08/23.
//

import UIKit

class NetworkManager: NSObject {
    
    // MARK: - performs server call
    class func requestServer(request: RequestData, completion: @escaping (Result<Data?, Error>)-> ()) {
//        var urlString: String = kBaseUrl
//        urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        guard let url = URL(string: kBaseUrl) else {
            fatalError("BaseURL could not be configured.")
        }
        var urlRequest = URLRequest(url: url)
//        var urlRequest = URLRequest(url: url,
//                                    cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
//                                    timeoutInterval: 50.0)
        urlRequest.httpMethod = request.httpMethod
        urlRequest.httpBody = request.httpBody
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            //return error if there is any error in making request
            
            DispatchQueue.main.async {
                
                if let error = error {
                    completion(.failure(error))
                    return
                }
                //check response
                if let response = response, ((response as? HTTPURLResponse)?.statusCode ?? 0) >= 200 && ((response as? HTTPURLResponse)?.statusCode ?? 0) < 300 {
                    
                    if let data = data {
                        
                        completion(.success(data))
                    }
                    
                    if (response as? HTTPURLResponse)?.statusCode == 204 {
                        
                        completion(.success(nil))
                    }
                }
            }
        }
        //Resume task
        task.resume()
    }
}
