//
//  Movie+CoreDataProperties.swift
//  P5_whatShouldIStream
//
//  Created by Michael Harper on 11/30/16.
//  Copyright © 2016 MJH. All rights reserved.
//

import Foundation
import CoreData


extension Movie {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Movie> {
        return NSFetchRequest<Movie>(entityName: "Movie");
    }

    @NSManaged public var guideBoxId: NSNumber?
    @NSManaged public var id: NSNumber?
    @NSManaged public var onWatchlist: NSNumber?
    @NSManaged public var overview: String?
    @NSManaged public var posterPath: String?
    @NSManaged public var releaseDate: Date?
    @NSManaged public var service: String?
    @NSManaged public var title: String?
    @NSManaged public var type: String?
    @NSManaged public var voteAverage: NSNumber?
    @NSManaged public var actor: Person?
    @NSManaged public var genres: NSSet?
    @NSManaged public var list: List?

}

// MARK: Generated accessors for genres
extension Movie {

    @objc(addGenresObject:)
    @NSManaged public func addToGenres(_ value: Genre)

    @objc(removeGenresObject:)
    @NSManaged public func removeFromGenres(_ value: Genre)

    @objc(addGenres:)
    @NSManaged public func addToGenres(_ values: NSSet)

    @objc(removeGenres:)
    @NSManaged public func removeFromGenres(_ values: NSSet)

}
