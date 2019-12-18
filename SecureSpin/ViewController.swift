//
//  ViewController.swift
//  SecureSpin
//
//  Created by Student on 10/23/19.
//  Copyright © 2019 Student. All rights reserved.
//

/*
    FOR PEOPLE ON GITHUB: This app works on iPhone 6s and above, iOS 13.1.2, and XCode 11.0. It may not work on newer versions
 of any of these!
 */

/*
    Hi student in probobly Fall 2020, welcome to SecureSpin! This was my first time coding in Swift, XCode, or even a cellphone app,
 so sorry if the code isn't very good. I tried to leave some decent comments in case this is your first time using Swift as well, but
 idk how helpful I've been. I wrote a blog about this app for CS475,
 https://lindseyaherman.blogspot.com/2019/10/ajourney-of-thousand-miles-begins-with.html , where I liked to many of the websites
 where I learned how to code in Swift 5. If you're still confused, my John Carroll email is lherman21@jcu.edu , or if that gets deleted
 when I graduate, there's always lindseyherman95@yahoo.com. Feel free to shoot me an email about what code does.
 */


/*
    If you haven't done so already, go the the Main.storyboard and marvel at the click-and-drag graphics that make up the app.
 No Rectangle2D.Double code needed here! There are some confusing things in the actual code in the other classes though,
 such as the encryption and the many ways the screen changes each time a color is entered on the CreateLogin and WheelScreen.
 Also note that everything below the Assets.xcassets was auto-generated when the app was created, and I didn't change them.
 You probobly won't need to either. By the way, the Assets.xcassets stores all the images used in the app.
 Right now, the app is only using one image of a color wheel, but I kept the older color wheel images in case Dr. Gurary
 wants them one day for whatever reason.
 */


//  Each class is associated with a different screen. On the Main.storyboard, the white rectangle at the top of a screen
//  shows which class is associated with it. You can change what class is associated with the screen at any time. 



//  Import statements are like in Java, except it won't warn you if you need an import statement to make the code work, it will
//  just run code that can never work, like it did with the notification code!
import UIKit
//  IMPT!! WITHOUT THIS, THE NOTIFICATIONS WON'T WORK!!
import UserNotifications

//  This is the first screen that loads. I think it has to be called "View Controller", it's like how the
//  first page on a website is always "index.html".

//  A Mark makes the text after it show up next to the scroll bar on the right ------------------------------------------>
// MARK: - ViewController
class ViewController: UIViewController
{

    //   This will get set to the number of days since the first time the user opened the app.
    //  -1 means error! Should never stay this or get this value as the nil error below.
    var dayNumber = Int(-1)


    // MARK: - registerLocal()
    //  This is for the notification pop-up. Will print different things depending on which of the two buttons
    //  the user presses. The pop-up is built-in to Apple's code, I didn't code the popup or its buttons myself.
    func registerLocal() {
        let center = UNUserNotificationCenter.current()

        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("Yay!")
            } else {
                print("D'oh")
            }
        }
    }
    
    // MARK: - scheduleLocal()
    //  This creates the content of the notification.
    func scheduleLocal() {
        let center = UNUserNotificationCenter.current()

        let content = UNMutableNotificationContent()
        content.title = "Secure Spin"
        content.body = "A day has passed, please re-enter your password."
        //content.categoryIdentifier = "alarm"
        //content.userInfo = ["customData": "fizzbuzz"]
        content.sound = UNNotificationSound.default

        let now = Date()
        
        var dateComponents = DateComponents()
        
        //let calendar = Calendar.current
        //  Sets the notification to whatever time it currently is, so that it will go off exactly a day from then.
        dateComponents.hour = Calendar.current.component(.hour, from: now)
        dateComponents.minute = Calendar.current.component(.minute, from: now)
        //  "repeats: true" means the notifications will appear every day until the end of time!
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        //  If you want to quickly test what a notification will look like instead of waiting 24hrs, uncomment this line to
        //  make the notification appear 30 seconds after running the code.
        //let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 30, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        center.add(request)
    }
    
    
    
    //  MARK: - Begin Button
    @IBAction func Begin(_ sender: UIButton)
    {
        //  Only create the notification once; the first time the user opens the app.
        //  UserDefaults store data on the phone that remains even when the app is closed, so the next time the app
        //  is opened, it will still remember that "notificationCreated == true"
        if (UserDefaults.standard.object(forKey: "notificationCreated") == nil)
        {
            scheduleLocal()
            UserDefaults.standard.set(true, forKey: "notificationCreated")
            print("First Notification")
        }
        else
        {
            print("Already Scheduled a notification")
        }
        
        //  Three segue possibilities depending on what UserDefaults (if any) have been created on other screens.
        //  If it's the first time the user opened the app, they will all be nil (null).
        //if (UserDefaults.standard.object(forKey: "consentFormSigned") == nil)
        if (UserDefaults.standard.object(forKey: "profileCreated") == nil)
        {
            //  Added a Consent Form between ViewController and UserProfile:
            performSegue(withIdentifier: "beginToConsentForm", sender: self)
        }
        /*else if (UserDefaults.standard.object(forKey: "profileCreated") == nil)
        {
            performSegue(withIdentifier: "goToProfile", sender: self)
        }*/
        else if (UserDefaults.standard.object(forKey: "loginCreated") == nil)
        {
            performSegue(withIdentifier: "goToLogin", sender: self)
        }
        else
        {
            performSegue(withIdentifier: "goToWheel", sender: self)
        }
        
    }

    //  MARK: - getNumDays()
    //  Returns the number of days that have passed since the user first opened the app.
    func getNumDays(fromDate date : Date, toDate date2 : Date) -> Int
    {
        let unitFlags: Set<Calendar.Component> = [.day]
        let deltaD = Calendar.current.dateComponents( unitFlags, from: date, to: date2)
        //  -1 means error!
        return deltaD.day ?? -1
    }
    
    //  MARK: - getCurrentDate()
    //  Gets the current time down to the second
    func getCurrentDate()-> Date
    {
        var now = Date()
        var nowComponents = DateComponents()
        let calendar = Calendar.current
        nowComponents.year = Calendar.current.component(.year, from: now)
        //nowComponents.month = Calendar.current.component(.month, from: now) + 1
        nowComponents.month = Calendar.current.component(.month, from: now)
        //  If you want to test if the date code is working without waiting an actual day, just add a number to it like below:
        //  Don't forget, if the date is the 31st and you add 1, that will be the 32nd of the month, which isn't a real date.
        //  Add one to the month instead, and put the day back to 1.
        //nowComponents.day = Calendar.current.component(.day, from: now) - 15
        nowComponents.day = Calendar.current.component(.day, from: now)
        //print(nowComponents.day)
        nowComponents.hour = Calendar.current.component(.hour, from: now)
        nowComponents.minute = Calendar.current.component(.minute, from: now)
        nowComponents.second = Calendar.current.component(.second, from: now)
        nowComponents.timeZone = NSTimeZone.local
        now = calendar.date(from: nowComponents)!
        return now as Date
    }
    
    // MARK: - getFormerDate()
    //  If this is the first app open, the UserDefaults will be nil, so the former date will get set. If there are UserDefaults for it
    //  already due to a previous app open, they will stay the same.
    func getFormerDate()-> Date
    {
        var aDate = Date()
        var aDateComponents = DateComponents()
        let calendar = Calendar.current
        
        if (UserDefaults.standard.object(forKey: "year") == nil)
        {
            //print("new year")
            aDateComponents.year = Calendar.current.component(.year, from: aDate)
            UserDefaults.standard.set(aDateComponents.year, forKey: "year")
        }
        else
        {
            let data = UserDefaults.standard.object(forKey: "year")
            //if var year = data as? CGFloat
            //{
            aDateComponents.year = data as? Int
            //}
        }
        
        if (UserDefaults.standard.object(forKey: "month") == nil)
        {
            aDateComponents.month = Calendar.current.component(.month, from: aDate)
            UserDefaults.standard.set(aDateComponents.month, forKey: "month")
        }
        else
        {
            let data = UserDefaults.standard.object(forKey: "month")
            aDateComponents.month = data as? Int
        }
        
        if (UserDefaults.standard.object(forKey: "day") == nil)
        {
            aDateComponents.day = Calendar.current.component(.day, from: aDate)
            UserDefaults.standard.set(aDateComponents.day, forKey: "day")
        }
        else
        {
            let data = UserDefaults.standard.object(forKey: "day")
            aDateComponents.day = data as? Int
        }
        
        if (UserDefaults.standard.object(forKey: "hour") == nil)
        {
            aDateComponents.hour = Calendar.current.component(.hour, from: aDate)
            UserDefaults.standard.set(aDateComponents.hour, forKey: "hour")
        }
        else
        {
            let data = UserDefaults.standard.object(forKey: "hour")
            aDateComponents.hour = data as? Int
        }
        
        if (UserDefaults.standard.object(forKey: "minute") == nil)
        {
            aDateComponents.minute = Calendar.current.component(.minute, from: aDate)
            UserDefaults.standard.set(aDateComponents.minute, forKey: "minute")
        }
        else
        {
            let data = UserDefaults.standard.object(forKey: "minute")
            aDateComponents.minute = data as? Int
        }
        
        if (UserDefaults.standard.object(forKey: "second") == nil)
        {
            aDateComponents.second = Calendar.current.component(.second, from: aDate)
            UserDefaults.standard.set(aDateComponents.second, forKey: "second")
        }
        else
        {
            let data = UserDefaults.standard.object(forKey: "second")
            aDateComponents.second = data as? Int
        }
        
        //aDateComponents.month = Calendar.current.component(.month, from: aDate) + 1
        //  These count the number of midnights, so does not count the current day if less than 24 hrs left of it.
        //aDateComponents.day = Calendar.current.component(.day, from: aDate)- 15
        //print(aDateComponents.day)

        aDateComponents.timeZone = NSTimeZone.local
        aDate = calendar.date(from: aDateComponents)!
        return aDate as Date
    }
    
    //  MARK: - viewDidLoad()
    //  The viewDidLoad() is an auto-generated method.
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //  Creates the random number that will be used as the userID for that person when they send anonymous data to Dr. Gurary's
        //  database. It is between 0 and the maximum size for a UInt64() (largest type of Int).
        if (UserDefaults.standard.object(forKey: "userID") == nil)
        {
            var randomNumber = UInt64()
            randomNumber = UInt64.random(in: 0 ..< 10000000000000000)
            print(randomNumber)
            UserDefaults.standard.set(randomNumber, forKey: "userID")
        }
        
        //  Ask if user is ok with notifications
        registerLocal()
        
        //print("Number of days:")
        dayNumber = getNumDays(fromDate: getFormerDate(), toDate: getCurrentDate())
        UserDefaults.standard.set(dayNumber, forKey: "numberOfDays")
        print(dayNumber)
        
        //  JUST FOR TESTING IF FEEDBACKSCREEN ENCRYPTION WORKING!!
        if (dayNumber >= 2)
        //  Normally want this to only segue to the FeedbackScreen if >= 14 days have passed since the user first opened the app:
        //  Whoops! The first day is 0, not 1, so to get 14 days, actually want >= 13!
        //  Dr. Gurary said to change this to 2 or 3 days for the student testing:
        //if (dayNumber >= 13)
        {
            UserDefaults.standard.set(true, forKey: "fourteenDays")
        }
    }

}
