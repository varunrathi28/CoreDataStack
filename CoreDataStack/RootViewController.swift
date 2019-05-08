//
//  ViewController.swift
//  CoreDataStack
//
//  Created by Varun Rathi on 08/05/19.
//  Copyright © 2019 Varun Rathi. All rights reserved.
//

import UIKit

class RootViewController: UIViewController {


    var coreDataStack:CoreDataManager?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        coreDataStack = CoreDataManager(modelName: "Model", completionBlock: {
            self.setUpViews()
        })
    }
    
    func setUpViews(){
        view.backgroundColor = UIColor.red
    }


}

