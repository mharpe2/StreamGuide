//
//  awesomeMovieDetailViewController.swift
//  P5_whatShouldIStream
//
//  Created by Michael Harper on 11/3/16.
//  Copyright © 2016 MJH. All rights reserved.
//

import UIKit

class awesomeMovieDetailViewController: UIViewController {

    @IBOutlet weak var backroundImage: UIImageView!
   
    @IBOutlet weak var moveTitle: UILabel!
    @IBOutlet weak var overView: UITextView!
    @IBOutlet weak var releaseDate: UILabel!
    @IBOutlet weak var directedBy: UILabel!
    
    @IBOutlet weak var overViewHeightConstraint: NSLayoutConstraint!
    var imageGradient: CAGradientLayer!
    var movie: Movie!
    var movieString =  NSMutableAttributedString()
    var movieImageGradientLayer = CAGradientLayer()
    var movieTitle = NSMutableAttributedString()
    var movieOverview = NSMutableAttributedString()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let movie = movie else {
            log.error("movie is nil")
            return
        }
        
       // Movie information
        
        let attributes = [NSFontAttributeName:UIFont(name: "Arial-BoldMt", size:15)!,
                          NSForegroundColorAttributeName: UIColor .white ]

        moveTitle.attributedText = NSMutableAttributedString(string: movie.title!, attributes: attributes)
        
        directedBy.attributedText = NSMutableAttributedString(string: "DIRECTED BY", attributes: attributes)
        
        
        let calendar = Calendar.current
        let year = String (calendar.component(.year, from: movie.releaseDate!))
        releaseDate.attributedText = NSMutableAttributedString(string: year, attributes: attributes)
        
        
        overView.attributedText = NSMutableAttributedString(string: movie.overview!, attributes: attributes)
        
        let size = overView.sizeThatFits( CGSize(width: overView.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
        overView.contentSize.height = size.height
        overView.sizeToFit()
               
        
        // Backround Image
        
        if let posterPath = movie.posterPath {
            
            if let savedImage = movie.largelPosterImage {
                performUIUpdatesOnMain() {
                    self.backroundImage.image = savedImage
                }
            } else {
                _ = TheMovieDB.sharedInstance().taskForImageWithSize(TheMovieDB.PosterSizes.originalPoster, filePath: posterPath, completionHandler: { (imageData, error) in
                    if let image = UIImage(data: imageData! as Data) {
                        performUIUpdatesOnMain() {
                            self.backroundImage.image = image
                            self.movie.largelPosterImage = image
                            
                            // Setup gradient
                            self.imageGradient = CAGradientLayer()
                            self.imageGradient.frame = self.backroundImage.frame
                            self.imageGradient.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
                            self.imageGradient.locations = [0.0, 0.95]
                            self.imageGradient.opacity = 0.75
                            self.backroundImage.layer.insertSublayer(self.imageGradient, at: 0)
                            
                        }
                    } else {
                        log.error("could not download image for \(self.movie.title ?? "uknown")")
                    }
                }) // end tmbd closure
            }
        }
        
        //Download trailer array
        
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    @IBAction func tapRecognizer(_ sender: UITapGestureRecognizer) {
        
         log.info("tap gesture")
    }
  
    
    @IBAction func panGestureRecogizer(_ sender: UIPanGestureRecognizer) {
         log.info("pan gesture")
        self.dismiss(animated: true) {
            // code
        }
    }
    
}
