//
//  EventDetailsViewController.swift
//  DayPlannerV1
//
//  Created by Gavan Pang on 27/07/2016.
//  Copyright © 2016 Gavan Pang. All rights reserved.
//

import UIKit

protocol EventDetailsViewControllerDelegate {
    func eventDescription() -> String;
    func eventStartDateAndTime() -> NSDate;
    func eventEndTime() -> NSDate;
    func eventColorIndex() -> Int;
    func eventDidRequestDeleteAction();
}

class EventDetailsViewController: UITableViewController {

    var delegate : EventDetailsViewControllerDelegate?;
    
    @IBOutlet weak var eventTitleField  : UITextField!;
    
    @IBOutlet weak var datePicker       : UIPickerView!;
    @IBOutlet weak var startTimePicker  : UIDatePicker!;
    @IBOutlet weak var endTimePicker    : UIDatePicker!;
    
    var datePickerShowing       = false;
    var startTimePickerShowing  = false;
    var endTimePickerShowing    = false;
    
    @IBOutlet weak var eventDateLabel   : UILabel!;
    @IBOutlet weak var startTimeLabel   : UILabel!;
    @IBOutlet weak var endTimeLabel     : UILabel!;
    
    let calendar = NSCalendar.currentCalendar();
    
    var selectedDateIndex : Int = 0;
    var allDates : [NSDate] = [];
    var datePickerOptions : [String] = [];
    
    // Need to build this view programmatically, holds the colour selection boxes
    @IBOutlet weak var colorSelectionCellView : UIView!;
    var allColorOptionViews : [ColorOptionView] = [];
    var selectedColorIndex : Int = 0;
    var colorSelectionCellHeightMultiplier : CGFloat = 1.0;
    
    // Register for notifications to remind of the event
    var notificationForEvent : Bool = false;
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    // This is called BEFORE the delegate is set
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // This is called AFTER the delegate is set, so get the event details here
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        
        // Data is loaded by calling the delegate, due to this funny architecture
        
        // Event description
        self.eventTitleField.text = self.delegate?.eventDescription();
        
        // Set up the start and end dates
        self.setupTimePickerViews();
        
        // Then setup the date picker, as it depends on the start time being loaded first
        self.setupDatePickerView();
        
        // Gets rid of empty cells at the bottom
        self.tableView.tableFooterView = UIView();
        
        // Set up the color selection boxes
        let screenWidth = UIScreen.mainScreen().bounds.width - 60;
        
        // Starting point of the first frame
        var frameX : CGFloat = 10.0;
        var frameY : CGFloat = 10.0;
        var j = 0;
        
        // The following chunk ensures that the colours will be fit in a single cell
        for i in 0..<DataManager.sharedInstance.allColors.count {
            if((10.0 + (CGFloat(j+1)*60)) < screenWidth) {
                frameX = 10.0 + (CGFloat(j)*60);
                j += 1;
            } else {
                // Every time the options overflows the width of the screen, increase height
                j = 0;
                frameX = 10.0;
                frameY += 60.0;
                self.colorSelectionCellHeightMultiplier += 1.0
            }
            
            let colorBox = ColorOptionView.init(frame: CGRectMake(frameX, frameY, 50, 50), colorIndex: i, delegate: self);
            self.allColorOptionViews.append(colorBox);
            self.colorSelectionCellView.addSubview(colorBox);
        }
        
        // Don't forget to pull the default selection from the delegate
        self.selectedColorIndex = (self.delegate?.eventColorIndex())!;
        
        // Highlight the appropriate color
        let colorBox : ColorOptionView = self.allColorOptionViews[self.selectedColorIndex];
        colorBox.setSelected(true);
        
        /*
         // If the title is empty then make it first responder
         if(self.eventTitleField.text == "") {
         self.eventTitleField.becomeFirstResponder();
         }*/
    }
    
    private func setupTimePickerViews() {
        // The start time, minimum is 7am
        let startDateTime = (self.delegate?.eventStartDateAndTime())!;
        self.startTimePicker.date = startDateTime;
        let minDate = self.calendar.components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day], fromDate: startDateTime);
        minDate.hour = 8;
        minDate.minute = 0;
        self.startTimePicker.minimumDate = self.calendar.dateFromComponents(minDate);
        
        self.startTimeLabel.text = DTFormatters.sharedInstance.stringFromTime(startDateTime);
        
        // The date is mixed in with startDateTime, do some calculations here
        let today = self.calendar.component(NSCalendarUnit.Day, fromDate: NSDate());
        let selectedDay = self.calendar.component(NSCalendarUnit.Day, fromDate: startDateTime);
        self.selectedDateIndex = selectedDay - today;
        
        // The end time, or default to start time +15mins
        let endTime = self.delegate?.eventEndTime();
        self.endTimePicker.date = endTime!;
        self.endTimeLabel.text = DTFormatters.sharedInstance.stringFromTime(endTime!);
    }
    
    private func setupDatePickerView() {
        let currentDate = NSDate();
        let dayCounter = NSDateComponents.init();
        
        // Let us select 14 days range including today
        for i in 0..<14 {
            
            dayCounter.day = i;
            let date = self.calendar.dateByAddingComponents(dayCounter, toDate: currentDate, options: [])
            
            // Save the dates generated
            allDates.append(date!);
            
            // Fill out the date picker
            self.datePickerOptions.append(DTFormatters.sharedInstance.stringFromDate((date)!));
        }
        
        self.datePickerShowing = false;
        
        // Set the default display date
        self.eventDateLabel.text = self.datePickerOptions[self.selectedDateIndex];
        self.datePicker.selectRow(self.selectedDateIndex, inComponent: 0, animated: false);
    }

//MARK: - Delegate return accessors

    func updatedEventDescription() -> String {
        return eventTitleField.text!;
    }
    
    func updatedStartDateTime() -> NSDate {
        let dateAndTimeComponents = NSDateComponents.init();
        dateAndTimeComponents.year = self.calendar.component(NSCalendarUnit.Year, fromDate: self.allDates[selectedDateIndex]);
        dateAndTimeComponents.month = self.calendar.component(NSCalendarUnit.Month, fromDate: self.allDates[selectedDateIndex]);
        dateAndTimeComponents.day = self.calendar.component(NSCalendarUnit.Day, fromDate: self.allDates[selectedDateIndex]);
        
        dateAndTimeComponents.hour = self.calendar.component(NSCalendarUnit.Hour, fromDate: self.startTimePicker.date);
        dateAndTimeComponents.minute = self.calendar.component(NSCalendarUnit.Minute, fromDate: self.startTimePicker.date);
        
        return self.calendar.dateFromComponents(dateAndTimeComponents)!;
    }
    
    func updatedEndTime() -> NSDate {
        return self.endTimePicker.date;
    }
    
    func updatedColorIndex() -> Int {
        return self.selectedColorIndex;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: - ColorOptionViewDelegate
extension EventDetailsViewController : ColorOptionViewDelegate {
    func colorOptionViewSelected(colorIndex: Int) {
        // Deselect the old color selection
        let view = self.allColorOptionViews[self.selectedColorIndex];
        view.setSelected(false);
        
        // Select the new color selection
        self.selectedColorIndex = colorIndex;
        let newView = self.allColorOptionViews[self.selectedColorIndex];
        newView.isSelected = true;
    }
}

// The following for use with a generic picker view. Not needed for a date picker view.

// MARK: - Picker view data source

extension EventDetailsViewController : UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.datePickerOptions.count;
    }
    
// MARK: - Picker view delegate

    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return self.datePickerOptions[row];
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedDateIndex = row;
        self.eventDateLabel.text = self.datePickerOptions[row];
    }
}

// MARK: - Table view data source
extension EventDetailsViewController {
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        var height : CGFloat = 44.0;
        
        if(indexPath.section == 1 && indexPath.row == 1) {
            
            height = self.datePickerShowing ? 164.0 : 0.0;

        }
        
        else if(indexPath.section == 2 && indexPath.row == 1) {
            
            height = self.startTimePickerShowing ? 164.0 : 0.0;

        }
        
        else if(indexPath.section == 3 && indexPath.row == 1) {
            
            height = self.endTimePickerShowing ? 164.0 : 0.0;
        
        }
        
        else if(indexPath.section == 4 && indexPath.row == 0) {
            height = 10.0 + (60.0 * self.colorSelectionCellHeightMultiplier);
        }
        
        return height;
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if(indexPath.section == 0 && indexPath.row == 0) {
            self.eventTitleField.becomeFirstResponder();
        } else {
            self.eventTitleField.resignFirstResponder();
        }
        
        if(indexPath.section == 1 && indexPath.row == 0) {
            if(self.datePickerShowing) {
                // Hide date picker
                self.hideDatePicker();
            } else {
                // Show date picker
                self.showDatePicker();
                
                // Hide the other 2
                self.hideStartTimePicker();
                self.hideEndTimePicker();
            }
        }
        
        if(indexPath.section == 2 && indexPath.row == 0) {
            if(self.startTimePickerShowing) {
                // Hide start time picker
                self.hideStartTimePicker();
            } else {
                // Show start time picker
                self.showStartTimePicker();
                
                // Hide the date picker
                self.hideDatePicker();
                self.hideEndTimePicker();
            }
        }
        
        else if(indexPath.section == 3 && indexPath.row == 0) {
            if(self.endTimePickerShowing) {
                // Hide end time picker
                self.hideEndTimePicker();
            } else {
                // Show end time picker
                self.showEndTimePicker();
                
                // Hide the date picker
                self.hideDatePicker();
                self.hideStartTimePicker();
            }
        }
        
        else if(indexPath.section == 6 && indexPath.row == 0) {
            // Show prompt and delete on confirm
            let alertController = UIAlertController(title: nil, message: "This event will be deleted. This action cannot be undone.", preferredStyle: .ActionSheet)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
                // Do nothing
            }
            
            let deleteAction = UIAlertAction(title: "Delete ALL items", style: .Destructive) { (action) in
                
                self.delegate?.eventDidRequestDeleteAction();
            }
            
            alertController.addAction(cancelAction);
            alertController.addAction(deleteAction);
            
            self.presentViewController(alertController, animated: true) {}
        }
    }
    
    func showDatePicker() {
        self.datePickerShowing = true;
        
        self.tableView.beginUpdates();
        self.tableView.endUpdates();
        
        self.datePicker.hidden = false;
        self.datePicker.alpha = 0.0;
        
        UIView.animateWithDuration(0.25, animations: {
            self.datePicker.alpha = 1.0;
        })
    }
    
    func hideDatePicker() {
        self.datePickerShowing = false;
        
        self.tableView.beginUpdates();
        self.tableView.endUpdates();
        
        UIView.animateWithDuration(0.25, animations: {
            self.datePicker.alpha = 0.0;
            self.datePicker.hidden = true;
        })
    }
    
    func showStartTimePicker() {
        self.startTimePickerShowing = true;
        
        self.tableView.beginUpdates();
        self.tableView.endUpdates();
        
        self.startTimePicker.hidden = false;
        self.startTimePicker.alpha = 0.0;
        
        UIView.animateWithDuration(0.25, animations: {
            self.startTimePicker.alpha = 1.0;
        })
    }
    
    func hideStartTimePicker() {
        self.startTimePickerShowing = false;
        
        self.tableView.beginUpdates();
        self.tableView.endUpdates();
        
        UIView.animateWithDuration(0.25, animations: {
            self.startTimePicker.alpha = 0.0;
            self.startTimePicker.hidden = true;
        })
    }
    
    func showEndTimePicker() {
        self.endTimePickerShowing = true;
        
        self.tableView.beginUpdates();
        self.tableView.endUpdates();
        
        self.endTimePicker.hidden = false;
        self.endTimePicker.alpha = 0.0;
        
        UIView.animateWithDuration(0.25, animations: {
            self.endTimePicker.alpha = 1.0;
        })
    }
    
    func hideEndTimePicker() {
        self.endTimePickerShowing = false;
        
        self.tableView.beginUpdates();
        self.tableView.endUpdates();
        
        UIView.animateWithDuration(0.25, animations: {
            self.endTimePicker.alpha = 0.0;
            self.endTimePicker.hidden = true;
        })
    }
}

// MARK: - UIDatePicker methods

extension EventDetailsViewController {
    @IBAction func valueChanged(picker: UIDatePicker) {
        if(picker == self.startTimePicker) {
            self.startTimeLabel.text = DTFormatters.sharedInstance.stringFromTime(picker.date);
            
        }
        
        if(picker == self.endTimePicker) {
            self.endTimeLabel.text = DTFormatters.sharedInstance.stringFromTime(picker.date);
        }
    }
}
