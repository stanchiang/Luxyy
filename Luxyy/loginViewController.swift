//
//  loginViewController.swift
//  Luxyy
//
//  Created by Stanley Chiang on 1/17/16.
//  Copyright © 2016 Stanley Chiang. All rights reserved.
//

import UIKit
import Parse
import ParseUI

protocol loggedInDelegate {
    func userAuthenticated()
}

class loginViewController: UIViewController, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate  {

    var logInViewController: PFLogInViewController!
    var delegate: loggedInDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        self.logInViewController = PFLogInViewController()
        
        self.logInViewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        self.logInViewController.fields = [PFLogInFields.UsernameAndPassword, PFLogInFields.LogInButton, PFLogInFields.SignUpButton, PFLogInFields.PasswordForgotten]
        self.logInViewController.emailAsUsername = true
        self.logInViewController.delegate = self

        // Create the sign up view controller
        let signUpViewController: PFSignUpViewController = PFSignUpViewController()
        self.logInViewController.signUpController = signUpViewController
        signUpViewController.delegate = self
        signUpViewController.emailAsUsername = true
        self.presentViewController(self.logInViewController,  animated: true, completion:nil)

    }

    // Sent to the delegate when a PFUser is logged in.
    func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser) {
        print("did log in")
        self.dismissViewControllerAnimated(true, completion: nil)
        delegate.userAuthenticated()
    }
    
    func logInViewController(logInController: PFLogInViewController, didFailToLogInWithError error: NSError?) {
        if let description = error?.localizedDescription {
            let cancelButtonTitle = NSLocalizedString("OK", comment: "")
            UIAlertView(title: description, message: nil, delegate: nil, cancelButtonTitle: cancelButtonTitle).show()
        }
        print("Failed to log in...")
    }
    
    // MARK: - PFSignUpViewControllerDelegate
    
    func signUpViewController(signUpController: PFSignUpViewController, shouldBeginSignUp info: [String : String]) -> Bool {
        var informationComplete: Bool = true
        
        // loop through all of the submitted data
        for (key, _) in info {
            if let field = info[key] {
                if field.isEmpty {
                    informationComplete = false
                    break
                }
            }
        }
        
        // Display an alert if a field wasn't completed
        if (!informationComplete) {
            let title = NSLocalizedString("Signup Failed", comment: "")
            let message = NSLocalizedString("All fields are required", comment: "")
            let cancelButtonTitle = NSLocalizedString("OK", comment: "")
            UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: cancelButtonTitle).show()
        }
        
        return informationComplete;

    }
    
    // Sent to the delegate when a PFUser is signed up.
    func signUpViewController(signUpController: PFSignUpViewController, didSignUpUser user: PFUser) {
        print("did sign up")
        self.dismissViewControllerAnimated(true, completion: nil)
        delegate.userAuthenticated()
    }
    
    func signUpViewController(signUpController: PFSignUpViewController, didFailToSignUpWithError error: NSError?) {
        print("Failed to sign up...")
    }

}
