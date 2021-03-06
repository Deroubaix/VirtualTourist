//
//  DataController.swift
//  VirtualTourist
//
//  Created by Marisha Deroubaix on 12/11/18.
//  Copyright © 2018 Marisha Deroubaix. All rights reserved.
//

import Foundation
import CoreData

struct DataController {
  
  let objectModel: NSManagedObjectModel
  let persistentStoreCoordinator: NSPersistentStoreCoordinator
  let modelURL: URL
  let dbURL: URL
  let objectContext: NSManagedObjectContext
  let backgroundContext: NSManagedObjectContext
  let context: NSManagedObjectContext
  
  static let shared = DataController(modelName: "VirtualTourist")!
  
  init?(modelName: String) {
    guard let modelURL = Bundle.main.url(forResource: modelName, withExtension: "momd") else {
      print("Unable to find \(modelName) in main bundle")
      return nil
    }
    self.modelURL = modelURL
    
    guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
      print("Unable to create a model from \(modelURL)")
      return nil
    }
    self.objectModel = model
    
    persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
    
    objectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    objectContext.persistentStoreCoordinator = persistentStoreCoordinator
    context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    context.parent = objectContext
    backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    backgroundContext.parent = context
    
    let file = FileManager.default
    
    guard let docURL = file.urls(for: .documentDirectory, in: .userDomainMask).first else {
      print("Unable to reach the documents folder")
      return nil
    }
    self.dbURL = docURL.appendingPathComponent("model.sqlite")
    
    let options = [NSInferMappingModelAutomaticallyOption: true, NSMigratePersistentStoresAutomaticallyOption: true]
    
    do {
      try addStoreCoordinator(NSSQLiteStoreType, configuration: nil, storeURL: dbURL, options: options as [NSObject: AnyObject]?)
      print("Store successfully moved")
    } catch {
      print("Unable to add store at \(dbURL)")
    }
  }
  
  func addStoreCoordinator(_ storeType: String, configuration: String?, storeURL: URL, options: [AnyHashable: Any]?) throws {
    try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: dbURL, options: nil)
  }
  
  func dropAllData() throws {
    
    try persistentStoreCoordinator.destroyPersistentStore(at: dbURL, ofType: NSSQLiteStoreType, options: nil)
    
    try addStoreCoordinator(NSSQLiteStoreType, configuration: nil, storeURL: dbURL, options: nil)
  }
  
  typealias Batch = (_ workerContext: NSManagedObjectContext) -> ()
  
  func performBackgroundBathOperation(_ batch: @escaping Batch) {
    backgroundContext.perform {
      batch(self.backgroundContext)
      
      do {
        try self.backgroundContext.save()
      } catch {
        fatalError("Error saving backgroundContext: \(error.localizedDescription)")
      }
    }
  }
  
  // MARK: - Core Data Saving
  
  func save() {
    context.performAndWait {
      if self.context.hasChanges {
        do {
          try self.context.save()
        } catch {
          fatalError("Error while saving main context: \(error)")
        }
        self.objectContext.perform {
          do {
            try self.objectContext.save()
          } catch {
            fatalError("Error saving context: \(error)")
          }
        }
      }
    }
  }
  
  func autoSave(_ delayInSeconds: Int) {
    
    if delayInSeconds > 0 {
      print("Autosaving")
      save()
      
      let delayInNanoSeconds = UInt64(delayInSeconds) * NSEC_PER_SEC
      let time = DispatchTime.now() + Double(Int64(delayInNanoSeconds)) / Double(NSEC_PER_SEC)
      DispatchQueue.main.asyncAfter(deadline: time) {
        self.autoSave(delayInSeconds)
      }
      
    }
  }
}

