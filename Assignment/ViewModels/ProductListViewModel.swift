//
//  ProductListViewModel.swift
//  Assignment
//
//  Created by Obulisudharson on 14/08/23.
//

import UIKit

class ProductListViewModel: NSObject {
    
    var items = [ProductModel]()
    var itemsNew : [(key:String,values:[ProductModel])]?
    var dataSourceDict = [String:[ProductModel]]()
    var isGrouped: Bool?
    var searchKeyWord = ""

    /*** new search method ***/
    func getProductList(searchKeyword: String, completionHandler: @escaping (_ error: Error?, _ isChanged: Bool)-> ()) {
        
        if searchKeyword.isEmpty {
            self.fetchList(searchKeyword: searchKeyword, completionHandler: completionHandler)
        } else {
            self.fetchQueriedList(searchKeyword: searchKeyword, completionHandler: completionHandler)
        }
    }
    
    /*** search method implementation -> new search ***/
    /*** isChanged -> true will refresh tableView ***/
    func fetchList(searchKeyword: String, completionHandler: @escaping (_ error: Error?, _ isChanged: Bool)-> ()) {
        
        let productModel = ProductModel.readFromPersistentStore()
        if productModel.count > 0 {
            if (self.isGrouped ?? false) {
                self.dataSourceDict = Dictionary.init(grouping: productModel, by: { $0?.category ?? "" })
                let sortedDict = self.dataSourceDict.sorted(by: { $0.key < $1.key})
                self.itemsNew = sortedDict.compactMap({(key:$0,values:$1)})
            } else {
                self.items.removeAll()
                self.items = productModel
            }
            completionHandler(nil, true)
        } else {
            ServiceManager.getProductList(keyWord: searchKeyword) {[weak self] (result) in
                switch result {
                 case .success(let data):
                    guard let data = data else {
                        completionHandler(nil, true)
                        return
                    }
                    do {
                        let productResponseDict = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [[String:AnyObject]]
                        Product.parseAndSaveResponse(response: productResponseDict) { isSuccess in
                            if isSuccess {
                                let productModel = ProductModel.readFromPersistentStore()
                                if (self?.isGrouped ?? false) {
                                    self?.dataSourceDict = Dictionary.init(grouping: productModel, by: { $0?.category ?? "" })
                                    let sortedDict = self?.dataSourceDict.sorted(by: { $0.key < $1.key})
                                    self?.itemsNew = sortedDict?.compactMap({(key:$0,values:$1.sorted(by: {$0.id ?? 0 < $1.id ?? 0}))})
                                } else {
                                    self?.items.removeAll()
                                    self?.items = productModel
                                }
                            }
                        }
                        completionHandler(nil, true)
                    } catch {
                        
                        completionHandler(nil, true)
                    }
                case .failure(let error):
                    completionHandler(error, true)
                }
            }
        }
    }
    
    func fetchQueriedList(searchKeyword: String, completionHandler: @escaping (_ error: Error?, _ isChanged: Bool)-> ()){
        let productModel = ProductModel.searchProductsFromPersistentStore(searchKeyword)
        if (self.isGrouped ?? false) == true {
            self.dataSourceDict = Dictionary.init(grouping: productModel, by: { $0?.category ?? "" })
            let sortedDict = self.dataSourceDict.sorted(by: { $0.key < $1.key})
            self.itemsNew = sortedDict.compactMap({(key:$0,values:$1.sorted(by: {$0.id ?? 0 < $1.id ?? 0}))})
        } else {
            self.items.removeAll()
            self.items = productModel.sorted(by: {$0.id ?? 0 < $1.id ?? 0})
        }
        completionHandler(nil,true)
    }
    
    func sortByAscendingOrder() {
        if (self.isGrouped ?? false) == true {
            let sortedDict = self.dataSourceDict.sorted(by: { $0.key < $1.key})
            self.itemsNew = sortedDict.compactMap({(key:$0,values:$1.sorted(by: {$0.price ?? 0 < $1.price ?? 0}))})
        } else {
            self.items.sort(by: {$0.price ?? 0 < $1.price ?? 0})
        }
    }
    
    func sortByDescendingOrder() {
        if (self.isGrouped ?? false) == true {
            let sortedDict = self.dataSourceDict.sorted(by: { $0.key < $1.key})
            self.itemsNew = sortedDict.compactMap({(key:$0,values:$1.sorted(by: {$0.price ?? 0 > $1.price ?? 0}))})
        } else {
            self.items.sort(by: {$0.price ?? 0 > $1.price ?? 0})
        }
    }
    
    func sortByNameAscending() {
        if (self.isGrouped ?? false) == true {
            let sortedDict = self.dataSourceDict.sorted(by: { $0.key < $1.key})
            self.itemsNew = sortedDict.compactMap({(key:$0,values:$1.sorted(by: {$0.title ?? "" < $1.title ?? ""}))})
        } else {
            self.items.sort(by: {$0.title ?? "" < $1.title ?? ""})
        }
    }
    
    func sortByNameDescending() {
        if (self.isGrouped ?? false) == true {
            let sortedDict = self.dataSourceDict.sorted(by: { $0.key < $1.key})
            self.itemsNew = sortedDict.compactMap({(key:$0,values:$1.sorted(by: {$0.title ?? "" > $1.title ?? ""}))})
        } else {
            self.items.sort(by: {$0.title ?? "" > $1.title ?? ""})
        }
    }
    
    func sortByRatingAscending() {
        if (self.isGrouped ?? false) == true {
            let sortedDict = self.dataSourceDict.sorted(by: { $0.key < $1.key})
            self.itemsNew = sortedDict.compactMap({(key:$0,values:$1.sorted(by: {$0.rate ?? 0 > $1.rate ?? 0}))})
        } else {
            self.items.sort(by: {$0.rate ?? 0 > $1.rate ?? 0})
        }
    }
}
