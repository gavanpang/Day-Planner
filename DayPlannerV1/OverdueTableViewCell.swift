//
//  OverdueTableViewCell.swift
//  DayPlannerV1
//
//  Created by Gavan Pang on 4/09/2016.
//  Copyright © 2016 Gavan Pang. All rights reserved.
//

import UIKit

class OverdueTableViewCell: UITableViewCell {

    @IBOutlet var overdueEventView : OverdueEventView!;
    @IBOutlet var toggleCompleteButton : UIButton!;
    
    
    func setTimeAndDateText(startDateTime: NSDate, andEnd endTime: NSDate) {
        let dateText = DTFormatters.sharedInstance.stringFromDate(startDateTime);
        let startText = DTFormatters.sharedInstance.stringFromTime(startDateTime);
        let endText = DTFormatters.sharedInstance.stringFromTime(endTime);
        
        self.overdueEventView.setTopText(dateText);
        self.overdueEventView.setMiddleText(startText + " - " + endText);
    }
    
    func setEventDescriptionText(text: String) {
        self.overdueEventView.setBottomText(text);
    }
    
    func setBGColor(colorIndex: Int) {
        self.overdueEventView.setBGColor(colorIndex);        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.overdueEventView.setupGestureRecognizer();
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
