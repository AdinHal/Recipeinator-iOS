//
//  RegisterController.swift
//  Recipe-inator
//
//  Created by Adi on 05.03.22.
//

import UIKit
import Firebase
import FirebaseFirestore

class RegisterController: UIViewController{
    
    @IBOutlet var FullNameText: UITextField!
    @IBOutlet var LocationText: UITextField!
    @IBOutlet var EmailText: UITextField!
    @IBOutlet var PwdText: UITextField!
    var db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func handleRegister(_ sender: UIButton) {
        print("Handle register")
        guard let eml = EmailText.text else {return}
        guard let pwd = PwdText.text else {return}
        guard let name = FullNameText.text else {return}
        guard let loc = LocationText.text else {return}
        
        createUser(fullname: name, countrycity: loc, withEmail: eml, password: pwd)
    }
    
    @IBAction func handleShowLogin(_ sender: UIButton) {
        performSegue(withIdentifier: "registerToLogin", sender: self)
    }
    
    // MARK: - API
    func createUser(fullname: String, countrycity: String, withEmail email: String, password: String){
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            
            if let error = error{
                print("Failed to Sign up user with error: ", error.localizedDescription)
                return
            }
            
            guard let uid = result?.user.uid else {return}
            let values = ["email": email, "fullname": fullname, "location": countrycity]
            Database.database().reference().child("users").child(uid).updateChildValues(values, withCompletionBlock: {(error, ref) in
                if let error = error{
                    print("Failed to Update Database Values with error: ", error.localizedDescription)
                    return
                }
                self.db.collection("favorites").document(uid).setData([:
                   
                ]);
                self.performSegue(withIdentifier: "registerToLogin", sender: nil)
            })
        }
    }
}
