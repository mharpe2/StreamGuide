//
//  AppDelegate.swift
//  P5_whatShouldIStream
//
//  Created by Michael Harper on 4/11/16.
//  Copyright © 2016 MJH. All rights reserved.
//

import UIKit
import CoreData
//import BNRCoreDataStack
//import XCGLogger


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let log = XCGLogger.defaultInstance()
    var movieDB = TheMovieDB.sharedInstance()
    let documentsURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first! as NSURL
    
    private let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
    private lazy var loadingVC: UIViewController = {
        return self.mainStoryBoard.instantiateViewControllerWithIdentifier( "LoadingVC")
    }()
    
    private lazy var firstTabBarController: UITabBarController = {
        return self.mainStoryBoard.instantiateViewControllerWithIdentifier( "TabBarController") as! tabBarController

    }()
    
    var mainContext = {
        return CoreDataStackManager.sharedInstance().coreDataStack!.mainQueueContext
    }
    
     func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        log.setup(.Debug, showLogLevel: true, showFileNames: true, showLineNumbers: true, writeToFile: nil)
        log.info( "Documents Directory: \(documentsURL)" )
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        window?.rootViewController = loadingVC

        
        CoreDataStack.constructSQLiteStack(withModelName: "Model") { result in
            switch result {
            case .Success(let stack):
                CoreDataStackManager.sharedInstance().coreDataStack = stack
                 self.seedData()
                
                self.log.info("CoreData Stack running")
                TheMovieDB.sharedInstance().config.updateTMDB()
                let daysSinceUpdate = TheMovieDB.sharedInstance().config.daysSinceLastUpdate
                self.log.info("Days since last update \(daysSinceUpdate)")
//                if (self.movieDB.config.daysSinceLastUpdate > 1) ||
//                    (self.movieDB.config.daysSinceLastUpdate == nil){
                    //self.movieDB.config.updateTMDB()
                    //self.performUpdate()
//                }
                
                dispatch_async(dispatch_get_main_queue()) {
                   self.window?.rootViewController = self.firstTabBarController
                }
            case .Failure(let error):
                print(error)
            }
            
            
        }
        
//        // Delay execution of my block for 10 seconds.
//       
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(3.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
//            self.log.verbose("Proceeding")
//        }
//        sleep(2)
        
        self.window?.makeKeyAndVisible()
        
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func performUpdate() -> Int {
        
        log.verbose("resetting Coredata")
        self.mainContext().reset()
        var lists = NSMutableOrderedSet()
        
        CoreNetwork.getJsonFromHttp(MasterLists.googleDriveLocation) {
            (result, error) in
            if error == nil {
                guard let listsDict = result["lists"] as? [[String:AnyObject]] else
                {
                    self.log.verbose("Error processing list to dictionary")
                    return
                }
                // lists
                lists = List.listsFromResults(listsDict, context: self.mainContext() )
            }
            else {
                self.log.verbose("Error updating")
            }
        }
        return lists.count
    }
    
    private func seedData() {
        
        // Grab path for seed files in Supporting Files folder
        guard let listData = fileToNSData("lists", ofType: "json") else {
            log.error("Could not seed data")
            return
        }
        
        guard let  listJSON = CoreNetwork.parseJSON(listData) else {
            log.error("Could not parse list data to JSON")
            return
        }
        
        guard let listsDict = listJSON["lists"] as? [[String:AnyObject]] else
        {
            self.log.verbose("Error processing list to dictionary")
            return
        }
        
        // create lists
        var lists = NSMutableOrderedSet()
        self.mainContext().performBlockAndWait() {
            lists = List.listsFromResults(listsDict, context: self.mainContext())
            self.mainContext().saveContext()
        }
        
        // load data from file
        guard var movieGenreData = fileToNSData("movieGenres", ofType: "json"),
            var tvGenreData = fileToNSData("tvGenres", ofType: "json") else {
                log.error("Could not seed genres")
                return
        }
        
        
         // convert NSdata to json and save to result
            CoreNetwork.parseJSONWithCompletionHandler(listData) {
            result, error in
            if error == nil {
                guard let listsDict = result?["lists"] as? [[String:AnyObject]] else
                {
                    self.log.verbose("Error processing list to dictionary")
                    return
                }
                
                
                self.mainContext().performBlockAndWait() {
                    
                    //generate list set from listdata
                    
                    let lists = List.listsFromResults(listsDict, context: self.mainContext())
                   
                    //                    for item in listsDict {
                    //                        // generate list from dictionary and insert into context if they
                    //                        // are unique
                    //                        self.log.info("Creating Lists")
                    //                        let currentList = List.ListFromDictionary(item, inManagedObjectContext: self.mainContext() )
                    //                        self.mainContext().saveContext()
                    //                        self.log.info("Created \(currentList)")
                    //                    } // end for list
                    
                    // convert files to json
                    
                    
                    //                    guard let movieGenreData = self.fileToNSData(name: "movieGenres", ofType: "json"),
                    //                        let tvGenreData = self.fileToNSData(name: "tvGenres", ofType: "json") else {
                    //                            self.log.error("could not find seed data")
                    //                            return
                    //                    }
                    
//                    guard let movieGenreData = NSData(contentsOfFile: "movieGenres.json") else {
//                        self.log.error("Could not seed data")
//                    }
                    
//                    //try to add convert nsdata to json and add to coredata
//                    self.jsonGenreToCoreData(json: movieGenreData)
//                    self.jsonGenreToCoreData(json: tvGenreData)
                    
                    //Download all movies from list
                    self.log.info("download movies from list")
                    // parse data from file
                    
                    //dispatch_async(dispatch_get_main_queue()) {

                   
                    //}
                    
                    //let movieGenreJSON = CoreNetwork.parseJSON(movieGenreData)
                    self.jsonGenreToCoreData(movieGenreData)
                   // let tvGenreJSON = CoreNetwork.parseJSON(tvGenreData)
                    self.jsonGenreToCoreData(tvGenreData)

                   
                     self.downloadMoviesFromLists()
                    
                    do {
                    try self.mainContext().saveContextAndWait()
                    } catch _ {
                        self.log.error("could not seed initial data")
                    }

                    
                } // End performBlock
                            } // End parseWithJson
        } // end parseJson with listData
        
    }
    
    
    private func jsonGenreToCoreData(json: NSData?) {
        guard let data = json else
        {
            log.error("Json not valid NSData")
            return
        }
        
        // interate Movie Genre data and add to core data
        let jsonData = CoreNetwork.parseJSON(data)
        if jsonData != nil {
            guard let results = jsonData?["genres"] as? [[String:AnyObject]] else {
                self.log.error("error converting json results to [[string:anyobjec]]")
                return
            }
            
            self.mainContext().performBlockAndWait() {
                for genre in results {
                    let g = Genre.genreFromDictionary(genre, inManagedObjectContext: self.mainContext() )
                    //self.log.info("added genre \(g!.name)")
                    self.mainContext().saveContext()
                }
                self.mainContext().saveContext()
            }
        }
    }
    
    private func downloadMoviesFromLists() {
        
        self.mainContext().performBlockAndWait() {
            var lists = List.fetchLists(inManagedObjectContext: self.mainContext())
            for list in lists {
                let count = list.downloadMovies()
                self.log.info("Downloaded \(count) items on list \(list.name)")
//                // if list.movies.count == 0 {
//                TheMovieDB.sharedInstance().getMoviesFromList(list) {
//                    result, error in
//                    if error != nil {
//                        self.log.error("Could not download movies on list")
//                        return
//                    }
//                    else {
//                        // TMDB returned a movie dictionary
//                        // insert it into coredata
//                        //self.mainContext().performBlockAndWait() {
//                            if let movieResults  = result {
//                                let movies = Movie.moviesFromResults(movieResults, listID: list.id!, context: self.mainContext())
//                                list.movies = movies
//                                self.log.info("found \(movies.count) movies in list \(list.name)")
//                                self.mainContext().saveContext()
//                            }
//                        //}
//                    } // End of else
//                } // End of getMoviesFromList
//                // } // End if list movie count == 0
            }
            self.mainContext().saveContext()
        }
    }

    
   
    private func fileToNSData(name: String, ofType:String) -> NSData? {
    
        guard let filePath = NSBundle.mainBundle().pathForResource(name, ofType: ofType) else {
            log.error("could not find seed data file \(name).\(ofType)")
            return nil
        }
        
        var data: NSData
        do {
            data = try NSData(contentsOfFile: filePath, options: .DataReadingMappedIfSafe)
        }   catch _ {
            log.error("Could not convert seed data to json")
            return nil
        }
        return data
    }
    
    
} // AppDelegate

