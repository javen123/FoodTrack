//
//  DataController.swift
//  FoodTracker
//
//  Created by user on 12/15/14.
//  Copyright (c) 2014 Neva. All rights reserved.
//

import Foundation
import UIkit
import CoreData

class DataController {
    
    class func jsonAsUSDAIdAndSearchResults (json:NSDictionary) -> [(name: String, idValue:String)] {
        
        var usdaItemsSearchResults:[(name: String, idValue:String)] = []
        var searchResult: (name:String, idValue:String)
        
        if json["hits"] != nil {
            let results:[AnyObject] = json["hits"]! as [AnyObject]
            
            for itemDictionary in results {
                if itemDictionary["_id"] != nil {
                    if itemDictionary["fields"] != nil {
                        let fieldsDictionary = itemDictionary["fields"] as NSDictionary
                        if fieldsDictionary["item_name"] != nil {
                            let idValue:String = itemDictionary["_id"]! as String
                            let name:String = fieldsDictionary["item_name"]! as String
                            searchResult = (name: name, idValue:idValue)
                            usdaItemsSearchResults = [searchResult]
                        }
                    }
                }
            }
        }
        return usdaItemsSearchResults
    }
}