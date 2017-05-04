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
    let topSegment = "top"
    let segment: [String] = ["top", "genres", "goingaway", "upcoming"]
    var selectedListGroup = 0
    var predicate = NSPredicate()
    var storedOffsets = [Int: CGFloat]()
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!

    var imageView: UIImageView!
    
    
    //MARK: CoreData ------------------------------------------------------------------
    var listFRC: FetchedResultsController<List>!
    
    lazy var mainContext = {
        return CoreDataStackManager.sharedInstance().coreDataStack!.mainQueueContext
    }
    
    lazy var genreContext = CoreDataStackManager.sharedInstance().coreDataStack!.newBackgroundWorkerMOC()
    //lazy var  updateWorkerContext = CoreDataStackManager.sharedInstance().coreDataStack!.newBackgroundWorkerMOC()
    
    lazy var frcDelegate: ListFetchedResultsTableViewControllerDelegate = {
        
        return ListFetchedResultsTableViewControllerDelegate(tableView: self.tableView)
    }()
    
    fileprivate func getListFRCWithGroup(_ name: String) -> FetchedResultsController<List>
    {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: List.entityName)
        fetchRequest.predicate = NSPredicate(format: "group = %@", name)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "index", ascending: true)]
        fetchRequest.sortDescriptors = []
        
        //Create fetched results controller with the new fetch request.
        let fetchedResultsController = FetchedResultsController<List>(fetchRequest: fetchRequest,
                                                                      managedObjectContext: self.mainContext(), sectionNameKeyPath: "index", cacheName: nil)
        //self.tableView.reloadData()
        return fetchedResultsController
        
    }
    
    
    //MARK: LifeCycle -------------------------------------------------------------------
    
    //MARK: viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO: There is a concurency error here!!!! The error does not show because coredata debug
        // -com.apple.CoreData.ConcurrencyDebug 1 is not enabled.......
        // * NEED TO FIX
        
        //set delegates
        listFRC = getListFRCWithGroup( segment[selectedListGroup]  )
        
        // load exising lists
        //self.mainContext().performBlockAndWait() {
        self.mainContext().performBlockAndWait() {
            do {
                
                self.listFRC.setDelegate(self.frcDelegate)
                try self.listFRC.performFetch()
            
            } catch  _ {
                log.error(" Error fetching lists and movies")
            }
            
            log.info("Found \(self.listFRC.count) ")
        }
        
        self.mainContext().performBlockAndWait() {
            // check for updated list online
            CoreNetwork.performUpdateInBackround( self.mainContext() )
            self.mainContext().saveContext()
        }
        
    }
    
    
    //MARK: TableView Methods ------------------------------------------------------------
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return listFRC.sections?.count ?? 1
        
        if let sections = listFRC.sections, sections.count > 0 {
            return sections[section].objects.count
        } else {
            return 0
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "streamingServiceRow")  as? StreamingServiceRow //dequeueReusableCell(withIdentifier: "streamingServiceRow") as? StreamingServiceRow {
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
        return sections[section].objects[0].name ?? nil
    }
    
    // MARK: Segmented Controller
    
    
    @IBAction func segmentedControlChanged(_ sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex > segment.count {
            return
        }
        
        let selectedSegment = segment[sender.selectedSegmentIndex]
        listFRC = getListFRCWithGroup( selectedSegment )
        listFRC.setDelegate(frcDelegate)
        
        log.info("switch group to \(selectedSegment)")
        
        do {
            try self.listFRC.performFetch()
        }
        catch _ {
            log.error("error switching group to \(selectedSegment)")
            return
        }
        
        
        var rankedGenres: [Genre]? = []
        if selectedSegment == "genres" {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Genre.entityName)
            fetchRequest.sortDescriptors = []
            
            mainContext().performBlock() {
                do {
                    if let fetchResults = try self.mainContext().executeFetchRequest(fetchRequest) as? [Genre] {
                        
                        rankedGenres = fetchResults
                        rankedGenres!.sortInPlace({$0.movies!.count > $1.movies!.count})
                        
                        // build an array of images
                        var imageArray: [UIImage] = [UIImage]()
                        //for genre in rankedGenres! {
                        let genre = rankedGenres?.first
                        
                        if let genreMovies = genre!.movies {
                            for movie in genreMovies {
                                if let myMovie = movie as? Movie {
                                    if let image = myMovie.posterImage{
                                        let thumbnail = self.makeThumbNail(image)
                                        imageArray.append(thumbnail)
                                    }
                                }
                            }
                        }
                        //} // End for genre in rankedGenres
                        
                        //                        // dispaly image collage
                        //                        let collageImage = CollageImage.collageImage(self.view.frame, images: imageArray)
                        //                        self.imageView = UIImageView(image: collageImage)
                        //                        //self.imageView.contentMode = .TopLeft
                        //                        self.view.addSubview(self.imageView)
                        
                    }
                } catch _ {
                    log.error("fuckall")
                }
                
            }
        } // end of special "genres" case

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
        if let sections = listFRC.sections {
            return sections.count
        }
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sections = listFRC.sections else {
            log.error("Could not get listFRC.sections")
            return 0
        }
        
        log.info("tag: \(collectionView.tag)")
        return sections[collectionView.tag].objects[0].movies!.count ?? 0
        
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
        
        let allListsInSection = sections[collectionView.tag].objects
        let movies = allListsInSection[0].movies
        let movie = movies![indexPath.row] as! Movie
        
        // Set cell defaults
        cell.picture!.image = UIImage(named: "filmRole")
        
        
        if let posterPath = movie.posterPath {
            cell.activityIndicator.startAnimating()
            
            if let savedImage = movie.posterImage {
                DispatchQueue.main.async {
                    
                    cell.picture!.image = savedImage
                    cell.activityIndicator.stopAnimating()
                }
            } else {
                TheMovieDB.sharedInstance().taskForImageWithSize(TheMovieDB.PosterSizes.RowPoster, filePath: posterPath, completionHandler: { (imageData, error) in
                    if let image = UIImage(data: imageData!) {
                        dispatch_async(dispatch_get_main_queue()) {
                            cell.picture!.image = image
                            movie.posterImage = image
                            cell.activityIndicator.stopAnimating()
                        }
                    } else {
                        print(error)
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
        
        let allListsInSection = sections[collectionView.tag].objects
        let movies = allListsInSection[0].movies
        let movie = movies![indexPath.row] as! Movie
        
        let movieDetailViewController = self.storyboard?.instantiateViewController(withIdentifier: "MovieDetailViewController") as! MovieDetailViewController
        movieDetailViewController.movie = movie
        self.present(movieDetailViewController, animated: true) {                
            // Code
        }
    }
} // End of extension of class

extension ExploreViewController {
    
    func updateListsinBackround() {
        
    }
}





//---------------------------------------------------------------------------------------
////
////  ExploreScrollViewController.swift
////  P5_whatShouldIStream
////
////  Created by Michael Harper on 6/5/16.
////  Copyright © 2016 MJH. All rights reserved.
////
//
//import UIKit
//import CoreData
////import BNRCoreDataStack
////import XCGLogger
//
//class ExploreScrollViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
//{
//    var selectedIndexes = [NSIndexPath]()
//    var insertedIndexPaths: [NSIndexPath]!
//    var deletedIndexPaths: [NSIndexPath]!
//    var updatedIndexPaths: [NSIndexPath]!
//
//    let services = ["Netflix", "Amazon Prime"]
//    var movies: [Movie]?
//    let log = XCGLogger.defaultInstance()
//    var storedOffsets = [Int: CGFloat]()
//
//    @IBOutlet weak var tableView: UITableView!
//    @IBOutlet weak var segmentedControl: UISegmentedControl!
//
//    lazy var mainContext = {
//        return CoreDataStackManager.sharedInstance().coreDataStack!.mainQueueContext
//    }
//
//    lazy var genreContext = CoreDataStackManager.sharedInstance().coreDataStack!.newBackgroundWorkerMOC()
//
//    // fetchedResultsController
////    lazy var fetchedResultsController: FetchedResultsController<Movie> = {
////
////        let fetchRequest = NSFetchRequest(entityName: Movie.entityName)
////        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "service", ascending: true)]
////        fetchRequest.sortDescriptors = []
////
////        //Create fetched results controller with the new fetch request.
////        var fetchedResultsController = FetchedResultsController<Movie>(fetchRequest: fetchRequest,
////                                                                       managedObjectContext: self.mainContext(),
////                                                                       sectionNameKeyPath: nil,cacheName: nil)
////
////        return fetchedResultsController
////    }()
//
//    lazy var frcDelegate: MoviesFetchedResultsTableViewControllerDelegate = {
//        return MoviesFetchedResultsTableViewControllerDelegate(tableView: self.tableView)
//    }()
//
//
//    private func getListFRCWithGroup(name: String) -> FetchedResultsController<List>
//    {
//
//        let fetchRequest = NSFetchRequest(entityName: List.entityName)
//        fetchRequest.predicate = NSPredicate(format: "group = %@", name)
//        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "index", ascending: true)]
//        fetchRequest.sortDescriptors = []
//
//        //Create fetched results controller with the new fetch request.
//        let fetchedResultsController = FetchedResultsController<List>(fetchRequest: fetchRequest,
//                                                                      managedObjectContext: self.mainContext(), sectionNameKeyPath: "index", cacheName: nil)
//        //self.tableView.reloadData()
//        return fetchedResultsController
//
//    }
//
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//
//        // perform fetch
//        do {
//            try self.fetchedResultsController.
//        } catch let error as NSError {
//            print("Error performing fetch")
//        }
//        if self.fetchedResultsController.fetchedObjects?.count == 0{
//            print("no results from fetched results")
//        } else {
//            print("results > 0")
//            movies = self.fetchedResultsController.fetchedObjects
//        }
//
//    }
//
//
//    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return fetchedResultsController.sections?.count ?? 0
//        //.sections?[section].objects.count ?? 0
//    }
//
//   func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//
//        if let cell = tableView.dequeueReusableCellWithIdentifier("streamingServiceRow") as? StreamingServiceRow {
//            log.verbose("returning cell \(cell.description)"    )
//            return cell
//        } else {
//            log.verbose("returning empty streaming service row" )
//            return StreamingServiceRow()
//    }
//
//    }
//
//    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
//
//        guard let tableViewCell = cell as? StreamingServiceRow else { return }
//
//        tableViewCell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
//        tableViewCell.collectionViewOffset = storedOffsets[indexPath.row] ?? 0
//    }
//
//    func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
//
//        guard let tableViewCell = cell as? StreamingServiceRow else { return }
//
//        storedOffsets[indexPath.row] = tableViewCell.collectionViewOffset
//    }
//
//
//}
//
//
//extension ExploreScrollViewController: UICollectionViewDelegate, UICollectionViewDataSource {
//
//    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
//        print("in numberOfSectionsInCollectionView()")
//        return self.fetchedResultsController.sections?.count ?? 0
//    }
//
//    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//
//        let sectionInfo = self.fetchedResultsController.sections![section]
//        return sectionInfo.objects.count
//
//        //return (fetchedResultsController.sections?[collectionView.tag].objects.count) ?? 0
//
//    }
//
//    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
//
//        /* Get cell type */
//        let cellReuseIdentifier = "MovieCollectionViewCell"
//        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellReuseIdentifier, forIndexPath: indexPath) as! MovieCollectionViewCell
//
//        //get a moive array from BNR core data
//        guard let sections = fetchedResultsController.sections else {
//            assertionFailure("No Sections in fetched results")
//            return cell
//        }
//
//        let section = sections[indexPath.section]
//        let movie = section.objects[indexPath.row]
//
//        /* Set cell defaults */
//        cell.picture!.image = UIImage(named: "filmRole")
//
//        if let posterPath = movie.posterPath {
//            TheMovieDB.sharedInstance().taskForImageWithSize(TheMovieDB.PosterSizes.RowPoster, filePath: posterPath, completionHandler: { (imageData, error) in
//                if let image = UIImage(data: imageData!) {
//                    dispatch_async(dispatch_get_main_queue()) {
//                        cell.picture!.image = image
//                    }
//                } else {
//                    print(error)
//                }
//            })
//        }
//
//        return cell
//    }
//
//    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
//
//        print("Collection view at row \(collectionView.tag) selected index path \(indexPath)")
//        //get a moive array from BNR core data
//        guard let sections = fetchedResultsController.sections else {
//            assertionFailure("No Sections in fetched results")
//            return
//        }
//
//        let section = sections[indexPath.section]
//        let movie = section.objects[indexPath.row]
//
//        let movieDetailViewController = self.storyboard?.instantiateViewControllerWithIdentifier("MovieDetailViewController") as! MovieDetailViewController
//
//        movieDetailViewController.movie = movie
//
//        //self.show
//        self.navigationController?.pushViewController(movieDetailViewController, animated: true)
//        //self.presentViewController(movieDetailViewController, animated: true) {
//
//        // Code
//
//    }
//
//   }
//
//extension ExploreScrollViewController: NSFetchedResultsControllerDelegate {
//
//    func controllerWillChangeContent(controller: NSFetchedResultsController) {
//
//        // We are about to handle some new changes. Start out with empty arrays for each change type
//        insertedIndexPaths = [NSIndexPath]()
//        deletedIndexPaths = [NSIndexPath]()
//        updatedIndexPaths = [NSIndexPath]()
//
//        print("in controllerWillChangeContent")
//    }
//
//    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
//        switch type {
//
//        case .Insert:
//            print("Insert an item")
//            // Here we are noting that a new Color instance has been added to Core Data. We remember its index path
//            // so that we can add a cell in "controllerDidChangeContent". Note that the "newIndexPath" parameter has
//            // the index path that we want in this case
//            insertedIndexPaths.append(newIndexPath!)
//            break
//        case .Delete:
//            print("Delete an item")
//            // Here we are noting that a Color instance has been deleted from Core Data. We keep remember its index path
//            // so that we can remove the corresponding cell in "controllerDidChangeContent". The "indexPath" parameter has
//            // value that we want in this case.
//            deletedIndexPaths.append(indexPath!)
//            break
//        case .Update:
//            print("Update an item.")
//            // We don't expect Color instances to change after they are created. But Core Data would
//            // notify us of changes if any occured. This can be useful if you want to respond to changes
//            // that come about after data is downloaded. For example, when an images is downloaded from
//            // Flickr in the Virtual Tourist app
//            updatedIndexPaths.append(indexPath!)
//            break
//        case .Move:
//            print("Move an item. We don't expect to see this in this app.")
//            break
//            //default:
//            //break
//        }
//    }
//
////    func controllerDidChangeContent(controller: NSFetchedResultsController) {
////
////        print("in controllerDidChangeContent. changes.count: \(insertedIndexPaths.count + deletedIndexPaths.count)")
////
////        collectionView.performBatchUpdates({() -> Void in
////
////            for indexPath in self.insertedIndexPaths {
////                self.collectionView.insertItemsAtIndexPaths([indexPath])
////            }
////
////            for indexPath in self.deletedIndexPaths {
////                self.collectionView.deleteItemsAtIndexPaths([indexPath])
////            }
////            
////            for indexPath in self.updatedIndexPaths {
////                self.collectionView.reloadItemsAtIndexPaths([indexPath])
////            }
////            
////            }, completion: nil)
////    }
//
//    
//}
