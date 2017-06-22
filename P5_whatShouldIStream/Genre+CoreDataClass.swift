//
//  Genre+CoreDataClass.swift
//  P5_whatShouldIStream
//
//  Created by Michael Harper on 6/4/17.
//  Copyright © 2017 MJH. All rights reserved.
//

import Foundation
import CoreData


public class Genre: NSManagedObject {
    
    struct keys {
        static let id = "id"
        static let name = "name"
    }
    
    
    class func createGenreFrom(dictionary: [String: Any], context: NSManagedObjectContext) -> Genre
    {
        let genre = Genre(context: context)
        genre.id = dictionary[keys.id] as? NSNumber
        genre.name = dictionary[keys.name] as? String
        return genre
        
    }
    
    class func createGenreFrom(id: Int, name: String, context: NSManagedObjectContext) -> Genre {
        
        let genre = Genre(context: context)
        genre.id = NSNumber(value: id)
        genre.name = name
        return genre
        
    }
    
    
    // Assign movies to genres / movies to genres
    func genreFromMovies( _ movies: [Movie] ) {
        for movie in movies {
            for genre in movie.genreArray {
                if let genre = Genre.fetchGenreWithId(genre) {
                    //genre.movies?.addObject(movies)
                    genre.addToMovies(movie)
                }
            } // genre in movie
        } // movie in movies
    }
    
    
    // retrieve genre
    class func fetchGenreWithId(_ id: NSNumber) -> Genre? {
        
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
            genres.add( Genre.createGenreFrom(id: key, name: value, context: context!) )
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
        
        let request: NSFetchRequest<Genre> = Genre.fetchRequest()
        request.predicate = NSPredicate(format: "id = %@", id)
        
        if let genre = (try? context.fetch(request))?.first {
            return genre
        } else {
            
            let genre = Genre.createGenreFrom(dictionary: dictionary, context: context)
            return genre
        }
    }
    
    class func jsonGenreToCoreData(_ json: Data?) {
        guard let data = json else
        {
            log.error("Json not valid NSData")
            return
        }
        
        // interate Movie Genre data and add to core data
        let jsonData = CoreNetwork.parseJSON(data)
        if jsonData != nil {
            guard let results = jsonData?["genres"] as? [[String:AnyObject]] else {
                log.error("error converting json results to [[string:anyobjec]]")
                return
            }
            
            context.performAndWait() {
                for genre in results {
                    let g = Genre.genreFromDictionary(genre, inManagedObjectContext: context )
                    //coreDataStack.saveContext()
                }
                coreDataStack.saveContext()
            }
        }
    }
    
}
