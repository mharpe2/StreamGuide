//
//  BasicNetworking.swift
//  P5_whatShouldIStream
//
//  Created by Michael Harper on 5/4/16.
//  Copyright © 2016 MJH. All rights reserved.


import Foundation
import CoreData
import AWSCore
import AWSS3
import AWSCognito


class CoreNetwork {

    typealias CompletionHander = (_ result: Any?, _ error: NSError?) -> Void

    // AWS-S3 constants
    let bucket = "wsis-contentdelivery-mobilehub-326483023"
    let key = "wsis-master.txt"

    
    class func convertStringToDictionary(_ text: String) -> [String: Any]? {
        if let data = text.data(using: String.Encoding.utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch let error as NSError {
                print(error)
            }
        }
        return nil
    }
    
    class func getJsonFromHttp(_ location: String, completionHandler: @escaping CompletionHander) {
        
        let requestURL: URL = URL(string: location)!
        let urlRequest:URLRequest = URLRequest(url: requestURL)
       // let session = URLSession.shared
        
        let task = URLSession.shared.dataTask(with: urlRequest, completionHandler: {
            (data, response, error) -> Void in
            
            let httpsResponse = response as! HTTPURLResponse
            let statusCode = httpsResponse.statusCode
            
            if statusCode == 200 {
                parseJSONWithCompletionHandler(data!) {
                    (result, error) in
                    
                    if error == nil {
                        completionHandler(result, nil)
                       
                    }
                    else {
                       log.error()
                        completionHandler(nil, error)
                    }
                }
            }
        })    //end task
        
        task.resume()
    }
    
    class func getJsonFromAWSS3(_ bucket: String = "wsis-contentdelivery-mobilehub-326483023", key: String = "wsis-master.txt", completionHandler: @escaping CompletionHander) {
        print("View Controller running")
        // Do any additional setup after loading the view, typically from a nib.
        
        let credentialsProvider = AWSCognitoCredentialsProvider(
            regionType: .USEast1,
            identityPoolId: "us-east-1:15bb7f32-04e7-4602-bab5-37153ee3b011")
        let configuration = AWSServiceConfiguration(region:.USEast1, credentialsProvider:credentialsProvider)
        
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        // File Destination
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let masterFilePath = documentsDirectory + "wsis-master.txt"
        
        let fileManager = FileManager.default
        
        // check creation date
        if fileManager.fileExists(atPath: masterFilePath) {
            let fileAttributes = try? fileManager.attributesOfItem(atPath: masterFilePath)
            let creationDate = fileAttributes?[FileAttributeKey.creationDate]
            log.info("file created: \(String(describing: creationDate))")
            
            //check metadata of AWS file before we download it
            let headRequest = AWSS3HeadObjectRequest()
            headRequest?.bucket = bucket
            headRequest?.key = key
            log.info("last modified \(String(describing: headRequest?.ifModifiedSince = Date() ))")
            
            // if file exists but has no creation date, it must be corrupted?
            // Delete it I suppose
            do {
                try fileManager.removeItem( at: URL(fileURLWithPath: masterFilePath) )
            }
            catch let error as NSError {
                print("Could't delete file \(error.localizedDescription)")
            }
        }
        
        // file does not exist, so download it
        let downloadingFileURL = URL(fileURLWithPath: documentsDirectory)
        // Create the download request
        var request = AWSS3TransferManagerDownloadRequest()
        //request.downloadingFileURL
        request?.bucket = bucket
        request?.key = key
       
        request?.downloadingFileURL = downloadingFileURL.appendingPathComponent((request?.key!)!)
        
        // Submit the download request
        let transferManager = AWSS3TransferManager.default()
        log.info("Starting Download of \(String(describing: request?.key))")
        
        
        //var downloadOutput: AWSS3TransferManagerDownloadOutput
        //transferManager.download(request).cont
        transferManager.download(request!).continueWith(executor: AWSExecutor.mainThread(), block: {(task: AWSTask) -> AnyObject? in
            if let error = task.error as NSError? {
                
                if error.domain == AWSS3TransferManagerErrorDomain, let code = AWSS3TransferManagerErrorType(rawValue: error.code) {
                    switch code {
                    case .cancelled, .paused:
                        break
                    default:
                        print("Error downloading: \(key) Error: \(error)")
                        break
                        
                    }
                 } else {
                     print("Error downloading: \(key) Error: \(error)")
                }
                return nil
            }  // end if let error block
            
            completionHandler(request, nil)
            return nil
        })
    }
    
    
    class func parseJSONWithCompletionHandler(_ data: Data, completionHandler: (_ result: Any?, _ error: NSError?) -> Void) {
        
        var parsedResult: Any? = nil
        
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
            
        } catch let error as NSError {
            completionHandler(nil, error)
            return
            
        } catch {
            completionHandler( nil, NSError(domain: "parseJSONWithCompletionHandler", code: 0,
                                            userInfo: [NSLocalizedDescriptionKey : "Error: msg not found in parsed resut"])
            )
            return
        }
        
        completionHandler(parsedResult, nil)
        
    }

    class func errorForData(_ data: Data?, response: URLResponse?, error: NSError, errorMsg: String) -> NSError {
        
        if data == nil {
            return error
        }
        
        do {
            let parsedResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
            
            if let parsedResult = parsedResult as? [String : AnyObject], let errorMessage = parsedResult[errorMsg] as? String {
                let userInfo = [NSLocalizedDescriptionKey : errorMessage]
                return NSError(domain: "Error", code: 1, userInfo: userInfo)
            }
            
        } catch _ {}
        
        return error
    }
    
    // sync parse json
    class func parseJSON(_ data: Data) -> NSDictionary? {
        
        //let log = XCGLogger.defaultInstance()
        var parsingError: NSError? = nil
        
        let parsedResult: NSDictionary?
        do {
            
            parsedResult = try JSONSerialization.jsonObject(with: data, options: [JSONSerialization.ReadingOptions.allowFragments,  JSONSerialization.ReadingOptions.mutableContainers]) as? NSDictionary
        } catch let error as NSError {
            parsingError = error
            parsedResult = nil
        }
        
        if let error = parsingError {
            log.error("Parsing error: \( error.localizedDescription)")
            return nil
        }
        return parsedResult
    }
    
    
    
    // URL Encoding a dictionary into a parameter string
    
    class func escapedParameters(_ parameters: [String : Any]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            // make sure that it is a string value
            let stringValue = "\(value)"
            
            // Escape it
            let escapedValue = stringValue.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            
            // Append it
            
            if let unwrappedEscapedValue = escapedValue {
                urlVars += [key + "=" + "\(unwrappedEscapedValue)"]
            } else {
                print("Warning: trouble excaping string \"\(stringValue)\"")
            }
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joined(separator: "&")
    }
    
    class func performUpdateInBackround(_ context: NSManagedObjectContext) -> Int {
        
        //Download list stored in json format
        //CoreNetwork.getJsonFromHttp(MasterLists.googleDriveLocation) {
        CoreNetwork.getJsonFromAWSS3("wsis-contentdelivery-mobilehub-326483023", key: "wsis-master.txt") {
        
            (result, error) in
            if error == nil {
                let result = result as!  AWSS3TransferManagerDownloadRequest
                print("printing results returned \(result.downloadingFileURL)")
                //if let jsonData = NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe, error: nil)

                var jsonData = Data()
                do {
                jsonData = try Data(contentsOf: result.downloadingFileURL,  options: Data.ReadingOptions.mappedIfSafe)
                }
                
                catch let error as NSError{
                    log.error("Error loading json data: \(error.localizedDescription)")
                    return
                }
                    
                guard let jsonResult = parseJSON(jsonData) else
                {
                    log.error("Error in guard")
                    return
                }
                
                //print("json Result ** \(jsonResult)")
                
                //convert file to json list
                guard let listsDict = jsonResult["lists"] as? [[String: Any]] else //as! [[String:AnyObject]] else
                {
                    log.error("Error processing list to dictionary \(jsonResult) ")
                    return
                }
                
                //print("List Dict Result ** \(listsDict)")

                // Create lists and Save
                _ = List.listsFromResults(listsDict, context: context)
                coreDataStack.saveContext()
                
                // get all the lists and download movie info where list.movies
                // is empty
                let allLists = List.fetchLists(inManagedObjectContext: context )
                for list in allLists where (list.movies!.count == 0)
                {
                    TheMovieDB.sharedInstance().getMoviesFromList(list) { result, error in
                        if let error = error {
                            log.error("\(error.localizedDescription)")
                        } else {
                            
                            let movies = Movie.moviesFromResults(result! as [[String : Any]], listID: list.id!, context: context)
                            list.movies = NSOrderedSet(array: movies)
                            coreDataStack.saveContext()
                            
                        }
                        
                    } // End of else
                } // End of TheMovieDB.getMoviesFromList
            } // End of for list in allLists
        }
        return 0
    }
    
    
}




