//
//  LoadingVC.swift
//  P5_whatShouldIStream
//
//  Created by Michael Harper on 8/21/16.
//  Copyright © 2016 MJH. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import ChameleonFramework


class LoadingVC: UIViewController {

      @IBOutlet weak var loadingView: NVActivityIndicatorView!
    
    var myView: NVActivityIndicatorView!
    var frame = CGRect()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
