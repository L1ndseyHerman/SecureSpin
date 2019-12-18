//
//  ResetPassword2.swift
//  SecureSpin
//
//  Created by Student on 12/12/19.
//  Copyright © 2019 Student. All rights reserved.
//

import UIKit
//  The pop-up for resetting a password.

class ResetPassword2: UIViewController
{

    @IBOutlet weak var yesText: UITextField!
    
    
    @IBAction func Yes(_ sender: UIButton)
    {
        //  Only does the segue if a user types something into the textbox. No math like Dr. Gurary wanted,
        //  just something to make them think.
        //  A label says to "Enter 'y' for 'Yes'", but they can enter whatever.
        if (yesText.text != "")
        {
            //  Set the colors back to nil
            UserDefaults.standard.set(nil, forKey: "firstColor")
            UserDefaults.standard.set(nil, forKey: "secondColor")
            UserDefaults.standard.set(nil, forKey: "thirdColor")
            UserDefaults.standard.set(nil, forKey: "fourthColor")
            //  If the user closes the app right after they segue to the login screen, this will send them back there instead of
            //  to the WheelScreen.
            UserDefaults.standard.set(nil, forKey: "loginCreated")
            //  The actual segue
            performSegue(withIdentifier: "resetToLogin", sender: self)
        }
    }
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()


    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
