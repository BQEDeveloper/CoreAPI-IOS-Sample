//
//  BaseViewController.swift
//  Timelogger
//
//  Created by Zulkarnain Shah on 08/02/19.
//  Copyright © 2019 BQE. All rights reserved.
//

import Foundation
import UIKit
import Lottie

class BaseViewController: UIViewController {
    @IBOutlet weak var dimView: UIView!
    @IBOutlet weak var lottieAnimationView: LOTAnimationView!
    @IBOutlet weak var lblLoaderTitle: UILabel!
    
    /** Displays a Lottie powered progress bar*/
    func showLoader(message: String){
        self.view.isUserInteractionEnabled = false
        self.lottieAnimationView.isHidden = false
        self.dimView.isHidden = false
        self.lottieAnimationView.setAnimation(named: "loading")
        self.lottieAnimationView.loopAnimation = true
        self.lottieAnimationView.play()
        self.lblLoaderTitle.text = message
    }
    
    /** Hides the progress loader */
    func hideLoader(){
        self.view.isUserInteractionEnabled = true
        self.lottieAnimationView.stop()
        self.dimView.isHidden = true
    }
}
