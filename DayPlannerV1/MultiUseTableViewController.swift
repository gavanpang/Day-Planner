//
//  MultiUseTableViewController.swift
//  DayPlannerV1
//
//  Created by Gavan Pang on 25/08/2016.
//  Copyright © 2016 Gavan Pang. All rights reserved.
//

import UIKit
import CoreData

protocol MultiUseTableViewControllerDelegate {
    
}

enum TabState {
    case Overdue
    case Pending
    case Recurring
}

class MultiUseTableViewController: UITableViewController {

    var delegate : MultiUseTableViewControllerDelegate?;
  
    var tabSelected : TabState = .Overdue;
    
    // Change cell height depending on which tab is displayed
    var cellHeight : CGFloat = 0.0;
    
    // One array to store data for all three tabs
    var dataArray : [NSManagedObject] = [];
    
    /*
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
 */   
 
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }


    // MARK: - Tab Bar state
    func setTableViewStateOverdue() {
        self.tabSelected = TabState.Overdue;

        // Adapt the cell height
        self.cellHeight = 70.0;
        
        // Load the data
        self.dataArray = DataManager.sharedInstance.loadOverdueEvents();
        
        // Display
        self.tableView.reloadData();
    }
    
    func setTableViewStatePending() {
        
    }
    
    func setTableViewStateRecurring() {
        
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1;
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.dataArray.count;
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell : UITableViewCell;
        
        switch tabSelected  {
        case .Overdue:
            cell = self.getCellWithIdentifierOverdue(indexPath);
            
            //self.setTableViewWithOverdueDefaults();
            break
        case .Pending:
            cell = self.getCellWithIdentifierPending(indexPath);

            break
        case .Recurring:
            cell = self.getCellWithIdentifierRecurring(indexPath);

            break
        }
        
        return cell;
    }
    
    private func getCellWithIdentifierOverdue(indexPath: NSIndexPath) -> OverdueTableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("overdue", forIndexPath: indexPath) as! OverdueTableViewCell;
        
        let overdueEvent = dataArray[indexPath.row] as! Event;
        
        cell.setTimeAndDateText(overdueEvent.eventDateAndTime!, andEnd: overdueEvent.endTime!);
        cell.setEventDescriptionText(overdueEvent.eventDescription!);
        cell.setBGColor((overdueEvent.color?.integerValue)!);

        return cell;
    }
    
    private func getCellWithIdentifierPending(indexPath: NSIndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCellWithIdentifier("pending", forIndexPath: indexPath)
        
    }
    
    private func getCellWithIdentifierRecurring(indexPath: NSIndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCellWithIdentifier("recurring", forIndexPath: indexPath)
        
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.cellHeight;
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
