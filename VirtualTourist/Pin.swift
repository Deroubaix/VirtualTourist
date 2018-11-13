//
//  Pin.swift
//  VirtualTourist
//
//  Created by Marisha Deroubaix on 13/11/18.
//  Copyright © 2018 Marisha Deroubaix. All rights reserved.
//

import Foundation
import CoreData

class Pin: NSManagedObject {
  
  @NSManaged var latitude: NSNumber?
  @NSManaged var longitude: NSNumber?
  @NSManaged var photo: NSSet?
  @NSManaged var pages: NSNumber?
  
  convenience init(latitude: Double, longitude: Double, context: NSManagedObjectContext) {
    
    if let entity = NSEntityDescription.entity(forEntityName: "Pin", in: context) {
      self.init(entity: entity, insertInto: context)
      self.latitude = latitude as NSNumber?
      self.longitude = longitude as NSNumber?
    } else {
      fatalError("Unable to find entity name ")
    }
  }
}
