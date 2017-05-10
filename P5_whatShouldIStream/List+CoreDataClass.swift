//
//  List+CoreDataClass.swift
//  P5_whatShouldIStream
//
//  Created by Michael Harper on 11/30/16.
//  Copyright © 2016 MJH. All rights reserved.
//

import Foundation
import CoreData


open class List: NSManagedObject {

    open static let entityName = "List"
    
    override open var description: String {
        return "Listid \(id), Name \(name), Date \(date)"
    }
    
    struct keys {
        static let date = "date"
        static let id = "id"
        static let name = "name"
        static let type = "type"
        static let service = "service"
        static let index = "index"
        static let group = "group"
        
        static let list = entityName
        
    }
    
      
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        // Core Data
        if let entity =  NSEntityDescription.entity(forEntityName: "List", in: context) {
            
            super.init(entity: entity, insertInto: context)
            // Dictionary
            self.id = dictionary[keys.id] as? String
            self.name = dictionary[keys.name] as? String
            self.type = dictionary[keys.type] as? String
            self.index = dictionary[keys.index] as? NSNumber
            self.group = dictionary[keys.group] as? String
            
            if let dateStr = dictionary[keys.date] as? String { // extract date
                date = Date.sharedDateFormatter.date(from: dateStr)
                if date == nil {
                    date = Date()
                    log.verbose("Could not get date of list: \(self.description)")
                }
            }
            
            self.movies = NSMutableOrderedSet()
            
        } else {
            fatalError("could not find entity List")
        }
    }
    
    func downloadMovies() -> Int {
        
        //self.managedObjectContext
        self.managedObjectContext!.performAndWait() {
            TheMovieDB.sharedInstance().getMoviesFromList(self) {
                result, error in
                if error != nil {
                    log.error("Could not download movies on list")
                    return
                }
                else {
                    
                    if let movieResults  = result {
                        
                        for movie in movieResults {
                            // strip optional from movieFromDictionary
                            if let myMovie = Movie.movieFromDictionary(movie as [String : AnyObject], inManagedObjectContext: self.managedObjectContext!) {
                                myMovie.list = self
                                log.info("added \(myMovie.title)")
                            }
                        }
                        coreDataStack.saveContext()
                        log.info("\(self.movies!.count) TOTAL movies added)")
                        
                    }
                    //}
                } // End of else
            } // End of getMoviesFromList
            // } // End if list movie count == 0
            coreDataStack.saveContext()
        }
        
        return movies!.count
    }
    
    
    class func ListFromDictionary(_ dictionary: [String: AnyObject], inManagedObjectContext context: NSManagedObjectContext ) -> List? {
        
        //let log = XCGLogger.defaultInstance()
        
        // Dictionary
        guard let id = dictionary[keys.id] as? String else {
            log.error("Could not get list id")
            return nil
        }
        
        guard let newListDate = dateFromDictionary(dictionary) else {
            log.error("could not parse data from list json with id \(id)")
            return nil
        }
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: List.entityName)
        request.predicate = NSPredicate(format: "id = %@", id)
        
        if let list = (try? context.fetch(request))?.first as? List {
            
            // check if the new list is some how older or the same
            // return the existingObjet
            if let existingListDate = list.date {
                if newListDate.isLessThanDate(existingListDate) ||
                    (newListDate == existingListDate)
                {
                    return list
                }
                    // if newListDate is the same date as the existing list
                    // then the existing list is deleted and a new list is created
                else {
                    
                    context.delete(list)
                    let list = List(dictionary: dictionary, context: context)
                    return list
                }
            }
        }
        else {
            let list = List(dictionary: dictionary, context: context)
            return list
        }
        return nil
    }
    
    
    class func dateFromDictionary(_ dictionary: [String:AnyObject]   ) -> Date? {
        
        var thisDate: Date?
        if let dateStr = dictionary[keys.date] as? String { // extract date
            thisDate = Date.sharedDateFormatter.date(from: dateStr)!
            //            if thisDate == nil {
            //                thisDate = NSDate()
            //            }
        }
        return thisDate!
    }
    
    /* Helper: Given an array of dictionaries, convert them to an array of List objects */
    class func listsFromResults(_ results: [[String : AnyObject]], context: NSManagedObjectContext?) -> NSMutableOrderedSet {
        
        let lists = NSMutableOrderedSet()
        //let log = XCGLogger.defaultInstance()
        log.info("Creating Lists")
        
        for var result in results {
            
            // prevent list duplicates
            if let listId = result[List.keys.id] as? String {
                let predicate = NSPredicate(format: "id == %@", listId)
                let fetchRequest: NSFetchRequest<List> = List.fetchRequest()
                fetchRequest.fetchLimit = 1
                fetchRequest.predicate = predicate
                
                do {
                    let foundIt = try context?.fetch(fetchRequest)//List.findFirstInContext(context!, predicate: predicate)
                    if foundIt == nil {
                        lists.add( List(dictionary: result, context: context!) )
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
    static func fetchLists(inManagedObjectContext context: NSManagedObjectContext ) -> [List] {
        let error: NSError? = nil
        
        var results: [AnyObject]?
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: List.entityName)
        do {
            results = try context.fetch(fetchRequest)
        } catch error! as NSError {
            results = nil
        } catch _ {
            results = nil
        }
        
        if error != nil {
          log.error("Could not fetch lists: \(error?.localizedDescription)" )
        }
        
        return results as! [List]
        
    }

}
