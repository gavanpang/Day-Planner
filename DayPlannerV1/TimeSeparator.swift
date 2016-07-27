//
//  TimeSeparator.swift
//  DayPlannerV1
//
//  Created by Gavan Pang on 23/07/2016.
//  Copyright © 2016 Gavan Pang. All rights reserved.
//

import UIKit

class TimeSeparator: UIView {
    
    private var separatorWidth : CGFloat = UIScreen.mainScreen().bounds.width * 0.75;
    private let separatorHeight : CGFloat = 2.0
    
    init(xPos: CGFloat, yPos: CGFloat, width: CGFloat)
    {
        super.init(frame: CGRectMake(xPos, yPos, width, self.separatorHeight));
        self.separatorWidth = width;        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }

    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
        
        //create the path
        let separatorPath = UIBezierPath();
        
        //set the path's line width to the height of the stroke
        separatorPath.lineWidth = separatorHeight;
        
        //move the initial point of the path
        //to the start of the horizontal stroke
        separatorPath.moveToPoint(CGPoint(x: 0, y: self.separatorHeight/2));
        
        //add a point to the path at the end of the stroke
        separatorPath.addLineToPoint(CGPointMake(separatorWidth, self.separatorHeight/2));
        
        //set the stroke color
        UIColor.blackColor().setStroke()
        
        //draw the stroke
        separatorPath.stroke();
    }
 
    
}
