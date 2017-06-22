//
//  Person+CoreDataClass.swift
//  P5_whatShouldIStream
//
//  Created by Michael Harper on 6/4/17.
//  Copyright © 2017 MJH. All rights reserved.
//

import Foundation
import CoreData
import UIKit


public class Person: NSManagedObject {

    struct Keys {
        static let name = "name"
        static let profilePath = "profile_path"
        static let movies = "movies"
        static let id = "id"
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
