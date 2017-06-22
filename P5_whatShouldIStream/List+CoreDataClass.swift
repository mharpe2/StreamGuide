//
//  List+CoreDataClass.swift
//  P5_whatShouldIStream
//
//  Created by Michael Harper on 6/4/17.
//  Copyright © 2017 MJH. All rights reserved.
//

import Foundation
import CoreData


public class List: NSManagedObject {
    
    struct keys {
        static let date = "date"
        static let id = "id"
        static let name = "name"
        static let type = "type"
        static let service = "service"
        static let index = "index"
        static let group = "group"
    }

    
    
    class func createFrom(dictionary: [String: Any], context: NSManagedObjectContext) -> List {
        let list = List()
        
        list.id = dictionary[keys.id] as? String
        list.name = dictionary[keys.name] as? String
        list.type = dictionary[keys.type] as? String
        list.index = dictionary[keys.index] as? NSNumber
        list.group = dictionary[keys.group] as? String
        
        return list

    }

    
    class func listsFromResults(_ results: [[String : Any]], context: NSManagedObjectContext?) -> NSMutableOrderedSet {
        
        let lists = NSMutableOrderedSet()
        log.info("Creating Lists")
        
        for var result in results {
            
            // prevent list duplicates
            if let listId = result[List.keys.id] as? String {
                let predicate = NSPredicate(format: "id == %@", listId)
                let fetchRequest: NSFetchRequest<List> = List.fetchRequest()
                fetchRequest.fetchLimit = 1
                fetchRequest.predicate = predicate
                
                do {
                    let foundIt = try context?.fetch(fetchRequest)
                    if foundIt?.count == 0 {
                        lists.add( List.createFrom(dictionary: result, context: context!) )
                    }
                }
                catch _ {
                }
            }
        }
        
        log.info("added \(lists.count) lists" )
        return lists
    }
    
    // Helper: get all lists
    class func fetchLists(inManagedObjectContext context: NSManagedObjectContext ) -> [List] {
        let error: NSError? = nil
        
        var results: [Any]?
        
        let fetchRequest: NSFetchRequest<List>  = List.fetchRequest() //NSFetchRequest<NSFetchRequestResult>(entityName: List.entityName)
        do {
            results = try context.fetch(fetchRequest)
        } catch error! as NSError {
            results = nil
        } catch _ {
            results = nil
        }
        
        if error != nil {
            log.error("Could not fetch lists: \(String(describing: error?.localizedDescription))" )
        }
        
        return results as! [List]
        
    }


}
