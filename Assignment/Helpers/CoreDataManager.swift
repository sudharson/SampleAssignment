//
//  CoreDataManager.swift
//  Assignment
//
//  Created by Obulisudharson on 15/08/23.
//

import Foundation
import CoreData

let SYNC_TIME_THRESHOLD:TimeInterval = 172800

open class CoreDataManager: NSObject {

    // MARK: CoreData Stack
    @objc static let sharedManager: CoreDataManager = {
        let manager = CoreDataManager()
        manager.coreDataHelper = CoreDataHelper.init(name: "Assignment")
        manager.coreDataHelper?.loadStore(storeURL: manager.sourceStoreURL, completionHandler: {error in
            
        })
        return manager
    }()
    
    @objc public func isStoreLoaded()->Bool{
        return self.coreDataHelper?.isStoreLoaded ?? false
    }
    
    @objc static let mainStoreFileName = "AssignmentPersistenceStore.sqlite"
    @objc public static let managedObjectContext: NSManagedObjectContext = CoreDataManager.sharedManager.getManagedObjectContext()
    @objc public static let backgroundObjectContext: NSManagedObjectContext = CoreDataManager.sharedManager.getBackgroundContext()

    @objc var coreDataHelper: CoreDataHelper?

    /// The managed object model for the application.
    @objc lazy var managedObjectModel: NSManagedObjectModel = {
        /*
        This property is not optional. It is a fatal error for the application
        not to be able to find and load its model.
        */
        // let modelURL = NSBundle.mainBundle().URLForResource("ThinkandLearn", withExtension: "momd")!
        let modelURL = Bundle.main.url(forResource: "Assignment", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    /// Primary persistent store coordinator for the application.
    @objc lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        /*
        This implementation creates and return a coordinator, having added the
        store for the application to it. (The directory for the store is created, if necessary.)
        */
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        do {
            let options = [
                NSMigratePersistentStoresAutomaticallyOption: true,
                NSInferMappingModelAutomaticallyOption: true
            ]
            
            try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: self.sourceStoreURL, options: options)
        }
        catch {
            fatalError("Could not add the persistent store: \(error).")

        }
        
        return persistentStoreCoordinator
    }()
    
    
    /// The managed object context for the application.
    @objc func getManagedObjectContext() -> NSManagedObjectContext {
        /*
        This property is not optional. It is a fatal error for the application
        not to be able to find and load its model.
        */
        return (self.coreDataHelper?.viewContext)!
    }
    
    @objc func getBackgroundContext() -> NSManagedObjectContext {
        return (self.coreDataHelper?.bgContext)!
    }
    
    /// The directory the application uses to store the Core Data store file.
    @objc lazy var applicationsDocumentsDirectory: URL = {
        let fileManager = FileManager.default
        
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        
        let documentDirectoryURL = urls.last!
        
        return documentDirectoryURL
    }()
    
    /// URL for the main Core Data store file.
    @objc lazy var sourceStoreURL: URL = {
        print("store URL ==\(self.applicationsDocumentsDirectory.appendingPathComponent(CoreDataManager.mainStoreFileName))")
        return self.applicationsDocumentsDirectory.appendingPathComponent(CoreDataManager.mainStoreFileName)
    }()
    
    
    //MARK: Core data saving support
    
    @objc func saveContext(){
    
        let managedObjectContext = CoreDataManager.managedObjectContext
        if managedObjectContext.hasChanges{
            
            do{
                try managedObjectContext.save()
                
            }
            catch{
                
               // fatalError("failed to save context with error \(error)")
                //fatalError("failed to save context with error \(error)")
                
            }
            
        }

    }
    
    @objc func saveBgContext() {
        let managedObjectContext = CoreDataManager.backgroundObjectContext
        if managedObjectContext.hasChanges{
            
            do{
                try managedObjectContext.save()
                
            }
            catch{
                
                // fatalError("failed to save context with error \(error)")
                //fatalError("failed to save context with error \(error)")
                
            }
            
        }
    }
    
    func execute<T: NSManagedObject>(fetchRequest request: NSFetchRequest<T>, context: NSManagedObjectContext = CoreDataManager.managedObjectContext) -> [T]{
        
        var fetchedObjects = [T]()

        do {

            fetchedObjects = try context.fetch(request)

        } catch {
            print(error)
        }
        
        return fetchedObjects
    }
    
    
    
    //MARK: Utility methods
    
    @objc lazy var sourceStoreType: String = {
        
        return NSSQLiteStoreType;
   
        }() as String
    


    
}





@objc public extension NSManagedObject{

    static let defaultPredicateType: NSCompoundPredicate.LogicalType = .and

    @objc func save(){
    
        CoreDataManager.sharedManager.saveContext()
    }
    
    @objc class var defaultContext : NSManagedObjectContext{
    
        return CoreDataManager.managedObjectContext
        
    }
    
    @objc class var backgroundContext : NSManagedObjectContext {
        return CoreDataManager.backgroundObjectContext
    }
    
    @objc func backgroundSave() {
        CoreDataManager.sharedManager.saveBgContext()
    }
    
    /**
     This property **must return correct entity name** because it's used all across other helpers to reference custom `NSManagedObject` subclass.
     You may override this property in your custom `NSManagedObject` subclass if needed (but it should work out of the box generally).
     */
    @objc class var entityName: String {
        var name = NSStringFromClass(self)
        name = name.components(separatedBy: ".").last! //componentsSeparated(by: ".").last!
        return name
    }
    

    
    // MARK: Create
    
     /**
     Creates fetch request for any entity type with given predicate (optional) and sort descriptors (optional).
     
     - parameter predicate: Predicate for fetch request.
     - parameter sortDescriptors: Sort Descriptors for fetch request.
     
     - returns: The created fetch request.
     */
    @nonobjc class func createFetchRequest<T: NSManagedObject>(predicate: NSPredicate? = nil,
                                  sortDescriptors: [NSSortDescriptor]? = nil) -> NSFetchRequest<T> {
        
        let request = NSFetchRequest<T>(entityName: entityName)
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        return request
    }
    
    
    
    
    /**
     Creates predicate for given attributes and predicate type.
     
     - parameter attributes: Dictionary of attribute names and values.
     - parameter predicateType: If not specified, `.and` will be used.
     
     - returns: The created predicate.
     */
   @objc class func createPredicate(with attributes: [AnyHashable : Any],
                               predicateType: NSCompoundPredicate.LogicalType = defaultPredicateType) -> NSPredicate {
        
        var predicates = [NSPredicate]()
        for (attribute, value) in attributes {
            predicates.append(NSPredicate(format: "%K = %@", argumentArray: [attribute, value]))
        }
        let compoundPredicate = NSCompoundPredicate(type: predicateType, subpredicates: predicates)
        return compoundPredicate
    }
    
    
    /**
     Creates new instance of entity object.
     
     - parameter context: If not specified, CoreDataManager.managedObjectContext will be used.
     
     - returns: New instance of `Self`.
     */
    @objc @discardableResult class func create(in context: NSManagedObjectContext = CoreDataManager.managedObjectContext) -> Self {
        let entityDescription = NSEntityDescription.entity(forEntityName: entityName, in: context)!
        let object = self.init(entity: entityDescription, insertInto: context)
        return object
    }
    
    /**
     Creates new instance of entity object and configures it with given attributes.
     
     - parameter attributes: Dictionary of attribute names and values.
     - parameter context: If not specified, CoreDataManager.managedObjectContext will be used.
     
     - returns: New instance of `Self` with set attributes.
     */
    @objc @discardableResult class func create(with attributes: [String : Any],
                                         in context: NSManagedObjectContext = CoreDataManager.managedObjectContext) -> Self {
        
        let object = create(in: context)
        if attributes.count > 0 {
            object.setValuesForKeys(attributes)
        }
        return object
    }
    
  

    
    
    /**
     Finds the first record for given attribute and value or creates new if it does not exist.
     
     - parameter attribute: Attribute name.
     - parameter value: Attribute value.
     - parameter context: If not specified, CoreDataManager.managedObjectContext will be used.
     
     - returns: Instance of managed object.
     */
    @objc class func firstOrCreate(with attribute: String, value: Any,
                             in context: NSManagedObjectContext = CoreDataManager.managedObjectContext) -> Self {
        
        return _firstOrCreate(with: attribute, value: value, in: context)
    }
    
    /**
     Finds the first record for given attribute and value or creates new if it does not exist. Generic version.
     
     - parameter attribute: Attribute name.
     - parameter value: Attribute value.
     - parameter context: If not specified, CoreDataManager.managedObjectContext will be used.
     
     - returns: Instance of `Self`.
     */
    @nonobjc private class func _firstOrCreate<T>(with attribute: String, value: Any,
                                      in context: NSManagedObjectContext = CoreDataManager.managedObjectContext) -> T {
        
        let object = firstOrCreate(with: [attribute : value], in: context)
        return object as! T
    }
    
    /**
     Finds the first record for given attributes or creates new if it does not exist.
     
     - parameter attributes: Dictionary of attribute names and values.
     - parameter predicateType: If not specified, `.AndPredicateType` will be used.
     - parameter context: If not specified, CoreDataManager.managedObjectContext will be used.
     
     - returns: Instance of managed object.
     */
    @objc class func firstOrCreate(with attributes: [String : Any],
                             predicateType: NSCompoundPredicate.LogicalType = defaultPredicateType,
                             in context: NSManagedObjectContext = CoreDataManager.managedObjectContext) -> Self {
        
        return _firstOrCreate(with: attributes, predicateType: predicateType, in: context)
    }
    
    /**
     Finds the first record for given attributes or creates new if it does not exist. Generic version.
     
     - parameter attributes: Dictionary of attribute names and values.
     - parameter predicateType: If not specified, `.AndPredicateType` will be used.
     - parameter context: If not specified, CoreDataManager.managedObjectContext will be used.
     
     - returns: Instance of `Self`.
     */
    
    @nonobjc private class func _firstOrCreate<T>(with attributes: [String : Any],
                                      predicateType: NSCompoundPredicate.LogicalType = defaultPredicateType,
                                      in context: NSManagedObjectContext = CoreDataManager.managedObjectContext) -> T {
        
        let predicate = createPredicate(with: attributes, predicateType: predicateType)
        let request = createFetchRequest(predicate: predicate)
        request.fetchLimit = 1
        
        let objects = CoreDataManager.sharedManager.execute(fetchRequest: request, context: context)
        return (objects.first ?? create(with: attributes, in: context)) as! T
    }
    
    
    // MARK: - Delete
     /*
      Methods can be added for following scenarios
        1. Deleting an instance
        2. Delete all records
        3. Delete all records for a given predicate
        4. Deletes all records for given attributes.
      */

    
    
    // MARK: - Find All
    
    /**
     Finds all records.
     
     - parameter sortDescriptors: Sort descriptors.
     - parameter context: If not specified, CoreDataManager.managedObjectContext will be used.
     
     - returns: Optional managed object.
     */
    @objc class func all(orderedBy sortDescriptors: [NSSortDescriptor]? = nil,
                   in context: NSManagedObjectContext = CoreDataManager.managedObjectContext) -> [NSManagedObject]? {
        
        let request = createFetchRequest(sortDescriptors: sortDescriptors)
        let objects = CoreDataManager.sharedManager.execute(fetchRequest: request, context: context)
        return objects.count > 0 ? objects : nil
    }
    
    @objc class func allBg(orderedBy sortDescriptors: [NSSortDescriptor]? = nil,
                         in context: NSManagedObjectContext = CoreDataManager.backgroundObjectContext) -> [NSManagedObject]? {
        
        let request = createFetchRequest(sortDescriptors: sortDescriptors)
        let objects = CoreDataManager.sharedManager.execute(fetchRequest: request, context: context)
        return objects.count > 0 ? objects : nil
    }
    
    
    /**
     Finds all records for given predicate.
     
     - parameter predicate: Predicate.
     - parameter sortDescriptors: Sort descriptors.
     - parameter context: If not specified, CoreDataManager.managedObjectContext will be used.
     
     - returns: Optional managed object.
     */
    @objc class func all(with predicate: NSPredicate, orderedBy sortDescriptors: [NSSortDescriptor]? = nil,
                   in context: NSManagedObjectContext = CoreDataManager.managedObjectContext) -> [NSManagedObject]? {
        
        let request = createFetchRequest(predicate: predicate, sortDescriptors: sortDescriptors)
        let objects = CoreDataManager.sharedManager.execute(fetchRequest: request, context: context)
        return objects.count > 0 ? objects : nil
    }
    
    @objc class func allBg(with predicate: NSPredicate, orderedBy sortDescriptors: [NSSortDescriptor]? = nil,
                         in context: NSManagedObjectContext = CoreDataManager.backgroundObjectContext) -> [NSManagedObject]? {
        
        let request = createFetchRequest(predicate: predicate, sortDescriptors: sortDescriptors)
        let objects = CoreDataManager.sharedManager.execute(fetchRequest: request, context: context)
        return objects.count > 0 ? objects : nil
    }
    
    /**
     Finds all records for given attribute and value.
     
     - parameter attribute: Attribute name.
     - parameter value: Attribute value.
     - parameter sortDescriptors: Sort descriptors.
     - parameter context: If not specified, CoreDataManager.managedObjectContext will be used.
     
     - returns: Optional managed object.
     */
    @objc class func all(with attribute: String, value: Any, orderedBy sortDescriptors: [NSSortDescriptor]? = nil,
                   in context: NSManagedObjectContext = CoreDataManager.managedObjectContext) -> [NSManagedObject]? {
        
        let predicate = NSPredicate(format: "%K = %@", argumentArray: [attribute, value])
        return all(with: predicate, orderedBy: sortDescriptors, in: context)
    }
    
    /**
     Finds all records for given attributes.
     
     - parameter attributes: Dictionary of attribute names and values.
     - parameter predicateType: If not specified, `.AndPredicateType` will be used.
     - parameter sortDescriptors: Sort descriptors.
     - parameter context: If not specified, CoreDataManager.managedObjectContext will be used.
     
     - returns: Optional managed object.
     */
    @objc class func all(with attributes: [AnyHashable : Any],
                   predicateType: NSCompoundPredicate.LogicalType = defaultPredicateType,
                   orderedBy sortDescriptors: [NSSortDescriptor]? = nil,
                   in context: NSManagedObjectContext = CoreDataManager.managedObjectContext) -> [NSManagedObject]? {
        
        let predicate = createPredicate(with: attributes, predicateType: predicateType)
        return all(with: predicate, orderedBy: sortDescriptors, in: context)
    }
    
    @objc class func allBg(with attributes: [AnyHashable : Any],
                         predicateType: NSCompoundPredicate.LogicalType = defaultPredicateType,
                         orderedBy sortDescriptors: [NSSortDescriptor]? = nil,
                         in context: NSManagedObjectContext = CoreDataManager.backgroundObjectContext) -> [NSManagedObject]? {
        
        let predicate = createPredicate(with: attributes, predicateType: predicateType)
        return allBg(with: predicate, orderedBy: sortDescriptors, in: context)
    }
    
    /**
     
     Same can be added for Generic
     */
    
    
    // MARK: - Count
    /*
     Methods to get the record count can be added
     */

    
    // MARK: - Distinct
    /*
     Methods to get distinct values for given attribute and predicate can be added
     */
     
    
    // MARK: - Find First
    
    /*
     Methods to get first record based on the attributes, sort descriptors and predicate can be added
     */
    
    

    
}
