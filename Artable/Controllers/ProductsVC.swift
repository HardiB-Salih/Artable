//
//  ProductsVC.swift
//  Artable
//
//  Created by Hardi B. Salih on 16.02.2023.
//

import UIKit
import Firebase

class ProductsVC: UIViewController, ProductCellDelegate {

    // Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // Variables
    var products = [Product]()
    var category: Category!
    var listener: ListenerRegistration!
    var db : Firestore!
    var showFavorites = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Firestore.firestore()
        setUpTableView()
        setupQuery()
    }
    
    func setUpTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: Identifiers.ProductCell, bundle: nil), forCellReuseIdentifier: Identifiers.ProductCell)
    }
    
    func productFavorited(product: Product) {
        if UserService.isGuest {
            self.simpleAlert(title: "Hi friend!", msg: "This is a user only feature, please create a registered user to take advantage of all our features.")
            return
        }
        
        UserService.favoriteSelected(product: product)
        guard let index = products.firstIndex(of: product) else { return }
        tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }
    
    func productAddToCart(product: Product) {
        if UserService.isGuest {
            self.simpleAlert(title: "Hi friend!", msg: "This is a user only feature, please create a registered user to take advantage of all our features.")
            return
        }
        StripeCart.addItemToCart(item: product)
    }
}

extension ProductsVC {
    
    func setupQuery() {
        
        var ref: Query!
        if showFavorites {
            ref = db.collection("users").document(UserService.user.id).collection("favorites")
        } else {
            ref = db.products(categoryId: category.id)
        }
        
        listener = ref.addSnapshotListener({ (snap, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
            }
            
            snap?.documentChanges.forEach({ (change) in
                let data = change.document.data()
                let product = Product.init(data: data)
                
                switch change.type {
                case .added:
                    self.onDocumentAdded(change: change, product: product)
                case .modified:
                    self.onDocumentModified(change: change, product: product)
                case .removed:
                    self.onDocumentRemoved(change: change)
                @unknown default:
                    Auth.auth().handleFireAuthError(error: error!, vc: self)
                }
            })
        })
    }
    
    
    func onDocumentAdded(change: DocumentChange, product: Product) {
        let newIndex = Int(change.newIndex)
        products.insert(product, at: newIndex)
        tableView.insertRows(at: [IndexPath(row: newIndex, section: 0)], with: .fade)
    }
    
    func onDocumentModified(change: DocumentChange, product: Product) {
        if change.oldIndex == change.newIndex {
            // Item changed, but remained in the same position
            let index = Int(change.newIndex)
            products[index] = product
            tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
        } else {
            // Item changed and changed position
            let oldIndex = Int(change.oldIndex)
            let newIndex = Int(change.newIndex)
            products.remove(at: oldIndex)
            products.insert(product, at: newIndex)
            tableView.moveRow(at: IndexPath(row: oldIndex, section: 0), to: IndexPath(row: newIndex, section: 0))
        }
    }
    
    func onDocumentRemoved(change: DocumentChange) {
        let oldIndex = Int(change.oldIndex)
        products.remove(at: oldIndex)
        tableView.deleteRows(at: [IndexPath(row: oldIndex, section: 0)], with: .left)
    }
}

extension ProductsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.ProductCell, for: indexPath) as? ProductCell {
            cell.configureCell(product: products[indexPath.row], delegate: self)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ProductDetailVC()
        let selectedProduct = products[indexPath.row]
        vc.product = selectedProduct
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overCurrentContext
        present(vc, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    
}

