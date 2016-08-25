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
    func eventToggleCompletionState(objectID: NSManagedObjectID) -> Bool;
}

class EventView: UIView {

    weak var delegate : EventViewDelegate?;
    
    // In case we ever need access directly
    var eventID : NSManagedObjectID?;
    
    var timeTextView = UITextView.init();
    var descriptionTextView = UITextView.init();
    
    // To determine whether text is strikethrough or normal
    var isComplete : Bool = false;
    
    // For drawing the frame
    let borderHeight : CGFloat = 2.0;
    
    // For calculating the correct frame position during moving
    var tapOffsetFromOrigin : CGPoint = CGPointMake(0, 0);
    
    // How long to hold-press before view moves
    let minPressDuration : CFTimeInterval = 0.25;
    
    var strikeThroughAttributes : [String : NSObject]!;
    var normalAttributes : [String : NSObject]!;
    
    init(frame: CGRect, eventID: NSManagedObjectID, delegate: EventViewDelegate, compactFrame: Bool) {
        super.init(frame: frame);
        
        self.eventID = eventID;
        self.delegate = delegate;
        //self.timeTextView.font         = UIFont.systemFontOfSize(12.0);
        //self.descriptionTextView.font  = UIFont.systemFontOfSize(12.0);
        
        // Check the compactFrame bool
        self.setupViews(compactFrame);
        
        // Add all the gesture recognisers
        self.setupGestureRecognisers();
        
        // Set up the attributed text fonts
        self.setupAttributedFonts();
        
        // Set up the frame, and make it fade in
        self.alpha = 0.0;
        UIView.animateWithDuration(1.0, animations: {
            self.alpha = 1.0;
            //self.backgroundColor = bgColor.colorWithAlphaComponent(0.5);
        })
    }
    
    func setupViews(compactFrame: Bool) {
        // Position of the time label
        let timeLabelOrigin : CGPoint = CGPointMake(0, 0); // 3 points from the top
        let timeLabelHeight : CGFloat = 15.0; // Both labels are equal height, 10 points
        let timeLabelFrame = CGRectMake(timeLabelOrigin.x, timeLabelOrigin.y, frame.width/2, timeLabelHeight);
        self.timeTextView.frame = timeLabelFrame;
        
        let descTVFrame : CGRect!;
        
        // An event of 15 minutes requires a compact view so that the description is visible
        if(compactFrame) {
            let descTVOrigin : CGPoint = CGPointMake(frame.width/2, 0);
            let descTVHeight : CGFloat = self.frame.height;
            descTVFrame = CGRectMake(descTVOrigin.x, descTVOrigin.y, frame.width/2, descTVHeight);
        }
            
        else {
            // Position of description textview
            let descTVOrigin : CGPoint = CGPointMake(timeLabelOrigin.x, timeLabelOrigin.y + timeLabelHeight); // Gap between time and description of 4 points
            let descTVHeight : CGFloat = self.frame.height - descTVOrigin.y - 3; // 3 points from bottom
            descTVFrame = CGRectMake(descTVOrigin.x, descTVOrigin.y, frame.width - descTVOrigin.x, descTVHeight);
        }
        
        self.descriptionTextView.frame = descTVFrame;
        self.descriptionTextView.backgroundColor = UIColor.clearColor();
        self.descriptionTextView.userInteractionEnabled = false;
        
        // Adjust margins
        self.descriptionTextView.textContainer.lineFragmentPadding = 0;
        self.descriptionTextView.textContainerInset = UIEdgeInsetsZero;
        
        self.timeTextView.backgroundColor = UIColor.clearColor();
        self.timeTextView.userInteractionEnabled = false;
        
        // Adjust margins
        self.timeTextView.textContainer.lineFragmentPadding = 0;
        self.timeTextView.textContainerInset = UIEdgeInsetsZero;
        
        self.addSubview(self.timeTextView);
        self.addSubview(self.descriptionTextView);
    }
    
    func setupAttributedFonts() {
        let textColour : UIColor = UIColor.darkGrayColor();
        let font : UIFont = UIFont.systemFontOfSize(12.0);
        let strikethroughStyle = NSNumber.init(integer: NSUnderlineStyle.StyleSingle.rawValue);
        self.strikeThroughAttributes = [NSStrikethroughStyleAttributeName:strikethroughStyle,
                          NSForegroundColorAttributeName:textColour,
                          NSFontAttributeName: font];
        
        let textColour2 : UIColor = UIColor.blackColor();
        let font2 : UIFont = UIFont.systemFontOfSize(12.0);
        let strikethroughStyle2 = NSNumber.init(integer: NSUnderlineStyle.StyleNone.rawValue);
        self.normalAttributes = [NSStrikethroughStyleAttributeName:strikethroughStyle2,
                                 NSForegroundColorAttributeName:textColour2,
                                 NSFontAttributeName: font2];
    }
    
// MARK: - Gesture recognisers
    // Add all gesture recognisers to the view
    func setupGestureRecognisers() {
        // Long press to move the view
        let longPressRecogniser = UILongPressGestureRecognizer.init(target: self, action: #selector(handleLongPress(_:)));
        longPressRecogniser.minimumPressDuration = self.minPressDuration;
        self.addGestureRecognizer(longPressRecogniser);
        
        // Tap to edit
        let tapRecogniser = UITapGestureRecognizer.init(target: self, action: #selector(handleTap(_:)));
        self.addGestureRecognizer(tapRecogniser);
        
        // Swipe to toggle completion state
        let swipeRecogniser = UISwipeGestureRecognizer.init(target: self, action: #selector(handleSwipe(_:)));
        self.addGestureRecognizer(swipeRecogniser);
    }
    
    // Tap to edit this view
    func handleTap(recognizer: UITapGestureRecognizer) {
        self.delegate?.eventShouldBeginEditing(self);
        //self.clipsToBounds
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
    
    // Swipe will toggle completion state of the event
    func handleSwipe(recognizer: UISwipeGestureRecognizer) {
        // Toggle and get the result
        self.isComplete = (self.delegate?.eventToggleCompletionState(self.eventID!))!;
        
        let viewText = self.descriptionTextView.text;
        let timeText = self.timeTextView.text;
        
        if(isComplete == true) {
            // Strikethrough text
            self.descriptionTextView.attributedText = self.textWithStrikethroughFont(viewText);
            self.timeTextView.attributedText = self.textWithStrikethroughFont(timeText!);
        } else {
            // Normal text
            self.descriptionTextView.attributedText = self.textWithNormalFont(viewText);
            self.timeTextView.attributedText = self.textWithNormalFont(timeText);
        }

    }
    
     func textWithStrikethroughFont(text: String) -> NSAttributedString {
         let attrText : NSAttributedString = NSAttributedString.init(string: text, attributes: self.strikeThroughAttributes);
         
         return attrText;
     }
     
     func textWithNormalFont(text: String) -> NSAttributedString {
         let attrText : NSAttributedString = NSAttributedString.init(string: text, attributes: self.normalAttributes);
         
         return attrText;
     }
    
// MARK: - Setter methods
    
    func updateStartAndEndTimes(startTime: NSDate!, endTime: NSDate!) {
        let startTimeString = DTFormatters.sharedInstance.stringFromTime(startTime);
        let endTimeString   = DTFormatters.sharedInstance.stringFromTime(endTime);
        
        self.timeTextView.text = startTimeString + " - " + endTimeString;
    }
    
    func updateEventDescription(description: String) {
        self.descriptionTextView.text = description;
    }
    
    func updateEventCompletionState(isComplete: Bool) {
        
        // Record, then update text
        self.isComplete = isComplete;
        
        let viewText = self.descriptionTextView.text;
        let timeText = self.timeTextView.text;
        
        if(isComplete == true) {
            // Strikethrough text
            self.descriptionTextView.attributedText = self.textWithStrikethroughFont(viewText);
            self.timeTextView.attributedText = self.textWithStrikethroughFont(timeText!);
        } else {
            // Normal text
            self.descriptionTextView.attributedText = self.textWithNormalFont(viewText);
            self.timeTextView.attributedText = self.textWithNormalFont(timeText);
        }
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
    
    func updateBGColor(colorIndex: Int) {
        let color = DataManager.sharedInstance.allColors[colorIndex];
        self.backgroundColor = color.colorWithAlphaComponent(0.4);
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
}
