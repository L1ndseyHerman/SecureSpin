//
//  UserProfile.swift
//  SecureSpin
//
//  Created by Student on 10/30/19.
//  Copyright © 2019 Student. All rights reserved.
//


//  MARK: - ENCRYPTING/DECRYPTING
//  Look for the marks in the randomIv() and the For Decryption Only! There are things in those two places that you need to change
//  for encryption vs decryption. Also, while the FeedbackScreen can also encrypt data and send it to the database, you'll
//  want to copy-n-paste the bytes from the database and decrypt them here!

import UIKit
//  These are for encryption/decryption:
import Foundation
import CommonCrypto

//  I have no clue what a "protocol" is, I just copied-n-pasted from
//  https://medium.com/@vialyx/security-data-transforms-with-swift-aes256-on-ios-6509917497d

protocol Randomizer {
    static func randomIv() -> Data
    static func randomSalt() -> Data
    static func randomData(length: Int) -> Data
}

protocol Crypter {
    func encrypt(_ digest: Data) throws -> Data
    func decrypt(_ encrypted: Data) throws -> Data
}

//  This is a struct, which is like a class, only not though. Why is it on the same page as a class? I have no clue. Copy-n-paste.
//  Did you know that it is visible in other classes, such as the FeedbackScreen? It wouldn't let me re-declare it there,
//  because it is already here!
struct AES256Crypter {
    
    private var key: Data
    private var iv: Data
    
    public init(key: Data, iv: Data) throws {
        guard key.count == kCCKeySizeAES256 else {
            throw Error.badKeyLength
        }
        guard iv.count == kCCBlockSizeAES128 else {
            throw Error.badInputVectorLength
        }
        self.key = key
        self.iv = iv
    }
    
    enum Error: Swift.Error {
        case keyGeneration(status: Int)
        case cryptoFailed(status: CCCryptorStatus)
        case badKeyLength
        case badInputVectorLength
    }
    
    private func crypt(input: Data, operation: CCOperation) throws -> Data {
        var outLength = Int(0)
        var outBytes = [UInt8](repeating: 0, count: input.count + kCCBlockSizeAES128)
        var status: CCCryptorStatus = CCCryptorStatus(kCCSuccess)
        input.withUnsafeBytes { (encryptedBytes: UnsafePointer<UInt8>!) -> () in
            iv.withUnsafeBytes { (ivBytes: UnsafePointer<UInt8>!) in
                key.withUnsafeBytes { (keyBytes: UnsafePointer<UInt8>!) -> () in
                    status = CCCrypt(operation,
                                     CCAlgorithm(kCCAlgorithmAES128),            // algorithm
                        CCOptions(kCCOptionPKCS7Padding),           // options
                        keyBytes,                                   // key
                        key.count,                                  // keylength
                        ivBytes,                                    // iv
                        encryptedBytes,                             // dataIn
                        input.count,                                // dataInLength
                        &outBytes,                                  // dataOut
                        outBytes.count,                             // dataOutAvailable
                        &outLength)                                 // dataOutMoved
                }
            }
        }
        guard status == kCCSuccess else {
            throw Error.cryptoFailed(status: status)
        }
        return Data(bytes: UnsafePointer<UInt8>(outBytes), count: outLength)
    }
    
    static func createKey(password: Data, salt: Data) throws -> Data {
        let length = kCCKeySizeAES256
        var status = Int32(0)
        var derivedBytes = [UInt8](repeating: 0, count: length)
        password.withUnsafeBytes { (passwordBytes: UnsafePointer<Int8>!) in
            salt.withUnsafeBytes { (saltBytes: UnsafePointer<UInt8>!) in
                status = CCKeyDerivationPBKDF(CCPBKDFAlgorithm(kCCPBKDF2),                  // algorithm
                    passwordBytes,                                // password
                    password.count,                               // passwordLen
                    saltBytes,                                    // salt
                    salt.count,                                   // saltLen
                    CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA1),   // prf
                    10000,                                        // rounds
                    &derivedBytes,                                // derivedKey
                    length)                                       // derivedKeyLen
            }
        }
        guard status == 0 else {
            throw Error.keyGeneration(status: Int(status))
        }
        return Data(bytes: UnsafePointer<UInt8>(derivedBytes), count: length)
    }
    
}

extension AES256Crypter: Crypter {
    
    func encrypt(_ digest: Data) throws -> Data {
        return try crypt(input: digest, operation: CCOperation(kCCEncrypt))
    }
    
    func decrypt(_ encrypted: Data) throws -> Data {
        return try crypt(input: encrypted, operation: CCOperation(kCCDecrypt))
    }
    
}

extension AES256Crypter: Randomizer {
    
    //  MARK: - randomIv()
    //  All of the above stuff I copied-n-pasted from online, but this is important! You need to change stuff here depending if you're
    //  encrypting to send to the database or decrypting from the database!
    static func randomIv() -> Data {
        
        //  This should always have a length of 16, because that is a kCCBlockSizeAES128
        //  Use the commented out code below for DECRYPTING! Replace the numbers in previousBytes with the 16 numbers in the "time"
        //  column in the database:
        //  Also, there is a place by the For Decryption Only! on the scroll bar on the right to put the numbers in the "data"
        //  column in the database, since those are needed for decryption as well.
        
        /*let previousBytes: [UInt8] = [97, 183, 48, 115, 4, 193, 209, 201, 75, 128, 228, 227, 147, 185, 41, 223]
        print("Previous Bytes!:")
        print(previousBytes)
        let previousIv = NSData(bytes: previousBytes, length: previousBytes.count)
        print("Previous IV!")
        print(previousIv)
        let dataIv = Data(previousIv)*/
        
        //  Only use this line below if you are ENCRYPTING! Otherwise, comment it out.
        let dataIv = randomData(length: kCCBlockSizeAES128)
        
        //  These lines can be used for encrypting and decrypting:
        print("Random IV:")
        print("As Data:")
        print(dataIv as NSData)
        return dataIv
    }
    
    //  MARK: randomSalt()
    //  Not random anymore, Dr. Gurary says it doesn't need to be for basic encryption (not an impt bank account)
    static func randomSalt() -> Data {
        //return randomData(length: 8)

        //  For GitHub only:
        let salt = String("NotRealS")
        let dataSalt = Data(salt.utf8)
        return dataSalt
    }
    
    //  MARK: randomData()
    //  Oh, so this gets called in the methods right above it. Duh.
    static func randomData(length: Int) -> Data {
        var data = Data(count: length)
        //  The length is 16, which is the length of the data returned by the randomIv()
        /*print("LENGTH!!")
        print(length)
        let stringData = String("ABCDEFGHABCDEFGH")
        let data = Data(stringData.utf8)*/
        
        //  Hopefully they won't get rid of this depreciated code in Swift 6, because I'm too lazy to find new encryption right now :)
        let status = data.withUnsafeMutableBytes { mutableBytes in
            SecRandomCopyBytes(kSecRandomDefault, length, mutableBytes)
        }
        assert(status == Int32(0))
        return data
    }
    
}

//  MARK: - UserProfile
//  The stuff above wasn't in the class yet! It is actually visible from all classes, and used in FeedbackScreen without
//  re-declaring it there!
class UserProfile: UIViewController
{
    
    //  They all start as what is originally selected
    //  These variables are what will get transfered to the database
    var ageSave = Int(0)
    var genderSave = String("Private")
    var skillSave = String("Private")
    var timeSave = String("Private")
    var unlockSave = String("Private")
    var colorBlindSave = String("Private")
    
    //  This has to do with the age slider
    @IBOutlet weak var age: UISlider!
    @IBOutlet weak var changableAgeLabel: UILabel!
    @IBAction func ageChoice(_ sender: UISlider)
    {
        ageSave = Int(sender.value)
        changableAgeLabel.text = "\(ageSave)"
    }
    
    
    //  This is for gender. Each remaining method, such as "skill" is a new UISegmentedControl
    @IBOutlet weak var gender: UISegmentedControl!
    @IBAction func genderChoice(_ sender: Any)
    {
        switch gender.selectedSegmentIndex
        {
            case 0:
                genderSave = "Male"
                //print(genderSave)
            case 1:
                genderSave = "Female"
                //print(genderSave)
            case 2:
                genderSave = "Other"
                //print(genderSave)
            case 3:
                genderSave = "Private"
                //print(genderSave)
            default:
                 break
        }
    }
    
    @IBOutlet weak var skill: UISegmentedControl!
    @IBAction func skillChoice(_ sender: Any)
    {
        switch skill.selectedSegmentIndex
        {
            case 0:
                skillSave = "1"
                //print(skillSave)
            case 1:
                skillSave = "2"
                //print(skillSave)
            case 2:
                skillSave = "3"
                //print(skillSave)
            case 3:
                skillSave = "4"
                //print(skillSave)
            case 4:
                skillSave = "5"
                //print(skillSave)
            case 5:
                skillSave = "Private"
                //print(skillSave)
            default:
                 break
        }
    }
    
    @IBOutlet weak var time: UISegmentedControl!
    @IBAction func timeChoice(_ sender: Any)
    {
        switch time.selectedSegmentIndex
        {
            case 0:
                timeSave = "1-2 seconds"
                //print(timeSave)
            case 1:
                timeSave = "3-4 seconds"
                //print(timeSave)
            case 2:
                timeSave = "5+ seconds"
                //print(timeSave)
            case 3:
                timeSave = "Private"
                //print(timeSave)
            default:
                 break
        }
    }
    
    @IBOutlet weak var unlock: UISegmentedControl!
    @IBAction func unlockChoice(_ sender: Any)
    {
        switch unlock.selectedSegmentIndex
        {
            case 0:
                unlockSave = "Finger"
                //print(unlockSave)
            case 1:
                unlockSave = "FaceID"
                //print(unlockSave)
            case 2:
                unlockSave = "PIN"
                //print(unlockSave)
            case 3:
                unlockSave = "Pass"
                //print(unlockSave)
            case 4:
                unlockSave = "Other"
                //print(unlockSave)
            case 5:
                unlockSave = "Private"
                //print(unlockSave)
            default:
                 break
        }
    }
    
    @IBOutlet weak var colorBlind: UISegmentedControl!
    @IBAction func colorBlindChoice(_ sender: Any)
    {
        switch colorBlind.selectedSegmentIndex
        {
            case 0:
                colorBlindSave = "No"
                //print(colorBlindSave)
            case 1:
                colorBlindSave = "Red-G"
                //print(colorBlindSave)
            case 2:
                colorBlindSave = "Blue-Y"
                //print(colorBlindSave)
            case 3:
                colorBlindSave = "Total"
                //print(colorBlindSave)
            case 4:
                colorBlindSave = "Private"
                //print(colorBlindSave)
            default:
                 break
        }
    }
    
    
    //  MARK: - postRequest()
    //  Sends the ENCRYPTED stuff that could identify who someone is to Dr. Gurary's database.
    func postRequest()
    {
        //  Uses background thread:
            DispatchQueue.global(qos: .background).async
            {
                
                //  The postData can't see the encrypted stuff if it's only inside of the do{} that might fail.
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
              
                
            //  Like the "try" of "try/catch" in Java:
            do {
            //aString = "AES256"
            aString = String(self.ageSave)
            aString = aString + "," + self.genderSave
            aString = aString + "," + self.skillSave
            aString = aString + "," + self.timeSave
            aString = aString + "," + self.unlockSave
            aString = aString + "," + self.colorBlindSave
            print("A String =")
            print(aString)
            sourceData = Data(aString.utf8)
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
                
                
                
                //  MARK: For Decryption Only!
                //  Only uncomment the stuff below if you are DECRYPTING! Put the bytes that are in the database column "data"
                //  into the
                //  "bytesFromDatabase" variable here, then leave the code below it starting with the print statement the same, and it
                //  will decrypt for you. Don't forget to also change the randomIv() stuff to the bytes from the database as well,
                //  or it won't be able to decrypt!
                
                /*let bytesFromDatabase: [UInt8] = [53, 172, 155, 219, 156, 141, 242, 27, 154, 128, 233, 248, 104, 246, 198, 164, 6, 221, 165, 103, 224, 220, 223, 222, 143, 151, 152, 19, 205, 241, 29, 146, 206, 229, 63, 44, 10, 100, 21, 107, 235, 203, 221, 70, 61, 177, 15, 97]
                print("Bytes From Database:")
                print(bytesFromDatabase)
                print("Length of Bytes From Database:")
                print(bytesFromDatabase.count)
                let backToNSData = NSData(bytes: bytesFromDatabase, length: bytesFromDatabase.count)
                print("Back To NSDATA:")
                print(backToNSData)
                let backToData = Data(backToNSData)
                print("Back to Data!")
                print(backToData)
                let plsDecryptPls = try aes.decrypt(backToData)
                print("Decrypted??")
                print(String(data: plsDecryptPls, encoding: .utf8)!)*/
                
                
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
                
                

                //let decryptedData = try aes.decrypt(encryptedData)
            

        } catch {
            print("Failed")
            print(error)
        }
        
        
        
        
    //  MARK: - Done With Encryption, send to database.
    //  You can comment out the code below up to webTask.resume() for DECRYPTION
                
    //Create url object
     guard let url = URL(string: "http://passworks.dyndns-remote.com/spin/pushSpinDemo.php") else {return}
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
                //  Cast everything to a String first:
        var timeWasInt = String()
        let someData = UserDefaults.standard.object(forKey: "userID")
        if let randomNumber = someData as? UInt64
        {
            timeWasInt = String(randomNumber)
        }

                
        //  The columns in the table are "userid", "time", "data", and "extras". This sends the data to those columns. The
        //  things like "&time=" have to be exactly that to get the data to that column. The other things are the actual data
        //  variables that get sent there.
        
        let userId = String("userid=")
        //var postData = "userid=".data(using: .utf8)
        let userIdData = timeWasInt
        let time = String("&time=")
        let timeData = stringFromByteArrayIv
        print("IV:")
        print(timeData)
        let data = String("&data=")
        dataData = stringFromByteArray
        print("Encrypted Data:")
        print(dataData)

                
        let extras = String("&extras=")
        let extrasData = String("Came from UserProfile")
        //let postData = userId.data(using: utf8)
                
        //  Then cast all the Strings to utf8 Datas to send over the internet to Dr. Gurary's database:
        //  Everything has to be transmitted in a single variable. It looks like
        //let postData = "userid=12342&time=234234&data=12345&extras=77686".data(using: .utf8)
        //  if it's all declared at once.
                
        var postData = Data(userId.utf8)
        //print(postData as NSData)
        postData = postData + Data(userIdData.utf8)
        postData = postData + Data(time.utf8)
        postData = postData + Data(timeData.utf8)
        postData = postData + Data(data.utf8)
        postData = postData + Data(dataData.utf8)
        postData = postData + Data(extras.utf8)
        postData = postData + Data(extrasData.utf8)
        
        
        
     

      
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
        //  The code below will catch because it's not JSON. However, inside of the error message is the correct message of
        //  stuff being inserted in the database.
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
     }
    }
    
    //  MARK: - Create Profile Button
    @IBAction func CreateProfile(_ sender: UIButton)
    {
        //  SEND PROFILE DATA TO THE DATABASE HERE, THEN THE USERDEFAULT MAKES SURE IT NEVER GETS SENT AGAIN!!
        UserDefaults.standard.set(true, forKey: "profileCreated")
        postRequest()

        //  Now go to the CreateLogin screen to create a password:
        performSegue(withIdentifier: "profileToLogin", sender: self)
    }
    
    //  MARK: - viewDidLoad()
    //  Everything below just showed up when I created this class:
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}
