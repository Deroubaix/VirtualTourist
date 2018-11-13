//
//  Photos.swift
//  VirtualTourist
//
//  Created by Marisha Deroubaix on 13/11/18.
//  Copyright © 2018 Marisha Deroubaix. All rights reserved.
//

import Foundation
import CoreData

class Photos: NSManagedObject {
  
  @NSManaged var image: Data?
  @NSManaged var imageURL: String?
  @NSManaged var pin: Pin?
  
  convenience init(image: Data, context: NSManagedObjectContext) {
    
    if let entity = NSEntityDescription.entity(forEntityName: "Photos", in: context) {
      self.init(entity: entity, insertInto: context)
      self.image = image
    } else {
      fatalError("Unable to find entity name")
    }
  }
  
}
