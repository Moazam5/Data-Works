//
//  ViewController.swift
//  SeniorProject
//
//  Created by Moazam Mir on 3/20/20.
//  Copyright © 2020 Moazam. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController
{
    
    
    //Make user defaults object
    let defaults = UserDefaults.standard   //if this is let, how can we change its property later? (note for Moazam)
    var goToSwiping = false
    var userID = "Example ID - 1234"
    var date = "mm-dd-yyyy"
    var directoryName = "default"
    let fileObject = CreateFile()
    let notificationManager = LocalNotificationManager()
    var cameraPermission = false


    @IBOutlet weak var idLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureNotification()
    //    defaults.set(true, forKey: "swipingVC")
   
        if let id = defaults.string(forKey: "userID"){
            userID = id
            idLabel.text =  "Your User ID: \(userID)"
        }else{
            idLabel.text =  "Example ID: 0000"
        }
      }
    
    func configureNotification()
    {
        //Add Notifications
        notificationManager.notifications = [
            Notification(id: "reminder-1", title: "Remember to Complete the Activity!",body: "Have you completed the activity for today?",
                                   datetime:DateComponents(calendar: Calendar.current,  hour: 12, minute: 00, weekday: 1)),
           Notification(id: "reminder-2", title: "Remember to Complete the Activity!",body: "Have you completed the activity for today?",
                                            datetime:DateComponents(calendar: Calendar.current,  hour: 12, minute: 00, weekday: 2)),
           Notification(id: "reminder-3", title: "Remember to Complete the Activity!",body: "Have you completed the activity for today?",
                                            datetime:DateComponents(calendar: Calendar.current,  hour: 12, minute: 00, weekday: 3)),
           Notification(id: "reminder-4", title: "Remember to Complete the Activity!",body: "Have you completed the activity for today?",
                                            datetime:DateComponents(calendar: Calendar.current,  hour: 12, minute: 00, weekday: 4)),
           Notification(id: "reminder-5", title: "Remember to Complete the Activity!",body: "Have you completed the activity for today?",
                                            datetime:DateComponents(calendar: Calendar.current,  hour: 12, minute: 00, weekday: 5)),
           Notification(id: "reminder-6", title: "Remember to Complete the Activity!",body: "Have you completed the activity for today?",
                                            datetime:DateComponents(calendar: Calendar.current,  hour: 12, minute: 00, weekday: 6)),
           Notification(id: "reminder-7", title: "Remember to Complete the Activity!",body: "Have you completed the activity for today?",
                                            datetime:DateComponents(calendar: Calendar.current,  hour: 12, minute: 00 , weekday: 7))
              ]
            //Schedule Notifications
            notificationManager.schedule()
   }
    

    @IBAction func startButton(_ sender: UIButton)
    {
        /*
         Get the value of SwipingVC to determine which VC to go to
         Check for the time differences
         Conditional to determine which VC to go to
         If all conditions fail, tell user they have completed everything
         */
       
        
        goToSwiping = defaults.bool(forKey: "swipingVC")
        let timeDiff = timeDifference()
        
        if goToSwiping == true && timeDiff >=  0.01 // hours should be >= 12
        {
          //  self.defaults.set(Date().timeIntervalSince1970, forKey: "lastUsedTime")
            askForCamera(segueVC: "swipingVC")
        }
        else if goToSwiping == false && timeDiff >=  0.03   // hours should be >= 12
        {
    //        self.defaults.set(Date().timeIntervalSince1970, forKey: "lastUsedTime")
            askForCamera(segueVC: "writingVC")
        }
        else
        {
            alertForNoActivity()
        }
        
        
    }
    
    
        override func prepare(for segue: UIStoryboardSegue, sender: Any?)
        {
            
            print("The Usr id is \(defaults.string(forKey: "userID"))") //Initially this is nil
          
            //Set the value for userID which is stored in UserDefaults, if not set, prompt user for one
            
            if let id = defaults.string(forKey: "userID"){
                userID = id
                print("User id is \(userID)")
            }
            else   //Ask for id
            {
                 let alert = UIAlertController(title: "Enter User ID", message: "The user ID is a 4-digit identification number assigned to each person. Please enter 5555 if you don't have one.", preferredStyle: .alert)

                alert.addTextField { (textField) in
                    textField.placeholder = "5555"
                }
                    let alertAction = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
                   // self.userID =
                    let textField = alert.textFields![0] // Force unwrapping because we know it exists.
                    self.userID = textField.text!
                    //Store userID in User Defaults
                    self.defaults.set(self.userID, forKey: "userID")
                    self.idLabel.text = "Your User ID: \(self.userID)"

                }
                alert.addAction(alertAction)
                self.present(alert, animated: true, completion: nil)
                //return
            }

            
            self.date = getTodayAsString()  //this can be gotten rid of
            self.directoryName = "\(date)-\(userID)"   //Here we can end up putting nil for the userID, look into this
            //Save the directory name in user defaults
            defaults.set(directoryName, forKey: "folderName")
                                      
            
            if segue.identifier == "writingVC"
            {
                fileObject.createWritingFiles(folderName: directoryName)                 //create directory with all the files

                let destinationVC = segue.destination as! WritingViewController
                destinationVC.smObject.startSensors()              //Start Accelerometer and Gyroscope
                if cameraPermission == true
                {
                    destinationVC.requestForCamera = true              //Request For video recording
                }
                destinationVC.maxTime = Double(60)                     //Set time for the activity

              //  destinationVC.userId = self.userID  //not using this anywhere for now
                
                if #available(iOS 13.0, *) {
                destinationVC.isModalInPresentation = true
                } else {
                // Fallback on earlier versions
            }
        }

            else if segue.identifier == "swipingVC"
            {
                print("In the other swiping conditional")
                
                fileObject.createSwipingFiles(folderName: directoryName)   //Create directory with all the files
                
                let destinationVC = segue.destination as! GameViewController
                destinationVC.smObject.startSensors()    //Start Accelerometer and Gyroscope
                if cameraPermission == true
                {
                    destinationVC.requestForCamera = true              //Request For video recording
                }
                destinationVC.timerTime = 60             //the time for activity
                
                if #available(iOS 13.0, *) {
                    destinationVC.isModalInPresentation = true
                } else {
                    // Fallback on earlier versions
                }
            }
            
            
    }
    
    
    func askForCamera(segueVC : String)
    {
        let alert = UIAlertController(title: "Permission For Camera", message: "The App will record video from the front camera during the activity. Please Press Accept to grant permission or Deny to deny permission", preferredStyle: .alert)
        
        //ACCEPT ACTION
        let acceptAction = UIAlertAction(title: "Accept", style: .default)
        { (UIAlertAction) in
            
            self.cameraPermission = true
            print("Camera permission is \(self.cameraPermission)")
            //Perform segue from within alert
                  
            if segueVC == "swipingVC"
            {
                self.performSegue(withIdentifier: "swipingVC", sender: self)
            }
            else if segueVC == "writingVC"
            {
                self.performSegue(withIdentifier: "writingVC", sender: self)
                
            }
        }
        //DENY ACTION
        let denyAction = UIAlertAction(title: "Deny", style: .default)
        { (UIAlertAction) in
            self.cameraPermission = false
            print("Camera permission is \(self.cameraPermission)")
       //     self.defaults.set(Date().timeIntervalSince1970, forKey: "lastUsedTime")
            self.performSegue(withIdentifier: "swipingVC", sender: self)
        }
        
        alert.addAction(acceptAction)
        alert.addAction(denyAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    //Completion Alert
    func alertForNoActivity()
    {
        let alert = UIAlertController(title: "No Activity", message: "You have completed all activities for today", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    //Get the date as mm-dd-yyyy-hh:mm
    func getTodayAsString() -> String{
        
        let date = Date()
        let calender = Calendar.current
        let components = calender.dateComponents([.year,.month,.day,.hour,.minute,.second], from: date)
        
        let year = components.year
        let month = components.month
        let day = components.day
        let hour = components.hour
        let minute = components.minute
        //  let second = components.second
        
        let currentDate = String(year!) + "-" + String(month!) + "-" + String(day!) +  "-" + String(hour!)  + "-" + String(minute!)
        return currentDate
    }
    
    func timeDifference() -> Double
    {
        let previousTime = defaults.double(forKey: "lastUsedTime")
        let newTime = Date().timeIntervalSince1970
        
        print("Past time \(previousTime)\n New Time : \(newTime)")
        let diff = Double(newTime - previousTime)
        let hours = diff / 3600
        let minutes = (diff - hours * 3600) / 60
        print("Hours : \(hours)\n Minutes : \(minutes)")
        
        return hours
        
    }

}

