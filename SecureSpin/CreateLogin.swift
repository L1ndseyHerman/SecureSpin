//
//  CreateLogin.swift
//  SecureSpin
//
//  Created by Student on 10/23/19.
//  Copyright © 2019 Student. All rights reserved.
//

import UIKit
//  For vibrations:
import AudioToolbox.AudioServices

//  MARK: - CreateLogin
//  This lets you set the password and then you have to re-enter it four times, for a total of five times. Although, if you
//  mess up the re-entering, it could be many more times....
class CreateLogin: UIViewController
{
    
    //  Create global variables here
    
    //  The wheel image
    //  The line below would be needed for the code in the viewDidLoad() to work, but now that I commented that code out
    //  because I found a better way, the click-and-drag @IBOutlet is needed instead
    //let imageView = UIImageView()
    @IBOutlet weak var imageView: UIImageView!
    
    var lastLocation = CGPoint(x: 0, y: 0)
    var currentLocation = CGPoint(x: 0, y: 0)
    var currentAngle = CGFloat(0)
    
    //  Can be 0, 1, 2, 3; resets at 0 as numberOfPasswordEnters increases, or if the Reset button is pushed.
    var numberOfColorsEntered = Int(0)
    //  Swift 5 does angles in radians, this is after I convert it to degrees
    var angleInDegrees = CGFloat(0)
    //  Can be 0, 1, 2, 3, 4.
    var numberOfPasswordEnters = Int(0)
    //  Did the user not get their password right on the first try? This keeps track of how many tries before
    //  they got it right. It should take at least 5 times though, since it's creating a password, then 4+ re-enters
    //  depending on how many tries it takes them to get it right. 
    var numberOfAttempts = Int(0)
    
    //  For duration:
    //  These are reused
    var startTime : UInt64 = 0
    var stopTime : UInt64 = 0
    var numer: UInt64 = 0
    var denom: UInt64 = 0
    var duration : UInt64 = 0
    //var durationInSeconds: Double = 0
    
    //  This is when the screen first loads.
    var firstStartTime : UInt64 = 0
    //  This is the entire time for all 5+ password enters
    var totalTime : Double = -1
    
    var firstColorTime : Double = -1
    var secondColorTime : Double = -1
    var thirdColorTime : Double = -1
    var fourthColorTime : Double = -1
    
    //  For one password enter, could get sent multiple times if user messes up/resets.
    var onePasswordEnter : Double = -1
    
    //  For saving the vibration:
    //var vibrationOne = UInt32(0)
    //var vibrationTwo = UInt32(0)
    //var vibrationThree = UInt32(0)
    //var vibrationFour = UInt32(0)
    var vibrationOne = String("None")
    var vibrationTwo = String("None")
    var vibrationThree = String("None")
    var vibrationFour = String("None")
    
    var vibrationString = String("None")
    
    //  For amount off from color they were:
    var differenceOne = CGFloat(9000)
    var differenceTwo = CGFloat(9000)
    var differenceThree = CGFloat(9000)
    var differenceFour = CGFloat(9000)
    
    //  For annoying warning:
    var unusedVariable = CGFloat(0)
    
    var marginOfErrorHalved = CGFloat(15)
    
    // Default to false
    var gotColorWrong = Bool(false)
    
    //  The Colors Chosen:
    var firstColor = CGFloat(-1)
    var secondColor = CGFloat(-1)
    var thirdColor = CGFloat(-1)
    var fourthColor = CGFloat(-1)
    
    //  For not playing a vibration when segueing to the next screen:
    var notDoneWithVibrations = Bool(true)
    
    //  These are the four label rectangles that change color:
    @IBOutlet weak var Color1: UILabel!
    @IBOutlet weak var Color2: UILabel!
    @IBOutlet weak var Color3: UILabel!
    @IBOutlet weak var Color4: UILabel!
    //  These are their "borders", actually bigger label rectangles with a white background underneath the colorful ones:
    @IBOutlet weak var Border1: UILabel!
    @IBOutlet weak var Border2: UILabel!
    @IBOutlet weak var Border3: UILabel!
    @IBOutlet weak var Border4: UILabel!
    
    //  The three rows of white text at the top of the screen.
    @IBOutlet weak var topText1: UILabel!
    @IBOutlet weak var topText2: UILabel!
    @IBOutlet weak var topText3: UILabel!
    
    //  The four labels to rotate vibrations to, plus "daLine" for rotating to the line (letter "l") when creating a password.
    //  Whoops, these aren't needed, do images instead!
    @IBOutlet weak var T1: UILabel!
    @IBOutlet weak var T2: UILabel!
    @IBOutlet weak var B1: UILabel!
    @IBOutlet weak var B2: UILabel!
    //  Images:
    @IBOutlet weak var T1Image: UIImageView!
    @IBOutlet weak var T2Image: UIImageView!
    @IBOutlet weak var B1Image: UIImageView!
    @IBOutlet weak var B2Image: UIImageView!
    
    
    //  Top of 3 "lines" (letter l's):
    @IBOutlet weak var daLine: UILabel!
    //  Next:
    @IBOutlet weak var daLine2: UILabel!
    //  Bottom:
    @IBOutlet weak var daLine3: UILabel!
    
    
    //  The random vibration that was chosen:
    var vibrationNumber = UInt32(0)
    //  A thinking-outside-the-box solution to exiting the while-loop of one vibration so that a new vibration's while-loop can start:
    var exitWhileLoopCounter = Int(0)
    //  The background thread for the vibrations:
    let backgroundQueue1 = DispatchQueue(label: "com.app.queue", qos: .background)
    //  For making the rectangles at the bottom choose a color based on the color at like "T2" if it's that vibration,
    //  instead of always the color at zero degrees:
    var addToAngle = CGFloat(0)
    //  For choosing a random vibration:
    var randomNumber = Int(-1)
    
    //  MARK: - postRequest()
    //  Sends data to Dr. Gurary's database
    func postRequest()
    {
        //  On a background thread!
        DispatchQueue.global(qos: .background).async
        {
            //Create url object
            guard let url = URL(string: "http://passworks.dyndns-remote.com/spin/pushSpinCreation.php") else {return}
            //Create the session object
            let session = URLSession.shared

            //Create the URLRequest object using the url object
            var request = URLRequest(url: url)

            //Set the request method. Important Do not set any other headers, like Content-Type
            request.httpMethod = "POST" //set http method as POST

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
                var dataData = String(format: "%f", self.firstColor)
                dataData = dataData + "," + String(format: "%f", self.secondColor)
                dataData = dataData + "," + String(format: "%f", self.thirdColor)
                dataData = dataData + "," + String(format: "%f", self.fourthColor)
                dataData = dataData + "," + String(format: "%f", self.differenceOne)
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
      } catch let responseError {
      print("Serialisation in error in creating response body: \(responseError.localizedDescription)")
      let message = String(bytes: serverData, encoding: .ascii)
      print(message as Any)
      }
      })
          //Run the task
          webTask.resume()
        //  Only do this after they have been sent!
        //  And only if not done:
        if (self.notDoneWithVibrations)
        {
            self.resetVariablesSentToDatabase()
            self.timeNextColorEnter()
        }
      }
     }
    //  MARK: - radiansToDegrees()
    func radiansToDegrees(radianAngle: CGFloat) -> CGFloat
    {
        var degreeAngle = CGFloat()
        degreeAngle = radianAngle * (180 / .pi);
        return degreeAngle
    }
    
    //  MARK: - radiansToDegrees()
    func degreesToRadians(degreeAngle: CGFloat) -> CGFloat
    {
        var radianAngle = CGFloat()
        radianAngle = degreeAngle * (.pi / 180);
        return radianAngle
    }
    
    //  MARK: - resetVariablesSentToDatabase()
    //  Gets ready for another round of entering four password digits.
    func resetVariablesSentToDatabase()
    {
        //  Timing the color entry starts over:
        var info = mach_timebase_info(numer: 0, denom: 0)
        mach_timebase_info(&info)
        numer = UInt64(info.numer)
        denom = UInt64(info.denom)
        startTime = mach_absolute_time()
        
        vibrationTwo = "None"
        vibrationThree = "None"
        vibrationFour = "None"
        //  Start the next vibration
        getRandom()
        vibrationOne = vibrationString
        
        //  WHOOPS, AND RESET COLOR TIMES!
        firstColorTime = -1
        secondColorTime = -1
        thirdColorTime = -1
        fourthColorTime = -1
        onePasswordEnter = -1
        
        //  stored vs current angle difs back to default numbers
        differenceOne = 9000
        differenceTwo = 9000
        differenceThree = 9000
        differenceFour = 9000
        
    }
    
    //  MARK: - timeNextColorEnter()
    //  Gets the mach time (like System.nanotime() in Java) for the start of the next color entry, the end time will be determined
    //  in the giant if-statements lower down
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
    
    
    //  MARK: - colorOfAngle()
    //  Fancy if-statements for text based on color
    /*func colorOfAngle(angle: CGFloat) -> String
    {
        //  WILL INCLUDE THE SMALLER ANGLE BUT EXCLUDE THE LARGER ONE TO MAKE SURE NO OVERLAP!!
        if ((angle >= 0 && angle < 15) || (angle >= 345 && angle < 360))
        {
            //  The commented-out colors are for the original Wheel of Fortune wheel, this wheel is just shifted over by 1 color:
            //return "Yellow"
            return "YOrange"
        }
        else if (angle >= 15 && angle < 45)
        {
            //return "LGreen"
            return "Yellow"
        }
        else if (angle >= 45 && angle < 75)
        {
            //return "DGreen"
            return "YGreen"
        }
        else if (angle >= 75 && angle < 105)
        {
            //return "LBlue"
            return "BGreen"
        }
        else if (angle >= 105 && angle < 135)
        {
            //return "MBlue"
            return "LBlue"
        }
        else if (angle >= 135 && angle < 165)
        {
            //return "DBlue"
            return "MBlue"
        }
        else if (angle >= 165 && angle < 195)
        {
            //return "Violet"
            return "DBlue"
        }
        else if (angle >= 195 && angle < 225)
        {
            //return "Pink"
            return "Violet"
        }
        else if (angle >= 225 && angle < 255)
        {
            //return "Red"
            return "Pink"
        }
        else if (angle >= 255 && angle < 285)
        {
            //return "DOrange"
            return "Red"
        }
        else if (angle >= 285 && angle < 315)
        {
            //return "MOrange"
            return "ROrange"
        }
        else if (angle >= 315 && angle < 345)
        {
            //return "LOrange"
            return "Orange"
        }
        //  Should never get returned unless error
        return "Unimplemented!"
    }*/
    
    //  MARK: - colorOfBackground()
    //  Fancy if-statements for the color of the rectangles at the bottom of the screen:
    func colorOfBackground(angle: CGFloat) -> UIColor
    {
        //  First, make sure the color being chosen is the one lining up with "1T", "2T", etc based on current vibration,
        //  not the color at zero degrees unless it's lining up with "daLine".
        var angle = angle - addToAngle
        print("Original angle:")
        print(angle)
        print("Add to angle for color:")
        print(addToAngle)
        if (angle < 0)
        {
            angle = angle + 360
        }
        print("Final angle:")
        print(angle)

        //  Now get the color based on the angle.
        //  WILL INCLUDE THE SMALLER ANGLE BUT EXCLUDE THE LARGER ONE TO MAKE SURE NO OVERLAP!!
        //  Also, it should always be less than 360 degrees, but it can be equal to 0.
        if ((angle >= 0 && angle < 15) || (angle >= 345 && angle < 360))
        {
            //  yellowOrange
            return UIColor(red: 255/255, green: 200/255, blue: 0/255, alpha: 1.0)
        }
        else if (angle >= 15 && angle < 45)
        {
            //  yellow
            return UIColor(red: 255/255, green: 255/255, blue: 0/255, alpha: 1.0)
        }
        else if (angle >= 45 && angle < 75)
        {
            //  yellowGreen
            return UIColor(red: 100/255, green: 255/255, blue: 0/255, alpha: 1.0)
        }
        else if (angle >= 75 && angle < 105)
        {
            //  blueGreen
            return UIColor(red: 0/255, green: 255/255, blue: 100/255, alpha: 1.0)
        }
        else if (angle >= 105 && angle < 135)
        {
            //  cyan
            return UIColor(red: 0/255, green: 255/255, blue: 255/255, alpha: 1.0)
        }
        else if (angle >= 135 && angle < 165)
        {
            //  mediumBlue
            return UIColor(red: 0/255, green: 155/255, blue: 255/255, alpha: 1.0)
        }
        else if (angle >= 165 && angle < 195)
        {
            //  darkBlue
            return UIColor(red: 0/255, green: 0/255, blue: 255/255, alpha: 1.0)
        }
        else if (angle >= 195 && angle < 225)
        {
            //  violet
            return UIColor(red: 155/255, green: 0/255, blue: 255/255, alpha: 1.0)
        }
        else if (angle >= 225 && angle < 255)
        {
            //  magenta
            return UIColor(red: 255/255, green: 0/255, blue: 255/255, alpha: 1.0)
        }
        else if (angle >= 255 && angle < 285)
        {
            //  red
            return UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 1.0)
        }
        else if (angle >= 285 && angle < 315)
        {
            //  redOrange
            return UIColor(red: 255/255, green: 100/255, blue: 0/255, alpha: 1.0)
        }
        else if (angle >= 315 && angle < 345)
        {
            //  orange
            return UIColor(red: 255/255, green: 155/255, blue: 0/255, alpha: 1.0)
        }
        //  Should never get returned unless error
        return UIColor.black
    }

    //  MARK: - forgotPassword()
    //  Makes the popup appear and the vibration stop.
    @IBAction func forgotPassword(_ sender: UIButton)
    {
        //numberOfAttempts = numberOfAttempts + 1
        postRequest()
        //  Stop the vibration from playing
            exitWhileLoopCounter = exitWhileLoopCounter + 1
            performSegue(withIdentifier: "loginToReset", sender: self)
    }
    
    //  MARK: - resetTry()
    //  Resets that password enter, like if you are on the third digit of the second password enter, it will restart at the
    //  first digit of the second password enter
    @IBAction func resetTry(_ sender: UIButton)
    {
        //  Start over with first color
        numberOfColorsEntered = 0
        //view.backgroundColor = UIColor.darkGray
        //  Draw attention to changing text
        topText1.backgroundColor = UIColor.darkGray
        topText2.backgroundColor = UIColor.darkGray
        topText3.backgroundColor = UIColor.darkGray
        //  Reset the color of all rectangles to black
        Color1.backgroundColor = UIColor.black
        Color2.backgroundColor = UIColor.black
        Color3.backgroundColor = UIColor.black
        Color4.backgroundColor = UIColor.black
        //  Only make first border visible
        Border1.backgroundColor = UIColor.white
        Border2.backgroundColor = UIColor.black
        Border3.backgroundColor = UIColor.black
        Border4.backgroundColor = UIColor.black
        //  Get ready to play a new vibration
        exitWhileLoopCounter = exitWhileLoopCounter + 1
        
        //  If it was on the 1-tap then 2-taps round, go back to one-tap:
        if (randomNumber == 4 || randomNumber == 5)
        {
            randomNumber = 4
            //T2.isHidden = true
            //T1.isHidden = false
            T2Image.isHidden = true
            T1Image.isHidden = false
            
            topText1.text = "Great, now line your first two colors up with"
            topText2.text = "the '1T' for the 'one tap' vibration. You"
            topText3.text = "can start over by pressing the 'Reset' button."
        }
        
        //  If it was on the 1-buzz then 2-buzzes round, go back to 1-buzz
        if (randomNumber == 6 || randomNumber == 7)
        {
            randomNumber = 6
            //B2.isHidden = true
            //B1.isHidden = false
            
            B2Image.isHidden = true
            B1Image.isHidden = false
            topText1.text = "Great, now line the first two colors up with"
            topText2.text = "the '1B' for the 'one buzz' vibration. You"
            topText3.text = "can start over by pressing the 'Reset' button."
        }
        


        //  Send time of whatever colors were entered (maybe not all four) to database
        onePasswordEnter = firstColorTime + secondColorTime + thirdColorTime + fourthColorTime
        print(onePasswordEnter)
        
        numberOfAttempts = numberOfAttempts + 1
        //  SEND TO DATABASE HERE!!!!!!!!
        postRequest()
        //resetVariablesSentToDatabase()
        
    }
    
    //  MARK: - passwordCreation()
    //  Method used for creating all four colors of the password:
    func passwordCreation(key : String, label : UILabel, olderLabel : UILabel) -> CGFloat
    {
        //  Get angle from radians to degrees:
        angleInDegrees = radiansToDegrees(radianAngle: currentAngle)
        print(angleInDegrees)
        //print(colorOfAngle(angle: angleInDegrees))
        
        //  Store the angle of the color in the UserDefaults. For example, the color light orange might be 1.32354 , or something.
        //  The UserDefault for it will remain on the phone even when the app is closed. It only gets deleted when the app does.
        UserDefaults.standard.set(angleInDegrees, forKey: key)
        numberOfColorsEntered = numberOfColorsEntered + 1
        //label.text = colorOfAngle(angle: angleInDegrees)
        // New!
        //olderLabel.backgroundColor = colorOfBackground(angle: angleInDegrees)
        
        //  Set the rectangle for that color to the color, move on to the next rectangle being the one that switches
        //  as the wheel rotates
        label.backgroundColor = colorOfBackground(angle: angleInDegrees)
        
        //  This makes it so that whenever you press the button, the one-tap vibration is played, which is a tactile way
        //  of letting the user know they sucessfully pressed the button instead of maybe pressing to the right of the button
        //  and missing it. That way, they don't have to waste time looking down at the rectangles on the bottom of the screen
        //  to see if a color was entered.
        AudioServicesPlaySystemSound(1520)
        
        //  Return the degrees of the angle of color the user chose to be their color in that digit of the password.
        return angleInDegrees
    }
    
    //  MARK: - reEnterPassword()
    //  Method used for re-entering the password the next four times:
    func reEnterPassword(key : String, vibration : UInt32, label : UILabel) -> CGFloat
    {
        //  Should never stay this
        var tempDifference = CGFloat(9000)
        angleInDegrees = radiansToDegrees(radianAngle: currentAngle)
        print(angleInDegrees)
        //print(colorOfAngle(angle: angleInDegrees))
        let data = UserDefaults.standard.object(forKey: key)
        if var storedAngle = data as? CGFloat
        {
            print()
            print("Angle in Degrees")
            print(angleInDegrees)
            print("Stored Angle")
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
            if (storedAngle > marginOfErrorHalved && storedAngle < 360 - marginOfErrorHalved)
            {
                print("Normal Angle")
                if ((angleInDegrees >= storedAngle - marginOfErrorHalved) && (angleInDegrees <= storedAngle + marginOfErrorHalved))
                {
                    numberOfColorsEntered = numberOfColorsEntered + 1
                    //AudioServicesPlaySystemSound(vibration)

                }
                else
                {
                    //AudioServicesPlaySystemSound(vibration)
                    numberOfColorsEntered = numberOfColorsEntered + 1
                    gotColorWrong = true
                }
                
            }
            //  Could fix yellow glitch?
            //else if (storedAngle >= 345 || storedAngle < 15)
            else if (storedAngle <= marginOfErrorHalved)
            {
                print("Small Angle")
                let remainder = marginOfErrorHalved - storedAngle
                print ("Remainder")
                print(remainder)
                //if ((angleInDegrees >= 345 && angleInDegrees < 360) || (angleInDegrees >= 0 && angleInDegrees < 15))
                //  storedAngle = 350, angleInDegrees = 355
                //  355 > 350                          355 < 360                 360 - 355 = 5              360 - 350 = 10
                //if ((angleInDegrees >= storedAngle && angleInDegrees < 360) || (360 - angleInDegrees <= storedAngle - 360))
                //  Gets 15degrees below angle
                if ((angleInDegrees <= storedAngle + marginOfErrorHalved && angleInDegrees >= 0) || (angleInDegrees > 360 - remainder))
                {
                    numberOfColorsEntered = numberOfColorsEntered + 1
                    //AudioServicesPlaySystemSound(vibration)
                    
                }
                else
                {
                    //AudioServicesPlaySystemSound(vibration)
                    numberOfColorsEntered = numberOfColorsEntered + 1
                    gotColorWrong = true
                }
                
            }
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
                    numberOfColorsEntered = numberOfColorsEntered + 1
                    //AudioServicesPlaySystemSound(vibration)
                }
                else
                {
                    //AudioServicesPlaySystemSound(vibration)
                    numberOfColorsEntered = numberOfColorsEntered + 1
                    gotColorWrong = true
                }
                
            }
            
        }
    return tempDifference
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
    //  Like "Mouse Released" in Java.
    
    //  Sorry, these are the GIANT if-statements
    //  If Dr. Gurary asks you to go from four colors to two, which he was thinking about, just
    //  copy-n-paste the code from the "else if (numberOfColorsEntered == 3)" 's into the "else if (numberOfColorsEntered == 2)", then
    //  delete the "else if (numbersOfColorsEntered == 3)". That should happen five times, since there are five rounds of
    //  password entering "numberOfPasswordEnters" (0 - 4). Also change all of the variables that say like "Color4" to "Color3",
    //  or just skip from 2 to 4 and delete the 3's, idk. Actually, keeping the variables the same and skipping might be easiest.
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        if let touch = touches.first
        {

            currentLocation = touch.location(in: view)
            currentAngle = updateRotation(currentLocation: currentLocation)
            
            //  All the rest of the password stuff. Probobly more of this should be in a method than currently is.
            if (numberOfPasswordEnters == 0)
            {
                if (numberOfColorsEntered == 0)
                {
                    //  Storing the colors in a variable now as well as UserDefaults:
                    firstColor = passwordCreation(key: "firstColor", label: Color2, olderLabel: Color1)
                    
                    //  No longer draw user's attention to text:
                    topText1.backgroundColor = UIColor.black
                    topText2.backgroundColor = UIColor.black
                    topText3.backgroundColor = UIColor.black
                    Border1.backgroundColor = UIColor.black
                    Border2.backgroundColor = UIColor.white
                    
                    //  End timing first color.
                    firstColorTime = stopLastColorEnter()
                    //  Start timing second color.
                    timeNextColorEnter()
                    
                }
                else if (numberOfColorsEntered == 1)
                {
                    secondColor = passwordCreation(key: "secondColor", label: Color3, olderLabel: Color2)
                    Border2.backgroundColor = UIColor.black
                    Border3.backgroundColor = UIColor.white
                    
                    stopTime = mach_absolute_time()
                    print("Stop Time:")
                    print(stopTime)
                    //duration = stopTime - startTime
                    duration = ((stopTime - startTime) * numer) / denom
                    print("Duration in Nanoseconds:")
                    print(duration)
                    secondColorTime = Double(duration) / 1000000000
                    print("Second Color First Enter:")
                    print(secondColorTime)
                    
                    secondColorTime = stopLastColorEnter()
                    timeNextColorEnter()
                    
                }
                else if (numberOfColorsEntered == 2)
                {
                    thirdColor = passwordCreation(key: "thirdColor", label: Color4, olderLabel: Color3)
                    Border3.backgroundColor = UIColor.black
                    Border4.backgroundColor = UIColor.white
                    thirdColorTime = stopLastColorEnter()
                    timeNextColorEnter()
                }
                else if (numberOfColorsEntered == 3)
                {
                    //  Increase the number of attempts taken to enter a password since just finished entering a password
                    numberOfAttempts = numberOfAttempts + 1
                    print("Attempt number:")
                    print(numberOfAttempts)
                    fourthColor = passwordCreation(key: "fourthColor", label: Color1, olderLabel: Color4)
                    
                    //  Reset number of colors entered for next round
                    numberOfColorsEntered = 0
                    //  Increment number of password enters for next if-statement
                    numberOfPasswordEnters = numberOfPasswordEnters + 1
                    //  Change text
                    topText1.text = "Great, now line your first two colors up with"
                    topText2.text = "the '1T' for the 'one tap' vibration. You"
                    topText3.text = "can start over by pressing the 'Reset' button."
                    //  Hide "daLine", show "T1" label
                    daLine.isHidden = true
                    daLine2.isHidden = true
                    daLine3.isHidden = true
                    //T1.isHidden = false
                    T1Image.isHidden = false

                    //Color1.isHidden = true
                    //Color2.isHidden = true
                    //Color3.isHidden = true
                    //Color4.isHidden = true
                    
                    //  Reset rectangle colors for next round
                    Color1.backgroundColor = UIColor.black
                    Color2.backgroundColor = UIColor.black
                    Color3.backgroundColor = UIColor.black
                    Color4.backgroundColor = UIColor.black
                    
                    //  Draw user's attention to new text:
                    //view.backgroundColor = UIColor.darkGray
                    topText1.backgroundColor = UIColor.darkGray
                    topText2.backgroundColor = UIColor.darkGray
                    topText3.backgroundColor = UIColor.darkGray
                    
                    Border4.backgroundColor = UIColor.black
                    Border1.backgroundColor = UIColor.white
                    //  Get 1-Tap vibration
                    randomNumber = 4
                    //getRandom()
                    //vibrationOne = vibrationString
                    
                    fourthColorTime = stopLastColorEnter()
                    
                    //  Set time for entering all four digits of password:
                    onePasswordEnter = firstColorTime + secondColorTime + thirdColorTime + fourthColorTime
                    print(onePasswordEnter)
                    
                    //  SEND TO DATABASE HERE!!!!!!!!
                    postRequest()
                    //  WHOOPS, AND RESET COLOR TIMES!
                    //firstColorTime = -1
                    //secondColorTime = -1
                    //thirdColorTime = -1
                    //fourthColorTime = -1
                    //onePasswordEnter = -1
                    
                    //timeNextColorEnter()
                    
                }
            }
                // method key, vibration?
                
                
                
            //  Now time to re-enter password:
            else if (numberOfPasswordEnters == 1)
            {
                //  Colors are chosen, draw data attention to differences
                firstColor = -1
                secondColor = -1
                thirdColor = -1
                fourthColor = -1
                if (numberOfColorsEntered == 0)
                {
                    //  Find the difference between the correct angle of the color and the angle of the color
                    //  that the user entered:
                    differenceOne = reEnterPassword(key: "firstColor", vibration: 1102, label: Color2)
                    //view.backgroundColor = UIColor.black
                    //  Stop drawing user's attention to text, it's the same now
                    topText1.backgroundColor = UIColor.black
                    topText2.backgroundColor = UIColor.black
                    topText3.backgroundColor = UIColor.black
                    topText1.text = "Great, now line your first two colors up with"
                    topText2.text = "the '1T' for the 'one tap' vibration. You"
                    topText3.text = "can start over by pressing the 'Reset' button."
                    Border1.backgroundColor = UIColor.black
                    Border2.backgroundColor = UIColor.white
                    //  Because the number is 4, continue to play 1-Tap vibration
                    randomNumber = 4
                    getRandom()
                    //  Set the second vibration String that gets sent to the database column to the vibration chosen (1-Tap).
                    vibrationTwo = vibrationString
                    
                    firstColorTime = stopLastColorEnter()
                    
                    timeNextColorEnter()
                    
                }
                else if (numberOfColorsEntered == 1)
                {
                    differenceTwo = reEnterPassword(key: "secondColor", vibration: 1102, label: Color3)
                    //  Draw user's attention to text
                    topText1.backgroundColor = UIColor.darkGray
                    topText2.backgroundColor = UIColor.darkGray
                    topText3.backgroundColor = UIColor.darkGray
                    //  2-Tap now
                    topText1.text = "Great, now line your next two colors up with"
                    topText2.text = "the '2T' for the 'two taps' vibration. You"
                    topText3.text = "can start over by pressing the 'Reset' button."
                    Border2.backgroundColor = UIColor.black
                    Border3.backgroundColor = UIColor.white
                    //  5 = 2-Taps
                    randomNumber = 5
                    exitWhileLoopCounter = exitWhileLoopCounter + 1
                    getRandom()
                    //  Set String to 2-Taps
                    vibrationThree = vibrationString
                    //  Hide the "T1" label, show "T2" label
                    //T1.isHidden = true
                    //T2.isHidden = false
                    T1Image.isHidden = true
                    T2Image.isHidden = false
                    
                    secondColorTime = stopLastColorEnter()
                    
                    timeNextColorEnter()
                    
                }
                else if (numberOfColorsEntered == 2)
                {
                    differenceThree = reEnterPassword(key: "thirdColor", vibration: 1102, label: Color4)
                    topText1.backgroundColor = UIColor.black
                    topText2.backgroundColor = UIColor.black
                    topText3.backgroundColor = UIColor.black
                    Border3.backgroundColor = UIColor.black
                    Border4.backgroundColor = UIColor.white
                    //  Still 1-Taps
                    randomNumber = 5
                    exitWhileLoopCounter = exitWhileLoopCounter + 1
                    getRandom()
                    vibrationFour = vibrationString
                    
                    thirdColorTime = stopLastColorEnter()
                    
                    timeNextColorEnter()
                    
                }
                else if (numberOfColorsEntered == 3)
                {
                    //  Finished another password attempt
                    numberOfAttempts = numberOfAttempts + 1
                    print("Attempt number:")
                    print(numberOfAttempts)
                    differenceFour = reEnterPassword(key: "fourthColor", vibration: 1102, label: Color1)
                    Border4.backgroundColor = UIColor.black
                    Border1.backgroundColor = UIColor.white
                    
                    fourthColorTime = stopLastColorEnter()
                    
                                        
                    onePasswordEnter = firstColorTime + secondColorTime + thirdColorTime + fourthColorTime
                    print(onePasswordEnter)
                    
                    //  SEND TO DATABASE HERE!!!!!!!!
                    postRequest()
                    //  WHOOPS, AND RESET COLOR TIMES!
                    //firstColorTime = -1
                    //secondColorTime = -1
                    //thirdColorTime = -1
                    //fourthColorTime = -1
                    //onePasswordEnter = -1
                    
                    //differenceOne = 9000
                    //differenceTwo = 9000
                    //differenceThree = 9000
                    //differenceFour = 9000
                    
                    //timeNextColorEnter()
                    
                    if (gotColorWrong == false)
                    {
                        numberOfColorsEntered = 0
                        numberOfPasswordEnters = numberOfPasswordEnters + 1
                        topText1.text = "Great, now line the first two colors up with"
                        topText2.text = "the '1B' for the 'one buzz' vibration. You"
                        topText3.text = "can start over by pressing the 'Reset' button."
                        //view.backgroundColor = UIColor.darkGray
                        topText1.backgroundColor = UIColor.darkGray
                        topText2.backgroundColor = UIColor.darkGray
                        topText3.backgroundColor = UIColor.darkGray
                        Color1.backgroundColor = UIColor.black
                        Color2.backgroundColor = UIColor.black
                        Color3.backgroundColor = UIColor.black
                        Color4.backgroundColor = UIColor.black
                        //  Stuff below for 1-Buzz vibration now playing:
                        randomNumber = 6
                        //T2.isHidden = true
                        //B1.isHidden = false
                        T2Image.isHidden = true
                        B1Image.isHidden = false
                        //getRandom()
                    }
                    else
                    {
                        numberOfColorsEntered = 0
                        topText1.text = "One or more of the colors you entered"
                        topText2.text = "were incorrect. Try again."
                        topText3.text = ""
                        //view.backgroundColor = UIColor.darkGray
                        topText1.backgroundColor = UIColor.darkGray
                        topText2.backgroundColor = UIColor.darkGray
                        topText3.backgroundColor = UIColor.darkGray
                        Color1.backgroundColor = UIColor.black
                        Color2.backgroundColor = UIColor.black
                        Color3.backgroundColor = UIColor.black
                        Color4.backgroundColor = UIColor.black
                        gotColorWrong = false
                        //  Got wrong, so go back to 1-Tap vibration
                        randomNumber = 4
                        exitWhileLoopCounter = exitWhileLoopCounter + 1
                        //T2.isHidden = true
                        T2Image.isHidden = true
                        //T1.isHidden = false
                        T1Image.isHidden = false
                        //vibrationTwo = "None"
                        //vibrationThree = "None"
                        //vibrationFour = "None"
                        //getRandom()
                        //vibrationOne = vibrationString
                    }
                }
            }
            else if (numberOfPasswordEnters == 2)
            {
                if (numberOfColorsEntered == 0)
                {
                    differenceOne = reEnterPassword(key: "firstColor", vibration: 4095, label: Color2)
                    //view.backgroundColor = UIColor.black
                    topText1.backgroundColor = UIColor.black
                    topText2.backgroundColor = UIColor.black
                    topText3.backgroundColor = UIColor.black
                    topText1.text = "Great, now line the first two colors up with"
                    topText2.text = "the '1B' for the 'one buzz' vibration. You"
                    topText3.text = "can start over by pressing the 'Reset' button."
                    Border1.backgroundColor = UIColor.black
                    Border2.backgroundColor = UIColor.white
                    randomNumber = 6
                    exitWhileLoopCounter = exitWhileLoopCounter + 1
                    //vibrationTwo = "None"
                    //vibrationThree = "None"
                    //vibrationFour = "None"
                    getRandom()
                    vibrationTwo = vibrationString
                    
                    firstColorTime = stopLastColorEnter()
                    
                    timeNextColorEnter()
                    
                }
                else if (numberOfColorsEntered == 1)
                {
                    differenceTwo = reEnterPassword(key: "secondColor", vibration: 4095, label: Color3)
                    topText1.backgroundColor = UIColor.darkGray
                    topText2.backgroundColor = UIColor.darkGray
                    topText3.backgroundColor = UIColor.darkGray
                    topText1.text = "Great, now line your next two colors up with"
                    topText2.text = "the '2B' for the 'two buzzes' vibration. You"
                    topText3.text = "can start over by pressing the 'Reset' button."
                    Border2.backgroundColor = UIColor.black
                    Border3.backgroundColor = UIColor.white
                    //  On to 2-Buzz vibration
                    //B1.isHidden = true
                    //B2.isHidden = false
                    B1Image.isHidden = true
                    B2Image.isHidden = false
                    randomNumber = 7
                    exitWhileLoopCounter = exitWhileLoopCounter + 1
                    getRandom()
                    vibrationThree = vibrationString
                    
                    secondColorTime = stopLastColorEnter()
                    
                    timeNextColorEnter()
                    
                }
                else if (numberOfColorsEntered == 2)
                {
                    differenceThree = reEnterPassword(key: "thirdColor", vibration: 4095, label: Color4)
                    topText1.backgroundColor = UIColor.black
                    topText2.backgroundColor = UIColor.black
                    topText3.backgroundColor = UIColor.black
                    Border3.backgroundColor = UIColor.black
                    Border4.backgroundColor = UIColor.white
                    randomNumber = 7
                    exitWhileLoopCounter = exitWhileLoopCounter + 1
                    getRandom()
                    vibrationFour = vibrationString
                    
                    thirdColorTime = stopLastColorEnter()
                    
                    timeNextColorEnter()
                    
                }
                else if (numberOfColorsEntered == 3)
                {
                    numberOfAttempts = numberOfAttempts + 1
                    print("Attempt number:")
                    print(numberOfAttempts)
                    differenceFour = reEnterPassword(key: "fourthColor", vibration: 4095, label: Color1)
                    Border4.backgroundColor = UIColor.black
                    Border1.backgroundColor = UIColor.white

                    fourthColorTime = stopLastColorEnter()
                    
                                        
                    onePasswordEnter = firstColorTime + secondColorTime + thirdColorTime + fourthColorTime
                    print(onePasswordEnter)
                    
                    //  SEND TO DATABASE HERE!!!!!!!!
                    postRequest()
                    //  WHOOPS, AND RESET COLOR TIMES!
                    //firstColorTime = -1
                    //secondColorTime = -1
                    //thirdColorTime = -1
                    //fourthColorTime = -1
                    //onePasswordEnter = -1
                    
                    //differenceOne = 9000
                    //differenceTwo = 9000
                    //differenceThree = 9000
                    //differenceFour = 9000
                    
                    //timeNextColorEnter()
                    
                    if (gotColorWrong == false)
                    {
                        numberOfColorsEntered = 0
                        numberOfPasswordEnters = numberOfPasswordEnters + 1
                        topText1.text = "Good, now line each color up with whatever"
                        topText2.text = "vibration you feel. Goes two rounds. You"
                        topText3.text = "can start over by pressing the 'Reset' button."
                        //view.backgroundColor = UIColor.darkGray
                        topText1.backgroundColor = UIColor.darkGray
                        topText2.backgroundColor = UIColor.darkGray
                        topText3.backgroundColor = UIColor.darkGray
                        Color1.backgroundColor = UIColor.black
                        Color2.backgroundColor = UIColor.black
                        Color3.backgroundColor = UIColor.black
                        Color4.backgroundColor = UIColor.black
                        
                        //  Now the vibration is truely random and all labels are visible since it can be any vibration.
                        randomNumber = 0
                        exitWhileLoopCounter = exitWhileLoopCounter + 1
                        //T1.isHidden = false
                        //T2.isHidden = false
                        //B1.isHidden = false
                        //B2.isHidden = false
                        T1Image.isHidden = false
                        T2Image.isHidden = false
                        B1Image.isHidden = false
                        B2Image.isHidden = false
                        //vibrationTwo = "None"
                        //vibrationThree = "None"
                        //vibrationFour = "None"
                        //getRandom()
                        //vibrationOne = vibrationString
                    }
                    else
                    {
                        numberOfColorsEntered = 0
                        topText1.text = "One or more of the colors you entered"
                        topText2.text = "were incorrect. Try again."
                        topText3.text = ""
                        //view.backgroundColor = UIColor.darkGray
                        topText1.backgroundColor = UIColor.darkGray
                        topText2.backgroundColor = UIColor.darkGray
                        topText3.backgroundColor = UIColor.darkGray
                        Color1.backgroundColor = UIColor.black
                        Color2.backgroundColor = UIColor.black
                        Color3.backgroundColor = UIColor.black
                        Color4.backgroundColor = UIColor.black
                        gotColorWrong = false
                        //  Back to 1-Buzz vibration
                        randomNumber = 6
                        exitWhileLoopCounter = exitWhileLoopCounter + 1
                        //B2.isHidden = true
                        //B1.isHidden = false
                        B2Image.isHidden = true
                        B1Image.isHidden = false 
                        //vibrationTwo = "None"
                        //vibrationThree = "None"
                        //vibrationFour = "None"
                        //getRandom()
                        //vibrationOne = vibrationString
                    }
                }
            }
                
            else if (numberOfPasswordEnters == 3)
            {
                if (numberOfColorsEntered == 0)
                {
                    differenceOne = reEnterPassword(key: "firstColor", vibration: 1011, label: Color2)
                    Border1.backgroundColor = UIColor.black
                    Border2.backgroundColor = UIColor.white
                    //view.backgroundColor = UIColor.black
                    topText1.backgroundColor = UIColor.black
                    topText2.backgroundColor = UIColor.black
                    topText3.backgroundColor = UIColor.black
                    topText1.text = "Good, now line each color up with whatever"
                    topText2.text = "vibration you feel. Goes two rounds. You"
                    topText3.text = "can start over by pressing the 'Reset' button."
                    exitWhileLoopCounter = exitWhileLoopCounter + 1
                    getRandom()
                    vibrationTwo = vibrationString
                    
                    firstColorTime = stopLastColorEnter()

                    timeNextColorEnter()
                    
                }
                else if (numberOfColorsEntered == 1)
                {
                    differenceTwo = reEnterPassword(key: "secondColor", vibration: 1011, label: Color3)
                    Border2.backgroundColor = UIColor.black
                    Border3.backgroundColor = UIColor.white
                    exitWhileLoopCounter = exitWhileLoopCounter + 1
                    getRandom()
                    vibrationThree = vibrationString
                    
                    secondColorTime = stopLastColorEnter()
                    
                    timeNextColorEnter()
                    
                }
                else if (numberOfColorsEntered == 2)
                {
                    differenceThree = reEnterPassword(key: "thirdColor", vibration: 1011, label: Color4)
                    Border3.backgroundColor = UIColor.black
                    Border4.backgroundColor = UIColor.white
                    exitWhileLoopCounter = exitWhileLoopCounter + 1
                    getRandom()
                    vibrationFour = vibrationString
                    
                    thirdColorTime = stopLastColorEnter()
                    
                    timeNextColorEnter()
                    
                }
                else if (numberOfColorsEntered == 3)
                {
                    numberOfAttempts = numberOfAttempts + 1
                    print("Attempt number:")
                    print(numberOfAttempts)
                    differenceFour = reEnterPassword(key: "fourthColor", vibration: 1102, label: Color1)
                    Border4.backgroundColor = UIColor.black
                    Border1.backgroundColor = UIColor.white
                    
                    fourthColorTime = stopLastColorEnter()
                    
                                        
                    onePasswordEnter = firstColorTime + secondColorTime + thirdColorTime + fourthColorTime
                    print(onePasswordEnter)
                    
                    //  SEND TO DATABASE HERE!!!!!!!!
                    postRequest()
                    //  WHOOPS, AND RESET COLOR TIMES!
                    //firstColorTime = -1
                    //secondColorTime = -1
                    //thirdColorTime = -1
                    //fourthColorTime = -1
                    //onePasswordEnter = -1
                    
                    //differenceOne = 9000
                    //differenceTwo = 9000
                    //differenceThree = 9000
                    //differenceFour = 9000
                    
                    //timeNextColorEnter()
                    
                    if (gotColorWrong == false)
                    {
                        numberOfColorsEntered = 0
                        numberOfPasswordEnters = numberOfPasswordEnters + 1
                        topText1.text = "Good, now do that again. Last round "
                        topText2.text = "of entering your password. You"
                        topText3.text = "can start over by pressing the 'Reset' button."
                        //view.backgroundColor = UIColor.darkGray
                        topText1.backgroundColor = UIColor.darkGray
                        topText2.backgroundColor = UIColor.darkGray
                        topText3.backgroundColor = UIColor.darkGray
                        Color1.backgroundColor = UIColor.black
                        Color2.backgroundColor = UIColor.black
                        Color3.backgroundColor = UIColor.black
                        Color4.backgroundColor = UIColor.black
                        exitWhileLoopCounter = exitWhileLoopCounter + 1
                        //vibrationTwo = "None"
                        //vibrationThree = "None"
                        //vibrationFour = "None"
                        //getRandom()
                        //vibrationOne = vibrationString
                    }
                    else
                    {
                        numberOfColorsEntered = 0
                        topText1.text = "One or more of the colors you entered"
                        topText2.text = "were incorrect. Try again."
                        topText3.text = ""
                        //view.backgroundColor = UIColor.darkGray
                        topText1.backgroundColor = UIColor.darkGray
                        topText2.backgroundColor = UIColor.darkGray
                        topText3.backgroundColor = UIColor.darkGray
                        Color1.backgroundColor = UIColor.black
                        Color2.backgroundColor = UIColor.black
                        Color3.backgroundColor = UIColor.black
                        Color4.backgroundColor = UIColor.black
                        gotColorWrong = false
                        exitWhileLoopCounter = exitWhileLoopCounter + 1
                        //vibrationTwo = "None"
                        //vibrationThree = "None"
                        //vibrationFour = "None"
                        //getRandom()
                        //vibrationOne = vibrationString
                    }
                }
            }
                
            else if (numberOfPasswordEnters == 4)
            {
                if (numberOfColorsEntered == 0)
                {
                    differenceOne = reEnterPassword(key: "firstColor", vibration: 1011, label: Color2)
                    Border1.backgroundColor = UIColor.black
                    Border2.backgroundColor = UIColor.white
                    //view.backgroundColor = UIColor.black
                    topText1.backgroundColor = UIColor.black
                    topText2.backgroundColor = UIColor.black
                    topText3.backgroundColor = UIColor.black
                    topText1.text = "Good, now do that again. Last round "
                    topText2.text = "of entering your password. You"
                    topText3.text = "can start over by pressing the 'Reset' button."
                    exitWhileLoopCounter = exitWhileLoopCounter + 1
                    getRandom()
                    vibrationTwo = vibrationString
                    
                    firstColorTime = stopLastColorEnter()
                    
                    timeNextColorEnter()
                    
                }
                else if (numberOfColorsEntered == 1)
                {
                    differenceTwo = reEnterPassword(key: "secondColor", vibration: 1011, label: Color3)
                    Border2.backgroundColor = UIColor.black
                    Border3.backgroundColor = UIColor.white
                    exitWhileLoopCounter = exitWhileLoopCounter + 1
                    getRandom()
                    vibrationThree = vibrationString
                    
                    secondColorTime = stopLastColorEnter()
                    
                    timeNextColorEnter()
                    
                }
                else if (numberOfColorsEntered == 2)
                {
                    differenceThree = reEnterPassword(key: "thirdColor", vibration: 1011, label: Color4)
                    Border3.backgroundColor = UIColor.black
                    Border4.backgroundColor = UIColor.white
                    exitWhileLoopCounter = exitWhileLoopCounter + 1
                    getRandom()
                    vibrationFour = vibrationString
                    
                    thirdColorTime = stopLastColorEnter()
                    
                    timeNextColorEnter()
                    
                }
                else if (numberOfColorsEntered == 3)
                {
                    numberOfAttempts = numberOfAttempts + 1
                    print("Attempt number:")
                    print(numberOfAttempts)
                    differenceFour = reEnterPassword(key: "fourthColor", vibration: 1011, label: Color1)
                    
                    fourthColorTime = stopLastColorEnter()
                    
                    onePasswordEnter = firstColorTime + secondColorTime + thirdColorTime + fourthColorTime
                    print(onePasswordEnter)
                    //timeNextColorEnter()
                    //postRequest()
                    if (gotColorWrong == false)
                    {
                        //  This is the total time for entering a password! Only gets set if last password enter.
                        stopTime = mach_absolute_time()
                        print("Stop time:")
                        print(stopTime)
                        //duration = stopTime - startTime
                        duration = ((stopTime - firstStartTime) * numer) / denom
                        print("Duration in Nanoseconds:")
                        print(duration)
                        
                        //  Find the total time of all password enters, so all four colors of all five password enters,
                        //  unless they messed up, then maybe more password enters than that.
                        totalTime = Double(duration) / 1000000000
                        print("Total Time:")
                        print(totalTime)
                        
                        
                        //  IMPT! Makes sure the postRequest() method doesn't play a new vibration
                        notDoneWithVibrations = false
                        
                        postRequest()
                        /*durationInSeconds = Double(duration) / 1000000000
                        print("Duration in Seconds:")
                        print(durationInSeconds)*/
                        
                        //  Successfully created a password!
                        UserDefaults.standard.set(true, forKey: "loginCreated")
                        
                        //  Check to see if fourteen days have passed since the user first opened the app.
                        //  This could be possible if the user forgot their password and came back to this screen from the WheelScreen.
                        let data = UserDefaults.standard.object(forKey: "fourteenDays")
                        if let days = data as? Bool
                        {
                            if (days == true)
                            {
                                //  If it's been 14 days and the user has not yet submitted feedback on the FeedbackScreen, send them
                                //  there.
                                if (UserDefaults.standard.object(forKey: "feedbackSent") == nil)
                                {
                                    UserDefaults.standard.set(true, forKey: "feedbackSent")
                                    performSegue(withIdentifier: "loginToFeedback", sender: self)
                                }
                                //  If they already submitted feedback and just felt like entering their password again
                                //  past 14 days, go to TotallyDone. They should only submit feedback once, and don't need to
                                //  keep re-entering their password past 14 days, but Dr. Gurary said they can if they want to.
                                else
                                {
                                    performSegue(withIdentifier: "loginToTotallyDone", sender: self)
                                }
                            }
                        }
                        
                        
                        exitWhileLoopCounter = exitWhileLoopCounter + 1
                        performSegue(withIdentifier: "loginToDone", sender: self)
                    }
                    else
                    {
                        numberOfColorsEntered = 0
                        topText1.text = "One or more of the colors you entered"
                        topText2.text = "were incorrect. Try again."
                        topText3.text = ""
                        //view.backgroundColor = UIColor.darkGray
                        topText1.backgroundColor = UIColor.black
                        topText2.backgroundColor = UIColor.black
                        topText3.backgroundColor = UIColor.black
                        Color1.backgroundColor = UIColor.black
                        Color2.backgroundColor = UIColor.black
                        Color3.backgroundColor = UIColor.black
                        Color4.backgroundColor = UIColor.black
                        gotColorWrong = false
                        Border4.backgroundColor = UIColor.black
                        Border1.backgroundColor = UIColor.white
                        exitWhileLoopCounter = exitWhileLoopCounter + 1
                        
                        
                        
                        onePasswordEnter = firstColorTime + secondColorTime + thirdColorTime + fourthColorTime
                        print(onePasswordEnter)
                        
                        //  SEND TO DATABASE HERE!!!!!!!!
                        postRequest()
                        //  WHOOPS, AND RESET COLOR TIMES!
                        //firstColorTime = -1
                        //secondColorTime = -1
                        //thirdColorTime = -1
                        //fourthColorTime = -1
                        //onePasswordEnter = -1
                        
                        //differenceOne = 9000
                        //differenceTwo = 9000
                        //differenceThree = 9000
                        //differenceFour = 9000
                        
                        //vibrationTwo = "None"
                        //vibrationThree = "None"
                        //vibrationFour = "None"
                        //getRandom()
                        //vibrationOne = vibrationString
                    }
                }
            }
        }
    }
       
    //  MARK: - wrapd()
    //  This makes sure the angle stays between 0 and 359.9999999.... degrees instead of going to like -9000 if you keep
    //  rotating the wheel counter-clockwise.
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
    //  Rotates the wheel using the touchesBegan(), touchesMoved(), touchesEnded(), and wrapd()
    func updateRotation(currentLocation: CGPoint) -> CGFloat
    {
        let fromAngle = atan2(lastLocation.y-imageView.center.y, lastLocation.x-imageView.center.x);
           
        let toAngle = atan2(currentLocation.y-imageView.center.y, currentLocation.x-imageView.center.x);
           
        //  Whoops, this person didn't know about .pi!
        //let newAngle = wrapd(_val: currentAngle + (toAngle - fromAngle), _min: 0, _max: 2*3.14);
        let newAngle = wrapd(_val: currentAngle + (toAngle - fromAngle), _min: 0, _max: 2 * .pi);
           
        imageView.transform = view.transform.rotated(by: newAngle)
        
        
        angleInDegrees = radiansToDegrees(radianAngle: newAngle)
        //print(angleInDegrees)
        //print(colorOfAngle(angle: angleInDegrees))
        
        //  This makes the current rectangle update its color as the wheel spins:
        if (numberOfColorsEntered == 0)
        {
            //Color1.text = colorOfAngle(angle: angleInDegrees)
            Color1.backgroundColor = colorOfBackground(angle: angleInDegrees)
        }
        else if (numberOfColorsEntered == 1)
        {
            //Color2.text = colorOfAngle(angle: angleInDegrees)
            Color2.backgroundColor = colorOfBackground(angle: angleInDegrees)
        }
        else if (numberOfColorsEntered == 2)
        {
            //Color3.text = colorOfAngle(angle: angleInDegrees)
            Color3.backgroundColor = colorOfBackground(angle: angleInDegrees)
        }
        else if (numberOfColorsEntered == 3)
        {
            //Color4.text = colorOfAngle(angle: angleInDegrees)
            Color4.backgroundColor = colorOfBackground(angle: angleInDegrees)
        }
        
        
        return newAngle;
    }
    
    
    
    //  MARK: - getRandom()
    //  Chooses a vibration and plays it on a background thread
    func getRandom()
    {
        //exitWhileLoopCounter = exitWhileLoopCounter + 1

        // Choose this in the other class for number of colors/passwords entered for like 00, 01, 02, 03. Starts as -1.
        //  Sometimes you want a vibration that isn't random.
        //  0, 1, 2, 3 = random
        //  4, 5, 6, 7 = not random. Used for the password enters where you want a certain thing. There is a password enter
        //  of 1Tap, 1Tap, 2Tap, 2Tap. That would be 4, 4, 5, 5. The next round is a similar thing with the buzzes.
        
        //  This gets a random vibration if the last vibration was random
        if (randomNumber == 0 || randomNumber == 1 || randomNumber == 2 || randomNumber == 3)
        {
            randomNumber = Int.random(in: 0 ..< 4)
        }
        //print(randomNumber)
        
        //let loopNumber = exitWhileLoopCounter
        //let thread0 = DispatchQueue.global(qos: .background).async

        if (randomNumber == 0 || randomNumber == 4)
        {
            //  No vibration
            //AudioServicesPlaySystemSound(1520)
            vibrationNumber = 1520
            vibrationString = "1Tap"
            addToAngle = 45
            print("1T")
        }
        else if (randomNumber == 1 || randomNumber == 5)
        {
            //AudioServicesPlaySystemSound(1520)
            //AudioServicesPlaySystemSound(1102)
            vibrationNumber = 1102
            vibrationString = "2Taps"
            addToAngle = 135
            print("2T")
        }
        else if (randomNumber == 2 || randomNumber == 6)
        {
            //AudioServicesPlaySystemSound(4095)
            vibrationNumber = 4095
            vibrationString = "1Buzz"
            //AudioServicesPlaySystemSound(1102)
            addToAngle = 225
            print("1B")
        }
        
        else if (randomNumber == 3 || randomNumber == 7)
        {
            //AudioServicesPlaySystemSound(1011)
            vibrationNumber = 1011
            vibrationString = "2Buzzes"
            //  This is 3-taps from back when the vibrations were none, 1-Tap, 2-Taps, and 3-Taps.
            //AudioServicesPlaySystemSound(1521)
            addToAngle = 315
            print("2B")
        }
        
        //  Getting ready to exit one while-loop of vibration and start a new one:
        let loopNumber = self.exitWhileLoopCounter
        
        //  The background thread for vibrations!
        backgroundQueue1.async
        {
        //DispatchQueue.main.async(execute: workItem!)
        //workItem1 = DispatchWorkItem

             while loopNumber == self.exitWhileLoopCounter
             //while (0 < 1)
             {
                 //AudioServicesPlaySystemSound(1520)
                AudioServicesPlaySystemSound(self.vibrationNumber)
                //  This is one second in miliseconds:
                //usleep(1000000)
                //  This is 0.8 seconds:
                usleep(800000)
                //usleep(580000)
                //  1 second:
                //sleep(1)
             }
             //print ("Background thread ran")
         }
        
    }
    

    //  MARK: - viewDidLoad()
    //  The main method, only called once as the screen first loads
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        //  This isn't the best way to code the wheel image! It makes it so that it is always in the center of the screen
        //  ON ANY SIZE PHONE, which is known as a constraint. Unfortunately, everything else is based on an iPhone7 screen-size,
        //  so on a bigger phone, the wheel would be lower down, because the middle of the screen is lower down, and it would be
        //  over top of the rectangles of color and buttons below it.
        
        /*
        //  Wheel things:
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
        /*var info = mach_timebase_info(numer: 0, denom: 0)
        mach_timebase_info(&info)
        numer = UInt64(info.numer)
        denom = UInt64(info.denom)
        
        startTime = mach_absolute_time()
        print("Start time:")
        print(startTime)
        print()*/
        
        //  Starts off first rectangle as LOrange because that color is at 0 degrees (daLine).
        Color1.backgroundColor = colorOfBackground(angle: 0)
        //  Makes sure the colorful rectangle labels draw over top of the white "borders" that are actually other labels:
        self.view.bringSubviewToFront(Color1)
        self.view.bringSubviewToFront(Color2)
        self.view.bringSubviewToFront(Color3)
        self.view.bringSubviewToFront(Color4)
    }

}
