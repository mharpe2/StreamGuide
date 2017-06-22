//
//  Show+CoreDataProperties.swift
//  P5_whatShouldIStream
//
//  Created by Michael Harper on 6/4/17.
//  Copyright © 2017 MJH. All rights reserved.
//

import Foundation
import CoreData


extension Show {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Show> {
        return NSFetchRequest<Show>(entityName: "Show")
    }

    @NSManaged public var season_number: Int16
    @NSManaged public var tv_id: Int16
    @NSManaged public var episodes: NSOrderedSet?

}

// MARK: Generated accessors for episodes
extension Show {

    @objc(insertObject:inEpisodesAtIndex:)
    @NSManaged public func insertIntoEpisodes(_ value: Movie, at idx: Int)

    @objc(removeObjectFromEpisodesAtIndex:)
    @NSManaged public func removeFromEpisodes(at idx: Int)

    @objc(insertEpisodes:atIndexes:)
    @NSManaged public func insertIntoEpisodes(_ values: [Movie], at indexes: NSIndexSet)

    @objc(removeEpisodesAtIndexes:)
    @NSManaged public func removeFromEpisodes(at indexes: NSIndexSet)

    @objc(replaceObjectInEpisodesAtIndex:withObject:)
    @NSManaged public func replaceEpisodes(at idx: Int, with value: Movie)

    @objc(replaceEpisodesAtIndexes:withEpisodes:)
    @NSManaged public func replaceEpisodes(at indexes: NSIndexSet, with values: [Movie])

    @objc(addEpisodesObject:)
    @NSManaged public func addToEpisodes(_ value: Movie)

    @objc(removeEpisodesObject:)
    @NSManaged public func removeFromEpisodes(_ value: Movie)

    @objc(addEpisodes:)
    @NSManaged public func addToEpisodes(_ values: NSOrderedSet)

    @objc(removeEpisodes:)
    @NSManaged public func removeFromEpisodes(_ values: NSOrderedSet)

}
