//
//  Genre+CoreDataClass.swift
//  P5_whatShouldIStream
//
//  Created by Michael Harper on 11/30/16.
//  Copyright © 2016 MJH. All rights reserved.
//

import Foundation
import CoreData


open class Genre: NSManagedObject {
    
    open static let entityName = "Genre"
    
    override open var description: String {
        return "Genre \(id)"
    }
    
    struct keys {
        static let id = "id"
        static let name = "name"
    }
    
     
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(dictionary: [String : Any], context: NSManagedObjectContext) {
        
        // Core Data
        let entity =  NSEntityDescription.entity(forEntityName: "Genre", in: context)!
        super.init(entity: entity, insertInto: context)
        
        // Dictionary
        id = dictionary[keys.id] as? NSNumber
        name = dictionary[keys.name] as? String
        
        
    }
    
    init(id: Int, name: String, context: NSManagedObjectContext) {
        
        // Core Data
        let entity =  NSEntityDescription.entity(forEntityName: "Genre", in: context)!
        super.init(entity: entity, insertInto: context)
        
        // Dictionary
        self.id = id as NSNumber
        self.name = name
    }
    
    // Assign movies to genres / movies to genres
    func genreFromMovies( _ movies: [Movie] ) {
        for movie in movies {
            for genre in movie.genreArray {
                if let genre = fetchGenreWithId(genre) {
                    //genre.movies?.addObject(movies)
                    genre.addToMovies(movie)
                }
                
            } // genre in movie
        } // movie in movies
    }
    
    
    // retrieve genre
    func fetchGenreWithId(_ id: NSNumber) -> Genre? {
        
        var genre: Genre? = nil
        
        let predicate = NSPredicate(format: "id == %@", id)
        let fetchRequest: NSFetchRequest<Genre> = Genre.fetchRequest()
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = predicate
        
        var results: [AnyObject]?
        do {
            results = try context.fetch(fetchRequest)
        } catch _ {
            
        } // end catch
        
        genre = results?[0] as? Genre
        return genre
    }
    
    class func genreFromResults(_ results: [Int : String],  context: NSManagedObjectContext?) -> NSMutableOrderedSet {
        
        let genres = NSMutableOrderedSet()
        
        for (key,value) in results {
            genres.add( Genre(id: key, name: value, context: context!) )
        }
        
        return genres
    }
    
    class func genreFromDictionary(_ dictionary: [String: Any], inManagedObjectContext context: NSManagedObjectContext ) -> Genre? {
        
        // Dictionary
        guard let id = dictionary[keys.id] as? NSNumber,
            let _ = dictionary[keys.name] as? String else {
                log.error("could not find id or name in dictionary")
                return nil
        }
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Genre.entityName)
        request.predicate = NSPredicate(format: "id = %@", id)
        
        if let genre = (try? context.fetch(request))?.first as? Genre {
            return genre
        } else {
            
            let genre = Genre(dictionary: dictionary, context: context)
            return genre
        }
    }


}
