//
//  Movie.swift
//  TheMovieDB
//
//  Created by Jason on 1/11/15.
//

import UIKit
import CoreData
//import BNRCoreDataStack

class Movie : NSManagedObject, CoreDataModelable {
    
    static let entityName = "Movie"
    
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
    
    @NSManaged var title: String?
    @NSManaged var id: NSNumber?
    @NSManaged var guideBoxId: NSNumber?
    @NSManaged var list: List //relationship
    @NSManaged var posterPath: String?
    @NSManaged var releaseDate: NSDate?
    @NSManaged var actor: Person?
    @NSManaged var voteAverage: NSNumber?
    @NSManaged var overview: String?
    @NSManaged var service: String?
    @NSManaged var genres: NSMutableSet? // relationship
    @NSManaged var onWatchlist: NSNumber?
    @NSManaged var type: String? // movie or tv show
    
    
    // hold array of genres until they can be mapped
    // into coredata
    var genreArray: [NSNumber] = [NSNumber]()
    
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        
        // Core Data
        if let entity =  NSEntityDescription.entityForName("Movie", inManagedObjectContext: context) {
            super.init(entity: entity, insertIntoManagedObjectContext: context)
            
            // Dictionary
            title = dictionary[Keys.title] as? String
            id = dictionary[Keys.id] as? Int
            posterPath = dictionary[Keys.posterPath] as? String
            voteAverage = dictionary[Keys.voteAverage] as? NSNumber
            overview = dictionary[Keys.overview] as? String
            onWatchlist = dictionary[Keys.watchlist] as? NSNumber
            service = dictionary[Keys.service] as? String
            
            
            
            if let array = dictionary[Keys.genresId] as? [NSNumber] {
                genreArray = array
                print("genre \(genres)")
            }
            
            if let dateString = dictionary[Keys.releaseDate] as? String {
                if let date = TheMovieDB.sharedDateFormatter.dateFromString(dateString) {
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
                var xxl = "XXL"
                path = xxl.stringByAppendingString(path)
                return TheMovieDB.Caches.imageCache.imageWithIdentifier(path)
                print(path)
            }
            
            return nil
        }
        
        set {
            
            if var path = posterPath {
                var xxl = "XXL"
                path = xxl.stringByAppendingString(path)
                TheMovieDB.Caches.imageCache.storeImage(newValue, withIdentifier: path )
                print(path)
            }
            
        }
    }
    
    
    class func movieFromDictionary(dictionary: [String: AnyObject], inManagedObjectContext context: NSManagedObjectContext ) -> Movie? {
        
        let log = XCGLogger.defaultInstance()
        // Dictionary
        guard let id = dictionary[Keys.id] as? NSNumber else {
            log.error("Could not get list id")
            return nil
        }
        
        
        let request = NSFetchRequest(entityName: Movie.entityName)
        request.predicate = NSPredicate(format: "id == %@", id)
        
        if let movie = (try? context.executeFetchRequest(request))?.first as? Movie {
            return movie
        } else {
            let movie = Movie(dictionary: dictionary, context: context) //NSEntityDescription.insertNewObjectForEntityForName(entityName, inManagedObjectContext: context) as? Movie {
            
            return movie
        }
        
    }

    
    /* Helper: Given an array of dictionaries, convert them to an array of TMDBMovie objects */
    static func moviesFromResults(results: [[String : AnyObject]], listID: String, context: NSManagedObjectContext?) -> NSMutableOrderedSet {
        
        let movies = NSMutableOrderedSet()
        
        for result in results {
            
            movies.addObject( Movie(dictionary: result, context: context!) )
        }
        
        return movies
    }
    
    //    static func moviesFromLists(lists: NSMutableOrderedSet) -> NSMutableOrderedSet {
    //
    //        for l in lists {
    //
    //        }
    //    }
    
    override func prepareForDeletion() {
        
        guard let path = posterPath else {
            print("prepare for deletion has failed")
            return
        }
        
        // Delete image
        TheMovieDB.Caches.imageCache.storeImage(nil, withIdentifier: path)
    }
    
    
}



