//
//  AlertViewController.swift
//  Kai12
//
//  Created by Class on 2022/4/13.
//

import UIKit

class AlertViewController: UIViewController {

    @IBOutlet var blackView: UIView!
    @IBOutlet weak var alertButton1: UIButton!
    @IBOutlet weak var alertButton2: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func dontGo(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)

    }
    
    

}
