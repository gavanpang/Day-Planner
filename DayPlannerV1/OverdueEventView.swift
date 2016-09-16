//
//  OverdueEventView.swift
//  DayPlannerV1
//
//  Created by Gavan Pang on 4/09/2016.
//  Copyright © 2016 Gavan Pang. All rights reserved.
//

import UIKit
import CoreData

class OverdueEventView : UIView {
    
    // For drawing the frame
    let borderHeight : CGFloat = 2.0;
    
    // Tracking during long press (moving the view)
    var tapOffsetFromOrigin : CGPoint = CGPointZero;
    
    @IBOutlet var topLabel : UILabel!;
    @IBOutlet var middleLabel : UILabel!;
    @IBOutlet var bottomLabel : UILabel!;

    func setTopText(text: String) {
        self.topLabel.text = text;
    }
    
    func setMiddleText(text: String) {
        self.middleLabel.text = text;
    }
    
    func setBottomText(text: String) {
        self.bottomLabel.text = text;
    }
    
    func setBGColor(colorIndex : Int)
    {
        let color = DataManager.sharedInstance.allColors[colorIndex];
        self.backgroundColor = color.colorWithAlphaComponent(0.4);
    }
    
    func setupGestureRecognizer() {
        // Long press to move the view
        let longPressRecogniser = UILongPressGestureRecognizer.init(target: self, action: #selector(handleLongPress(_:)));
        longPressRecogniser.minimumPressDuration = 0.25;
        self.addGestureRecognizer(longPressRecogniser);
    }
    
    // Moves the event across two different viewcontrollers, we use the keyWindow to achieve this
    @IBAction func handleLongPress(recognizer: UILongPressGestureRecognizer) {
        
        // For this method
        let tapLocInWindow = recognizer.locationInView(nil);
        //let tapLoc = recognizer.locationInView(self.superview);
        
        // This is where we move an event
        if(recognizer.state == UIGestureRecognizerState.Began)
        {
            // Record the original tap location to help keep the view under the user's finger
            self.tapOffsetFromOrigin = recognizer.locationInView(self);
            
            // Change the appearance of the view as feedback of long press
            UIView.animateWithDuration(0.3, animations: {
                self.alpha = 0.5;
            })
            
            // Remove this view from the super TableViewCell
            
            // Add this view to the keyWindow
            
            // Tell the super TableViewCell this view is removed, and shrink to zero height
            
        }
            
        else if(recognizer.state == UIGestureRecognizerState.Changed)
        {
            // Move the view
            self.frame.origin.x = tapLocInWindow.x - self.tapOffsetFromOrigin.x;
            self.frame.origin.y = tapLocInWindow.y - self.tapOffsetFromOrigin.y;
            
            // Check whether the user's finger has crossed over into CenterViewController.
            
            
            // If yes, then:-
            // 1) toggle the side panel animation
            // 2) set the didReopenCenterView flag to indicate this event will be reallocated to the
            // center view
            
        }
            
        else if(recognizer.state == UIGestureRecognizerState.Ended)
        {
            // Did the side panel toggle? If no, then terminate
            
            // Otherwise add the event to the current view

            // First calculate frame origin
            let frameOrigin = CGPointMake(tapLocInWindow.x - self.tapOffsetFromOrigin.x,
                                          tapLocInWindow.y - self.tapOffsetFromOrigin.y);
            
            // Tell CenterViewController that this event has been reallocated
            
            // Let CenterViewController handle everything.
            //self.delegate!.eventMoved(frameOrigin, eventView: self);
            
            // Change the appearance back to default
            UIView.animateWithDuration(0.3, animations: {
                self.alpha = 1.0;
            })
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
    
}
