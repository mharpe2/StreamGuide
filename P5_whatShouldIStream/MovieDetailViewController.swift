//
//  MovieDetailViewController.swift
//  P5_whatShouldIStream
//
//  Created by Michael Harper on 5/31/16.
//  Copyright © 2016 MJH. All rights reserved.
//

import UIKit

class MovieDetailViewController: UITableViewController {
    
    fileprivate let kTableviewHeaderHeight: CGFloat = 280.0
    fileprivate let kTableHeaderCutAway: CGFloat = 0
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
    //MARK: outlets
    @IBOutlet weak var posterImage: UIImageView!
    
    var movie: Movie?
    
    var navItem = UINavigationItem()
    var backItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: nil, action: #selector(buttonPressed))

    //    let titleItem = UINavigationItem()
    //    var tmdbRating: UILabel?

    var headerView: UIView!
    var headerMaskLayer: CAShapeLayer!
    
    @IBOutlet weak var navBar: UINavigationBar!
    
    var effectiveHeight: CGFloat {
        return kTableviewHeaderHeight - kTableHeaderCutAway/2
    }

    
    //MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configUI()
        
        guard let movie = movie else {
            return
        }
        
        downloadMovieDetails(movie: movie)
        
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }

    func buttonPressed(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    func updateHeaderView() {
        var headerRect = CGRect(x: 0, y: -effectiveHeight, width: tableView.bounds.width, height: effectiveHeight + kTableHeaderCutAway/2)
        if (tableView.contentOffset.y < -effectiveHeight) {
            headerRect.origin.y = tableView.contentOffset.y
            headerRect.size.height = -tableView.contentOffset.y + kTableHeaderCutAway/2
        }
        headerView.frame = headerRect
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: headerRect.width, y: 0))
        path.addLine(to: CGPoint(x: headerRect.width, y: headerRect.height))
        path.addLine(to: CGPoint(x: 0, y: headerRect.height - kTableHeaderCutAway))
        headerMaskLayer?.path = path.cgPath
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieDetailCell") as! MovieDetailCell
        cell.overview.text = movie?.overview
        cell.overview.numberOfLines = 0
        cell.overview.sizeToFit()
        
        
        let formater = NumberFormatter()
        formater.maximumFractionDigits = 1
        if let rating = movie?.voteAverage {
            if let vote = formater.string(from: rating) {
                cell.rating!.text = "TMDB Rating: \(vote)"
            }
        }
        return cell
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateHeaderView()
    }

    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    @IBAction func addToWatchList(_ sender: AnyObject) {
        toggleFavoriteButton()
        coreDataStack.saveContext()
    }
    
    func toggleFavoriteButton() {
        
        guard let favoriteMovie = movie else {
            return
        }
        
        if favoriteMovie.onWatchlist == NSNumber(value: true as Bool) {
            favoriteMovie.onWatchlist = NSNumber(value: false as Bool)
            addButton.setImage(#imageLiteral(resourceName: "Blue Heart Filled"), for: UIControlState.normal)        }
        else {
            favoriteMovie.onWatchlist = NSNumber(value: true as Bool)
            addButton.setImage(#imageLiteral(resourceName: "red Heart FIlled"), for: UIControlState.normal)
            
        }
    
    }
    
    func syncFavoriteButton() {
        guard let favoriteMovie = movie else {
            return
        }

         if favoriteMovie.onWatchlist == NSNumber(value: true as Bool) {
             addButton.setImage(#imageLiteral(resourceName: "red Heart FIlled"), for: UIControlState.normal)
        }
         else
        {
            addButton.setImage(#imageLiteral(resourceName: "Blue Heart Filled"), for: UIControlState.normal)
        }
    }
    
    func configUI() {
        
        tableView.estimatedRowHeight = 64
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // set up header view
        headerView = tableView.tableHeaderView
        tableView.tableHeaderView = nil
        tableView.addSubview(headerView)
        
        tableView.contentInset = UIEdgeInsets(top: effectiveHeight, left: 0, bottom: 0, right: 0)
        tableView.contentOffset = CGPoint(x: 0, y: -effectiveHeight)
        
        
        // table header mask layer
        headerMaskLayer = CAShapeLayer()
        headerMaskLayer.fillColor = UIColor.black.cgColor
        headerView.layer.mask = headerMaskLayer
        updateHeaderView()
        
        navItem.leftBarButtonItem = backItem
        navItem.title = movie?.title
        navBar.setItems([navItem], animated: true)
        
        //create place holder image
        posterImage!.image = UIImage(named: "filmRole")
        
        syncFavoriteButton()

        
    }
    
    func downloadMovieDetails(movie: Movie) {
        
        // Download larger image if it does not exist already
        
        if movie.posterImage != nil {
            //self.posterImage.contentMode = .ScaleAspectFit
            self.posterImage.image = movie.posterImage
        } else {
            if let posterPath = movie.posterPath {
                _ = TheMovieDB.sharedInstance().taskForImageWithSize(TheMovieDB.PosterSizes.DetailPoster, filePath: posterPath, completionHandler: { (imageData, error) in
                    if let image = UIImage(data: imageData!) {
                        DispatchQueue.main.async {
                            self.posterImage.image! = image
                        }
                    } else {
                        if let error = error {
                            log.error(error.localizedDescription)
                        }
                        
                    }
                })
            }
        }
        
        
        // Download trailers.
        
        TheMovieDB.sharedInstance().getVideos(movie.tmdb_id!) {
            results, error in
            if error != nil {
                log.error("error")
            }
                
            else {
                if let results = results {
                    log.info(results)
                }
            }
        }

    }
    
}
