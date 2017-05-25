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
    //@IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var overView: UITextView!
    @IBOutlet weak var overViewHeightConstraint: NSLayoutConstraint!
    var movie: Movie!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       // movieTitle.text = movie.title
        overView.text = movie.overview
        //sizeThatFits:CGSizeMake(textView.frame.size.width, CGFLOAT_MAX)].height
        let size = overView.sizeThatFits( CGSize(width: overView.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
        overView.contentSize.height = size.height
        overView.sizeToFit()
               
        
        if let posterPath = movie.posterPath {
            
            if let savedImage = movie.largelPosterImage {
                DispatchQueue.main.async {
                    self.backroundImage.image = savedImage
                }
            } else {
                _ = TheMovieDB.sharedInstance().taskForImageWithSize(TheMovieDB.PosterSizes.originalPoster, filePath: posterPath, completionHandler: { (imageData, error) in
                    if let image = UIImage(data: imageData! as Data) {
                        DispatchQueue.main.async {
                            self.backroundImage.image = image
                            self.movie.largelPosterImage = image
                            
                        }
                    } else {
                        log.error("could not download image for \(self.movie.title ?? "uknown")")
                    }
                }) // end tmbd closure
            }
        }
        
        //Download trailer array
        
        TheMovieDB.sharedInstance().getVideos(movie.id!) {
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
