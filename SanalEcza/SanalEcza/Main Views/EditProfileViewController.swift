//
//  EditProfileViewController.swift
//  SanalEcza
//
//  Created by Cevher Şirin on 17.05.2023.
//

import UIKit
import JGProgressHUD

class EditProfileViewController: UIViewController {
    
    //MARK: IBOutlets
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    
    //MARK: VARS
    let hud = JGProgressHUD(style: .dark)
    
    
    //MARK: View Lifecycle
    

    override func viewDidLoad() {
        super.viewDidLoad()

        loadUserInfo()
    }
    
    //MARK: IBActions
    
    @IBAction func saveBarButtonPressed(_ sender: Any) {
        
        dismissKeyboard()
        
        if textFieldsHaveText() {
            
            let withValues = [kFIRSTNAME : nameTextField.text!, kLASTNAME : surnameTextField.text!, kFULLNAME : (nameTextField.text! + " " + surnameTextField.text!), kFULLADDRESS : addressTextField.text!]
            
            updateCurrentUserInFirestore(withValues: withValues) { (error) in
                
                if error == nil {
                    self.hud.textLabel.text = "User Updated!"
                    self.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
                    self.hud.show(in: self.view)
                    self.hud.dismiss(afterDelay: 2.0) // 2 SECONDS DELAY
                    
                } else {
                    print("ERROR Updating User", error!.localizedDescription)
                    self.hud.textLabel.text = error!.localizedDescription
                    self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
                    self.hud.show(in: self.view)
                    self.hud.dismiss(afterDelay: 2.0) // 2 SECONDS DELAY
                }
            }
        } else {
            hud.textLabel.text = "All Fields Are Required!"
            hud.indicatorView = JGProgressHUDErrorIndicatorView()
            hud.show(in: self.view)
            hud.dismiss(afterDelay: 2.0) // 2 SECONDS DELAY
        }
    }
    
    @IBAction func logOutButtonPressed(_ sender: Any) {
        
        logOutUser()
    }
    
    //MARK: UpdateUI
    
    private func loadUserInfo() {
        
        if MUser.currentId() != nil {
            let currentUser = MUser.currentUser()!
            
            nameTextField.text = currentUser.firstName
            surnameTextField.text = currentUser.lastName
            addressTextField.text = currentUser.fullAddress
        }
    }
    
    //MARK: Helper Funcs
    private func dismissKeyboard() {
        
        self.view.endEditing(false)
    }
    
    private func textFieldsHaveText() -> Bool {
        
        return (nameTextField.text != "" && surnameTextField.text != "" && addressTextField.text != "")
    }
    
    private func logOutUser() {
        MUser.logOutCurrentUser { (error) in
            
            if error == nil {
                print("Logged Out!")
                self.navigationController?.popViewController(animated: true)
            } else {
                print("ERROR LOGIN OUT", error!.localizedDescription)
            }
        }
    }


}
