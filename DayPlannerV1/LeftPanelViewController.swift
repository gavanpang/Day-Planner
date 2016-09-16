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
    
    var multiUseController : MultiUseTableViewController?;

    @IBOutlet var tabBar : UITabBar!;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    // Custom setup of the nav bar of the view
    override func viewWillAppear(animated: Bool) {
        let screenWidth = UIScreen.mainScreen().bounds.width;
        
        let myNav: UINavigationBar = UINavigationBar.init(frame: CGRectMake(0, 20, screenWidth - 35, 44));
        self.view.addSubview(myNav);
        
        let doneItem = UIBarButtonItem.init(title: "Done", style: UIBarButtonItemStyle.Plain, target: self, action:#selector(donePressed(_:)));
        let cancelItem = UIBarButtonItem.init(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(cancelPressed(_:)));
        
        let navigItem : UINavigationItem = UINavigationItem.init(title: "");
        navigItem.leftBarButtonItem = cancelItem;
        navigItem.rightBarButtonItem = doneItem;
        
        myNav.items = [navigItem];
    }
    
    func donePressed(sender: AnyObject?) {
        // Update the event
        //self.delegate?.rightControllerDidEndEditingEvent(self.eventViewController!);
    }
    
    func cancelPressed(sender: AnyObject?) {
        // Dismiss the side panel only
        //self.delegate?.rightControllerDidCancelEditing();
    }
    
    func tabBar(tabBar: UITabBar!, didSelectItem item: UITabBarItem!) {

        switch item.tag  {
        case 0:
            // Overdue
            self.setTableViewWithOverdueDefaults();
            break
        case 1:
            // Pending
            break
        case 2:
            // Recurring
            break
        default:
            print("default tab");
            // Overdue
            break
        }
        
        // Save the selection
        DataManager.sharedInstance.setLastSelectedTab(item.tag);
    }
    
    func setTableViewWithOverdueDefaults() {
        self.multiUseController?.setTableViewStateOverdue();
    }
    
    // This method gives us a reference to the TableViewController, as it's embedded in container
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? MultiUseTableViewController
            where segue.identifier == "embedMultiUseTable" {
            
            self.multiUseController = vc;
            self.multiUseController?.delegate = self;
            
            // Init the view with the correct tab and data
            let selectedTab = DataManager.sharedInstance.lastSelectedTab;
            self.tabBar.selectedItem = self.tabBar.items![selectedTab];
            self.tabBar(self.tabBar, didSelectItem: self.tabBar.selectedItem);
            }
    }
}

extension LeftPanelViewController : MultiUseTableViewControllerDelegate {
    
}
