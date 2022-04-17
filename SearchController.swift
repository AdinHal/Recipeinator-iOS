//
//  SearchController.swift
//  Recipe-inator
//
//  Created by Adi on 08.03.22.
//

import UIKit
import SwiftUI
import Firebase
import FirebaseFirestore

class SearchController : UIViewController{
    var db = Firestore.firestore()
    @IBOutlet var collectionView: UICollectionView!
    var recipesArray : [String] = []
    var starsArray : [String] = []
    var hoursArray : [String] = []
    var minutesArray : [String] = []
    var categoriesArray : [String] = []
    var vtp = String()
    @IBOutlet var searchBar: UISearchBar!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.isHidden = true
        probna()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        searchBar.isHidden = true
        probna()
    }
    
    // MARK: - Navigation Buttons
    @IBAction func homeBtnNavigation(_ sender: UIButton) {
        self.performSegue(withIdentifier: "searchToHome", sender: self)
    }
    @IBAction func recipeBtnNavigation(_ sender: UIButton) {
        self.performSegue(withIdentifier: "searchToRecipe", sender: self)
    }
    @IBAction func groceriesBtnNavigation(_ sender: UIButton) {
        self.performSegue(withIdentifier: "searchToGroceries", sender: self)
    }
    @IBAction func profileBtnNavigation(_ sender: UIButton) {
        self.performSegue(withIdentifier: "searchToProfile", sender: self)
    }

    // MARK: - Search Results
   
    func probna(){
        db.collection("recipes").addSnapshotListener{(snapshot, error) in
            if let snapshot = snapshot {
                self.recipesArray = snapshot.documents.map{doc in doc.data()["name"] as! String}
                self.starsArray = snapshot.documents.map{doci in doci.data()["stars"] as! String}
                self.hoursArray = snapshot.documents.map{doca in doca.data()["hours"] as! String}
                self.minutesArray = snapshot.documents.map{docent in docent.data()["minutes"] as! String}
                self.categoriesArray = snapshot.documents.map{producent in producent.data()["category"] as! String}
            }
        }

    collectionView.delegate = self
    collectionView.dataSource = self
    collectionView.reloadData()
    }
   
}

extension SearchController : UICollectionViewDelegate, UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recipesArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "recipeResult", for: indexPath) as! searchResultCollectionViewCell
        
        cell.titleLabel.text = recipesArray[indexPath.row]
        cell.starsLabel.text = starsArray[indexPath.row]
        cell.hoursLabel.text = hoursArray[indexPath.row]
        cell.minutesLabel.text = minutesArray[indexPath.row]
        cell.categoryLabel.text = categoriesArray[indexPath.row]
      
        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ShowRecipeController {
            let selectedRow = collectionView.indexPath(for: sender as! UICollectionViewCell)?.row
            destination.valueToPass = recipesArray[selectedRow!]
            }
    }
}

extension UIView{
    // MARK: - cornerRadius Option for Storyboard with @IBInspectable
    @IBInspectable var cornerRadiusV: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderColorV: UIColor? {
            get {
                return UIColor(cgColor: layer.borderColor!)
            }
            set {
                layer.borderColor = newValue?.cgColor
            }
        }
}
