//
//  ImageDownloader.swift
//  Assignment
//
//  Created by Obulisudharson on 14/08/23.
//

import UIKit

class ImageDownloader: NSObject {
    
    static let shared = ImageDownloader()
    private let cache = NSCache<NSString, AnyObject>()
    private var operationQueue = OperationQueue()

    func downloadImage(imageUrlString : String , completionHandler : @escaping (UIImage? , String) -> ()) {
        guard let imageUrl = URL(string: imageUrlString) else {
            completionHandler(nil, imageUrlString)
            return
        }
        if let image = cache.object(forKey: imageUrlString as NSString)  {
            completionHandler(image as? UIImage, imageUrlString)
            return
        }
        let operation =  operationQueue.operations.filter({ (operation) -> Bool in
            let imageOperation = operation as! ImageOperation
            if imageOperation.imageUrl == imageUrl {
                return true
            }
            return false
        }).first as? ImageOperation
        
        if operation == nil {
            let imageOperation = ImageOperation(imageUrl: imageUrl)
            imageOperation.downloadHandler = { (image, imageUrlString) in
                if let image = image, let imageUrlString = imageUrlString as? NSString {
                    self.cache.setObject(image, forKey: imageUrlString)
                }
                completionHandler(image, imageUrlString)
            }
            operationQueue.addOperation(imageOperation)
        }
    }
}
