//
//  Movie+CoreDataClass.swift
//  P5_whatShouldIStream
//
//  Created by Michael Harper on 11/30/16.
//  Copyright © 2016 MJH. All rights reserved.
//

import Foundation
import CoreData
import UIKit


open class Movie: NSManagedObject {
    
    open static let entityName = "Movie"
    
    struct Keys {
        static let title = "title"
        static let posterPath = "poster_path"
        static let releaseDate = "release_date"
        static let listId = "list"
        static let overview = "overview"
        static let voteAverage = "vote_average"
        static let service = "service"
        static let id = "id"
        static let genresId = "genre_ids"
        static let watchlist = "watchlist"
        static let movie = "movie"
        static let tv = "tv"
    }
    
    // hold array of genres until they can be mapped
    // into coredata
    var genreArray: [NSNumber] = [NSNumber]()
    
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(dictionary: [String : Any], context: NSManagedObjectContext) {
        
        // Core Data
        if let entity =  NSEntityDescription.entity(forEntityName: "Movie", in: context) {
            super.init(entity: entity, insertInto: context)
            
            // Dictionary
            title = dictionary[Keys.title] as? String
            id = dictionary[Keys.id] as? NSNumber
            posterPath = dictionary[Keys.posterPath] as? String
            voteAverage = dictionary[Keys.voteAverage] as? NSNumber
            overview = dictionary[Keys.overview] as? String
            onWatchlist = dictionary[Keys.watchlist] as? NSNumber
            service = dictionary[Keys.service] as? String
            
            
            
            if let array = dictionary[Keys.genresId] as? [NSNumber] {
                genreArray = array
                print("genre \(String(describing: genres))")
            }
            
            if let dateString = dictionary[Keys.releaseDate] as? String {
                if let date = Date.sharedDateFormatter.date(from: dateString) {
                    releaseDate = date
                }
            }
            
            
        } else {
            fatalError("could not find movie")
        }
        
    }
    
    
    var posterImage: UIImage? {
        
        get {
            return TheMovieDB.Caches.imageCache.imageWithIdentifier(posterPath)
        }
        
        set {
            TheMovieDB.Caches.imageCache.storeImage(newValue, withIdentifier: posterPath!)
        }
    }
    
    var largelPosterImage: UIImage? {
        get {
            if var path = posterPath {
                let xxl = "XXL"
                path = xxl + path
                return TheMovieDB.Caches.imageCache.imageWithIdentifier(path)
            }
            
            return nil
        }
        
        set {
            
            if var path = posterPath {
                let xxl = "XXL"
                path = xxl + path
                TheMovieDB.Caches.imageCache.storeImage(newValue, withIdentifier: path )
                print(path)
            }
            
        }
    }
    
    
    class func movieFromDictionary(_ dictionary: [String: Any], inManagedObjectContext context: NSManagedObjectContext ) -> Movie? {
        
            guard let id = dictionary[Keys.id] as? NSNumber else {
            log.error("Could not get list id")
            return nil
        }
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Movie.entityName)
        request.predicate = NSPredicate(format: "id == %@", id)
        
        if let movie = (try? context.fetch(request))?.first as? Movie {
            return movie
        } else {
            let movie = Movie(dictionary: dictionary, context: context) //NSEntityDescription.insertNewObjectForEntityForName(entityName, inManagedObjectContext: context) as? Movie {
            
            return movie
        }
        
    }
    
    
    /* Helper: Given an array of dictionaries, convert them to an array of TMDBMovie objects */
    class func moviesFromResults(_ results: [[String : Any]], listID: String, context: NSManagedObjectContext?) -> [Movie]
    {
        var movies = [Movie]()
        for result in results {
            
            if let movie = Movie.movieFromDictionary(result, inManagedObjectContext: context!) {
                 movies.append(movie)
            }
        }
        return movies
    }
    
    
    override open func prepareForDeletion() {
        
        guard let path = posterPath else {
            print("prepare for deletion has failed")
            return
        }
        
        // Delete image
        TheMovieDB.Caches.imageCache.storeImage(nil, withIdentifier: path)
    }
    

}
