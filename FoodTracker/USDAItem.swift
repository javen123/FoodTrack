//
//  USDAItem.swift
//  FoodTracker
//
//  Created by user on 1/6/15.
//  Copyright (c) 2015 Neva. All rights reserved.
//

import Foundation
import CoreData
@objc(USDAItem)
class USDAItem: NSManagedObject {

    @NSManaged var calcium: String
    @NSManaged var carbohydrates: String
    @NSManaged var cholesterol: String
    @NSManaged var dateAdded: NSDate
    @NSManaged var energy: String
    @NSManaged var fatTotal: String
    @NSManaged var idValue: String
    @NSManaged var name: String
    @NSManaged var protein: String
    @NSManaged var sugar: String
    @NSManaged var vitaminC: String

}
