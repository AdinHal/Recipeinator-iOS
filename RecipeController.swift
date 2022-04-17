//
//  RecipeController.swift
//  Recipe-inator
//
//  Created by Adi on 09.03.22.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage
import Photos
import PhotosUI

class RecipeController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    var db = Firestore.firestore()
    private let storage = Storage.storage().reference()
    var photos = [PHAsset]()
    var urlString = ""
    @IBOutlet var steppers: [UIStepper]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: Photo Library Access Permission
        PHPhotoLibrary.requestAuthorization{[unowned self] authStatus in DispatchQueue.main.async {
            if authStatus == .authorized{
                print("Photo Library : Access Granted")
                //print(self)
            }else{
                print("Access Denied")
            }
        }}
        
        let results = PHAsset.fetchAssets(with: .image, options: nil)
        results.enumerateObjects({
            (photo: AnyObject, i: Int, bool)-> Void in
            let p = photo as! PHAsset
            self.photos.append(p)
        })
    }
    
    // MARK: - Navigation Buttons
    
    @IBAction func homeBtnNavigation(_ sender: UIButton) {
        self.performSegue(withIdentifier: "recipeToHome", sender: self)
    }
    @IBAction func searchBtnNavigation(_ sender: UIButton) {
        self.performSegue(withIdentifier: "recipeToSearch", sender: self)
    }
    @IBAction func groceriesBtnNavigationn(_ sender: UIButton) {
        self.performSegue(withIdentifier: "recipesToGroceries", sender: self)
    }
    @IBAction func profileBtnNavigation(_ sender: UIButton) {
        self.performSegue(withIdentifier: "recipesToProfile", sender: self)
    }
    
    // MARK: - Create Controllers
    
    // Hours & Minutes
    
    @IBOutlet var hoursLabel: UILabel!
    @IBOutlet var minutesLabel: UILabel!
    @IBAction func hoursStepper(_ sender: UIStepper) {
        self.hoursLabel.text = Int(sender.value).description + " h"
    }
    @IBAction func minutesStepper(_ sender: UIStepper) {
        self.minutesLabel.text = Int(sender.value).description + " min"
    }
    
    // Servings
    
    @IBOutlet var servingsLabel: UILabel!
    @IBAction func oneStepper(_ sender: UIStepper) {
        self.servingsLabel.text = Int(sender.value).description + " serving(s)"
    }
    
    // Rating

    @IBOutlet var starsLabel: UILabel!
    @IBAction func oneStepperStars(_ sender: UIStepper) {
        self.starsLabel.text = Int(sender.value).description+" star(s)"
    }
    
    // Ingredients
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var ingredientInput: UITextField!
    @IBOutlet var ingredientAmountInput: UITextField!
    var ingredients : [String] = []
    
    @IBAction func addIngredient(_ sender: UIButton) {
        if (ingredientInput.text! == "" || ingredientAmountInput.text! == ""){
            let alertControler = UIAlertController(title: nil, message: "Please fill out both fields", preferredStyle: .alert)
            alertControler.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(alertControler, animated: true, completion: nil)
        } else{
            let delimiter = " "
            let ingredient = ingredientInput.text!+delimiter+ingredientAmountInput.text!
            ingredients.append(ingredient)
            
            for ingredien in ingredients{
                print(ingredien)
            }
            ingredientInput.text = ""
            ingredientAmountInput.text = ""
        }
        tableView.reloadData()
    }
    
    // MARK: Send Recipe
    
    @IBOutlet var recipeNameInput: UITextField!
    @IBOutlet var recipeCategoryInput: UITextField!
    @IBOutlet var recipeInstructionsInput: UITextField!
    
    @IBAction func selectImage(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
        picker.dismiss(animated: true,completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else{return}
        guard let imageData = image.pngData() else {return}
        let fileNameRandom = randomString(length: 10)
        let riversRef = storage.child("images/\(fileNameRandom).png")
        
        // Upload the file to the path "images/food.jpg"
        let uploadTask = riversRef.putData(imageData, metadata: nil) { (metadata, error) in
          guard let metadata = metadata else {
            // Uh-oh, an error occurred!
            return
          }
          // Metadata contains file metadata such as size, content-type.
          let size = metadata.size
          // You can also access to download URL after upload.
          riversRef.downloadURL { (url, error) in
            guard let downloadURL = url else {
              // Uh-oh, an error occurred!
                print("Upload failed!")
              return
            }
              
              self.urlString = url!.absoluteString
              print("Download URL: \(self.urlString)")
          }
        }
        // upload image data
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        picker.dismiss(animated: true,completion: nil)
    }
    
    func randomString(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    @IBAction func sendRecipe(_ sender: UIButton) {
        let recipeUniqueID = randomString(length: 10)
        if (recipeNameInput.text == "" || ingredients.isEmpty){
            let alertControler = UIAlertController(title: nil, message: "Please fill out all the fields", preferredStyle: .alert)
            alertControler.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(alertControler, animated: true, completion: nil)
        }else{
            db.collection("recipes").document(recipeNameInput.text!).setData([
                "uniqueID": recipeUniqueID,
                "name": recipeNameInput.text!,
                "category": recipeCategoryInput.text!,
                "instructions": recipeInstructionsInput.text!,
                "hours": hoursLabel.text!,
                "minutes": minutesLabel.text!,
                "servings": servingsLabel.text!,
                "stars": starsLabel.text!,
                "ingredients": ingredients,
                "imageURL": urlString
            ]) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("Document successfully written!")
                    self.recipeNameInput.text! = ""
                    self.recipeCategoryInput.text! = ""
                    self.recipeInstructionsInput.text! = ""
                    self.hoursLabel.text = "0 hour(s)"
                    self.minutesLabel.text = "0 minute(s)"
                    self.servingsLabel.text = "0 serving(s)"
                    self.starsLabel.text = "0 star(s)"
                    self.ingredients = []
                    self.tableView.reloadData()
                    for stepper in self.steppers{
                        stepper.value = 0
                    }
                }
            }
        }
    }
}
extension RecipeController : UITableViewDelegate, UITableViewDataSource{

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
            return ingredients.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
            cell?.textLabel?.text = ingredients[indexPath.row]
            return cell!
        }

        public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
            return 40
        }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
          if editingStyle == .delete {
            print("Deleted")

            self.ingredients.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
          }
        }
}
    
    
    

