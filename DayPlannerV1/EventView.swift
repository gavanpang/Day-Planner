//
//  EventView.swift
//  DayPlannerV1
//
//  Created by Gavan Pang on 24/07/2016.
//  Copyright © 2016 Gavan Pang. All rights reserved.
//

import UIKit
import CoreData

protocol EventViewDelegate : class {
    func eventMoved(tapLocation: CGPoint, eventView: EventView);
    func eventShouldBeginEditing(eventView: EventView);
}

class EventView: UIView {

    weak var delegate : EventViewDelegate?;
    
    var eventID : NSManagedObjectID?;
    
    var timeLabel : UILabel! = UILabel.init();
    var descriptionLabel : UILabel! = UILabel.init();
    
    // For drawing the frame
    let borderHeight : CGFloat = 2.0;
    
    // For calculating the correct frame position during moving
    var tapOffsetFromOrigin : CGPoint = CGPointMake(0, 0);
    
    // How long to hold-press before view moves
    let minPressDuration : CFTimeInterval = 0.25;

    init(frame: CGRect, eventID: NSManagedObjectID, delegate: EventViewDelegate, compactFrame: Bool) {
        super.init(frame: frame);
        
        self.eventID = eventID;
        self.delegate = delegate;
        self.timeLabel.font         = UIFont.systemFontOfSize(12.0);
        self.descriptionLabel.font  = UIFont.systemFontOfSize(12.0);
        
        
        // TODO: Check if event is 15 mins, use a smaller rect frame on a single line
        // Check the compactFrame bool
        
        // Position of the time label
        let timeLabelOrigin : CGPoint = CGPointMake(5, 3); // 3 points from the top
        let timeLabelHeight : CGFloat = 10.0; // Both labels are equal height, 10 points
        let timeLabelFrame = CGRectMake(timeLabelOrigin.x, timeLabelOrigin.y, frame.width - timeLabelOrigin.x, timeLabelHeight);
        self.timeLabel.frame = timeLabelFrame;

        // Position of description label
        let descLabelOrigin : CGPoint = CGPointMake(timeLabelOrigin.x, timeLabelOrigin.y + timeLabelHeight + 4); // Gap between time and description of 4 points
        let descLabelHeight : CGFloat = frame.height - descLabelOrigin.y - 3; // 3 points from bottom
        let descLabelFrame = CGRectMake(descLabelOrigin.x, descLabelOrigin.y, frame.width - descLabelOrigin.x, descLabelHeight);
        self.descriptionLabel.frame = descLabelFrame;
        
        self.addSubview(self.timeLabel);
        self.addSubview(self.descriptionLabel);
        
        // Long press to move the view
        let longPressRecogniser = UILongPressGestureRecognizer.init(target: self, action: #selector(handleLongPress(_:)));
        longPressRecogniser.minimumPressDuration = self.minPressDuration;
        self.addGestureRecognizer(longPressRecogniser);
        
        // Tap to edit
        let tapRecogniser = UITapGestureRecognizer.init(target: self, action: #selector(handleTap(_:)));
        self.addGestureRecognizer(tapRecogniser);
        
        // Set up the frame, and make it fade in
        self.alpha = 0.0;
        UIView.animateWithDuration(1.0, animations: {
            self.alpha = 1.0;
            //self.backgroundColor = bgColor.colorWithAlphaComponent(0.5);
        })
    }
    
    // Moves the event in the CenterViewController
    func handleLongPress(recognizer: UILongPressGestureRecognizer) {
        
        //let tapLocInWindow = recognizer.locationInView(nil);
        let tapLoc = recognizer.locationInView(self.superview);
        
        // This is where we move an event
        if(recognizer.state == UIGestureRecognizerState.Began)
        {
            // Record the original tap location
            self.tapOffsetFromOrigin = recognizer.locationInView(self);
            
            // Change the appearance of the view as feedback of long press
            UIView.animateWithDuration(0.3, animations: {
                self.alpha = 0.5;
            })
        }
        
        else if(recognizer.state == UIGestureRecognizerState.Changed)
        {
            //move your views here.
            
            self.frame.origin.x = tapLoc.x - self.tapOffsetFromOrigin.x;
            self.frame.origin.y = tapLoc.y - self.tapOffsetFromOrigin.y;
        }
        
        else if(recognizer.state == UIGestureRecognizerState.Ended)
        {
            //else do cleanup
            let frameOrigin = CGPointMake(tapLoc.x - self.tapOffsetFromOrigin.x,
                                        tapLoc.y - self.tapOffsetFromOrigin.y);
            
            // Let CenterViewController handle everything.
            self.delegate!.eventMoved(frameOrigin, eventView: self);
            
            // Change the appearance back to default
            UIView.animateWithDuration(0.3, animations: {
                self.alpha = 1.0;
            })
        }
    }

    // Tap to edit this view
    func handleTap(recognizer: UITapGestureRecognizer) {
        self.delegate?.eventShouldBeginEditing(self);
        //self.clipsToBounds
    }
    
// MARK: - Setter methods
    
    func updateStartAndEndTimes(startTime: NSDate!, endTime: NSDate!) {
        let startTimeString = DTFormatters.sharedInstance.stringFromTime(startTime);
        let endTimeString   = DTFormatters.sharedInstance.stringFromTime(endTime);
        
        self.timeLabel.text = startTimeString + " - " + endTimeString;
    }
    
    func updateEventDescription(description: String) {
        self.descriptionLabel.text = description;
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
        
        //create the path
        let borderPath = UIBezierPath();
        
        //set the path's line width to the height of the stroke
        borderPath.lineWidth = self.borderHeight;
        
        //move the initial point of the path
        //to the start of the horizontal stroke
        borderPath.moveToPoint(CGPoint(x: 0, y: 0));
        
        //add a point to the path at the end of the stroke
        borderPath.addLineToPoint(CGPointMake(self.bounds.width, 0));
        borderPath.addLineToPoint(CGPointMake(self.bounds.width, self.bounds.height));
        borderPath.addLineToPoint(CGPointMake(0, self.bounds.height));
        borderPath.addLineToPoint(CGPointMake(0, 0));
        
        //set the stroke color
        UIColor.blackColor().setStroke()
        
        //draw the stroke
        borderPath.stroke();
    }
    
    func updateBGColor(bgColor: UIColor) {
        self.backgroundColor = bgColor.colorWithAlphaComponent(0.5);
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
}
