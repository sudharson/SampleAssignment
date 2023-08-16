//
//  ImageOperation.swift
//  Assignment
//
//  Created by Obulisudharson on 14/08/23.
//

import UIKit

class ImageOperation: Operation {
    override var isAsynchronous: Bool {
        return true
    }
    let imageUrl : URL
    var downloadHandler : ((UIImage? , String)->())?
    
    required init(imageUrl : URL ) {
        self.imageUrl = imageUrl
    }
    
    private var _executing = false {
        willSet {
            willChangeValue(forKey: "isExecuting")
        }
        didSet {
            didChangeValue(forKey: "isExecuting")
        }
    }
    
    override var isExecuting: Bool {
        return _executing
    }
    
    
    private var _finished = false {
        willSet {
            willChangeValue(forKey: "isFinished")
        }
        didSet {
            didChangeValue(forKey: "isFinished")
        }
    }
    
    override var isFinished: Bool {
        return _finished
    }
    
    override func start() {
        main()
    }
    
    override func main() {
        if isCancelled {
            _finished = true
            return
        }
        _finished = false
        _executing = true
        downloadImage()
    }
    
    
    func downloadImage() {
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.requestCachePolicy = .returnCacheDataElseLoad
        let cache = URLCache(memoryCapacity: 0, diskCapacity: 50*1024*1024, diskPath: "myCache")
        sessionConfig.urlCache = cache
        let session = URLSession(configuration: sessionConfig)
        let downloadTask = session.downloadTask(with: imageUrl) { [weak self] (fileUrl, response, error)  in
            if error == nil {
                if let location = fileUrl , let data = try? Data(contentsOf: location) {
                    let image = UIImage(data: data)
                    self?.downloadHandler!(image,self?.imageUrl.absoluteString ?? "")
                }
            }
            self?._executing = false
            self?._finished = true
        }
        downloadTask.resume()
    }
}
