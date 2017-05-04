//
//  WatchListViewController.swift
//  P5_whatShouldIStream
//
//  Created by Michael Harper on 4/11/16.
//  Copyright © 2016 MJH. All rights reserved.
//

import UIKit
import CoreData

class WatchListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    lazy var mainContext = {
        return CoreDataStackManager.sharedInstance().coreDataStack!.mainQueueContext
    }
    
    // fetchedResultsController
    lazy var fetchedResultsController: FetchedResultsController<Movie> = {
        
        let fetchRequest = NSFetchRequest(entityName: Movie.entityName)
        fetchRequest.predicate = NSPredicate(format: "onWatchlist == %@", true)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        fetchRequest.sortDescriptors = []
        
        //Create fetched results controller with the new fetch request.
        var fetchedResultsController = FetchedResultsController<Movie>(fetchRequest: fetchRequest,
                                                                       managedObjectContext: self.mainContext(),
                                                                       sectionNameKeyPath: nil,
                                                                       cacheName: nil)
        return fetchedResultsController
    }()
    
    lazy var frcDelegate: MoviesFetchedResultsTableViewControllerDelegate = {
        return MoviesFetchedResultsTableViewControllerDelegate(tableView: self.tableView )
    }()

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.fetchedResultsController.setDelegate(self.frcDelegate)

       
        // perform fetch
        do {
            try self.fetchedResultsController.performFetch()
        } catch let error as NSError {
            log.error("\(error.localizedDescription)"  )
        }
        if self.fetchedResultsController.fetchedObjects?.count == 0{
           log.info("no watchlist movies found")
        } else {
            log.info("watchlist movies found")
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        //tableView.reloadData()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension WatchListViewController: UITableViewDelegate, UITableViewDataSource  {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        /* Get cell type */
        let cellReuseIdentifier = "MovieTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! MovieTableViewCell!
        
        //get a moive array from BNR core data
        guard let sections = fetchedResultsController.sections else {
            assertionFailure("No Sections in fetched results")
            return cell!
        }
        
        let section = sections[indexPath.section]
        let movie = section.objects[indexPath.row]
        
               /* Set cell defaults */
        cell?.picture!.image = UIImage(named: "filmRole")
        cell.title!.text = movie.title
        cell.overView.text = movie.overview
        //cell.picture!.contentMode = UIViewContentMode.ScaleAspectFit
        
        cell?.activityIndicator.startAnimating()
        if let posterPath = movie.posterPath {
            TheMovieDB.sharedInstance().taskForImageWithSize(TheMovieDB.PosterSizes.RowPoster, filePath: posterPath, completionHandler: { (imageData, error) in
                if let image = UIImage(data: imageData!) {
                    dispatch_async(dispatch_get_main_queue()) {
                        cell.picture!.image = image
                    }
                } else {
                    print(error)
                }
                cell.activityIndicator.stopAnimating()
            })
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print("numberOfRows: \(fetchedResultsController.sections?[section].objects.count ?? 0)")
        return fetchedResultsController.sections?[section].objects.count ?? 0
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        //get a moive array from BNR core data
        guard let sections = fetchedResultsController.sections else {
            assertionFailure("No Sections in fetched results")
            return
        }
        
        let section = sections[indexPath.section]
        let movie = section.objects[indexPath.row]
        
        let movieDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "MovieDetailViewController") as! MovieDetailViewController
        
        movieDetailViewController.movie = movie
        
//        self.presentViewController(movieDetailViewController, animated: true) {
//            
//            // Code
//        }
        self.navigationController?.pushViewController(movieDetailViewController, animated: true)

    }
    
    func getMovieFromFRC(_ indexPath: IndexPath) -> Movie? {
        //get a moive array from BNR core data
        guard let sections = fetchedResultsController.sections else {
            assertionFailure("No Sections in fetched results")
            return nil
        }
        
        let section = sections[indexPath.section]
        let movie = section.objects[indexPath.row]
        return movie
        
    }
    
    //MARK: Delete tableview cell
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            if let movieToDelete = getMovieFromFRC(indexPath) {
                movieToDelete.onWatchlist = NSNumber(value: false as Bool)
                mainContext().saveContext()
            }
            //confirmDelete(movieToDelete)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    
}

