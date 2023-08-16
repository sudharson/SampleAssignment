//
//  Product+CoreDataClass.swift
//  Assignment
//
//  Created by Obulisudharson on 15/08/23.
//
//

import Foundation
import CoreData


public class Product: NSManagedObject {
    class func parseAndSaveResponse(response: [[String:AnyObject]]?, completionHandler: @escaping (_ completed: Bool) -> ()){
        
        guard let response = response else {
            completionHandler(false)
            return }
        
        for product in response {
            if let productId = product["id"] as? Int64 {
                let item = Product.firstOrCreate(with: "productId", value: productId)
                item.productPrice = product["price"] as? Double ?? 0
                item.productName = product["title"] as? String
                item.productDescription = product["description"] as? String
                item.productImageUrl = product["image"] as? String
                item.productCategory = product["category"] as? String
                if let rating = product["rating"] {
                    item.productRating = rating["rate"] as? Double ?? 0
                    item.productRatingCount = rating["count"] as? Int64 ?? 0
                }
            }
        }
        
        try? Product.defaultContext.save()
        completionHandler(true)
    }
    
    class func fetchAllProducts() -> [Product]? {
        
        let productList = Product.all(orderedBy: [NSSortDescriptor(key: "productId", ascending: true)])
        if let products = productList {
            return products as? [Product]
        }
        return nil
    }
    
    class func fetchProducts(_ searchStr: String) -> [Product]? {
        let predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [NSPredicate(format:"productName CONTAINS[c] %@", searchStr), NSPredicate(format:"productDescription CONTAINS[c] %@", searchStr), NSPredicate(format:"productCategory CONTAINS[c] %@", searchStr)])
        //NSCompoundPredicate(andPredicateWithSubpredicates: [NSPredicate(format:"productName CONTAINS[C] %@", searchStr), NSPredicate(format:"productDescription CONTAINS[C] %@", searchStr)])
        if let products = Product.all(with: predicate) {
            return products as? [Product]
        }
        return nil
    }
}
