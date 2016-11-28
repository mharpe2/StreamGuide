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
    @IBOutlet weak var movieTitle: UILabel!
    
    var movie: Movie!
    let log = XCGLogger.defaultInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let posterPath = movie.posterPath {
            
            if let savedImage = movie.largelPosterImage {
                dispatch_async(dispatch_get_main_queue()) {
                    self.backroundImage.image = savedImage
                }
            } else {
                TheMovieDB.sharedInstance().taskForImageWithSize(TheMovieDB.PosterSizes.originalPoster, filePath: posterPath, completionHandler: { (imageData, error) in
                    if let image = UIImage(data: imageData! as NSData) {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.backroundImage.image = image
                            self.movie.largelPosterImage = image
                            
                        }
                    } else {
                        self.log.error("could not download image for \(self.movie.title)")
                    }
                }) // end tmbd closure
            }
        }
 
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
