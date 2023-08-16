//
//  AppUtility.swift
//  Assignment
//
//  Created by Obulisudharson on 16/08/23.
//

import UIKit

struct AppUtility {
    
    static func getThumbnailImage(imageUrl: String?) -> UIImage? {
        var thumbnailImage: UIImage?
        if let imageUrl = imageUrl {
            ImageDownloader.shared.downloadImage(imageUrlString: imageUrl) {(image, error) in
                thumbnailImage = image
            }
        }
        return thumbnailImage
    }
    
}
