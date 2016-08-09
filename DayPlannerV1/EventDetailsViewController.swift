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

    private var selectedDateIndex   : NSInteger = 0;
    private var allDates            : [NSDate] = [];
    private var datePickerOptions   : [String] = [];
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    // This is called BEFORE the delegate is set
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set default time for start and end time pickers
        
    }

    // This is called AFTER the delegate is set, so get the event details here
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        
        // Data is loaded by calling the delegate, due to this funny architecture
        
        // The date picker
        self.setupDatePickerView();
        
        // Event description
        self.eventTitleField.text = self.delegate?.eventDescription();
        
        // The start time
        let startDateTime = (self.delegate?.eventStartDateAndTime())!;
        self.startTimePicker.date = startDateTime;
        self.startTimeLabel.text = DTFormatters.sharedInstance.stringFromTime(startDateTime);
        


        // The end time, or default to start time +15mins
        let endTime = self.delegate?.eventEndTime();
        self.endTimePicker.date = endTime!;
        self.endTimeLabel.text = DTFormatters.sharedInstance.stringFromTime(endTime!);
        
        /*
         // If the title is empty then make it first responder
         if(self.eventTitleField.text == "") {
         self.eventTitleField.becomeFirstResponder();
         }*/
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
        self.eventDateLabel.text = self.datePickerOptions[0];
    }
    
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
        else if(indexPath.section == 2 && indexPath.row == 0) {
            if(self.startTimePickerShowing) {
                // Hide start time picker
                self.hideStartTimePicker();
            } else {
                // Show start time picker
                self.showStartTimePicker();
                
                // Hide the date picker
                self.hideDatePicker();
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
            }
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
