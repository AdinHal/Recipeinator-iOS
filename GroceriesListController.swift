//
//  GroceriesListController.swift
//  Recipe-inator
//
//  Created by Adi on 09.03.22.
//

import UIKit
import Firebase
import FirebaseFirestore

class GroceriesListController:UIViewController{
    var groceries : [String] = []
    var documentIDs : [String] = []
    var grocery: String = ""
    @IBOutlet var groceryInput: UITextField!
    var db = Firestore.firestore()
    @IBOutlet var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        populateGroceries()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        populateGroceries()
    }
    
    // MARK: -Navigation Buttons
    @IBAction func homeBtnNavigation(_ sender: UIButton) {
        self.performSegue(withIdentifier: "groceriesToHome", sender: self)
    }
    @IBAction func searchBtnNavigation(_ sender: UIButton) {
        self.performSegue(withIdentifier: "groceriesToSearch", sender: self)
    }
    @IBAction func recipesBtnNavigation(_ sender: UIButton) {
        self.performSegue(withIdentifier: "groceriesToRecipes", sender: self)
    }
    
    @IBAction func profileBtnNavigation(_ sender: UIButton) {
     self.performSegue(withIdentifier: "groceriesToProfile", sender: self)
    }
    
    
    // MARK: -API
    @IBAction func createGrocery(){
        if groceryInput.text == ""{
            let alertControler = UIAlertController(title: nil, message: "Please enter a Grocery Name", preferredStyle: .alert)
            alertControler.addAction(UIAlertAction(title: "Close", style: .destructive, handler: {(_) in alertControler.dismiss(animated: true)}))
            present(alertControler, animated: true, completion: nil)
        }else{
            db.collection("groceries").document(groceryInput.text!).setData(["grocery" : groceryInput.text!]){ error in
                if let error = error{
                    print (error)
                }else{
                    print("Grocery sent successfully")
                    self.groceryInput.text = ""
                }
                self.populateGroceries()
                self.collectionView.reloadData()
            }
    }
}
    
    func populateGroceries(){
            db.collection("groceries").addSnapshotListener{(snapshot, error) in
                if let snapshot = snapshot {
                    self.groceries = snapshot.documents.map{doc in doc.data()["grocery"] as! String}
                    
                }
            }
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.reloadData()
    }
    
    @IBAction func eraseGrocery(sender:UIButton) {
      let i : Int = (sender.layer.value(forKey: "grocery")) as! Int
      let groc = self.groceries[i]
      db.collection("groceries").document(groc).delete(){
            error in
            if let error = error {
                print(error.localizedDescription)
            }else{
                self.populateGroceries()
                self.collectionView.reloadData()
            }
        }
      collectionView.reloadData()
    }
   
}

extension GroceriesListController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return groceries.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "groceryItem", for: indexPath) as! groceriesListCollectionViewCell
        //let arrayForCell = groceries[indexPath.row]
        cell.label.text = groceries[indexPath.row]
        cell.deleteButton?.layer.setValue(indexPath.row, forKey: "grocery")

        return cell
    }
    
    
}
