//
//  Product+CoreDataProperties.swift
//  Assignment
//
//  Created by Obulisudharson on 15/08/23.
//
//

import Foundation
import CoreData


extension Product {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Product> {
        return NSFetchRequest<Product>(entityName: "Product")
    }

    @NSManaged public var productDescription: String?
    @NSManaged public var productId: Int64
    @NSManaged public var productImageUrl: String?
    @NSManaged public var productName: String?
    @NSManaged public var productPrice: Double
    @NSManaged public var productRatingCount: Int64
    @NSManaged public var productRating: Double
    @NSManaged public var productCategory: String?
    

}

extension Product : Identifiable {

}
