//
//  Person+CoreDataClass.swift
//  P5_whatShouldIStream
//
//  Created by Michael Harper on 11/30/16.
//  Copyright © 2016 MJH. All rights reserved.
//

import Foundation
import CoreData
import UIKit


open class Person: NSManagedObject {

   open static let entityName = "Person"
    
    struct Keys {
        static let name = "name"
        static let profilePath = "profile_path"
        static let movies = "movies"
        static let id = "id"
    }
    
    // 4. Include this standard Core Data init method.
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        let entity =  NSEntityDescription.entity(forEntityName: "Person", in: context)!
        
        super.init(entity: entity,insertInto: context)
        
        name = dictionary[Keys.name] as! String
        id = dictionary[Keys.id] as! Int as NSNumber
        imagePath = dictionary[Keys.profilePath] as? String
    }
    
    var image: UIImage? {
        get {
            return TheMovieDB.Caches.imageCache.imageWithIdentifier(imagePath)
        }
        
        set {
            TheMovieDB.Caches.imageCache.storeImage(image, withIdentifier: imagePath!)
        }
    }

}
