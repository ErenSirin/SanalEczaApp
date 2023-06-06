//
//  WelcomeViewController.swift
//  SanalEcza
//
//  Created by Cevher Şirin on 9.05.2023.
//

import UIKit
import JGProgressHUD
import NVActivityIndicatorView

class WelcomeViewController: UIViewController {

    //MARK: IBOutlets
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var resendButtonOutlet: UIButton!
    
    //MARK: Vars
    
    let hud = JGProgressHUD(style: .dark)
    var activityIndicator: NVActivityIndicatorView?
    
    
    
    
    //MARK: View Lifecycle
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        activityIndicator = NVActivityIndicatorView(frame: CGRect(x: self.view.frame.width / 2 - 30, y: self.view.frame.height / 2 - 30, width: 60, height: 60), type: .ballPulse, color: UIColor.red, padding: nil)
    }
    
    //MARK: IBActions
    

    @IBAction func cancelButtonPressed(_ sender: Any) {
        dissmissView()
        
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        print("login")
        
        if textFieldsHaveText() {
            
            loginUser()
            
        } else {
            hud.textLabel.text = "All Fields Are Required !"
            hud.indicatorView = JGProgressHUDErrorIndicatorView()
            hud.show(in: self.view)
            hud.dismiss(afterDelay: 2.0) //MARK: DELAY 2 SECONDS
        }

        
    }
    
    @IBAction func registerButtonPressed(_ sender: Any) {
        print("register")
        
        if textFieldsHaveText() {
            
            registerUser()
            
        } else {
            hud.textLabel.text = "All Fields Are Required !"
            hud.indicatorView = JGProgressHUDErrorIndicatorView()
            hud.show(in: self.view)
            hud.dismiss(afterDelay: 2.0) //MARK: DELAY 2 SECONDS
        }

    }
    
    
    @IBAction func forgotPasswordButtonPressed(_ sender: Any) {
        
        print("forgot")
        
        if emailTextField.text != "" {
            
            resetThePassword()
            
        } else {
            
            hud.textLabel.text = "Please Insert Email!"
            hud.indicatorView = JGProgressHUDErrorIndicatorView()
            hud.show(in: self.view)
            hud.dismiss(afterDelay: 2.0) //MARK: DELAY 2 SECONDS
        }

    }
    
    
    @IBAction func resendEmailButtonPressed(_ sender: Any) {
        
        print("resend")
        
        MUser.resendVerificationEmail(email: emailTextField.text!) { (error) in
            
            print("Error Resending Email", error?.localizedDescription)
        }

    }
    
    //MARK: Login User
    
    private func loginUser() {
        
        showLoadingIndicator()
        
        MUser.loginUserWith(email: emailTextField.text!, password: passwordTextField.text!) { (error, isEmailVerified) in
            
            if error == nil {
                
                if isEmailVerified {
                    
                    self.dissmissView()
                    print("Email is Verified")
                } else {
                    self.hud.textLabel.text = "Please Verify Your Email!"
                    self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
                    self.hud.show(in: self.view)
                    self.hud.dismiss(afterDelay: 2.0) //MARK: DELAY 2 SECONDS
                    self.resendButtonOutlet.isHidden = false
                }
                
            } else {
                print("Error Loging in the User", error!.localizedDescription)
                self.hud.textLabel.text = error!.localizedDescription
                self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
                self.hud.show(in: self.view)
                self.hud.dismiss(afterDelay: 2.0) //MARK: DELAY 2 SECONDS
                
            }
            
            self.hideLoadingIndicator()
            
            
            
        }
    }
    
    
    
    
    
    //MARK: Register User
    
    private func registerUser() {
        
        showLoadingIndicator()
        
        MUser.registerUserWith(email: emailTextField.text!, password: passwordTextField.text!) { (error) in
            
            if error == nil {
                
                self.hud.textLabel.text = "Verification Email Sent!"
                self.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
                self.hud.show(in: self.view)
                self.hud.dismiss(afterDelay: 2.0) //MARK: DELAY 2 SECONDS
                
            } else {
                print("Error Registering", error!.localizedDescription)
                self.hud.textLabel.text = error!.localizedDescription
                self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
                self.hud.show(in: self.view)
                self.hud.dismiss(afterDelay: 2.0) //MARK: DELAY 2 SECONDS
            }
            
            self.hideLoadingIndicator()
        }
        
    }
    
    
    
    
    
    //MARK: Helpers
    
    private func resetThePassword() {
        
        MUser.resetPasswordFor(email: emailTextField.text!) { (error) in
            
            if error == nil {
                
                self.hud.textLabel.text = "Reset Password Email Sent!"
                self.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
                self.hud.show(in: self.view)
                self.hud.dismiss(afterDelay: 2.0) //MARK: DELAY 2 SECONDS
                
            } else {
                self.hud.textLabel.text = error!.localizedDescription
                self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
                self.hud.show(in: self.view)
                self.hud.dismiss(afterDelay: 2.0) //MARK: DELAY 2 SECONDS
            }
        }
    }
    
    
    
    private func textFieldsHaveText() -> Bool {
        return (emailTextField.text != "" && passwordTextField.text != "")
    }
    
    
    private func dissmissView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: Activity İndicator
    
    private func showLoadingIndicator() {
        
        if activityIndicator != nil {
            self.view.addSubview(activityIndicator!)
            activityIndicator!.startAnimating()
        }
        
    }
    
    private func hideLoadingIndicator() {
        
        if activityIndicator != nil {
            
            activityIndicator!.removeFromSuperview()
            activityIndicator!.stopAnimating()
        }
        
        
    }
    
    
    
    
    
    
}
