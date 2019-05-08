//
//  CoreDataManager.swift
//  CoreDataStack
//
//  Created by Varun Rathi on 08/05/19.
//  Copyright © 2019 Varun Rathi. All rights reserved.
//

import Foundation
import CoreData

typealias CoreDataManagerCompletion = () -> ()



/*

============= Core Data Stack=====================

  MainManagedObjectContext (Child Context)
            |
   PrivateManagedObjectContext (Parent Context)
            |
   PersistantStoreCoordinator
            |
   PersistantStore

*/

public class CoreDataManager {


    
    public let modelName:String?
    private let completion:CoreDataManagerCompletion

    private lazy var managedObjectModel :NSManagedObjectModel = {
        guard let modelURL = Bundle.main.url(forResource:self.modelName, withExtension:"momd") else {
            fatalError("Unable to find Data Model")
        }
        guard let managedModel = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Unable to load model")
        }
        return managedModel
    }()
    
    private lazy var persistantStoreCoordinator : NSPersistentStoreCoordinator = {
        
        return NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
//        let persistantCord = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
//
//        let fileManager = FileManager.default
//        let storeName = self.modelName!+".sqlite"
//        let documentDirectoryPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
//        let persistantStoreCoordinatorPath = documentDirectoryPath.appendingPathComponent(storeName)
//        do {
//
//            let options = [NSMigratePersistentStoresAutomaticallyOption : true,
//                           NSInferMappingModelAutomaticallyOption : true]
//
//            try persistantCord.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: persistantStoreCoordinatorPath, options: options)
//
//
//        } catch {
//            fatalError("fatal error")
//        }
//        return persistantCord
    }()
    
    
    
   public private(set) lazy var privateManagedObjectContext:NSManagedObjectContext = {
        let managedContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        managedContext.persistentStoreCoordinator = self.persistantStoreCoordinator
        return managedContext
        
    }()
    
    
    public private(set) lazy var mainManagedObjectContext:NSManagedObjectContext = {
        
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.parent = self.privateManagedObjectContext
        return managedObjectContext
    }()
    
    
   public func privateChildManagedObjectContext()->NSManagedObjectContext {
   
    let managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    managedObjectContext.parent = self.mainManagedObjectContext
   return managedObjectContext
    }
   
    
    public func save() {
        
        mainManagedObjectContext.performAndWait {
            
            do {
                
                if self.mainManagedObjectContext.hasChanges {
                    try self.mainManagedObjectContext.save()
                }
                
            } catch {
                fatalError("Main Context Failed to Save")
            }
        }
        
        privateManagedObjectContext.perform {
            do {
                if self.privateManagedObjectContext.hasChanges {
                    try self.privateManagedObjectContext.save()
                }
                
                
            } catch {
                fatalError("private Context Failed to Save")
            }
        }
    }
    
    func setUpCoreDataStack(){
        
        guard let storeCoordinator = mainManagedObjectContext.persistentStoreCoordinator else {
            fatalError("Erorr in fetching store coordinator")
        }
        
        DispatchQueue.global().async {
            
           self.addPersistentStore(to: storeCoordinator)
            
            DispatchQueue.main.async {
                self.completion()
            }
            
        }
        
    }
    
    
    
    func addPersistentStore(to persistantStoreCoordinator:NSPersistentStoreCoordinator) {
        
        let fileManager = FileManager.default
        let storeName = self.modelName!+".sqlite"
        let documentDirectoryPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let persistantStoreCoordinatorPath = documentDirectoryPath.appendingPathComponent(storeName)
        do {
            
            let options = [NSMigratePersistentStoresAutomaticallyOption : true,
                           NSInferMappingModelAutomaticallyOption : true]
            
            try persistantStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: persistantStoreCoordinatorPath, options: options)
            
            
        } catch {
            fatalError("fatal error")
        }
        
    }
    
    
    init(modelName:String,completionBlock:@escaping CoreDataManagerCompletion) {
        self.modelName = modelName
        self.completion = completionBlock
        
        setUpCoreDataStack()
        
    }

}
