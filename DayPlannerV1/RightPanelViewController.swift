//
//  RightPanelViewController.swift
//  DayPlannerV1
//
//  Created by Gavan Pang on 21/07/2016.
//  Copyright © 2016 Gavan Pang. All rights reserved.
//

import UIKit

protocol RightPanelViewControllerDelegate {
    //func animalSelected(animal: Animal)
}

class RightPanelViewController : UITableViewController {
    
    var delegate : RightPanelViewControllerDelegate?;
    private var dateAndTime : NSDateComponents?;
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func displayDateAndTime(dateAndTime: NSDateComponents) {
        self.dateAndTime = dateAndTime;
    }
    
    override func viewWillAppear(animated: Bool) {
        let screenWidth = UIScreen.mainScreen().bounds.width;
        
        let myNav: UINavigationBar = UINavigationBar.init(frame: CGRectMake(60, 20, screenWidth, 44));
        self.view.addSubview(myNav);
        
        let doneItem = UIBarButtonItem.init(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action:#selector(donePressed(_:)));
        let cancelItem = UIBarButtonItem.init(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(cancelPressed(_:)));
        
        let navigItem : UINavigationItem = UINavigationItem.init(title: "");
        navigItem.leftBarButtonItem = cancelItem;
        navigItem.rightBarButtonItem = doneItem;
    }
    
    func donePressed(sender: AnyObject?) {
        
    }
    
    func cancelPressed(sender: AnyObject?) {
        
    }
    
    /*
    (void) viewWillAppear:(BOOL)animated {
    
    UINavigationBar *myNav = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    [UINavigationBar appearance].barTintColor = [UIColor lightGrayColor];
    [self.view addSubview:myNav];
    
    
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
    style:UIBarButtonItemStyleBordered
    target:self
    action:nil];
    
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithTitle:@"Done"
    style:UIBarButtonItemStyleBordered
    target:self action:nil];
    
    
    UINavigationItem *navigItem = [[UINavigationItem alloc] initWithTitle:@"Navigation Title"];
    navigItem.rightBarButtonItem = doneItem;
    navigItem.leftBarButtonItem = cancelItem;
    myNav.items = [NSArray arrayWithObjects: navigItem,nil];
    
    [UIBarButtonItem appearance].tintColor = [UIColor blueColor];
    }
    */
}