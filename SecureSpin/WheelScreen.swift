//
//  WheelScreen.swift
//  SecureSpin
//
//  Created by Student on 10/23/19.
//  Copyright © 2019 Student. All rights reserved.
//

import UIKit
//  For vibrations:
import AudioToolbox.AudioServices

// MARK: - WheelScreen
//  This is where you re-enter the password 1 time, hopefully, unless you mess up and have to redo it.
class WheelScreen: UIViewController
{
    
    //  Create global variables here
    
    //  The wheel image:
    //  The line below would be needed for the code in the viewDidLoad() to work, but now that I commented that code out
    //  because I found a better way, the click-and-drag @IBOutlet is needed instead
    
    //let imageView = UIImageView()
    @IBOutlet weak var imageView: UIImageView!
    //  Wheel stuff:
    var lastLocation = CGPoint(x: 0, y: 0)
    var currentLocation = CGPoint(x: 0, y: 0)
    var currentAngle = CGFloat(0)
    //  0, 1, 2, or 3:
    var numberOfColorsEntered = Int(0)
    //  Did the user not get their password right on the first try? This keeps track of how many tries before
    //  they got it right:
    var numberOfAttempts = Int(0)
    //  Swift 5 uses radians, converted to degrees to save in UserDefaults:
    var angleInDegrees = CGFloat(0)
    
    //  For random vibrations:
    var randomNumber = Int(0)
    //  If the user got a color wrong, make them re-enter their password:
    var gotColorWrong = Bool(false)
    //  For making the rectangles at the bottom choose a color based on the color at like "T2" if it's that vibration,
    //  instead of always the color at zero degrees:
    var addToAngle = CGFloat(0)
    
    var unusedVariable = CGFloat(0)
    
    //  For duration:
    //  For each individual color:
    var startTime : UInt64 = 0
    //  For total duration:
    var firstStartTime : UInt64 = 0
    
    var firstColorTime : Double = -1
    var secondColorTime : Double = -1
    var thirdColorTime : Double = -1
    var fourthColorTime : Double = -1
    
    //  For one password enter, could get sent multiple times if user messes up/resets.
    var onePasswordEnter : Double = -1
    
    //  For total duration:
    var totalTime : Double = -1
    //  For each individual color:
    var stopTime : UInt64 = 0
    
    //  Dumb extra steps for like nanotime in Swift as compared to Java:
    var numer: UInt64 = 0
    var denom: UInt64 = 0
    var duration : UInt64 = 0
    
    //  For amount off from color they were:
    var differenceOne = CGFloat(9000)
    var differenceTwo = CGFloat(9000)
    var differenceThree = CGFloat(9000)
    var differenceFour = CGFloat(9000)
    
    //  For saving the vibration:
    //var vibrationOne = UInt32(0)
    //var vibrationTwo = UInt32(0)
    //var vibrationThree = UInt32(0)
    //var vibrationFour = UInt32(0)
    var vibrationOne = String("None")
    var vibrationTwo = String("None")
    var vibrationThree = String("None")
    var vibrationFour = String("None")
    
    //var durationInSeconds: Double = 0
    
    //  Four choices:
    var vibrationString = String("None")
    var vibrationNumber = UInt32(0)
    //  For checking if the stored angle and the current angle are close enough to count as the correct color:
    var marginOfErrorHalved = CGFloat(15)
    
    //  The white text at the top of the screen:
    @IBOutlet weak var topText1: UILabel!
    @IBOutlet weak var topText2: UILabel!
    
    //  For vibration background thread:
    var exitWhileLoopCounter = Int(0)

    let backgroundQueue1 = DispatchQueue(label: "com.app.queue", qos: .background)
    
    //  For not playing a vibration when segueing to the next screen:
    var notDoneWithVibrations = Bool(true)
    
    //var weekdayVariable = Int(0)
    
    //  Here are three white rectangles for when a user enters a color to let them know they entered one, but not which color.
    //  There will not need to be a fourth one, because, upon entering the fourth color, they are either done and segue to the "Done" screen,
    //  or they will need to redo their password and start over with no rectangles.
    @IBOutlet weak var whiteRectangle1: UILabel!
    @IBOutlet weak var whiteRectangle2: UILabel!
    @IBOutlet weak var whiteRectangle3: UILabel!
    
    // MARK: - postRequest()
    //  This is what sends the data to Dr. Gurary's database
    func postRequest()
    {
        //  It does it on a background thread
        DispatchQueue.global(qos: .background).async
        {
            //Create url object
            guard let url = URL(string: "http://passworks.dyndns-remote.com/spin/pushSpinLogin.php") else {return}
            //Create the session object
            let session = URLSession.shared

            //Create the URLRequest object using the url object
            var request = URLRequest(url: url)

            //Set the request method. Important Do not set any other headers, like Content-Type
            request.httpMethod = "POST" //set http method as POST

            
         
         //var randomNumber = UserDefaults.standard.object(forKey: "userID")
         //  It added five 0's to the end of the number for some reason, doing "%.1f" makes sure it stays one decimal place
         //let stringFloat = String(format: "%f", randomNumber)
         //  Works for Doubles and CGFloats:
         //let stringFloat = String(format: "%.1f", randomNumber)
         //  Works for UInt64's, the last of the non-string data types I am sending to the database:
         var theUserId = String()
         let someData = UserDefaults.standard.object(forKey: "userID")
         if let randomNumber = someData as? UInt64
         {
             theUserId = String(randomNumber)
         }
            var theDayNumber = String()
        let dayNumber = UserDefaults.standard.object(forKey: "numberOfDays")
            if let theDay = dayNumber as? Int
            {
                theDayNumber = String(theDay)
            }
            
         let userId = String("userid=")
         //var postData = "userid=".data(using: .utf8)
         var userIdData = theUserId
            userIdData = userIdData + "," + theDayNumber
            userIdData = userIdData + "," + String(self.numberOfAttempts)
         let time = String("&time=")
         //let timeData = timeWasInt
        var timeData = String(format: "%f", self.firstColorTime)
            timeData = timeData + "," + String(format: "%f", self.secondColorTime)
            timeData = timeData + "," + String(format: "%f", self.thirdColorTime)
            timeData = timeData + "," + String(format: "%f", self.fourthColorTime)
            timeData = timeData + "," + String(format: "%f", self.onePasswordEnter)
            timeData = timeData + "," + String(format: "%f", self.totalTime)
            let data = String("&data=")
         //let dataData = String(encryptedData)
         //let dataData = String("Cant encrypt")
            //var dataData = String(format: "%f", self.firstColor)
            //dataData = dataData + "," + String(format: "%f", self.secondColor)
            //dataData = dataData + "," + String(format: "%f", self.thirdColor)
            //dataData = dataData + "," + String(format: "%f", self.fourthColor)
            var dataData = String(format: "%f", self.differenceOne)
            dataData = dataData + "," + String(format: "%f", self.differenceTwo)
            dataData = dataData + "," + String(format: "%f", self.differenceThree)
            dataData = dataData + "," + String(format: "%f", self.differenceFour)
            let extras = String("&extras=")
            var extrasData = self.vibrationOne
            extrasData = extrasData + "," + self.vibrationTwo
            extrasData = extrasData + "," + self.vibrationThree
            extrasData = extrasData + "," + self.vibrationFour
            //let postData = userId.data(using: utf8)
         var postData = Data(userId.utf8)
         print(postData as NSData)
         postData = postData + Data(userIdData.utf8)
         postData = postData + Data(time.utf8)
         postData = postData + Data(timeData.utf8)
         postData = postData + Data(data.utf8)
         postData = postData + Data(dataData.utf8)

         postData = postData + Data(extras.utf8)
         postData = postData + Data(extrasData.utf8)
         
         
        //  Only works if everything is a String, can't do String variables, will send the name of the variable
            //  instead of its data
      //let postData = "userid=12342&time=234234&data="12345"&extras=77686".data(using: .utf8)

         
     request.httpBody = postData
      
      //Create a task using the session object, to run and return completion handler
      let webTask = session.dataTask(with: request, completionHandler: {data, response, error in
      guard error == nil else {
      print(error?.localizedDescription ?? "Response Error")
      return
      }
      guard let serverData = data else {
      print("server data error")
      return
      }
      do {
      if let requestJson = try JSONSerialization.jsonObject(with: serverData, options: .mutableContainers) as? [String: Any]{
      print("Response: \(requestJson)")
      }
        //  It isn't JSON, so it's ok that it catches it here, as long as it says "Optional(Inserted correctly /n", blah blah blah
      } catch let responseError {
      print("Serialisation in error in creating response body: \(responseError.localizedDescription)")
      let message = String(bytes: serverData, encoding: .ascii)
      print(message as Any)
      }
      })
          //Run the task
          webTask.resume()
        //  Only do this after they have been sent!
            //  This needs to be on this background thread, because the background thread runs slower than the main one, so
            //  if it's on the main thread, it will often send reset values to the database, so I put the resetting
            //  on the background thread so that it only happens after the correct values send.
            //  And only if not segueing to new screen!
            if (self.notDoneWithVibrations)
            {
                self.resetVariablesSentToDatabase()
                self.timeNextColorEnter()
            }
            
        }

    }
    //  MARK: - forgotPassword()
    //  Stop vibration, go to popup screen
    @IBAction func forgotPassword(_ sender: UIButton)
    {
        //numberOfAttempts = numberOfAttempts + 1
        postRequest()
        //  Stop the vibration from playing 
        exitWhileLoopCounter = exitWhileLoopCounter + 1
        performSegue(withIdentifier: "wheelToReset", sender: self)
    }
    
    //  MARK: - resetTry()
    //  Start over on first digit of color.
    @IBAction func resetTry(_ sender: UIButton)
    {
        //  Screen starts over:
        numberOfColorsEntered = 0
        //view.backgroundColor = UIColor.darkGray
        //  Draw attention to new text
        topText1.backgroundColor = UIColor.darkGray
        topText2.backgroundColor = UIColor.darkGray
        //  Make rectangles for colors entered disappear
        whiteRectangle1.backgroundColor = UIColor.black
        whiteRectangle2.backgroundColor = UIColor.black
        whiteRectangle3.backgroundColor = UIColor.black
        

        
        onePasswordEnter = firstColorTime + secondColorTime + thirdColorTime + fourthColorTime
        print(onePasswordEnter)
        numberOfAttempts = numberOfAttempts + 1
        //  SEND TO DATABASE HERE!!!!!!!!
        postRequest()
        //resetVariablesSentToDatabase()
    }
    
    //  MARK: - resetVariablesSentToDatabase()
    func resetVariablesSentToDatabase()
    {
        //  Timing the color entry starts over:
        var info = mach_timebase_info(numer: 0, denom: 0)
        mach_timebase_info(&info)
        numer = UInt64(info.numer)
        denom = UInt64(info.denom)
        startTime = mach_absolute_time()
        
        //  The vibrations start over:
        vibrationTwo = "None"
        vibrationThree = "None"
        vibrationFour = "None"
        getRandom()
        vibrationOne = vibrationString
        //  WHOOPS, AND RESET COLOR TIMES!
        firstColorTime = -1
        secondColorTime = -1
        thirdColorTime = -1
        fourthColorTime = -1
        onePasswordEnter = -1
        
        //  Difference between correct color and what they entered starts over:
        differenceOne = 9000
        differenceTwo = 9000
        differenceThree = 9000
        differenceFour = 9000
        
    }
    
    // MARK: - timeNextColorEnter()
    //  For timing how long it takes a user to enter a color. (starting timer)
    func timeNextColorEnter()
    {
        var info = mach_timebase_info(numer: 0, denom: 0)
        mach_timebase_info(&info)
        numer = UInt64(info.numer)
        denom = UInt64(info.denom)
        startTime = mach_absolute_time()
    }
    
    //  MARK: - stopLastColorEnter()
    //  Stops the timer, method above starts the timer
    func stopLastColorEnter() -> Double
    {
        stopTime = mach_absolute_time()
        print("Stop Time:")
        print(stopTime)
        //duration = stopTime - startTime
        duration = ((stopTime - startTime) * numer) / denom
        print("Duration in Nanoseconds:")
        print(duration)
        let aColorTime = Double(duration) / 1000000000
        print("A Color Time:")
        print(aColorTime)
        return aColorTime
    }
    
    // MARK: - selectingOneColor()
    //  It does too much stuff, and so does the if-statement. There should be lots of methods, probobly
    func selectingOneColor(key : String) -> CGFloat
    {
        //  Should never stay this
        var tempDifference = CGFloat(9000)

        angleInDegrees = radiansToDegrees(radianAngle: currentAngle)
        print(angleInDegrees)
        let data = UserDefaults.standard.object(forKey: key)
        if var storedAngle = data as? CGFloat
        {
            print("Actual Stored Angle:")
            print(storedAngle)

            
            storedAngle = storedAngle + addToAngle
            if (storedAngle > 359)
            {
                storedAngle = storedAngle - 360
            }
            print("With addToAngle:")
            print(storedAngle)
            
            //  Can be like 180 in one direction, -180 in the other
            tempDifference = storedAngle - angleInDegrees
            
            //  This has a margin of error of 15degrees more or less for the user, can change whenever
            //if ((angleInDegrees >= storedAngle - marginOfErrorHalved) && (angleInDegrees <= storedAngle + marginOfErrorHalved))
            if (storedAngle > marginOfErrorHalved && storedAngle < 360 - marginOfErrorHalved)
            {
                print("Normal Angle")
                if ((angleInDegrees >= storedAngle - marginOfErrorHalved) && (angleInDegrees <= storedAngle + marginOfErrorHalved))
                {
                    print("Got it right!")
                }
                else
                {
                    print("Got it wrong!")
                    gotColorWrong = true
                }
            }
            //  So if an angle is <= 15, doing the same thing as the other angles will result in the (angle - 15) being like -4 or
            //  something, but those aren't angles on a wheel, so want -4 to be 356 instead, so this does that.
            else if (storedAngle <= marginOfErrorHalved)
            {
                print("Small Angle")
                let remainder = marginOfErrorHalved - storedAngle
                print ("Remainder")
                print(remainder)

                if ((angleInDegrees <= storedAngle + marginOfErrorHalved && angleInDegrees > 0) || (angleInDegrees >= 360 - remainder))
                {
                    print("Got it right!")
                }
                else
                {
                    print("Got it wrong!")
                    gotColorWrong = true
                }
            }
                //  And then this is the same thing but for angles like 370 that would be above 360, want it to be 10 degrees instead.
            else if (storedAngle >= 360 - marginOfErrorHalved)
            {
                print("Big Angle")
                let remainder = (storedAngle + marginOfErrorHalved) - 360
                print ("Remainder")
                print(remainder)
                //if ((angleInDegrees >= 345 && angleInDegrees < 360) || (angleInDegrees >= 0 && angleInDegrees < 15))
                //  storedAngle = 350, angleInDegrees = 355
                //  355 > 350                          355 < 360                 360 - 355 = 5              360 - 350 = 10
                //if ((angleInDegrees >= storedAngle && angleInDegrees < 360) || (360 - angleInDegrees <= storedAngle - 360))
                //  Gets 15degrees below angle
                if ((angleInDegrees >= storedAngle - marginOfErrorHalved && angleInDegrees < 360) || (angleInDegrees <= remainder))
                {
                    print("Got it right!")
                }
                else
                {
                    print("Got it wrong!")
                    gotColorWrong = true
                }
            }
                
                //else if (storedAngle >= 345 || storedAngle < 15)
            //{
                //if ((angleInDegrees >= 345 && angleInDegrees < 360) || (angleInDegrees >= 0 && angleInDegrees < 15))
                //{
                    //print("Got it right!")
                //}
            //}

            
            numberOfColorsEntered = numberOfColorsEntered + 1
            
        }
        return tempDifference
    }
    
    

    
      
      //    MARK: - radiansToDegrees()
        //  What it sounds like
      func radiansToDegrees(radianAngle: CGFloat) -> CGFloat
      {
          var degreeAngle = CGFloat()
          degreeAngle = radianAngle * (180 / .pi);
          return degreeAngle
      }
      
    //  MARK: - degreesToRadians()
    //  What it sounds like
      func degreesToRadians(degreeAngle: CGFloat) -> CGFloat
      {
          var radianAngle = CGFloat()
          radianAngle = degreeAngle * (.pi / 180);
          return radianAngle
      }
    
  
    //  MARK: - getRandom()
    //  Chooses random vibration and runs it on a background thread:
    func getRandom()
    {
        //  Stops the previous vibration:
        exitWhileLoopCounter = exitWhileLoopCounter + 1
        //  0,1,2,3
        randomNumber = Int.random(in: 0 ..< 4)
        //print(randomNumber)

        if (randomNumber == 0)
        {
            //  No vibration
            //AudioServicesPlaySystemSound(1520)
            vibrationNumber = 1520
            vibrationString = "1Tap"
            //  This makes it so that the color chosen is the one facing the "1T" label at 45-degrees on the wheel
            addToAngle = 45
            print("1T")
        }
        else if (randomNumber == 1)
        {
            //AudioServicesPlaySystemSound(1520)
            //AudioServicesPlaySystemSound(1102)
            vibrationNumber = 1102
            vibrationString = "2Taps"
            addToAngle = 135
            print("2T")
        }
        else if (randomNumber == 2)
        {
            //AudioServicesPlaySystemSound(4095)
            vibrationNumber = 4095
            vibrationString = "1Buzz"
            //AudioServicesPlaySystemSound(1102)
            addToAngle = 225
            print("1B")
        }
        
        else if (randomNumber == 3)
        {
            //AudioServicesPlaySystemSound(1011)
            vibrationNumber = 1011
            vibrationString = "2Buzzes"
            //  If you want three taps:
            //AudioServicesPlaySystemSound(1521)
            addToAngle = 315
            print("2B")
        }
        
        
        let loopNumber = self.exitWhileLoopCounter
        //  The background thread that works!
        backgroundQueue1.async
        {
        //DispatchQueue.main.async(execute: workItem!)
        //workItem1 = DispatchWorkItem

             while loopNumber == self.exitWhileLoopCounter
             //while (0 < 1)
             {
                AudioServicesPlaySystemSound(self.vibrationNumber)
                //  One second of sleep in miliseconds:
                //usleep(1000000)
                //  0.8 seconds of sleep:
                usleep(800000)
                //  0.58 seconds is the length of the 1-buzz vibration, 0.8 the 2-buzz longest vibration
                //usleep(580000)
                //  One second of sleep:
                //sleep(1)
             }
         }
    }
    
    //  MARK: - touchesBegan()
        //  Like "Mouse Pressed" in Java
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        if let touch = touches.first
        {

            lastLocation = touch.location(in: view)
            currentLocation = touch.location(in: view)

        }
    }
       
    //  MARK: - touchesMoved()
    //  Like "Mouse Dragged" in Java
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        if let touch = touches.first
        {

            currentLocation = touch.location(in: view)
            unusedVariable = updateRotation(currentLocation: currentLocation)

        }
    }
       
    //  MARK: - touchesEnded()
    //  Like "Mouse Released" in Java
    //  This method has a giant glob of if-statements that should probobly have more methods in them than they do
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        if let touch = touches.first
        {

            currentLocation = touch.location(in: view)
            currentAngle = updateRotation(currentLocation: currentLocation)

            //  Lots of long if-statements for what color user is entering:
            if (numberOfColorsEntered == 0)
            {
                //  The first time you enter a color, the text should be this:
                topText1.text = "Line up each color in your password with the"
                topText2.text = "number of taps or buzzes you felt before it:"
                //  Get the difference between the actual angle of color the user chose as their password and what angle
                //  they curerntly chose.
                differenceOne = selectingOneColor(key: "firstColor")
                //  Get a new random vibration
                getRandom()
                //  Set the second vibration variable to it. Don't forget, the first vibration plays before the first color
                //  is entered, so when you enter the first color, you want the second vibration.
                vibrationTwo = vibrationString
                //  Change the background color of the text to black because it's not new text.
                //view.backgroundColor = UIColor.black
                topText1.backgroundColor = UIColor.black
                topText2.backgroundColor = UIColor.black
                //  Display a single white rectangle to represent one password color has been entered
                whiteRectangle1.backgroundColor = UIColor.white
                //  Stops timer
                firstColorTime = stopLastColorEnter()
                //  Starts timer
                timeNextColorEnter()
            }
            else if (numberOfColorsEntered == 1)
            {
                //  The text doesn't need to change here.
                differenceTwo = selectingOneColor(key: "secondColor")
                getRandom()
                vibrationThree = vibrationString
                whiteRectangle2.backgroundColor = UIColor.white
                secondColorTime = stopLastColorEnter()
                timeNextColorEnter()
            }
            else if (numberOfColorsEntered == 2)
            {
                //  Text still same
                differenceThree = selectingOneColor(key: "thirdColor")
                getRandom()
                vibrationFour = vibrationString
                whiteRectangle3.backgroundColor = UIColor.white
                thirdColorTime = stopLastColorEnter()
                timeNextColorEnter()
            }
            else if (numberOfColorsEntered == 3)
            {
                //  Increase the number of attempts the user made to enter their password. Should be 1 if first try,
                //  more if they got it wrong previously.
                numberOfAttempts = numberOfAttempts + 1
                print("Attempt number:")
                print(numberOfAttempts)
                differenceFour = selectingOneColor(key: "fourthColor")
                fourthColorTime = stopLastColorEnter()
                
                //  This is different for the fourth color, want to set the variable for the time taken to enter
                //  all four colors this round here:
                onePasswordEnter = firstColorTime + secondColorTime + thirdColorTime + fourthColorTime
                print(onePasswordEnter)
                
                //postRequest()
                
                
                if (gotColorWrong == false)
                {
                    exitWhileLoopCounter = exitWhileLoopCounter + 1
                    
                    //  This is for the total time of entering password(s), not just the most recent color!
                    stopTime = mach_absolute_time()
                    print("Stop time:")
                    print(stopTime)
                    //duration = stopTime - startTime
                    print("First Start Time:")
                    print(firstStartTime)
                    duration = ((stopTime - firstStartTime) * numer) / denom
                    print("Duration in Nanoseconds:")
                    print(duration)
                    //durationInSeconds = Double(duration) / 1000000000
                    //print("Duration in Seconds:")
                    //print(durationInSeconds)
                    
                    //  totalTime is the time of all their password enters. For example, if they entered their
                    //  password three times becasue they got it wrong twice, then finally got it right, the time would be
                    //  for all three password enters (12 color times).
                    totalTime = Double(duration) / 1000000000
                    print("Total Time:")
                    print(totalTime)
                    
                    //  IMPT! Makes sure the postRequest() method doesn't play a new vibration
                    notDoneWithVibrations = false
                    postRequest()
                    
                    //  Segue to the FeedbackScreen if >= 14 days have passed since the user first opened the app.
                    let data = UserDefaults.standard.object(forKey: "fourteenDays")
                    if let days = data as? Bool
                    {
                        if (days == true)
                        {
                            //  BUT, if they already did the feedback screen, like if the user decided to continue to try
                            //  entering their password even after the 14 days are up, then don't let them send
                            //  feedback twice. Send them to the "TotallyDone" screen instead.
                            if (UserDefaults.standard.object(forKey: "feedbackSent") == nil)
                            {
                                UserDefaults.standard.set(true, forKey: "feedbackSent")
                                performSegue(withIdentifier: "wheelToFeedback", sender: self)
                            }
                            else
                            {
                                performSegue(withIdentifier: "wheelToTotallyDone", sender: self)
                            }
                        }
                    }
                    
                    //  If >= 14 days have not passed, segue to the Done screen.
                    performSegue(withIdentifier: "wheelToDone", sender: self)
                    
                }
                else
                {
                    print("WRONG!!")
                    //  Change the text
                    topText1.text = "One or more of the colors you entered"
                    topText2.text = "were incorrect. Try again."
                    numberOfColorsEntered = 0
                    

                    
                    //  THEN MAKE SURE IT IS POSSIBLE TO GET IT RIGHT IN THE FUTURE! FACEPALM!
                    gotColorWrong = false
                    //view.backgroundColor = UIColor.darkGray
                    
                    //  Change the background color to draw user's attention to changed text.
                    topText1.backgroundColor = UIColor.darkGray
                    topText2.backgroundColor = UIColor.darkGray
                    //  "Delete" rectangles (make them the same color as the background)
                    whiteRectangle1.backgroundColor = UIColor.black
                    whiteRectangle2.backgroundColor = UIColor.black
                    whiteRectangle3.backgroundColor = UIColor.black
                    
                    //onePasswordEnter = firstColorTime + secondColorTime + thirdColorTime + fourthColorTime
                    //print(onePasswordEnter)
                    postRequest()
                    //  NEED TO PUT THIS IN THE POSTREQUEST() TO ONLY HAPPEN AFTER SENDS TO LAGGY DATABASE!!
                    //resetVariablesSentToDatabase()
             
                }
            }
        }
    }
       
    //  MARK: - wrapd()
    //  This makes sure the angle stays between 0 and 359.9999999.... degrees
    //  I converted it from Objective-C to Swift 5, which is why there are weird variables with _ and stuff:
    //double wrapd(double _val, double _min, double _max)
    func wrapd(_val: CGFloat, _min: CGFloat, _max: CGFloat) -> CGFloat
    {
        if(_val < _min)
        {
            return _max - (_min - _val);
        }
        if(_val > _max)
        {
            return _min - (_max - _val);
        }
        return _val;
    }
       
    //  MARK: - updateRotation()
    //- (float) updateRotation:(CGPoint)_location
    func updateRotation(currentLocation: CGPoint) -> CGFloat
    {
        let fromAngle = atan2(lastLocation.y-imageView.center.y, lastLocation.x-imageView.center.x);
           
        let toAngle = atan2(currentLocation.y-imageView.center.y, currentLocation.x-imageView.center.x);
           
        //  Whoops, this person didn't know about .pi!
        //let newAngle = wrapd(_val: currentAngle + (toAngle - fromAngle), _min: 0, _max: 2*3.14);
        let newAngle = wrapd(_val: currentAngle + (toAngle - fromAngle), _min: 0, _max: 2 * .pi);
        //CGAffineTransform cgaRotate = CGAffineTransformMakeRotation(newAngle);
           
        imageView.transform = view.transform.rotated(by: newAngle)
        return newAngle;
    }

    //  MARK: - viewDidLoad()
    //  This is like the main method in Java:
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //  This isn't the best way to code the wheel image! It makes it so that it is always in the center of the screen
        //  ON ANY SIZE PHONE, which is known as a constraint. Unfortunately, everything else is based on an iPhone7 screen-size,
        //  so on a bigger phone, the wheel would be lower down, because the middle of the screen is lower down, and it would be
        //  over top of the rectangles of color and buttons below it.
        //  Trying new image thing
        
        /*
        imageView.translatesAutoresizingMaskIntoConstraints = false
        //imageView.image = UIImage(named: "ColorWheel")
        imageView.image = UIImage(named: "ColorWheelSubtle")
        //  Makes sure wheel is circle not oval:
        imageView.contentMode = .scaleAspectFill
        //  Doesn't seem to do anything:
        imageView.clipsToBounds = true
        view.addSubview(imageView)
        //  These just make the Color Wheel show up in the middle
        //  of the screen:
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        //  Deleting the width and height anchors makes the
        //  wheel fill the entire screen
        imageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9).isActive = true
        //imageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1.0).isActive = true
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1).isActive = true
        */

        //  For duration:
        var info = mach_timebase_info(numer: 0, denom: 0)
        mach_timebase_info(&info)
        numer = UInt64(info.numer)
        denom = UInt64(info.denom)
        
        firstStartTime = mach_absolute_time()
        print("First start time:")
        print(firstStartTime)
        print()
        startTime = mach_absolute_time()
        print("Start time:")
        print(startTime)
        print()
        
        //  Play the first vibration as the screen loads:
        getRandom()
        vibrationOne = vibrationString
        
    }

}
