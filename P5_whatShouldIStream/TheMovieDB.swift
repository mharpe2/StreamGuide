//
//  TheMovieDB.swift
//  TheMovieDB
//
//
//

import Foundation

class TheMovieDB : NSObject {
    
    typealias CompletionHander = (_ result: Any?, _ error: NSError?) -> Void
    
    var session: URLSession!
    
    var config = Config.unarchivedInstance() ?? Config()
    
    override init() {
        super.init()        
    }

    
    // MARK: - All purpose task method for data
    
    func taskForResource(_ resource: String, parameters: [String : Any], completionHandler: @escaping CompletionHander) -> URLSessionDataTask {
        
        var mutableParameters = parameters
        var mutableResource = resource
        
        // Add in the API Key
        mutableParameters["api_key"] = Constants.ApiKey as Any
        
        // Substitute the id parameter into the resource
        if resource.range(of: ":id") != nil {
            assert(parameters[Keys.ID] != nil)
            
            mutableResource = mutableResource.replacingOccurrences(of: ":id", with: "\(parameters[Keys.ID]!)")
            mutableParameters.removeValue(forKey: Keys.ID)
        }
        
        let urlString = Constants.BaseUrlSSL + mutableResource + CoreNetwork.escapedParameters(mutableParameters)
        let url = URL(string: urlString)!
        let request = URLRequest(url: url)
     
        let task = URLSession.shared.dataTask(with: request, completionHandler: {data, response, downloadError in

            if let error = downloadError {
                let newError = TheMovieDB.errorForData(data, response: response, error: error as NSError)
                completionHandler(nil, newError)
            } else {
                
                CoreNetwork.parseJSONWithCompletionHandler(data!, completionHandler: completionHandler)
            }
        }) 
        
        task.resume()
        
        return task
    }
    
    func taskForResource(_ resource: String, completionHandler: @escaping CompletionHander) -> URLSessionDataTask {
        
        let mutableResource = resource
        var mutableParameters = [String:AnyObject]()
        
        // Add in the API Key
        mutableParameters["api_key"] = Constants.ApiKey as AnyObject
       
                
        let urlString = Constants.BaseUrlSSL + mutableResource + CoreNetwork.escapedParameters(mutableParameters)
        let url = URL(string: urlString)!
        let request = URLRequest(url: url)
        
        print(url)
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: {data, response, downloadError in
            
            if let error = downloadError {
                let newError = TheMovieDB.errorForData(data, response: response, error: error as NSError)
                completionHandler(nil, newError)
            } else {
                
                CoreNetwork.parseJSONWithCompletionHandler(data!, completionHandler: completionHandler)
            }
        }) 
        task.resume()
        return task
    }

    
    // MARK: - All purpose task method for images
    
    func taskForImageWithSize(_ size: String, filePath: String, completionHandler: @escaping (_ imageData: Data?, _ error: NSError?) ->  Void) -> URLSessionTask {
        
        let baseURL = URL(string: config.secureBaseImageURLString)!
        let url = baseURL.appendingPathComponent(size).appendingPathComponent(filePath)
        
        print(url)
        
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: {data, response, downloadError in
            
            if let error = downloadError {
                let newError = TheMovieDB.errorForData(data, response: response, error: error as NSError)
                completionHandler(nil, newError)
            } else {
                completionHandler(data, nil)
            }
        }) 
        
        task.resume()
        
        return task
    }
    
    
    // MARK: - Helpers
    
    
    // Try to make a better error, based on the status_message from TheMovieDB. If we cant then return the previous error

    class func errorForData(_ data: Data?, response: URLResponse?, error: NSError) -> NSError {
        
        if data == nil {
            return error
        }
        
        do {
            let parsedResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)

            if let parsedResult = parsedResult as? [String : AnyObject], let errorMessage = parsedResult[TheMovieDB.Keys.ErrorStatusMessage] as? String {
                let userInfo = [NSLocalizedDescriptionKey : errorMessage]
                return NSError(domain: "TMDB Error", code: 1, userInfo: userInfo)
            }
            
        } catch _ {}
        
        return error
    }
    
    // MARK: - Shared Instance
    
    class func sharedInstance() -> TheMovieDB {
        
        struct Singleton {
            static var sharedInstance = TheMovieDB()
        }
        
        return Singleton.sharedInstance
    }
    
    
    // MARK: - Shared Image Cache

    struct Caches {
        static let imageCache = ImageCache()
    }
    
    // MARK: - Help with updating the Config
    func updateConfig(_ completionHandler: @escaping (_ didSucceed: Bool, _ error: NSError?) -> Void) {
        
        let parameters = [String: AnyObject]()
        
        _ = taskForResource(Resources.Config, parameters: parameters) { JSONResult, error in
            
            if let error = error {
                completionHandler(false, error)
            } else if let newConfig = Config(dictionary: JSONResult as! [String : AnyObject]) {
                self.config = newConfig
                completionHandler(true, nil)
            } else {
                completionHandler(false, NSError(domain: "Config", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse config"]))
            }
        }
        
    }
}


