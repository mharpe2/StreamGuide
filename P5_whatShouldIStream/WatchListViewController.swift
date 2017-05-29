//
//  WatchListViewController.swift
//  P5_whatShouldIStream
//
//  Created by Michael Harper on 4/11/16.
//  Copyright © 2016 MJH. All rights reserved.
//

import UIKit
import CoreData

class WatchListViewController: UIViewController, NSFetchedResultsControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var fetchedResultsController: NSFetchedResultsController<Movie>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        attemptFetch()
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
        let movie = section.objects?[indexPath.row] as? Movie
        
               /* Set cell defaults */
        cell?.picture!.image = UIImage(named: "filmRole")
        cell?.title!.text = movie?.title
        cell?.overView.text = movie?.overview
        //cell.picture!.contentMode = UIViewContentMode.ScaleAspectFit
        
        cell?.activityIndicator.startAnimating()
        if let posterPath = movie?.posterPath {
            _ = TheMovieDB.sharedInstance().taskForImageWithSize(TheMovieDB.PosterSizes.RowPoster, filePath: posterPath, completionHandler: { (imageData, error) in
                if let image = UIImage(data: imageData!) {
                   performUIUpdatesOnMain() {
                        cell?.picture!.image = image
                    }
                } else {
                   log.error()
                }
                cell?.activityIndicator.stopAnimating()
            })
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print("numberOfRows: \(fetchedResultsController.sections?[section].objects.count ?? 0)")
        return fetchedResultsController.sections?[section].objects!.count ?? 0
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        //get a moive array from BNR core data
        guard let sections = fetchedResultsController.sections else {
            assertionFailure("No Sections in fetched results")
            return
        }
        
        let section = sections[indexPath.section]
        let movie = section.objects?[indexPath.row] as? Movie
        
        let movieDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "MovieDetailViewController") as! MovieDetailViewController
        
        movieDetailViewController.movie = movie
        
        self.navigationController?.pushViewController(movieDetailViewController, animated: true)

    }
    
    func getMovieFromFRC(_ indexPath: IndexPath) -> Movie? {
        //get a moive array from BNR core data
        guard let sections = fetchedResultsController.sections else {
            assertionFailure("No Sections in fetched results")
            return nil
        }
        
        let section = sections[indexPath.section]
        let movie = section.objects?[indexPath.row] as? Movie

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
                coreDataStack.saveContext()
            }
            //confirmDelete(movieToDelete)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func attemptFetch() {
        
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "onWatchlist == %@", NSNumber.init(booleanLiteral: true))
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self
        self.fetchedResultsController = fetchedResultsController
        
        do {
            try fetchedResultsController.performFetch()
            
        } catch {
            
            let error = error as NSError
            print("\(error)")
            
        }
    }
}



