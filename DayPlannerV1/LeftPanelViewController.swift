//
//  LeftPanelViewController.swift
//  DayPlannerV1
//
//  Created by Gavan Pang on 21/07/2016.
//  Copyright © 2016 Gavan Pang. All rights reserved.
//

import UIKit

protocol LeftPanelViewControllerDelegate {
    //func animalSelected(animal: Animal)
}

class LeftPanelViewController : UIViewController {
    
    var delegate : LeftPanelViewControllerDelegate?;
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
