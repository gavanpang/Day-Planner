//
//  CenterViewController.swift
//  DayPlannerV1
//
//  Created by Gavan Pang on 21/07/2016.
//  Copyright © 2016 Gavan Pang. All rights reserved.
//

import UIKit
import CoreData

@objc
protocol CenterViewControllerDelegate {
    optional func toggleLeftPanel();
    optional func toggleRightPanel();
    optional func collapseSidePanels();
}

class CenterViewController: UIViewController {
    
    var delegate: CenterViewControllerDelegate?;
    
    let hourSpacing     : CGFloat = 65;
    let hourLabelWidth  : CGFloat = 50.0;
    let hourLabelHeight : CGFloat = 21.0;
    let labelToSepOffset: CGFloat = 10.0;
    var firstSepHeight  : CGFloat = 0.0;
    
    let calendar : NSCalendar = NSCalendar.currentCalendar();

    var currentEditingEvent : Event? = nil;
    var currentEventView    : EventView? = nil;
    
    var tempDescription : String?;
    var tempStartDateTime : NSDate?;
    var tempEndTime : NSDate?;
    var tempBGColor : UIColor?;
    
    @IBOutlet weak var objectsContainer : UIView!;
    @IBOutlet weak var topToolBar       : UIToolbar!;
    @IBOutlet weak var scrollView       : UIScrollView!;
    @IBOutlet weak var dateSlider       : UISlider!;
    var titleDateLabel                  : UILabel!;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    
        self.setupTitleLabel();
        self.setupScrollView();
        self.setupScrollViewMarkers();
        self.resizeSliderForBounds();
        
        // Load first batch of data with -1 as index
        let events = DataManager.sharedInstance.loadEventsWithIndex(-1);
        
        print("Adding events");
        for event in events {
            let view = self.addEventToScrollView(event);
            self.updateViewWithEventDetails(view, event: event);
            
            print(event.eventDescription, event.eventDateAndTime, event.endTime);
        }
        
        // Tap received by scrollview is to create a new event
        let tapRecogniser = UITapGestureRecognizer.init(target: self, action: #selector(newEventWithCustomTime(_:)));
        self.scrollView.addGestureRecognizer(tapRecogniser);
        
        // Convenient to calculate this
        self.firstSepHeight = self.hourLabelHeight/2;
    }
    
// MARK: - IBActions
    
    @IBAction func leftButtonTapped(sender: AnyObject) {
        
        delegate?.toggleLeftPanel?();
    }
    
    // Tapping right button adds a new event with the current time as default
    @IBAction func newEventWithCurrentTime(sender: AnyObject) {
        
        self.tempStartDateTime = DataManager.sharedInstance.timeDateRoundUpFifteenMinutes(NSDate());
        
        delegate?.toggleRightPanel?();
    }
    
    // Tapping on the scrollview creates a new event
    func newEventWithCustomTime(recognizer: UIGestureRecognizer) {
        
        let tapLoc = recognizer.locationInView(self.scrollView);
        let dateAndTime = self.roundedDateForTapLocation(tapLoc);
        
        // Store only the start date/time, for eventDetailsViewController to access
        self.tempStartDateTime = dateAndTime;
        
        // Pass the event to the editing (right panel) view
        self.delegate?.toggleRightPanel?();
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: - Helper methods

extension CenterViewController {
    func addEventToScrollView(event: Event) -> EventView {
        // Calculate position
        let viewFrame = self.frameForEventViewForTime(event.eventDateAndTime!, andEndTime: event.endTime!);
        
        var isCompactFrame = false;
        if(viewFrame.height == self.hourSpacing/4.0) {
            isCompactFrame = true;
        }
        
        // Create view
        let eventView = EventView.init(frame: viewFrame, eventID: event.objectID, delegate: self, compactFrame: isCompactFrame);
        
        // Add to view
        self.scrollView.addSubview(eventView);
        
        return eventView
    }

    func updateViewWithEventDetails(view: EventView, event: Event) {
        // Update/create details
        view.updateEventDescription((event.eventDescription)!);
        view.updateStartAndEndTimes((event.eventDateAndTime)!, endTime: (event.endTime)!)
        view.updateBGColor(UIColor.orangeColor())
    }
}

// MARK: - Calculation methods
extension CenterViewController {
    
    func frameForEventViewForTime(startTime : NSDate, andEndTime endTime: NSDate) -> CGRect {
        // X and Y
        let startTimeComp = self.calendar.components([NSCalendarUnit.Hour, NSCalendarUnit.Minute], fromDate: startTime);
        
        var yLocation = (CGFloat(startTimeComp.hour) * self.hourSpacing) + self.hourLabelHeight/2;
        yLocation += (CGFloat(startTimeComp.minute)/60.0) * self.hourSpacing;
        
        let xLocation = self.hourLabelWidth + self.firstSepHeight;
        
        // Size
        let screensize = UIScreen.mainScreen().bounds;
        let frameWidth = screensize.width - (self.hourLabelWidth + self.labelToSepOffset);
        
        
        let endTimeComp = self.calendar.components([NSCalendarUnit.Hour, NSCalendarUnit.Minute], fromDate: endTime);

        let hourDifference = endTimeComp.hour - startTimeComp.hour;
        let minuteDifference = endTimeComp.minute - startTimeComp.minute;
        
        var height = (CGFloat(hourDifference) * self.hourSpacing) + (CGFloat(minuteDifference)/60.0 * self.hourSpacing);
        
        // Set a minimum bound on the height, currently 15 mins
        if(height < self.hourSpacing/4) {
            height = self.hourSpacing/4;
        }
        
        return CGRectMake(xLocation, yLocation, frameWidth, height);
    }
    
    // Returns the date and time for the tapped location
    func roundedDateForTapLocation(tapLocation: CGPoint) -> NSDate {
        // Round the y location to the closest 15 minutes
        // First round down to the closest hour
        var hours = floor((tapLocation.y - self.firstSepHeight) / self.hourSpacing);
        var minutes : NSInteger = 0;
        
        // This will do the fine-grained rounding
        let remainder = (tapLocation.y - self.firstSepHeight) % self.hourSpacing;
        if(remainder > self.hourSpacing/8) {
            minutes = 15;
        }
        
        if(remainder > (self.hourSpacing * 3/8)) {
            minutes = 30;
        }
        
        if(remainder > (self.hourSpacing * 4/8)) {
            minutes = 45;
        }
        
        if(remainder > (self.hourSpacing * 7/8)) {
            hours += 1;
            minutes = 0;
        }
        
        // Get the full date from DataManager
        
        return DataManager.sharedInstance.currentViewDateWithTime(Int(hours), minutes: minutes);
    }
    
    // Return Y location for nearest snap location (currently every 15 minutes)
    func roundedLocationForEventView(tapLocation : CGPoint) -> CGPoint {
        // Round the y location to the closest hour
        var hours = floor((tapLocation.y - self.firstSepHeight) / self.hourSpacing);
        
        // This will do the fine-grained rounding
        let remainder = (tapLocation.y - self.firstSepHeight) % self.hourSpacing;
        var minutes : CGFloat = 0.0;
        
        if(remainder > self.hourSpacing/8) {
            minutes = 15.0/60.0;
        }
        
        if(remainder > (self.hourSpacing * 3/8)) {
            minutes = 30.0/60.0;
        }
        
        if(remainder > (self.hourSpacing * 4/8)) {
            minutes = 45.0/60.0;
        }
        
        if(remainder > (self.hourSpacing * 7/8)) {
            hours += 1;
            minutes = 0.0;
        }
        
        // X is fixed, Y is rounded to nearest 15 minutes
        return CGPointMake(self.hourLabelWidth + self.labelToSepOffset, self.firstSepHeight + (hours * self.hourSpacing) + (minutes * self.hourSpacing));
    }
    
}

// MARK: - EventViewDelegate
extension CenterViewController : EventViewDelegate {
    func eventMoved(tapLocation: CGPoint, eventView: EventView) {
        
        // Update view location
        let snapLocation = self.roundedLocationForEventView(tapLocation);
        
        eventView.frame.origin.x = snapLocation.x;
        eventView.frame.origin.y = snapLocation.y;
        
        // Calculate new start/end time
        let newStartTime = self.roundedDateForTapLocation(snapLocation);
        
        let viewEndLoc = CGPointMake(snapLocation.x, snapLocation.y + eventView.frame.size.height);
        let newEndTime = self.roundedDateForTapLocation(viewEndLoc);
        
        // Update moc Event details
        let event : Event = DataManager.sharedInstance.eventWithID(eventView.eventID!);
        
        event.eventDateAndTime = newStartTime;
        event.endTime = newEndTime;

        // Update view displayed time
        eventView.updateStartAndEndTimes(event.eventDateAndTime, endTime: event.endTime);
        
        // save
        DataManager.sharedInstance.update();
    }
    
    func eventShouldBeginEditing(eventView: EventView) {
        // Save this so we can replace the updated details later
        self.currentEventView = eventView;
        
        // Get the Event from core data
        self.currentEditingEvent = DataManager.sharedInstance.eventWithID(eventView.eventID!);
        
        // Fill out the temporary variables to be read by EventDetailsController
        self.tempStartDateTime = self.currentEditingEvent?.eventDateAndTime;
        self.tempEndTime = self.currentEditingEvent?.endTime;
        self.tempDescription = self.currentEditingEvent?.eventDescription;
        
        // Open eventDetailsViewController and fill with details
        self.delegate?.toggleRightPanel!();
    }
}


// MARK:  EventDetailsViewController delegate
extension CenterViewController : EventDetailsViewControllerDelegate {
    func eventDescription() -> String {
        if(self.tempDescription != nil)
        {
            return self.tempDescription!;
        } else {
            return "";
        }
    }
    
    func eventStartDateAndTime() -> NSDate {
        // This cannot be nil
        return self.tempStartDateTime!;
    }
    
    func eventEndTime() -> NSDate {
        if(self.tempEndTime != nil) {
            return self.tempEndTime!;
        }
            // If there's no end time, default to 15 mins after the start time
        else {
            let fifteenMinutesComp = NSDateComponents.init();
            fifteenMinutesComp.hour = 0;
            fifteenMinutesComp.minute = 15;
            
            return self.calendar.dateByAddingComponents(fifteenMinutesComp, toDate: self.tempStartDateTime!, options: [])!;
        }
    }
}

// MARK: Left and Right ViewController delegate
extension CenterViewController : RightPanelViewControllerDelegate {
    func rightControllerDidCancelEditing() {
        self.delegate?.toggleRightPanel!();
        
        self.currentEditingEvent = nil;
        self.currentEventView = nil;
    }
    
    // This is called when 'DONE' is tapped in the right panel. We either create a new event
    // or update an existing event
    func rightControllerDidEndEditingEvent(eventVC : EventDetailsViewController) {
       
        // Update details
        self.currentEditingEvent?.eventDescription = eventVC.updatedEventDescription();
        self.currentEditingEvent?.eventDateAndTime = eventVC.updatedStartDateTime();
        self.currentEditingEvent?.endTime = eventVC.updatedEndTime();
        
        // Only runs if a new view to be created
        if(self.currentEventView == nil) {
            // New event so create a new EventView
            
            // Create Event and save to MOC
            self.currentEditingEvent = DataManager.sharedInstance.createEvent(eventVC.updatedStartDateTime());
            self.currentEditingEvent?.endTime = eventVC.updatedEndTime();
            self.currentEditingEvent?.eventDescription = eventVC.updatedEventDescription();

            print("New Event");
            print("Description", eventVC.updatedEventDescription());
            print("Start", eventVC.updatedStartDateTime());
            print("End", eventVC.updatedEndTime());
            
            // Save so the objectID is no longer temporary
            DataManager.sharedInstance.update();
            
            // Save the newly created view for reference
            self.currentEventView = addEventToScrollView(self.currentEditingEvent!);
        }
        
            // Is an existing event
        else {
            self.currentEditingEvent?.eventDateAndTime = eventVC.updatedStartDateTime();
            self.currentEditingEvent?.endTime = eventVC.updatedEndTime();
            self.currentEditingEvent?.eventDescription = eventVC.updatedEventDescription();
            
            // Save
            DataManager.sharedInstance.update();
        }
        
        // Update/create details
        self.updateViewWithEventDetails(self.currentEventView!, event: self.currentEditingEvent!);
        
        // Reset the pointers
        self.currentEventView = nil;
        self.currentEditingEvent = nil;
        
        self.delegate?.toggleRightPanel!();
    }
}

extension CenterViewController : LeftPanelViewControllerDelegate {
    
}

// MARK: - View Setup functions
extension CenterViewController {
    // Modify the top toolbar to display the title
    func setupTitleLabel() {
        
        // Calculate the appropriate width of the label
        let screenRect : CGRect = UIScreen.mainScreen().bounds;
        let screenWidth : CGFloat = screenRect.size.width;
        let titleWidth : CGFloat = (screenWidth - 105);
        
        // Set up the label
        let label = UILabel.init(frame: CGRectMake(0.0, 11.0, titleWidth, 21.0));
        label.font = UIFont.init(name: "Helvetiva-Bold", size: 18);
        label.backgroundColor = UIColor.clearColor();
        label.textAlignment = NSTextAlignment.Center;
        
        let currentDate = DataManager.sharedInstance.currentViewDate;
        label.text = DTFormatters.sharedInstance.stringFromDate(currentDate);
        
        self.titleDateLabel = label;
        
        // Init and apply the label, and replace the placeholder button with the label
        let titleBarButtonItem = UIBarButtonItem.init(customView: label);
        self.topToolBar!.items![1] = titleBarButtonItem;
    }
    
    func setupScrollView() {
        // Set up the scrollview
        let screenRect : CGRect = UIScreen.mainScreen().bounds;
        let screenWidth : CGFloat = screenRect.size.width;
        self.scrollView.contentSize = CGSizeMake(screenWidth, 24.0 * self.hourSpacing + self.hourLabelHeight);
    }
    
    func setupScrollViewMarkers() {
        
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
        self.addLabelToScrollView("13:00", forTime:13.0);
        self.addLabelToScrollView("14:00", forTime:14.0);
        self.addLabelToScrollView("15:00", forTime:15.0);
        self.addLabelToScrollView("16:00", forTime:16.0);
        self.addLabelToScrollView("17:00", forTime:17.0);
        self.addLabelToScrollView("18:00", forTime:18.0);
        self.addLabelToScrollView("19:00", forTime:19.0);
        self.addLabelToScrollView("20:00", forTime:20.0);
        self.addLabelToScrollView("21:00", forTime:21.0);
        self.addLabelToScrollView("22:00", forTime:22.0);
        self.addLabelToScrollView("23:00", forTime:23.0);
        self.addLabelToScrollView("24:00", forTime:24.0);
        
        for i in 0...24 {
            self.addHourSeparatorToScrollView(CGFloat(i));

        }
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
        sep.alpha = 0.2;
        self.scrollView.addSubview(sep);
    }
    
    func resizeSliderForBounds() {
        // Sets up the slider with the correct width
        let screenRect : CGRect = UIScreen.mainScreen().bounds;
        let screenWidth : CGFloat = screenRect.size.width;
        let sliderWidth : CGFloat = (screenWidth - 95);
        let frame : CGRect = CGRectMake(self.dateSlider.frame.origin.x,
                                        self.dateSlider.frame.origin.y,
                                        sliderWidth, self.dateSlider.frame.height);
        self.dateSlider.frame = frame;
    }
}

//MARK : - Date/page scrolling

extension CenterViewController {
    @IBAction func sliderValueChanged(sender: UISlider) {
        // This lets the thumb snap to whole integer positions
        self.dateSlider.value = round(self.dateSlider.value);
        
        let newIndex = Int(self.dateSlider.value);
        let currentIndex =  DataManager.sharedInstance.currentIndex;
        
        // If the current displayed list is different to the slider selection, scroll the view,
        // load the new list values in
        if(currentIndex != newIndex)
        {
            self.titleDateLabel.alpha = 0.0;
            
            // Notify the DataManager to load new data, and pull it out
            let events = DataManager.sharedInstance.loadEventsWithIndex(newIndex);
            
            for event in events {
                print(event.eventDescription, event.eventDateAndTime, event.endTime);
            }
            
            // Remove old events from view
            for view in self.scrollView.subviews {
                if view.isKindOfClass(EventView) {
                    view.removeFromSuperview();
                }
            }
            
            // Create new events and add them to view
            
            
            // Set the title with the newly computed date
            let currentDate = DataManager.sharedInstance.currentViewDate;
            self.titleDateLabel.text = DTFormatters.sharedInstance.stringFromDate(currentDate);
            
            // Animate the transition
            self.scrollNewPage(currentIndex, withNewIndex: newIndex);
            
            // Change the background color
            UIView.animateWithDuration(0.1, delay: 0.1, options: UIViewAnimationOptions.AllowUserInteraction, animations:
                {
                    self.titleDateLabel.alpha = 1.0;
                    //[self changeBackgroundToColor:self.currentToDoList.backgroundColor];
                }, completion: nil);
 
        }
    }
    
    func scrollNewPage(oldIndex: NSInteger, withNewIndex newIndex: NSInteger) {
        
        self.scrollView.alpha = 0.7;
        
        // Scroll the current view out
        if(oldIndex < newIndex)
        {
            // Scroll old list out to left
            self.scrollOldListOutToLeft();
        } else {
            // Scroll list out to right
            self.scrollOldListOutToRight();
        }
        
        //self.performSelector(#selector(ViewController.reloadTableData), withObject: nil, afterDelay: 0.15);
        
        // Scroll the new view in
        if(oldIndex < newIndex)
        {
            self.performSelector(#selector(CenterViewController.scrollNewListInFromRight), withObject: nil, afterDelay: 0.15);
        } else {
            self.performSelector(#selector(CenterViewController.scrollNewListInFromLeft), withObject: nil, afterDelay: 0.15);
        }
        
        UIView.animateWithDuration(1.0,
                                   delay: 0,
                                   options: UIViewAnimationOptions.AllowUserInteraction,
                                   animations: {
                                    self.scrollView.alpha = 1.0;
            },
                                   completion: nil );
    }
    
    // Paired with scrollNewListInFromRight
    func scrollOldListOutToLeft() {
        //Scroll OUT from LEFT
        let screenBound : CGRect    = UIScreen.mainScreen().bounds;
        let screenSize  : CGSize    = screenBound.size;
        let screenWidth : CGFloat   = screenSize.width;
        
        //Get the tableviews position
        var frameOut : CGRect = self.objectsContainer.frame;
        
        //add on value to x co-ordinates so it moves along the x axis giving a scrolling effect, scroll out
        frameOut.origin.x = 0 - screenWidth;
        frameOut.origin.y += 0;
        
        UIView.animateWithDuration(0.15,
                                   delay: 0,
                                   options: UIViewAnimationOptions.AllowUserInteraction,
                                   animations: {
                                    self.objectsContainer.frame = frameOut;
            },
                                   completion: nil );
        
        //End of Animating Scrolling Table View
    }
    
    func scrollNewListInFromRight() {
        let screenBound :CGRect     = UIScreen.mainScreen().bounds;
        let screenSize  : CGSize    = screenBound.size;
        let screenWidth : CGFloat   = screenSize.width;
        var resetPosition : CGRect  = self.objectsContainer.frame;
        resetPosition.origin.x = screenWidth;
        
        self.objectsContainer.frame = resetPosition;
        
        //Get the tableviews position
        var frameIn : CGRect = self.objectsContainer.frame;
        
        //add on value to x co-ordinates so it moves along the x axis giving a scrolling effect , scroll in
        frameIn.origin.x = 0;
        
        UIView.animateWithDuration(0.15,
                                   delay: 0,
                                   options: UIViewAnimationOptions.AllowUserInteraction,
                                   animations: {
                                    self.objectsContainer.frame = frameIn;
            },
                                   completion: nil );
        
        //End of Animating Scrolling Table View
    }
    
    // Paired with scrollNewListInFromLeft
    func scrollOldListOutToRight(){
        //Scroll OUT from LEFT
        let screenBound : CGRect    = UIScreen.mainScreen().bounds;
        let screenSize  : CGSize    = screenBound.size;
        let screenWidth : CGFloat   = screenSize.width;
        
        //Get the tableviews position
        var frameOut : CGRect = self.objectsContainer.frame;
        
        //add on value to x co-ordinates so it moves along the x axis giving a scrolling effect, scroll out
        frameOut.origin.x = screenWidth;
        frameOut.origin.y += 0;
        
        UIView.animateWithDuration(0.15,
                                   delay: 0,
                                   options: UIViewAnimationOptions.AllowUserInteraction,
                                   animations: {
                                    self.objectsContainer.frame = frameOut;
            },
                                   completion: nil );
        
        //End of Animating Scrolling Table View
    }
    
    func scrollNewListInFromLeft() {
        let screenBound : CGRect    = UIScreen.mainScreen().bounds;
        let screenSize : CGSize     = screenBound.size;
        let screenWidth : CGFloat   = screenSize.width;
        var resetPosition : CGRect  = self.objectsContainer.frame;
        resetPosition.origin.x = 0 - screenWidth;
        
        self.objectsContainer.frame = resetPosition;
        
        //Get the tableviews position
        var frameIn : CGRect = self.objectsContainer.frame;
        
        //add on value to x co-ordinates so it moves along the x axis giving a scrolling effect , scroll in
        frameIn.origin.x = 0;
        
        UIView.animateWithDuration(0.15,
                                   delay: 0,
                                   options: UIViewAnimationOptions.AllowUserInteraction,
                                   animations: {
                                    self.objectsContainer.frame = frameIn;
            },
                                   completion: nil );
        
        //End of Animating Scrolling Table View
    }
}

