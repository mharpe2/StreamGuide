//
//  FindViewController.swift
//  P5_whatShouldIStream
//
//  Created by Michael Harper on 4/11/16.
//  Copyright © 2016 MJH. All rights reserved.
//

import UIKit
import CoreData


class searchViewController: UIViewController { //DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    //@IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var searchTask: URLSessionDataTask!
    var guideboxResults = [GuideBoxSearchResults]()
    var searchController = UISearchController(searchResultsController: nil)
    var searchBar: UISearchBar!
    
    
    
    // fetchedResultsController
//    lazy var fetchedResultsController: NSFetchedResultsController<Movie> = {
//        
//        let fetchRequest = NSFetchRequest(entityName: Movie.entityName)
//        //fetchRequest.predicate = NSPredicate(format: "location == %@", self.selectedLocation)
//        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
//        fetchRequest.sortDescriptors = []
//        
//        //Create fetched results controller with the new fetch request.
//        var fetchedResultsController = FetchedResultsController<Movie>(fetchRequest: fetchRequest,
//                                                                       managedObjectContext: self.mainContext(),
//                                                                       sectionNameKeyPath: nil,
//                                                                       cacheName: nil)
//        return fetchedResultsController
//    }()
//    
//    lazy var frcDelegate: MoviesFetchedResultsTableViewControllerDelegate = {
//        return MoviesFetchedResultsTableViewControllerDelegate(tableView: self.tableView )
//    }()
//
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        //tableView.emptyDataSetSource = self
        //tableView.emptyDataSetDelegate = self
        
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        searchBar = searchController.searchBar
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //self.searchBar.becomeFirstResponder()
    }
    
    func imageForEmptyDataSet(_ scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "filmRole")
    }
}


extension searchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)  {
        
        if let task = searchTask {
            task.cancel()
        }
        
        if searchText == ""  {
            guideboxResults = [GuideBoxSearchResults]()
            tableView?.reloadData()
            objc_sync_exit(self)
            return
        }
        
        let resource = GuideBox.Resource.searchByTitle
        let parameters = ["showname": searchText]
        
        searchTask = GuideBox.sharedInstance().taskForResource(resource, parameters: parameters as [String : AnyObject]) {
            [unowned self] jsonResult, error in
            
            if let error = error {
                print("Error searching for shows: \(error.localizedDescription)" )
                return
            }
            
            // print(jsonResult)
            
//            if let showDictionaries = jsonResult?.value(forKey: "results") as? [[String: AnyObject]] {
//                self.searchTask = nil
//                
//                // guidebox
//                self.guideboxResults = showDictionaries.map() {
//                    GuideBoxSearchResults(dictionary: $0)
//                } // end guideBoxResults
//            } // end showDictionaries
            
            // Reload the table on the main thread
            performUIUpdatesOnMain{
                self.tableView!.reloadData()
            }
            
        } // searchTask
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //searchBar.resignFirstResponder()
    }
    
}


extension searchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let CellReuseId = "movieSearchResults"
        let movie = guideboxResults[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: CellReuseId)
        {
            configureCell(cell, movie: movie)
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return guideboxResults.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let movie = guideboxResults[indexPath.row]
        
        //        // Alert the delegate
        //        delegate?.actorPicker(self, didPickActor: movie)
        //
        //        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // All right, this is kind of meager. But its nice to be consistent
    func configureCell(_ cell: UITableViewCell, movie: GuideBoxSearchResults) {
        cell.textLabel!.text = movie.title
    }
    
}


extension searchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        //filterContentForSearchText(searchController.searchBar.text!)
        print("updating search results")
        searchMoviesOnGuideBox(searchBar.text!)
    }
    
    func searchMoviesOnGuideBox(_ searchText: String) {
        
        let trimmedSearchText = searchText.replacingOccurrences(of: " ", with: "")
        
        if let task = searchTask {
            task.cancel()
        }
        
        if trimmedSearchText == ""  {
            guideboxResults = [GuideBoxSearchResults]()
            tableView?.reloadData()
            objc_sync_exit(self)
            return
        }
        
        let resource = GuideBox.Resource.searchByTitle
        let parameters = ["showname": trimmedSearchText]
        
        searchTask = GuideBox.sharedInstance().taskForResource(resource, parameters: parameters as [String : AnyObject]) {
            [unowned self] jsonResult, error in
            
            if let error = error {
                print("Error searching for shows: \(error.localizedDescription)" )
                return
            }
            
            
            if let showDictionaries = (jsonResult as AnyObject).value(forKey: "results") as? [[String: AnyObject]] {
                self.searchTask = nil
                
                // guidebox
                self.guideboxResults = showDictionaries.map() {
                    GuideBoxSearchResults(dictionary: $0)
                } // end guideBoxResults
            } // end showDictionaries
            
            // Reload the table on the main thread
            DispatchQueue.main.async {
                self.tableView!.reloadData()
            }
            
        } // searchTask
    }
}



class GuideBoxSearchResults {
    var guideBoxid: String? = ""
    var theMovieDBId: String? = ""
    var title: String? = ""
    
    init(dictionary: [String: AnyObject]) {
        title = dictionary["title"] as? String
        guideBoxid = dictionary["id"] as? String
        theMovieDBId = dictionary["themoviedb"] as? String
        print("GuideBox: \(title)")
        
    }
}

