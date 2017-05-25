//
//  TheMovieDB-Convenience.swift
//  P5_whatShouldIStream
//
//  Created by Michael Harper on 5/12/16.
//  Copyright © 2016 MJH. All rights reserved.
//


import CoreData
//import BNRCoreDataStack


extension TheMovieDB {
    
    func getMoviesFromList(_ list: List, completionHandler: @escaping (_ result: [[String : Any]]?, _ error: NSError?) -> Void) {
        //removed nsmanaged context from function. -was not used
        
        // Query TMDB
        let resource = TheMovieDB.Resources.ListID
        var parameters = [String: Any]()
        
        parameters[TheMovieDB.Keys.ID] = list.id as Any?
        
        _ = TheMovieDB.sharedInstance().taskForResource(resource, parameters: parameters){ JSONResult, error  in
            if let error = error {
                print(error)
                completionHandler(nil, error)
                return
                
            } else {
                
                let domainText = "Creating list"
                guard let listDictionary = JSONResult as? [String: Any] else {
                    let errorText = "Can't create dictionary from result"
                    print("\(errorText)")
                    
                    completionHandler(nil, NSError(domain: domainText, code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse list"]))
                    
                    return
                }
                
                guard let newResults = JSONResult as? [String: Any] else {
                    log.error()
                    return
                }
                //if let results = JSONResult?.value(forKey: "items") as? [[String : AnyObject]] {
                if let results = newResults["items"] as? [[String : Any]] {
                    
                    //let movies = Movie.moviesFromResults(results, listID: list.id!)
                    //list.movies = movies
                    completionHandler(results, nil)
                    
                } // if let
                else {
                    completionHandler(nil, NSError(domain: "list parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse list"]))
                }
            }
        } // End of task for resource
    }

    
    func getGenres(_ resource: String, completionHandler: @escaping (_ result: [Int: String]?, _ error: NSError?) -> Void ) {
        
        // Query TMDB
        let resource = TheMovieDB.Resources.MovieGenreList
        let mutableParameters = [String: Any]()
        TheMovieDB.sharedInstance().taskForResource(resource, parameters: mutableParameters){ JSONResult, error  in
            
            var genres: [Int: String] = [:]
            
            if let error = error {
                print(error)
                completionHandler(nil, error)
                
            } else {
               if let results = (JSONResult as AnyObject).value(forKey: "genres") as? [[String: AnyObject]] {
                    print(results)
                    for i in results {
                        if let id = i["id"] as? Int {
                            if let name = i["name"] as? String {
                                genres[id] = name
                            }
                        }
                    } // loop
                }
                completionHandler(genres, nil)
            }
        } // End of task for resource
    }
    
    func getVideos(_ movieId: NSNumber, completionHandler: @escaping (_ result: [[String: AnyObject]]?, _ error: NSError?) -> Void ) {

        let resource = TheMovieDB.Resources.MovieIdVideos
        //let mutableParameters = [String:AnyObject]()
       let  mutableParameters = [Keys.ID: movieId]
        
        _ = TheMovieDB.sharedInstance().taskForResource(resource, parameters: mutableParameters) { JSONResult, error in
            
            log.info("\(JSONResult ?? "Failed Downloading Trailers")")

            if let error = error {
                log.error("\(error.localizedDescription)")
                completionHandler(nil, error)
                return
                
            } else {
                if let results = (JSONResult as AnyObject).value(forKey: "results") as? [[String: AnyObject]] {
                    log.info("found \(results.count) videos"  )
                    completionHandler(results, nil)
                    return
                }
            }
            
            log.error("Could not find value for key")
        
//        let postData = NSData(data: "{}".dataUsingEncoding(NSUTF8StringEncoding)!)
//        
//        var request =URLRequest(URL: NSURL(string: "https://api.themoviedb.org/3/movie/%7Bmovie_id%7D/videos?language=en-US&api_key=%3C%3Capi_key%3E%3E")!,
//                                          cachePolicy: .UseProtocolCachePolicy,
//                                          timeoutInterval: 10.0)
//        request.HTTPMethod = "GET"
//        request.HTTPBody = postData
//        
//        let session = NSURLSession.sharedSession()
//        let dataTask = session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
//            if (error != nil) {
//                log.error("\(error?.localizedDescription)")
//            } else {
//                let httpResponse = response as? NSHTTPURLResponse
//                //println(httpResponse)
//            }
//        })
//        
//        dataTask.resume()
            return
    }
 }

}
