//
//  ItemViewController.swift
//  SanalEcza
//
//  Created by Cevher Şirin on 18.04.2023.
//

import UIKit
import JGProgressHUD

class ItemViewController: UIViewController {

    //MARK: IBOutlets
    
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    //MARK: VARS
    var item: Item!
    var itemImages: [UIImage] = []
    let hud = JGProgressHUD(style: .dark)
    
    private let sectionInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    private let cellHeight : CGFloat = 196
    private let itemsPerRow: CGFloat = 1
    
    //MARK: ViewLifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        downloadPictures()
        
//        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self, action: #selector(self.backAction))]
//
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(image: UIImage(named: "baskettt"), style: .plain, target: self, action: #selector(self.addToBasketButtonPressed))]
//        navigationItem.title = "Test"
    }
    
//MARK: DOWNLOAD PICTURES
    
    private func downloadPictures() {
        
        if item != nil && item.imageLinks != nil {
            downloadImages(imageUrls: item.imageLinks) { (allImages) in
                if allImages.count > 0 {
                    self.itemImages = allImages as! [UIImage]
                    self.imageCollectionView.reloadData()
                }
            }
        }
    }
    
    
    
    
    
    
//MARK: SETUP UI
    
    private func setupUI() {
        
        if item != nil {
            self.title = item.name
            nameLabel.text = item.name
            priceLabel.text = convertToCurrency(item.price)
            descriptionTextView.text = item.description
        }
        
    }
    
//MARK: IBActions
    
    @objc func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func addToBasketButtonPressed() {
        
                
        if MUser.currentUser() != nil {
            
            downloadBasketFromFirestore(MUser.currentId()) { (basket) in //MARK: USER ID ?
                
                if basket == nil {
                    self.createNewBasket()
                } else {
                    basket!.itemIds.append(self.item.id)
                    self.updateBasket(basket: basket!, withValues: [kITEMIDS : basket!.itemIds])
                }
            }
        } else {
            
            showLoginView()
        }
    }
    
    //MARK: ADD To Basket
    
    private func createNewBasket() {
        let newBasket = Basket()
        newBasket.id = UUID().uuidString // UNIQUE ID
        newBasket.ownerId = MUser.currentId() //MARK: USER ID ?
        newBasket.itemIds = [self.item.id]
        saveBasketToFirestore(newBasket)
        
        self.hud.textLabel.text = "Added To Basket!"
        self.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
        self.hud.show(in: self.view)
        self.hud.dismiss(afterDelay: 2.0) // DELAY 2 SECONDS
        
    }
    
    private func updateBasket(basket: Basket, withValues: [String: Any]) {
        updateBasketInFirestore(basket, withValues: withValues) { (error) in
            
            if error != nil {
                self.hud.textLabel.text = "Error: \(error!.localizedDescription)"
                self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
                self.hud.show(in: self.view)
                self.hud.dismiss(afterDelay: 2.0) // DELAY 2 SECONDS
                
                print("error updating basket", error!.localizedDescription)

            } else {
                self.hud.textLabel.text = "Added To Basket!"
                self.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
                self.hud.show(in: self.view)
                self.hud.dismiss(afterDelay: 2.0) // DELAY 2 SECONDS

            }
            
        }
    }
    
    //MARK: Show login View
    
    private func showLoginView() {
        
        let loginView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "loginView")
        
        self.present(loginView, animated: true, completion: nil)
    }
    

}

extension ItemViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return itemImages.count == 0 ? 1 : itemImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ImageCollectionViewCell
        
        if itemImages.count > 0 {
            cell.setupImageWith(itemImage: itemImages[indexPath.row])
        }
        return cell
    }
    
    
}


extension ItemViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        let avaibleWidth = collectionView.frame.width - sectionInsets.left
        
        
        return CGSize(width: avaibleWidth, height: cellHeight) 
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return sectionInsets.left
    }
    
}
