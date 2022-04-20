//
//  ProfileController.swift
//  Recipe-inator
//
//  Created by Adi on 09.03.22.
//

import UIKit
import Firebase


class ProfileController : UIViewController{
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var profileInfoNameLabel: UILabel!
    @IBOutlet var profileNameLabel: UILabel!
    var recipesArray : [String] = []
    var uiColorArray = [UIColor]()
    var recipeIDs : [String] = []
    var favorites : [String] = []
    var docIDs : [String] = []
    var fetchedImages : [String] = []
    var fetchedFavorites : [String : Any] = [:]
    var db = Firestore.firestore()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUserData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        // Do any additional setup after the view appears, typically from a nib.
        loadUserData()
    }
    
    @IBAction func homeBtnNavigation(_ sender: UIButton) {
        self.performSegue(withIdentifier: "profileToHome", sender: self)
    }
    @IBAction func searchBtnNavigation(_ sender: UIButton) {
        self.performSegue(withIdentifier: "profileToSearch", sender: self)
    }
    
    @IBAction func recipesBtnNavigation(_ sender: UIButton) {
        self.performSegue(withIdentifier: "profileToRecipes", sender: self)
    }
    
    @IBAction func groceriesBtnNavigation(_ sender: UIButton) {
        self.performSegue(withIdentifier: "profileToGroceries", sender: self)
    }
    
    func appendColors(){
        let colorOne = UIColor.init(red: 45/255, green: 49/255, blue: 66/255, alpha: 1)
        let colorTwo = UIColor.init(red: 158/255, green: 118/255, blue: 143/255, alpha: 1)
        let colorThree = UIColor.init(red: 159/255, green: 164/255, blue: 196/255, alpha: 1)
        let colorFour = UIColor.init(red: 255/255, green: 87/255, blue: 10/255, alpha: 1)
        let colorFive = UIColor.init(red: 211/255, green: 184/255, blue: 140/255, alpha: 1)
        let colorSix = UIColor.init(red: 250/255, green: 159/255, blue: 66/255, alpha: 1)
        let colorSeven = UIColor.init(red: 51/255, green: 51/255, blue: 51/255, alpha: 1)
        let colorEight = UIColor.init(red: 126/255, green: 127/255, blue: 154/255, alpha: 1)
        let colorNine = UIColor.init(red: 36/255, green: 130/255, blue: 50/255, alpha: 1)
        let colorTen = UIColor.init(red: 245/255, green: 47/255, blue: 87/255, alpha: 1)
        uiColorArray.append(colorOne)
        uiColorArray.append(colorTwo)
        uiColorArray.append(colorThree)
        uiColorArray.append(colorFour)
        uiColorArray.append(colorFive)
        uiColorArray.append(colorSix)
        uiColorArray.append(colorSeven)
        uiColorArray.append(colorEight)
        uiColorArray.append(colorNine)
        uiColorArray.append(colorTen)
    }
    
    // MARK: -API
    func loadUserData(){
        guard let uid = Auth.auth().currentUser?.uid else{return}
        Database.database().reference().child("users").child(uid).child("fullname").observeSingleEvent(of: .value, with: {(snapshot) in
            guard let username = snapshot.value as? String else{return}
            self.profileNameLabel.text = username
            self.profileInfoNameLabel.text = username
            self.appendColors()
            self.fetchDataFromDB()
        })
        
        Database.database().reference().child("users").child(uid).child("location").observeSingleEvent(of: .value, with: {(snapshot) in
            guard let location = snapshot.value as? String else{return}
            self.locationLabel.text = location
        })

    }
    
    func fetchDataFromDB(){
        guard let uid = Auth.auth().currentUser?.uid else{return}
        
        let docRef = db.collection("favorites").document(uid)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data()! as [String : Any]
                //print("Document data: \(dataDescription)")
                self.fetchedFavorites = dataDescription
            } else {
                print("Document does not exist")
            }
        }
       
        for (key, value) in fetchedFavorites {
            print("Key > \(key) - Value > \(value)")
            self.recipeIDs.append(key)
            self.favorites.append(value as! String)
        }
        
        for favorite in favorites.reversed(){
                self.db.collection("recipes").whereField("name", isEqualTo: favorite)
                    .getDocuments() { (querySnapshot, err) in
                        if let err = err {
                            print("Error getting documents: \(err)")
                        } else {
                            for document in querySnapshot!.documents {
                                DispatchQueue.main.async {
                                    //print("\(document.documentID) => \(String(describing: document.data()["imageURL"]))")
                                   self.docIDs.append(document.documentID)
                                   self.fetchedImages.append(document.data()["imageURL"] as! String)
                                   self.collectionView.reloadData()
                                }
                            }
                        }
                }
            }
    }
    
    @IBAction func removeRecipeFromFavourites(_ sender: UIButton){
        guard let uid = Auth.auth().currentUser?.uid else{return}
        db.collection("favorites").document(uid).updateData([
            "\(recipeIDs[sender.tag])": FieldValue.delete(),
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Removed: ID > \(self.recipeIDs[sender.tag]) : Name > \(self.docIDs[sender.tag])")
                self.recipeIDs.remove(at: sender.tag)
                self.docIDs.remove(at: sender.tag)
                self.fetchedImages.remove(at: sender.tag)
                self.collectionView.reloadData()
                print("Document successfully updated")
                self.collectionView.reloadData()
            }
        }
    }
}

extension ProfileController : UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if docIDs.count < 10{
            return docIDs.count
        }else{
            return 10
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "favoriteRecipe", for: indexPath) as! ProfileCollectionViewCell
        
        cell.recipeName.text = docIDs[indexPath.row]
        cell.removeButton.tag = indexPath.row
        cell.backgroundColor = uiColorArray[indexPath.row]
        cell.layer.cornerRadius = 15
        cell.imageView.sd_setImage(with: URL(string: fetchedImages[indexPath.row]), placeholderImage:UIImage(named: "ceasar"))
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ShowRecipeController {
            let selectedRow = collectionView.indexPath(for: sender as! UICollectionViewCell)?.row
            destination.valueToPass = docIDs[selectedRow!]
      }
    }
}
