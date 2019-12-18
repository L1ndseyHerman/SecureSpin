//
//  FeedbackScreen.swift
//  SecureSpin
//
//  Created by Student on 11/6/19.
//  Copyright © 2019 Student. All rights reserved.
//

//  If you want the keyboard to go away, do something with this:
//textField.resignFirstResponder()
//  Also, make it class FeedbackScreen: UIViewController, UITextFieldDelegate
//  and do something with clicking on the UITextbox and dragging to the Orange circle and doing a thing, I think making it "delegate".
//  Don't need it now with smooshed screen, but if need to add a single new thing, will need this.


import UIKit
//  For encryption/decryption:
import Foundation
import CommonCrypto

//  MARK: FeedbackScreen
//  Similar to the UserProfile screen at the beginning, but this one only shows up if the person has been using the app
//  for >= 14 days.
class FeedbackScreen: UIViewController
{
    //  Variables to store in database: easySave(String), loggingSave(String), enjoyedSave(String), useSave(String), theFeedback(String)
    //  Note, theFeedback is from the textbox, so it could be very long, or it could be an empty string.
    var easySave = String("Private")
    @IBOutlet weak var easy: UISegmentedControl!
    @IBAction func selectEasy(_ sender: Any)
    {
        switch easy.selectedSegmentIndex
        {
            case 0:
                easySave = "1"
                //print(easySave)
            case 1:
                easySave = "2"
                //print(easySave)
            case 2:
                easySave = "3"
                //print(easySave)
            case 3:
                easySave = "4"
                //print(easySave)
            case 4:
                easySave = "5"
                //print(easySave)
            case 5:
                easySave = "Private"
                //print(easySave)
            default:
                break
        }
    }

    
    var loggingSave = String("Private")
    @IBOutlet weak var logging: UISegmentedControl!
    @IBAction func selectLogging(_ sender: Any)
    {
        switch logging.selectedSegmentIndex
        {
            case 0:
                loggingSave = "1"
                //print(loggingSave)
            case 1:
                loggingSave = "2"
                //print(loggingSave)
            case 2:
                loggingSave = "3"
                //print(loggingSave)
            case 3:
                loggingSave = "4"
                //print(loggingSave)
            case 4:
                loggingSave = "5"
                //print(loggingSave)
            case 5:
                loggingSave = "Private"
                //print(loggingSave)
            default:
                 break
        }
    }
    
    var enjoyedSave = String("Private")
    @IBOutlet weak var enjoyed: UISegmentedControl!
    @IBAction func selectEnjoyed(_ sender: Any)
    {
        switch enjoyed.selectedSegmentIndex
        {
            case 0:
                enjoyedSave = "1"
                //print(enjoyedSave)
            case 1:
                enjoyedSave = "2"
                //print(enjoyedSave)
            case 2:
                enjoyedSave = "3"
                //print(enjoyedSave)
            case 3:
                enjoyedSave = "4"
                //print(enjoyedSave)
            case 4:
                enjoyedSave = "5"
                //print(enjoyedSave)
            case 5:
                enjoyedSave = "Private"
                //print(enjoyedSave)
            default:
                 break
        }
    }
    
    var useSave = String("Private")
    @IBOutlet weak var use: UISegmentedControl!
    @IBAction func selectUse(_ sender: Any)
    {
        switch use.selectedSegmentIndex
        {
            case 0:
                useSave = "1"
                //print(useSave)
            case 1:
                useSave = "2"
                //print(useSave)
            case 2:
                useSave = "3"
                //print(useSave)
            case 3:
                useSave = "4"
                //print(useSave)
            case 4:
                useSave = "5"
                //print(useSave)
            case 5:
                useSave = "Private"
                //print(useSave)
            default:
                 break
        }
    }
    
    var theFeedback = String("")
    @IBOutlet weak var feedback: UITextField!
    
    
    //  MARK: postRequest()
    //  This sends data to Dr. Gurary's database. Note: This should only be used for ENCRYPTION. The randomIv() and the postRequest()
    //  method need to be in the same class, which is only true in the UserProfile class. You can put the bytes sent to the database
    //  from this class into UserProfile, and it will decrypt just fine.
        func postRequest()
        {
            //  Background thread starts here:
               DispatchQueue.global(qos: .background).async
               {
                   
                   //  The postData can't see the "encryptedData" variable if it's only inside of the do{} that might fail.
                   //  I put some fake data here to hide the real data.
                   var aString = "Not the real data"
                   var sourceData = Data(aString.utf8)
                   var encryptedData = Data(aString.utf8)
                   var dataData = String("")
                   var fakeIv = Data(aString.utf8)
                   var nsData = NSData(data: sourceData)
                   var someBytes = [UInt8](nsData)
                   var stringFromByteArray = String("")
                   var nsDataIv = NSData(data: fakeIv)
                   var someBytesIv = [UInt8](nsDataIv)
                   var stringFromByteArrayIv = String("")

                   
                //  Like the "try" of "try/catch" in Java
               do {
               //aString = "AES256"
                aString = self.easySave
               aString = aString + "," + self.loggingSave
               aString = aString + "," + self.enjoyedSave
               aString = aString + "," + self.useSave
               aString = aString + "," + self.theFeedback
               print("A String =")
               print(aString)
               sourceData = Data(aString.utf8)
               //let sourceData = "AES256".data(using: .utf8)!
                
                //  For GitHub only:
                let password = "NotRealP"
               let salt = AES256Crypter.randomSalt()
               let iv = AES256Crypter.randomIv()
                   
               //  To make visible outside of do{} for even if catch{}
               fakeIv = iv
                   
               let key = try AES256Crypter.createKey(password: password.data(using: .utf8)!, salt: salt)
               let aes = try AES256Crypter(key: key, iv: iv)
               encryptedData = try aes.encrypt(sourceData)
                   //print(encryptedData as NSData)
                   /*
                   dataData = String(decoding: encryptedData, as: UTF8.self)
                   print(dataData)*/
                   nsData = NSData(data: encryptedData)
                   print(nsData)
                   
                   someBytes = [UInt8](nsData)
                   print("Some Bytes:")
                   print(someBytes)
                   //print(someBytes[0])
                   for byte in someBytes
                   {
                       //  THIS WORKS FOR CONVERTING BYTES TO A HEXIDECIMAL STRING! BUT MAYBE WANT BYTES!
                       //stringFromByteArray = stringFromByteArray + String(format:"%02x", UInt8(byte))
                       stringFromByteArray = stringFromByteArray + String(byte) + ", "
                       //print(stringFromByteArray)
                   }
                   print(stringFromByteArray)
                   //  This gets "AES256
                   //let bytesFromDatabase: [UInt8] = [71, 45, 142, 136, 232, 189, 198, 56, 123, 179, 139, 191, 67, 125, 238, 219]
                   
                //  I think this should only be in the UserProfile class:
                
                   /*let bytesFromDatabase: [UInt8] = [240, 100, 225, 5, 65, 238, 34, 182, 108, 64, 212, 213, 5, 213, 159, 233, 68, 171, 223, 199, 112, 225, 48, 223, 30, 60, 6, 16, 243, 74, 201, 15, 240, 147, 225, 202, 85, 150, 131, 211, 182, 117, 222, 161, 107, 172, 158, 183]
                   print("Bytes From Database:")
                   print(bytesFromDatabase)
                   print("Length of Bytes From Database:")
                   print(bytesFromDatabase.count)
                   let backToNSData = NSData(bytes: bytesFromDatabase, length: bytesFromDatabase.count)
                   print("Back To NSDATA:")
                   print(backToNSData)
                   let backToData = Data(backToNSData)
                   print("Back to Data!")
                   print(backToData)*/
                   
                   /*let plsDecryptPls = try aes.decrypt(backToData)
                   print("Decrypted??")
                   print(String(data: plsDecryptPls, encoding: .utf8)!)*/
                   
                   
                   //print(plsDecryptPls as NSData)
                 
                 

                   
                   
                   //  Doing the same thing, but on the iv now instead of the data:
                   nsDataIv = NSData(data: fakeIv)
                   print(nsDataIv)
                   someBytesIv = [UInt8](nsDataIv)
                   print("Some IV Bytes:")
                   print(someBytesIv)
                   for byte in someBytesIv
                   {
                       stringFromByteArrayIv = stringFromByteArrayIv + String(byte) + ", "
                       //stringFromByteArrayIv = stringFromByteArrayIv + String(format:"%02x", UInt8(byte))
                       //print(stringFromByteArrayIv)
                   }
                   print(stringFromByteArrayIv)
                   /*let bytesFromDatabaseIv: [UInt8] = [97, 98, 99, 100, 101, 102, 103, 104, 49, 50, 51, 52, 53, 54, 55, 56]
                   print("Bytes From DatabaseIv:")
                   print(bytesFromDatabaseIv)
                   print("Length of Bytes From DatabaseIv:")
                   print(bytesFromDatabaseIv.count)
                   let backToNSDataIv = NSData(bytes: bytesFromDatabaseIv, length: bytesFromDatabaseIv.count)
                   print("Back To NSDATA Iv:")
                   print(backToNSDataIv)
                   let backToDataIv = Data(backToNSDataIv)
                   print("Back to Data Iv!")
                   print(backToDataIv)*/
                   
                   
                   //let plsDecryptPlsIv = try aes.decrypt(backToDataIv)
                   //print("Decrypted Iv??")
                   //print(plsDecryptPls as NSData)
                   //print(String(data: plsDecryptPlsIv, encoding: .utf8)!)
                   
                
                
            //  The "catch" of "do/catch":
           } catch {
               print("Failed")
               print(error)
           }
           
           
           
           
           
        //Create url object
        guard let url = URL(string: "http://passworks.dyndns-remote.com/spin/pushSpinSurvey.php") else {return}
        //Create the session object
        let session = URLSession.shared

        //Create the URLRequest object using the url object
        var request = URLRequest(url: url)

        //Set the request method. Important Do not set any other headers, like Content-Type
        request.httpMethod = "POST" //set http method as POST

        //Set parameters here. Replace with your own.
        //let postData = "param1_id=param1_value&param2_id=param2_value".data(using: .utf8)
           
           //var variable = String("userid=")
           //var variable2 = String("12345" + variable)
           //variable = variable + variable2
           
           //var randomNumber = UserDefaults.standard.object(forKey: "userID")
           //  It added five 0's to the end of the number for some reason, doing "%.1f" makes sure it stays one decimal place
           //let stringFloat = String(format: "%f", randomNumber)
           //  Works for Doubles and CGFloats:
           //let stringFloat = String(format: "%.1f", randomNumber)
           //  Works for UInt64's, the last of the non-string data types I am sending to the database:
           var timeWasInt = String()
           let someData = UserDefaults.standard.object(forKey: "userID")
           if let randomNumber = someData as? UInt64
           {
               timeWasInt = String(randomNumber)
           }

           //   Cast everything to a String first:
           let userId = String("userid=")
           //var postData = "userid=".data(using: .utf8)
           let userIdData = timeWasInt
           let time = String("&time=")
           //let timeData = fakeIv
           //let timeData = stringIvMaybe
           let timeData = stringFromByteArrayIv
           //let timeData = String(decoding: fakeIv, as: UTF8.self)
           print("IV:")
           print(timeData)
           let data = String("&data=")
           //var plsString = String(decoding: sourceData, as: UTF8.self)
                   //  Works! But do in try/catch:
           //let dataData = String(decoding: encryptedData, as: UTF8.self)
           dataData = stringFromByteArray
           print("Encrypted Data:")
           print(dataData)
                   
           //let canItData = Data(dataData.utf8)
           //let canItDecrypt = try aes.decrypt(canItData)
           //let str = String(decoding: data, as: UTF8.self)
           //let dataData = String(encryptedData)
           //let dataData = String("Cant encrypt")
           /*var dataData = String(self.ageSave)
           dataData = dataData + "," + self.genderSave
           dataData = dataData + "," + self.skillSave
           dataData = dataData + "," + self.timeSave
           dataData = dataData + "," + self.unlockSave
           dataData = dataData + "," + self.colorBlindSave
           //  Encrypt dataData here!
           //dataData = dataData + String(data: Data(bytes: stringFromByteArray), encoding: .utf8)
                   dataData = actualString
                   print("dataData:")
                   print(dataData)*/
                   
           let extras = String("&extras=")
           let extrasData = String("Came from FeedbackScreen")
           //let postData = userId.data(using: utf8)
                
            //  Now cast the Strings to utf8 Data to send over the internet:
           var postData = Data(userId.utf8)
           //print(postData as NSData)
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
            //  It's not JSON, so it will catch it and look like it's an error, but it is probobly fine unless the text inside of the
            //  "Optional()" says it's not.
        } catch let responseError {
        print("Serialisation in error in creating response body: \(responseError.localizedDescription)")
        let message = String(bytes: serverData, encoding: .ascii)
        print(message as Any)
        }
        })
            //Run the task
            webTask.resume()
        }
       }
    
    
    
    
    
    
    //  MARK: - Submit Feedback Button
    @IBAction func submitFeedback(_ sender: UIButton)
    {
        //  If it's null, sends an empty string instead of crashing
        theFeedback = feedback.text ?? ""
        postRequest()
        performSegue(withIdentifier: "feedbackToTotallyDone", sender: self)
    }
    
    //  MARK: - viewDidLoad()
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }


}
