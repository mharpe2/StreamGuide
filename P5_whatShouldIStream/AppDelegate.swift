
//
//  AppDelegate.swift
//  TheMovieManager
//
//  Created by Jarrod Parkes on 11/5/15.
//  Copyright © 2015 Udacity. All rights reserved.
//

import UIKit
import XCGLogger

//Global Log
let log = XCGLogger.default

//Global Context
let context = CoreDataStack().persistentContainer.viewContext




func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    return true
}

func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}

func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}

func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
  _ =  context.save
}






////
////  AppDelegate.swift
////  P5_whatShouldIStream
////
////  Created by Michael Harper on 4/11/16.
////  Copyright © 2016 MJH. All rights reserved.
////
//
//import UIKit
//import CoreData
////import AWSCore
//
//let log = XCGLogger.defaultInstance()
//
//@UIApplicationMain
//class AppDelegate: UIResponder, UIApplicationDelegate {
//    
//    var window: UIWindow?
//    
//    var movieDB = TheMovieDB.sharedInstance()
//    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! as URL
//    
//    fileprivate let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
//    fileprivate lazy var loadingVC: UIViewController = {
//        return self.mainStoryBoard.instantiateViewController( withIdentifier: "LoadingVC")
//    }()
//    
//    fileprivate lazy var firstTabBarController: UITabBarController = {
//        return self.mainStoryBoard.instantiateViewController( withIdentifier: "TabBarController") as! tabBarController
//        
//    }()
//    
//    var mainContext = {
//        return CoreDataStackManager.sharedInstance().coreDataStack!.mainQueueContext
//    }
//    
//    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
//         
//        
//        log.setup(.Debug, showLogLevel: true, showFileNames: true, showLineNumbers: true, writeToFile: nil)
//        log.info( "Documents Directory: \(documentsURL)" )
//        window = UIWindow(frame: UIScreen.main.bounds)
//        
//        window?.rootViewController = loadingVC
//        
//        
//        CoreDataStack.constructSQLiteStack(withModelName: "Model") { result in
//            switch result {
//            case .Success(let stack):
//                CoreDataStackManager.sharedInstance().coreDataStack = stack
//                self.seedData()
//                
//                log.info("CoreData Stack running")
//                TheMovieDB.sharedInstance().config.updateTMDB()
//                let daysSinceUpdate = TheMovieDB.sharedInstance().config.daysSinceLastUpdate
//                log.info("Days since last update \(daysSinceUpdate)")
//                //                if (self.movieDB.config.daysSinceLastUpdate > 1) ||
//                //                    (self.movieDB.config.daysSinceLastUpdate == nil){
//                //self.movieDB.config.updateTMDB()
//                //self.performUpdate()
//                //                }
//                
//                dispatch_async(dispatch_get_main_queue()) {
//                    self.window?.rootViewController = self.firstTabBarController
//                }
//            case .Failure(let error):
//                print(error)
//            }
//            
//            
//        }
//        
//        self.window?.makeKeyAndVisible()
//        return true
//    }
//    
//    func applicationWillResignActive(_ application: UIApplication) {
//        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
//        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
//    }
//    
//    func applicationDidEnterBackground(_ application: UIApplication) {
//        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
//        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
//    }
//    
//    func applicationWillEnterForeground(_ application: UIApplication) {
//        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
//    }
//    
//    func applicationDidBecomeActive(_ application: UIApplication) {
//        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//    }
//    
//    func applicationWillTerminate(_ application: UIApplication) {
//        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
//    }
//    
//    func performUpdate() -> Int {
//        
//        log.verbose("resetting Coredata")
//        self.mainContext().reset()
//        var lists = NSMutableOrderedSet()
//        
//        CoreNetwork.getJsonFromHttp(MasterLists.googleDriveLocation) {
//            (result, error) in
//            if error == nil {
//                guard let listsDict = result["lists"] as? [[String:AnyObject]] else
//                {
//                    log.verbose("Error processing list to dictionary")
//                    return
//                }
//                // lists
//                lists = List.listsFromResults(listsDict, context: self.mainContext() )
//            }
//            else {
//                log.verbose("Error updating")
//            }
//        }
//        return lists.count
//    }
//    
//    fileprivate func seedData() {
//        
//        // Grab path for seed files in Supporting Files folder
//        guard let listData = fileToNSData("lists", ofType: "json") else {
//            log.error("Could not seed data")
//            return
//        }
//        
//        guard let  listJSON = CoreNetwork.parseJSON(listData) else {
//            log.error("Could not parse list data to JSON")
//            return
//        }
//        
//        guard let listsDict = listJSON["lists"] as? [[String:AnyObject]] else
//        {
//            log.verbose("Error processing list to dictionary")
//            return
//        }
//        
//        // load genre data
//        guard var movieGenreData = fileToNSData("movieGenres", ofType: "json"),
//            var tvGenreData = fileToNSData("tvGenres", ofType: "json") else {
//                log.error("Could not seed genres")
//                return
//        }
//        
//        self.jsonGenreToCoreData(movieGenreData)
//        self.jsonGenreToCoreData(tvGenreData)
//        
//        
//        // convert NSdata to json and save to result
//        CoreNetwork.parseJSONWithCompletionHandler(listData) {
//            result, error in
//            if error == nil {
//                guard let listsDict = result?["lists"] as? [[String:AnyObject]] else
//                {
//                    log.verbose("Error processing list to dictionary")
//                    return
//                }
//                
//                self.mainContext().performBlockAndWait() {
//                    
//                    //generate list set from listdata
//                    
//                    let lists = List.listsFromResults(listsDict, context: self.mainContext())
//                    
//                    //Download all movies from list
//                    log.info("download movies from list")
//                    self.downloadMoviesFromLists()
//                    
//                    do {
//                        try self.mainContext().saveContextAndWait()
//                    } catch _ {
//                        log.error("could not seed initial data")
//                    }
//                    
//                } // End performBlock
//            } // End parseWithJson
//        } // end parseJson with listData
//        
//    }
//    
//    
//    fileprivate func jsonGenreToCoreData(_ json: Data?) {
//        guard let data = json else
//        {
//            log.error("Json not valid NSData")
//            return
//        }
//        
//        // interate Movie Genre data and add to core data
//        let jsonData = CoreNetwork.parseJSON(data)
//        if jsonData != nil {
//            guard let results = jsonData?["genres"] as? [[String:AnyObject]] else {
//                log.error("error converting json results to [[string:anyobjec]]")
//                return
//            }
//            
//            self.mainContext().performBlockAndWait() {
//                for genre in results {
//                    let g = Genre.genreFromDictionary(genre, inManagedObjectContext: self.mainContext() )
//                    //self.log.info("added genre \(g!.name)")
//                    self.mainContext().saveContext()
//                }
//                self.mainContext().saveContext()
//            }
//        }
//    }
//    
//    fileprivate func downloadMoviesFromLists() {
//        
//        self.mainContext().performBlockAndWait() {
//            let lists = List.fetchLists(inManagedObjectContext: self.mainContext())
//            
//            for list in lists {
//                list.downloadMovies()
//            }
//            
//            self.mainContext().saveContext()
//        }
//    }
//    
//    
//    
//    fileprivate func fileToNSData(_ name: String, ofType:String) -> Data? {
//        
//        guard let filePath = Bundle.main.path(forResource: name, ofType: ofType) else {
//            log.error("could not find seed data file \(name).\(ofType)")
//            return nil
//        }
//        
//        var data: Data
//        do {
//            data = try Data(contentsOf: URL(fileURLWithPath: filePath), options: .mappedIfSafe)
//        }   catch _ {
//            log.error("Could not convert seed data to json")
//            return nil
//        }
//        return data
//    }
//    
//    
//} // AppDelegate
//
