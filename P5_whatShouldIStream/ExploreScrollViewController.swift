//
//  ExploreScrollViewController.swift
//  P5_whatShouldIStream
//
//  Created by Michael Harper on 6/5/16.
//  Copyright © 2016 MJH. All rights reserved.
//

import UIKit
import CoreData
import ImageIO

class ExploreViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate
    
{
    
    // segmented control index into coredata group labels
    let segmentDict = ["top":0, "genres": 1, "goingaway": 2, "upcoming": 3]
    
    enum Catagory: String {
        case Top = "top"
        case Genres = "genres"
        case GoingAway = "goingAway"
        case Upcoming = "upcoming"
    }
    
    let topSegment = "top"
    let segment: [String] = ["top", "genres", "goingaway", "upcoming"]
    var selectedListGroup = 0
    var predicate = NSPredicate()
    var storedOffsets = [Int: CGFloat]()
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!

    var imageView: UIImageView!
    
    //MARK: CoreData ------------------------------------------------------------------
    var listFRC: NSFetchedResultsController<List>!
    
    
    //MARK: LifeCycle -------------------------------------------------------------------
    
    //MARK: viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        TheMovieDB.sharedInstance().config.updateTMDB()
        
        attemptFetch()
        tableView.reloadData()
      }
    
    
    //MARK: TableView Methods ------------------------------------------------------------
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return listFRC.sections?.count ?? 1
        
        if let sections = listFRC.sections, sections.count > 0 {
            return sections[section].objects!.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "streamingServiceRow")  as? StreamingServiceRow
        {
            log.verbose("returning cell \(cell.description)")
            //cell.collectionView = self.collectionView
            return cell
        } else {
            log.verbose("returning empty streaming service row" )
            let cell = StreamingServiceRow()
            //cell.collectionView = self.collectionView
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        log.info("Setting cell to index \(indexPath.section)")
        guard let tableViewCell = cell as? StreamingServiceRow else {
            log.error("tableView cell could not be set to cell as? StreamingServiceRow")
            return
        }
       
        tableViewCell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.section)
        tableViewCell.collectionViewOffset = storedOffsets[indexPath.section] ?? 0
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let tableViewCell = cell as? StreamingServiceRow else {
            log.error("tableView cell could not be set to cell as? StreamingServiceRow")
            return
        }
        
        storedOffsets[indexPath.section] = tableViewCell.collectionViewOffset
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return listFRC.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        guard let sections = listFRC.sections else { return nil }
        //return sections[section].objects?[0].name as? String ?? nil
        return (sections[section].objects?[0] as! List).name
    }
    
    // MARK: Segmented Controller
    
    
    @IBAction func segmentedControlChanged(_ sender: UISegmentedControl) {
            attemptFetch()
            tableView.reloadData()
    }
    
    func makeThumbNail(_ image: UIImage) -> UIImage {
        
        let size = image.size.applying(CGAffineTransform(scaleX: 0.25, y: 0.25))
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
        image.draw( in: CGRect(origin: CGPoint.zero, size: size))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        return scaledImage!
        
    }
    
    // try to create notification class
    //
    //    func notificationSlideUP() {
    //        let maxX = self.view.frame.maxX
    //        let maxY = self.view.frame.maxY
    //        let height = (self.view.frame.height) / 6
    //
    //        var notificationView: NVActivityIndicatorView = NVActivityIndicatorView(frame: CGRectMake(0.0, maxY - height, maxX, maxY), type: .SquareSpin, color: UIColor.blueColor() )
    //        //notificationView.backgroundColor = UIColor.redColor()
    //        notificationView.startAnimation()
    //        view.addSubview(notificationView)
    //
    //        //Nvactivity View
    //
    //        //var activityView = NVActivityIndicatorView(frame: CGRectMake(0.0, 0.0, (notificationView.frame.maxX)/4, (notificationView.frame.maxY)))
    //
    //        //        var activityView: NVActivityIndicatorView = NVActivityIndicatorView(frame: notificationView.frame, color: UIColor.flatGreenColorDark() )
    //        //        activityView.backgroundColor = UIColor.blueColor()
    //        //        activityView.startAnimation()
    //        //
    //        //        notificationView.addSubview(activityView)
    //
    //        delay(5) {
    //            notificationView.removeFromSuperview()
    //        }
    //    }
    //
    //    func delay(delay: Double, closure: ()->()) {
    //        dispatch_after(
    //            DispatchTime.now(
    //                dispatch_time_t(DispatchTime.now),
    //                Int64(delay * Double(NSEC_PER_SEC))
    //            ),
    //            DispatchQueue.main,
    //            closure
    //        )
    //    }
    
} // End of class


//MARK: CollectionView Methods ---------------------------------------------------------

extension ExploreViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        log.info(listFRC.sections?.count)
        return listFRC.sections?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sections = listFRC.sections else {
            log.error("Could not get listFRC.sections")
            return 0
        }
        
        log.info("tag: \(collectionView.tag)")
        //(sections[section].objects?[0] as! List).name
        //let moviesInSection = sections[collectionView.tag].objects?[0] as! [Movie]
        print("Section has \(((sections[collectionView.tag].objects?[0]) as! List).movies!.count)) Movies")
            
        log.info( ((sections[collectionView.tag].objects?[0]) as! List).movies!.count)
        return ((sections[collectionView.tag].objects?[0]) as! List).movies!.count   //?.movies?.count ?? 0
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        /* Get cell type */
        let cellReuseIdentifier = "MovieCollectionViewCell"
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as? MovieCollectionViewCell else {
            return UICollectionViewCell()
        }        
            guard let sections = listFRC.sections else {
            log.error("Could not get listFRC.sections")
            return UICollectionViewCell()
        }
        
        guard let allListsInSection = sections[collectionView.tag].objects as? [List],
                    let movies = allListsInSection[0].movies,
                    let movie = movies[indexPath.row] as? Movie else {
                        log.error("allListsInSection")
            
            return UICollectionViewCell()
        }
        
        
        // Set cell defaults
        cell.picture!.image = UIImage(named: "filmRole")
        
        
        if let posterPath = movie.posterPath {
            cell.activityIndicator.startAnimating()
            
            if let savedImage = movie.posterImage {
                 performUIUpdatesOnMain() {
                    
                    cell.picture!.image = savedImage
                    cell.activityIndicator.stopAnimating()
                }
            } else {
                _ = TheMovieDB.sharedInstance().taskForImageWithSize(TheMovieDB.PosterSizes.RowPoster, filePath: posterPath, completionHandler: { (imageData, error) in
                    if let image = UIImage(data: imageData!) {
                        //dispatch_async(dispatch_get_main_queue()) {
                        performUIUpdatesOnMain() {
                            cell.picture!.image = image
                            movie.posterImage = image
                            cell.activityIndicator.stopAnimating()
                        }
                    } else {
                        log.error()
                        cell.activityIndicator.stopAnimating()
                    }
                }) // end tmbd closure
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        print("Collection view at row \(collectionView.tag) selected index path \(indexPath)")
        
        guard let sections = listFRC.sections else {
            log.error("Could not get listFRC.sections")
            return
        }
        
        let allListsInSection = sections[collectionView.tag].objects as! [List]
        let movies =  allListsInSection[0].movies
        let movie = movies?[indexPath.row] as? Movie
        
        let movieDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "awesomeMovieDetailViewController") as! awesomeMovieDetailViewController
        movieDetailViewController.movie = movie
        self.present(movieDetailViewController, animated: true) {                
            // Code
        }
    }
    
    func attemptFetch() {
       
        
        let fetchRequest: NSFetchRequest<List> = List.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "index", ascending: true)]
        
        let topPred = NSPredicate(format: "group = %@", "top")//Catagory.Top.rawValue)
        let genresPred = NSPredicate(format: "group = %@", Catagory.Genres.rawValue)
        let goingAwayPred = NSPredicate(format: "group = %@", Catagory.GoingAway.rawValue)
        let upcomingPred = NSPredicate(format: "group = %@", Catagory.Upcoming.rawValue)
        
        if segmentedControl.selectedSegmentIndex == segmentDict[Catagory.Top.rawValue] {
            
             fetchRequest.predicate = topPred
            
        } else if segmentedControl.selectedSegmentIndex == segmentDict[Catagory.Genres.rawValue]  {
            
             fetchRequest.predicate = genresPred
            
        } else if segmentedControl.selectedSegmentIndex == segmentDict[Catagory.GoingAway.rawValue] {
            
             fetchRequest.predicate = goingAwayPred
            
        } else if segmentedControl.selectedSegmentIndex == segmentDict[Catagory.Upcoming.rawValue] {
            
             fetchRequest.predicate = upcomingPred
        }

        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: "index", cacheName: nil)
        controller.delegate = self
        listFRC = controller
        
        
        if updated == nil {
        CoreNetwork.getJsonFromAWSS3() {
            result, error in
            if (error == nil) {
                log.error(error?.localizedDescription)
            } else {
                print(result ?? "result was nil")
            }
            updated = Date()
            
            }
        }
       
        do {
            
            
            if listFRC.fetchedObjects?.count == 0 {
                log.info("updating Lists")
                CoreNetwork.performUpdateInBackround(context)
            }
            
            try listFRC.performFetch()
            
        } catch {
            
            let error = error as NSError
            log.error("\(error.localizedDescription)" )
            
        }
    }
} // End of extension of class

extension ExploreViewController {
    
    func updateListsinBackround() {
        
    }
}





