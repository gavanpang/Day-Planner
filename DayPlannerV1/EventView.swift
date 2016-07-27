//
//  EventView.swift
//  DayPlannerV1
//
//  Created by Gavan Pang on 24/07/2016.
//  Copyright © 2016 Gavan Pang. All rights reserved.
//

import UIKit

protocol EventViewDelegate : class {
    func nearestSnapLocation(tappedLocation: CGPoint) -> CGPoint;
}

class EventView: UIView {

    weak var delegate : EventViewDelegate?;
    
    let viewWidth   : CGFloat = 50.0;
    let viewHeight  : CGFloat = 50.0;
    
    // For drawing the frame
    let borderHeight : CGFloat = 1.0;
    
    init(xOrigin: CGFloat, yOrigin: CGFloat, bgColor: UIColor) {
        let frame : CGRect = CGRectMake(xOrigin, yOrigin, viewWidth, viewHeight);
        super.init(frame: frame);
        
        self.backgroundColor = bgColor.colorWithAlphaComponent(0.5);
        
        let longPressRecogniser = UILongPressGestureRecognizer.init(target: self, action: #selector(handleLongPress(_:)));
        self.addGestureRecognizer(longPressRecogniser);
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    
    func handleLongPress(recognizer: UILongPressGestureRecognizer) {
        
        //let tapLocInWindow = recognizer.locationInView(nil);
        let tapLoc = recognizer.locationInView(self.superview);
        
        // This is where we move an event
        if(recognizer.state == UIGestureRecognizerState.Began)
        {
            //if needed do some initial setup or init of views here
        } else if(recognizer.state == UIGestureRecognizerState.Changed)
        {
            self.center.x = tapLoc.x// + viewWidth/2;
            self.center.y = tapLoc.y //+ viewHeight/2;
            //move your views here.
        } else if(recognizer.state == UIGestureRecognizerState.Ended)
        {
            //else do cleanup
            let snapLocation = self.delegate!.nearestSnapLocation(tapLoc);
            self.center.x = snapLocation.x + self.viewWidth/2;
            self.center.y = snapLocation.y + self.viewHeight/2;
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
