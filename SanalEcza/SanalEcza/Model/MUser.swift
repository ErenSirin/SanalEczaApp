//
//  MUser.swift
//  SanalEcza
//
//  Created by Cevher Şirin on 9.05.2023.
//

import Foundation
import FirebaseAuth

class MUser {
    
    let objectId: String
    var email: String
    var firstName: String
    var lastName: String
    var fullName: String
    var purchasedItemIds: [String]
    
    var fullAddress: String?
    var onBoard: Bool
    
    //MARK: Initializers
    
    init(objectId: String, email: String, firstName: String, lastName: String) {
        self.objectId = objectId
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.fullName = firstName + " " + lastName
        self.fullAddress = ""
        self.onBoard = false
        self.purchasedItemIds = []
    }
    
    init(_dictionary: NSDictionary) {
        
        objectId = _dictionary[kOBJECTID] as! String
        
        if let mail = _dictionary[kEMAIL] {
            email = mail as! String
        } else {
            email = ""
        }
        
        if let fname = _dictionary[kFIRSTNAME] {
            firstName = fname as! String
        } else {
            firstName = ""
        }
        
        if let lname = _dictionary[kLASTNAME] {
            lastName = lname as! String
        } else {
            lastName = ""
        }
        
        fullName = firstName + " " + lastName
        
        if let faddress = _dictionary[kFULLADDRESS] {
            fullAddress = faddress as! String
        } else {
            fullAddress = ""
        }
            
        if let onB = _dictionary[kONBOARD] {
            onBoard = onB as! Bool
        } else {
            onBoard = false
        }
        
        if let purchasedIds = _dictionary[kPURCHASEDITEMIDS] {
            purchasedItemIds = purchasedIds as! [String]
        } else {
            purchasedItemIds = []
        }
    }
    
    //MARK: Return current User
    
    class func currentId() -> String {
        return Auth.auth().currentUser!.uid
    }
    
    class func currentUser() -> MUser? {
        if Auth.auth().currentUser != nil {
            if let dictionary = UserDefaults.standard.object(forKey: kCURRENTUSER) {
                return MUser.init(_dictionary: dictionary as! NSDictionary)
            }
        }
        
        return nil
    }
    
    //MARK: Login Func
    
    class func loginUserWith(email: String, password: String, completion: @escaping (_ error: Error?, _ isEmailVerified: Bool) -> Void) {
        
        Auth.auth().signIn(withEmail: email, password: password) { (AuthDataResult, error) in
            
            if error == nil {
                
                if AuthDataResult!.user.isEmailVerified {
                    
                    downloadUserFromFirestore(userId: AuthDataResult!.user.uid, email: email)
                    completion(error, true)
                    
                } else {
                    print("Email is not verified")
                    completion(error, false)
                }
                
            } else {
                completion(error, false)
            }
        }
    }
    
    
    //MARK: Register User
    
    class func registerUserWith(email: String, password: String, completion: @escaping (_ error: Error?) ->Void) {
        
        Auth.auth().createUser(withEmail: email, password: password) { (authDataResult, error) in
            
            completion(error)
            
            if error == nil {
                
                //send email verification
                authDataResult!.user.sendEmailVerification { (error) in
                    print("auth email verification error :  \(error?.localizedDescription)")
                    
                }
            }
        }
    }
    
    //MARK: Resend Link Methods

    class func resetPasswordFor(email: String, completion: @escaping (_ error: Error?) -> Void) {
        
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            
            completion(error)
        }
    }
    
    class func   resendVerificationEmail(email: String, completion: @escaping (_ error: Error?) -> Void) {
       
        Auth.auth().currentUser?.reload(completion: { (error) in
            
            Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in
                print(" Resend Email Error: ", error?.localizedDescription)
                completion(error)
            })
        })
    }
    
    class func logOutCurrentUser(completion: @escaping(_ error: Error?) -> Void) {
        
        do {
            
            try Auth.auth().signOut()
            UserDefaults.standard.removeObject(forKey: kCURRENTUSER)
            UserDefaults.standard.synchronize()
            completion(nil)

            
        } catch let error as NSError {
            completion(error)
        }
        
        
    }
    
    
} // END OF THE CLASS !!!

//MARK: Download User

func downloadUserFromFirestore(userId: String, email: String) {
    
    FirebaseReference(.User).document(userId).getDocument { (snapshot, error) in
        
        guard let snapshot = snapshot else { return }
        
        if snapshot.exists {
            print("Download Current User From Firestore")
            saveUserLocally(mUserDictionary: snapshot.data()! as NSDictionary)
        } else {
            // there is no user, save new in firestore
            
            let user = MUser(objectId: userId, email: email, firstName: "", lastName: "")
            saveUserLocally(mUserDictionary: userDictionaryFrom(user: user))
            saveUserToFirestore(mUser: user)
        }
    }
    
}








//MARK: Save User To Firebase

func saveUserToFirestore(mUser: MUser) {
    
    FirebaseReference(.User).document(mUser.objectId).setData(userDictionaryFrom(user: mUser) as! [String : Any]) { (error) in
        
        if error != nil {
            print("Error saving user \(error!.localizedDescription)")
        }
    }
}


func saveUserLocally(mUserDictionary: NSDictionary) {
    
    UserDefaults.standard.set(mUserDictionary, forKey: kCURRENTUSER)
    UserDefaults.standard.synchronize()
}


//MARK: Helper Function

func userDictionaryFrom(user: MUser) -> NSDictionary {
    
    let dict = [kOBJECTID : user.objectId, kEMAIL : user.email, kFIRSTNAME : user.firstName, kLASTNAME : user.lastName, kFULLNAME : user.fullName, kFULLADDRESS : user.fullAddress ?? "", kONBOARD : user.onBoard, kPURCHASEDITEMIDS : user.purchasedItemIds] as [String : Any]
    
    return dict as NSDictionary
}

//MARK: UPDATE USER

func updateCurrentUserInFirestore(withValues: [String : Any], completion: @escaping (_ error: Error?) -> Void) {
    
    if let dictionary = UserDefaults.standard.object(forKey: kCURRENTUSER) {
        let userObject = (dictionary as! NSDictionary).mutableCopy() as! NSMutableDictionary
        userObject.setValuesForKeys(withValues)
        FirebaseReference(.User).document(MUser.currentId()).updateData(withValues) { (error) in
            
            completion(error)
            
            if error == nil {
                saveUserLocally(mUserDictionary: userObject)
            }
        }
    }
}
