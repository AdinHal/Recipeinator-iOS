//
//  HomeController.swift
//  Recipe-inator
//
//  Created by Adi on 05.03.22.
//

import UIKit
import Firebase
import SwiftUI
import FirebaseFirestore
import Foundation
import SDWebImage

class HomeController: UIViewController{

    @IBOutlet var usernameLbl: UILabel!
    @IBOutlet var smallViewOne: UIView!
    @IBOutlet var smallViewOneImage: UILabel!
    @IBOutlet var smallViewTwo: UIView!
    @IBOutlet var smallViewTwoImage: UILabel!
    @IBOutlet var smallViewThree: UIView!
    @IBOutlet var smallViewThreeImage: UILabel!
    @IBOutlet var collView: UICollectionView!
    var uiColorArray = [UIColor]()
    var recipesArray : [String] = []
    var hoursArray : [String] = []
    var minutesArray : [String] = []
    var imageData : [String] = []
    var recipeIDs : [String] = []
    var db = Firestore.firestore()
   
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        appendColors()
        authenticateUserAndConfigureView()
        loadsmallViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        // Do any additional setup after the view appears, typically from a nib.
        appendColors()
        fetchDataFromDB()
    }
    
    // MARK: - Selectors
    
    @IBAction func signOutUser(_ sender: Any) {
        let alertControler = UIAlertController(title: nil, message: "Are You sure You want to Sign Out?", preferredStyle: .actionSheet)
        alertControler.addAction(UIAlertAction(title: "Sign out", style: .destructive, handler: {(_) in self.signOut()}))
        alertControler.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertControler, animated: true, completion: nil)
    }
    
    @IBAction func viewAllRecipes(_ sender: UIButton) {
        self.performSegue(withIdentifier: "homeToSearch", sender: self)
    }
    
    // MARK: - API
    
    func loadUserData(){
        guard let uid = Auth.auth().currentUser?.uid else{return}
        Database.database().reference().child("users").child(uid).child("fullname").observeSingleEvent(of: .value, with: {(snapshot) in
            guard let username = snapshot.value as? String else{return}
            let delimiter = " "
            let token = username.components(separatedBy: delimiter)
            self.usernameLbl.text = "\(token[0])?"
            self.appendColors()
            self.fetchDataFromDB()
        })
    }
    
    func signOut(){
        do{
            try Auth.auth().signOut()
            self.performSegue(withIdentifier: "homeToLogin", sender: nil)
        }catch let error {
            print("Failed to Sign out with error: ", error.localizedDescription)
        }
    }
    
    func authenticateUserAndConfigureView(){
        if Auth.auth().currentUser == nil{
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "homeToLogin", sender: nil)
            }
        }else{
            self.appendColors()
            self.fetchDataFromDB()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let secondVC = storyboard.instantiateViewController(identifier: "Home")
            show(secondVC, sender: self)
            self.fetchDataFromDB()
        }
        loadUserData()
    }
    
    func fetchDataFromDB(){
            db.collection("recipes").addSnapshotListener{(snapshot, error) in
                if let snapshot = snapshot {
                    self.recipesArray = snapshot.documents.map{doc in doc.data()["name"] as! String}
                    self.hoursArray = snapshot.documents.map{doca in doca.data()["hours"] as! String}
                    self.minutesArray = snapshot.documents.map{docent in docent.data()["minutes"] as! String}
                    self.recipeIDs = snapshot.documents.map{asistent in asistent.data()["uniqueID"] as! String}
                    self.imageData = snapshot.documents.map{producent in producent.data()["imageURL"] as! String}
                }
            }
           
            collView.reloadData()
    }

    
    //MARK: Navigation Buttons Connections
    
    @IBAction func searchButton(_ sender: UIButton) {
        self.performSegue(withIdentifier: "homeToSearch", sender: self)
    }
    @IBAction func recipeButton(_ sender: UIButton) {
        self.performSegue(withIdentifier: "homeToRecipe", sender: self)
    }
    @IBAction func groceriesButton(_ sender: UIButton) {
        self.performSegue(withIdentifier: "homeToGroceries", sender: self)
    }
    @IBAction func profileButton(_ sender: UIButton) {
        self.performSegue(withIdentifier: "homeToProfile", sender: self)
    }
    
    // MARK: UI/UX
    
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
    
    func loadsmallViews(){
        smallViewOne.backgroundColor = UIColor.init(red: 246/255, green: 142/255, blue: 95/255, alpha: 1)
        smallViewTwo.backgroundColor = UIColor.init(red: 59/255, green: 178/255, blue: 115/255, alpha: 1)
        smallViewThree.backgroundColor = UIColor.init(red: 55/255, green: 74/255, blue: 103/255, alpha: 1)
        smallViewOneImage.text = "🔥"
        smallViewTwoImage.text = "🌱"
        smallViewThreeImage.text = "🍟"
    }
}

extension HomeController: UICollectionViewDelegate, UICollectionViewDataSource{

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cellTwo = collView.dequeueReusableCell(withReuseIdentifier: "bottomCell", for: indexPath) as! bottomCollectionViewCell
        
            cellTwo.recipeNameMain.text = recipesArray[indexPath.row]
            cellTwo.timeLabelMain.text = "\(hoursArray[indexPath.row]) \(minutesArray[indexPath.row])"
            cellTwo.layer.cornerRadius = 15
            cellTwo.backgroundColor = uiColorArray[indexPath.row]
            cellTwo.imageBottom.sd_setImage(with: URL(string: imageData[indexPath.row]), placeholderImage:UIImage(named: "ceasar"))
            cellTwo.favButton.tag = indexPath.row
            
        
            return cellTwo
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if recipesArray.count < 10{
            return recipesArray.count
        }else{
            return 10
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ShowRecipeController {
            let selectedRow = collView.indexPath(for: sender as! UICollectionViewCell)?.row
            destination.valueToPass = recipesArray[selectedRow!]
      }
    }
    
    func randomString(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    @IBAction func addRecipeToFavourites(_ sender: UIButton) {
        sender.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        // addToFavourites(sender.tag)
        //let fileNameRandom = randomString(length: 5)
        guard let uid = Auth.auth().currentUser?.uid else{return}
        db.collection("favorites").document(uid).updateData([
            "\(recipeIDs[sender.tag])" : "\(recipesArray[sender.tag])"
        ]);
    }
}

extension Array{
    func split()->(left:[Element], right:[Element]){
        let count = self.count
        let half = count / 2
        let leftSplit = self[0 ..< half]
        let rightSplit = self[half ..< count]
        
        return(left: Array(leftSplit), right: Array(rightSplit))
    }
}
