//
//  CoreDataHelper.swift
//  Assignment
//
//  Created by Obulisudharson on 15/08/23.
//

import Foundation
import CoreData

/* `CoreDataHelper` is a simple wrapper class for setting up
 and using a Core Data stack.
 */

public class CoreDataHelper: NSObject {
    /*
     Main stack container responsible for every action done in this class
    */
    private let persistentContainer: NSPersistentContainer;
    
    /// A read-only flag indicating if the persistent store is loaded.
    public private (set) var isStoreLoaded = false

    /*
     Private queue to sycronise all write operations.
    */
    let  persistentContainerQueue : OperationQueue = {
        let queue = OperationQueue.init();
        queue.maxConcurrentOperationCount = 1;
        return queue;
    }()

    /*
     The managed object context associated with the main queue (read-only).
     To perform tasks on a private background queue see
     `performBackgroundTask:` and `newPrivateContext`.
     The context is configured to be generational and to automatically
     consume save notifications from other contexts.
     */
    public var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    public var bgContext: NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }
    
    /*
     The `URL` of the persistent store for this Core Data Stack. If there
     is more than one store this property returns the first store it finds.
     The store may not yet exist. It will be created at this URL by default
     when first loaded.
     This is a readonly property to create a persistent store in a different
     location use `loadStoreAtURL:withCompletionHandler`.
 */
    public var storeURL: URL? {
        var url: URL?
        let descriptions = persistentContainer.persistentStoreDescriptions
        if let firstDescription = descriptions.first {
            url = firstDescription.url
        }
        return url
    }
    
    /*
     Creates and returns a `CoreDataHelper` object. This is the designated
     initializer for the class. It creates the managed object model,
     persistent store coordinator and main managed object context but does
     not load the persistent store.
     The managed object model should be in the same bundle as this class.
     - Parameter name: The name of the persistent store.
     - Returns: A `CoreDataHelper` object or nil if the model
     could not be loaded.
     */
    public init?(name: String) {
        let bundle = Bundle(for: CoreDataHelper.self)// use different approach if we need to make it comaptible with app groups - future
        guard let mom = NSManagedObjectModel.mergedModel(from: [bundle]) else {
            return nil
        }
        persistentContainer = NSPersistentContainer(name: name, managedObjectModel: mom)
        super.init()
    }
    
    /*
     Load the persistent store from the default location.
     - Parameter handler: This handler block is executed on the calling
     thread when the loading of the persistent store has completed.
     
     To override the default name and location of the persistent store use
     `loadStoreAtURL:withCompletionHandler:`.
     */
    public func loadStore(completionHandler: @escaping (Error?) -> Void) {
        loadStore(storeURL: storeURL, completionHandler: completionHandler)
    }
    
    /*
     Load the persistent store from a specified location
     - Parameter storeURL: The URL for the location of the persistent
     store. It will be created if it does not exist.
     - Parameter handler: This handler block is executed on the calling
     thread when the loading of the persistent store has completed.
     */
    public func loadStore(storeURL: URL?, completionHandler: @escaping (Error?) -> Void) {
        if let storeURL = storeURL ?? self.storeURL {
            let description = storeDescription(with: storeURL)
            persistentContainer.persistentStoreDescriptions = [description]
        }
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            if error == nil {
                
                self.isStoreLoaded = true
                self.persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
            }
            completionHandler(error)
        }
    }
    
    /*
     Return the description of the Store at given Url
     - Parameter storeURL: An `NSURL` containing a URI of a managed object.
    */
    private func storeDescription(with url: URL) -> NSPersistentStoreDescription {
        let description = NSPersistentStoreDescription(url: url)
        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = true
        description.shouldAddStoreAsynchronously = false
        description.isReadOnly = false
        return description
    }
    
    /*
    Core Data Saving support - for the entire modal
    */
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}
