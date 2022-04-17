//
//  LoginController.swift
//  Recipe-inator
//
//  Created by Adi on 05.03.22.
//

import UIKit
import Firebase

class LoginController: UIViewController{
    
    @IBOutlet var EmailTekst: UITextField!
    @IBOutlet var PasswordTekst: UITextField!
    
    // MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Selectors
    @IBAction func handleLogin(_ sender: UIButton) {
        guard let eml = EmailTekst.text else {return}
        guard let pwd = PasswordTekst.text else {return}
        
        logUserIn(withEmail: eml, password: pwd)
    }
    
    @IBAction func handleShowSignUp(_ sender: UIButton) {
       performSegue(withIdentifier: "loginToRegister", sender: self)
    }
    
    // MARK: - API
    func logUserIn(withEmail email: String, password: String){
        Auth.auth().signIn(withEmail: email, password: password, completion: {(result, error) in
            
            
            if let error = error{
                print("Failed to Log in User with error: ",error.localizedDescription)
                return
            }
            
            self.performSegue(withIdentifier: "loginToHome", sender: nil)
        })
    }
    
}
