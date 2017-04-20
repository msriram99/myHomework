//
//  DetailViewController.swift
//  myHomework
//
//  Created by Himaja Motheram on 4/15/17.
//  Copyright © 2017 Sriram Motheram. All rights reserved.
//

import UIKit
import CoreData
import EventKit

class DetailViewController: UIViewController {
    
    var currentTask: Homework?
    let eventStore = EKEventStore()
    var managedContext  :NSManagedObjectContext!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBOutlet weak var taskNameTextField: UITextField?
    
    @IBOutlet weak var taskDescrTextField: UITextField?
    @IBOutlet weak var dueDatePicker: UIDatePicker?
    
    @IBOutlet weak var reminderdatePicker: UIDatePicker?
    
    @IBOutlet weak var taskCompletedSwitch: UISwitch?
  
  
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        checkEKAuthorizationStatus(type: .event)
        checkEKAuthorizationStatus(type: .reminder)
        managedContext = appDelegate.persistentContainer.viewContext
        
        if currentTask == nil {
           showdefault()
        }
        else{
            let task = currentTask
            display(task: task!)
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    
    @IBAction func savePressed(button: UIBarButtonItem) {
        if let task = currentTask {
            editTask (task: task)
            // print("done")
        } else {
            createTask()
        }
        
        createReminder()
        createCalendarItem()
              // self.navigationController!.popViewController(animated: true)
    }

    
    func display(task: Homework) {
       
        
        taskNameTextField?.text = task.name
        taskDescrTextField?.text = task.descr
        dueDatePicker?.date = task.duedate as! Date
        reminderdatePicker?.date = task.reminder_date as! Date
        taskCompletedSwitch?.isOn = task.completion_status
       
    }
    
    
     func createReminder( ) {
        let reminder = EKReminder(eventStore: eventStore)
        reminder.calendar = eventStore.defaultCalendarForNewReminders()
        reminder.title =  (taskNameTextField?.text)!
        let alarm = EKAlarm(absoluteDate: (reminderdatePicker?.date)!)
         reminder.addAlarm(alarm)
        
        do {
            try eventStore.save(reminder, commit: true)
        } catch let error {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    
     func createCalendarItem() {
        let calEvent = EKEvent(eventStore: eventStore)
        calEvent.calendar = eventStore.defaultCalendarForNewEvents
        calEvent.title = (taskNameTextField?.text)!
        calEvent.startDate = (dueDatePicker?.date)!
        calEvent.endDate = (dueDatePicker?.date)!
        do {
            try eventStore.save(calEvent, span: .thisEvent, commit: true)
        } catch let error {
            print("Error: \(error.localizedDescription)")
        }
    }
    func setTaskValues(task: Homework) {
       
        task.name = taskNameTextField?.text
        task.descr =  taskDescrTextField?.text
        task.duedate = dueDatePicker?.date as NSDate?
        task.reminder_date =  reminderdatePicker?.date as NSDate?
        task.completion_status = (taskCompletedSwitch?.isOn)!
        
    }
    
    func showdefault(){
        
      // taskNameTextField.text = "Enter Task Name here"
        //labelDateCreated.text  = "\(NSDate())"
        taskCompletedSwitch?.isOn = false
        
    }
    
    
    func createTask() {
    
       
        //newTask.duedate = NSDate()
      let newTask = NSEntityDescription.insertNewObject(forEntityName: "Homework", into: managedContext) as! Homework
          setTaskValues(task: newTask)
          appDelegate.saveContext()
          currentTask = newTask
    }
    
    func editTask(task: Homework) {
        setTaskValues(task: task)
        appDelegate.saveContext()
    }

    
    func requestAccessToEKType(type: EKEntityType) {
    eventStore.requestAccess(to: type) { (accessGranted, error) -> Void in
    if accessGranted {
    print("Granted \(type.rawValue)")
    } else {
    print("Not Granted")
    }
    }
    
    }
    
    func checkEKAuthorizationStatus(type: EKEntityType) {
        let status = EKEventStore.authorizationStatus(for: type)
        switch status {
        case .notDetermined:
            print("Not Determined")
            requestAccessToEKType(type: type)
        case .authorized:
            print("Authorized")
        case .restricted, .denied:
            print("Restricted/Denied")
        }
    }

}
