//
//  CenterViewController.swift
//  DayPlannerV1
//
//  Created by Gavan Pang on 21/07/2016.
//  Copyright © 2016 Gavan Pang. All rights reserved.
//

import UIKit

@objc
protocol CenterViewControllerDelegate {
    optional func toggleLeftPanel();
    optional func toggleRightPanel(dateAndTime: NSDateComponents?);
    optional func collapseSidePanels();
}


class CenterViewController: UIViewController {
    
    let hourSpacing     : CGFloat = 65;
    let hourLabelWidth  : CGFloat = 50.0;
    let hourLabelHeight : CGFloat = 21.0;
    let labelToSepOffset: CGFloat = 10.0;
    var firstSepHeight  : CGFloat = 0.0;
    
    // private let currentViewDateComponents : NSDateComponents    = NSDateComponents();
    var currentViewDate : NSDate                        = NSDate.init();
    let calendar : NSCalendar                           = NSCalendar.currentCalendar();

    // Use this as a constant here as it's expensive to instantiate
    let dateFormatter : NSDateFormatter             = NSDateFormatter.init();
    
    var delegate: CenterViewControllerDelegate?;
    
    @IBOutlet weak var objectsContainer : UIView!;
    @IBOutlet weak var toptoolBar       : UIToolbar!;
    @IBOutlet weak var scrollView       : UIScrollView!;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.setUpTitleLabel();
        
        // Set up the scrollview
        let screenRect : CGRect = UIScreen.mainScreen().bounds;
        let screenWidth : CGFloat = screenRect.size.width;
        self.scrollView.contentSize = CGSizeMake(screenWidth, 1024);
        
        self.addLabelToScrollView("0:00", forTime:0);
        self.addLabelToScrollView("1:00", forTime:1.0);
        self.addLabelToScrollView("2:00", forTime:2.0);
        self.addLabelToScrollView("3:00", forTime:3.0);
        self.addLabelToScrollView("4:00", forTime:4.0);
        self.addLabelToScrollView("5:00", forTime:5.0);
        self.addLabelToScrollView("6:00", forTime:6.0);
        self.addLabelToScrollView("7:00", forTime:7.0);
        self.addLabelToScrollView("8:00", forTime:8.0);
        self.addLabelToScrollView("9:00", forTime:9.0);
        self.addLabelToScrollView("10:00", forTime:10.0);
        self.addLabelToScrollView("11:00", forTime:11.0);
        self.addLabelToScrollView("12:00", forTime:12.0);
        
        self.addHourSeparatorToScrollView(0);
        self.addHourSeparatorToScrollView(1.0);
        self.addHourSeparatorToScrollView(2.0);
        self.addHourSeparatorToScrollView(3.0);
        self.addHourSeparatorToScrollView(4.0);
        self.addHourSeparatorToScrollView(5.0);
        self.addHourSeparatorToScrollView(6.0);
        self.addHourSeparatorToScrollView(7.0);
        self.addHourSeparatorToScrollView(8.0);
        self.addHourSeparatorToScrollView(8.0);
        self.addHourSeparatorToScrollView(9.0);
        self.addHourSeparatorToScrollView(10.0);
        self.addHourSeparatorToScrollView(11.0);
        self.addHourSeparatorToScrollView(12.0);


        let tapRecogniser = UITapGestureRecognizer.init(target: self, action: #selector(handleTap(_:)));
        self.scrollView.addGestureRecognizer(tapRecogniser);
        
        // Convenient to calculate this
        self.firstSepHeight = self.hourLabelHeight/2;
        
        //let mainScreen = UIScreen.mainScreen();
        //print("Main screen ", mainScreen.bounds.size.width, mainScreen.bounds.size.height);
        
    }
    
    // Modify the top toolbar to display the title
    func setUpTitleLabel() {
        
        // Calculate the appropriate width of the label
        let screenRect : CGRect = UIScreen.mainScreen().bounds;
        let screenWidth : CGFloat = screenRect.size.width;
        let titleWidth : CGFloat = (screenWidth - 105);
        
        // Set up the label
        let label = UILabel.init(frame: CGRectMake(0.0, 11.0, titleWidth, 21.0));
        label.font = UIFont.init(name: "Helvetiva-Bold", size: 18);
        label.backgroundColor = UIColor.clearColor();
        label.textAlignment = NSTextAlignment.Center;
        
        self.dateFormatter.dateFormat = "EEE, dd MMM yyyy"
        label.text = dateFormatter.stringFromDate(NSDate.init())
        
        // Init and apply the label, and replace the placeholder button with the label
        let titleBarButtonItem = UIBarButtonItem.init(customView: label);
        self.toptoolBar!.items![1] = titleBarButtonItem;
    }
    
    func addLabelToScrollView(time: String, forTime hour: CGFloat) {
        // Set up the label
        let label = UILabel.init(frame: CGRectMake(0.0, hour  * self.hourSpacing, self.hourLabelWidth, self.hourLabelHeight));
        label.font = UIFont.init(name: "Helvetiva-Bold", size: 18);
        label.backgroundColor = UIColor.clearColor();
        label.text = time;
        label.textAlignment = NSTextAlignment.Right;
        
        self.scrollView.addSubview(label);
    }
    
    func addHourSeparatorToScrollView(hour: CGFloat) {
        let screenRect : CGRect = UIScreen.mainScreen().bounds;
        let screenWidth : CGFloat = screenRect.size.width;
        
        let sepX = self.hourLabelWidth + labelToSepOffset;
        let sepY = (hour * self.hourSpacing) + self.hourLabelHeight/2;
        let sepWidth = screenWidth - self.hourLabelWidth - labelToSepOffset;
        let sep = TimeSeparator.init(xPos: sepX, yPos: sepY, width: sepWidth);
        self.scrollView.addSubview(sep);
    }
    
// MARK: IBActions
    
    @IBAction func leftButtonTapped(sender: AnyObject) {
        
        //print("OC width ", self.objectsContainer.frame.size.width, " Height ", self.objectsContainer.frame.size.height);
        
        delegate?.toggleLeftPanel?();
    }
    
    // Tapping right button adds a new event with the current time as default
    @IBAction func rightButtonTapped(sender: AnyObject) {
        let currentTime = NSDate.init();
        
        // Get the month, day, hour from today's date
        let currentDateComponents = calendar.components([NSCalendarUnit.Month, NSCalendarUnit.Day, NSCalendarUnit.Hour], fromDate: currentTime);
        
        // Set the new event to the hour (add minutes if so desired)
        currentDateComponents.hour += 1;
        
        delegate?.toggleRightPanel?(currentDateComponents);
    }
    
    func handleTap(recognizer: UIGestureRecognizer) {
        let tapLoc = recognizer.locationInView(self.scrollView);
 
        let tappedDateAndTime = self.roundedDateComponentsForTapLocation(tapLoc);
        self.delegate?.toggleRightPanel?(tappedDateAndTime);
        /*
        let roundedViewLoc = roundedLocationForEventView(tapLoc);
        
        
        // This is where we create a new item
        let newEvent = EventView.init(xOrigin: roundedViewLoc.x, yOrigin: roundedViewLoc.y, bgColor: UIColor.greenColor());
        newEvent.delegate = self;
        
        self.scrollView.addSubview(newEvent);
 */
    }
    
    // Returns the date and time for the tapped location
    func roundedDateComponentsForTapLocation(tapLocation: CGPoint) -> NSDateComponents {
        // Round the y location to the closest hour
        var hours = floor((tapLocation.y - self.firstSepHeight) / self.hourSpacing);
        
        // This will do the fine-grained rounding
        let remainder = (tapLocation.y - self.firstSepHeight) % self.hourSpacing;
        if(remainder >= self.hourSpacing/2) {
            hours += 1;
        }

        let tappedDateComponents = self.calendar.components([NSCalendarUnit.Month, NSCalendarUnit.Day], fromDate: self.currentViewDate);
        
        tappedDateComponents.hour = Int(hours);
        tappedDateComponents.minute = 0; // Will change when we do finer grained control
        
        return tappedDateComponents;
    }
    
    func roundedLocationForEventView(tapLocation : CGPoint) -> CGPoint {
        // Round the y location to the closest hour
        var hours = floor((tapLocation.y - self.firstSepHeight) / self.hourSpacing);
        
        let remainder = (tapLocation.y - self.firstSepHeight) % self.hourSpacing;
        if(remainder >= self.hourSpacing/2) {
            hours += 1;
        }
        
        // X is fixed, Y is rounded to nearest separator
        return CGPointMake(self.hourLabelWidth + self.labelToSepOffset, self.firstSepHeight + (hours * self.hourSpacing));
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: EventViewDelegate
extension CenterViewController : EventViewDelegate {
    func nearestSnapLocation(tappedLocation: CGPoint) -> CGPoint {
        return roundedLocationForEventView(tappedLocation);
    }
}

// MARK: Left and Right ViewController delegate
extension CenterViewController : LeftPanelViewControllerDelegate, RightPanelViewControllerDelegate {
    
}
