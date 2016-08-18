//
//  ColorOptionView.swift
//  DayPlannerV1
//
//  Created by Gavan Pang on 12/08/2016.
//  Copyright © 2016 Gavan Pang. All rights reserved.
//

import UIKit

protocol ColorOptionViewDelegate {
    func colorOptionViewSelected(colorIndex : Int);
}

class ColorOptionView: UIView {

    var delegate : ColorOptionViewDelegate!;
    
    private var fillColor : UIColor!;
    var isSelected : Bool = false; // default to false
    var colorIndex : Int = 0;
    
    private let selectionBorderWidth : CGFloat = 5.0
    
    init(frame: CGRect, colorIndex: Int, delegate: ColorOptionViewDelegate) {
        super.init(frame: frame);
        
        self.delegate = delegate;
        
        let color = DataManager.sharedInstance.allColors[colorIndex];
        self.fillColor = color.colorWithAlphaComponent(0.4);
        self.colorIndex = colorIndex;
        self.backgroundColor = UIColor.clearColor();
        
        let tapRecogniser = UITapGestureRecognizer();
        tapRecogniser.addTarget(self, action: #selector(handleTap(_:)));
        self.addGestureRecognizer(tapRecogniser);
    }
    
    func setSelected(selected: Bool) {
        self.isSelected = selected;
        setNeedsDisplay();
    }
    
    func handleTap(recogniser: UITapGestureRecognizer) {
        self.isSelected = true;
        self.delegate.colorOptionViewSelected(self.colorIndex);
        setNeedsDisplay();
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
        
        //create the path
        let squarePath = UIBezierPath();
        
        //set the path's line width to the height of the stroke
        //squarePath.lineWidth = self.borderHeight;
        
        //draw the square
        squarePath.moveToPoint(CGPoint(x: self.selectionBorderWidth, y: self.selectionBorderWidth));
        
        //add a point to the path at the end of the stroke
        squarePath.addLineToPoint(CGPointMake(self.bounds.width - self.selectionBorderWidth, self.selectionBorderWidth));
        squarePath.addLineToPoint(CGPointMake(self.bounds.width - self.selectionBorderWidth, self.bounds.height - self.selectionBorderWidth));
        squarePath.addLineToPoint(CGPointMake(self.selectionBorderWidth, self.bounds.height - self.selectionBorderWidth));
        squarePath.addLineToPoint(CGPointMake(self.selectionBorderWidth, self.selectionBorderWidth));
        
        // Set the fill colour and go
        self.fillColor.setFill();
        squarePath.fill();
        
        if(isSelected) {
            //create the path
            let borderPath = UIBezierPath();
            
            //set the path's line width to the height of the stroke
            borderPath.lineWidth = 10.0;
            
            //move the initial point of the path
            //to the start of the horizontal stroke
            borderPath.moveToPoint(CGPoint(x: 0, y: 0));
            
            //add a point to the path at the end of the stroke
            borderPath.addLineToPoint(CGPointMake(self.bounds.width, 0));
            borderPath.addLineToPoint(CGPointMake(self.bounds.width, self.bounds.height));
            borderPath.addLineToPoint(CGPointMake(0, self.bounds.height));
            borderPath.addLineToPoint(CGPointMake(0, 0));
            
            //set the stroke color
            UIColor.blueColor().colorWithAlphaComponent(0.1).setStroke()
            
            //draw the stroke
            borderPath.stroke();
        }
    }
    

}
