//
//  ConsentForm2.swift
//  SecureSpin
//
//  Created by Student on 12/12/19.
//  Copyright © 2019 Student. All rights reserved.
//

import UIKit
//  This is for the screen where the user agrees to terms and conditions. Added between the ViewController and UserProfile screens.
class ConsentForm2: UIViewController
{

    @IBAction func Submit(_ sender: UIButton)
    {
        performSegue(withIdentifier: "consentFormToProfile", sender: self)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
