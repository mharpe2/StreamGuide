//
//  Genre+CoreDataProperties.swift
//  P5_whatShouldIStream
//
//  Created by Michael Harper on 11/30/16.
//  Copyright © 2016 MJH. All rights reserved.
//

import Foundation
import CoreData


extension Genre {

    @nonobjc open override class func fetchRequest() -> NSFetchRequest<NSFetchRequestResult> {
        return NSFetchRequest(entityName: "Genre");
    }

    @NSManaged public var id: NSNumber?
    @NSManaged public var name: String?
    @NSManaged public var movies: NSSet?

}

// MARK: Generated accessors for movies
extension Genre {

    @objc(addMoviesObject:)
    @NSManaged public func addToMovies(_ value: Movie)

    @objc(removeMoviesObject:)
    @NSManaged public func removeFromMovies(_ value: Movie)

    @objc(addMovies:)
    @NSManaged public func addToMovies(_ values: NSSet)

    @objc(removeMovies:)
    @NSManaged public func removeFromMovies(_ values: NSSet)

}
