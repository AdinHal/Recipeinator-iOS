//
//  ShowRecipeController.swift
//  Recipe-inator
//
//  Created by Adi on 13.04.22.
//

import UIKit
import Firebase
import FirebaseFirestore

class ShowRecipeController : UIViewController{
    @IBOutlet var backView: UIView!
    var colorTwo = UIColor.init(red: 45/255, green: 49/255, blue: 66/255, alpha: 1)
    let height = UIScreen.main.bounds.height
    let width = UIScreen.main.bounds.width
    var db = Firestore.firestore()
    var dataDocument : [String : Any] = [:]
    var ingredients : [String] = []
    @IBOutlet var topView: UIView!
    @IBOutlet var midView: UIView!
    @IBOutlet var bottomView: UIView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var hoursLabel: UILabel!
    @IBOutlet var starsLabel: UILabel!
    @IBOutlet var servingsLabel: UILabel!
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var instructionsTextView: UITextView!
    @IBOutlet var recipeImage: UIImageView!
    @IBOutlet var collectionView: UICollectionView!
    var valueToPass = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backView.backgroundColor = colorTwo
        self.scrollView.contentSize = CGSize(width: 428, height: 700)
        self.scrollView.addSubview(topView)
        self.scrollView.addSubview(midView)
        self.scrollView.addSubview(bottomView)
        db.collection("recipes").whereField("name", isEqualTo: "\(valueToPass)")
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        self.dataDocument = document.data()
                        //print("\(document.documentID) => \(document.data())")
                        let hours = self.dataDocument["hours"] as? String
                        let minutes = self.dataDocument["minutes"] as? String
                        let servings = self.dataDocument["servings"] as? String
                        let stars = self.dataDocument["stars"] as? String
                        let category = self.dataDocument["category"] as? String
                        let instructions = self.dataDocument["instructions"] as? String
                        let name = self.dataDocument["name"] as? String
                        let ingr = self.dataDocument["ingredients"] as? NSArray
                        self.ingredients = ingr as! [String]
                        self.titleLabel.text = "\(name!)"
                        self.hoursLabel.text = "\(hours!) \(minutes!)"
                        self.servingsLabel.text = "\(servings!)"
                        self.starsLabel.text = "\(stars!)"
                        self.categoryLabel.text = "\(category!)"
                        self.instructionsTextView.text = "\(instructions!)"
                        let urlString = self.dataDocument["imageURL"] as? String
                        if let url = URL(string: urlString!) {
                            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                                guard let data = data, error == nil else { return }
                                
                                DispatchQueue.main.async { /// execute on main thread
                                    self.recipeImage.image = UIImage(data: data)
                                }
                            }
                            
                            task.resume()
                        }
                    }
            }
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        collectionView.reloadData()
    }
    
    @IBAction func goBackButton(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}

extension ShowRecipeController : UICollectionViewDelegate, UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ingredients.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ingredient", for: indexPath) as! recipePreviewCollectionViewCell
        //let arrayForCell = groceries[indexPath.row]
        cell.label.text = ingredients[indexPath.row]
    
        return cell
    }

}
