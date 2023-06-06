//
//  BasketViewController.swift
//  SanalEcza
//
//  Created by Cevher Şirin on 8.05.2023.
//

import UIKit
import JGProgressHUD
import Stripe

class BasketViewController: UIViewController {
    
    //MARK: IBOutlets
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var basketTotalPriceLabel: UILabel!
    @IBOutlet weak var totalItemsLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var checkOutButtonOutlet: UIButton!
    
    //MARK: Vars
    var basket: Basket?
    var allItems: [Item] = []
    var purchasedItemIds : [String] = []
    
    let hud = JGProgressHUD(style: .dark)
    var totalPrice = 0
    
        
    
    
    //MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = footerView
        
                
    }
    /* override func viewWillAppear(_ animated: Bool) {
     super.viewWillAppear(animated)
     loadBasketFromFirestore()
     }*/
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if MUser.currentUser() != nil {
            loadBasketFromFirestore()
        } else {
            self.updateTotalLabels(true)
        }
        
    }
    
    //MARK: IBActions
    
    
    @IBAction func checkoutButtonPressed(_ sender: Any) {
        
        if MUser.currentUser()!.onBoard {
            
            showPaymentOptions()
            
        } else {
            self.showNotification(text: "Please Complete Your Profile!", isError: true)
        }
        
        
    }
    
    //MARK: Download Basket
    private func loadBasketFromFirestore() {
        
        downloadBasketFromFirestore(MUser.currentId()) { (basket) in
            
            self.basket = basket
            self.getBasketItems()
        }
    }
    
    private func getBasketItems() {
        if basket != nil {
            downloadItems(basket!.itemIds) { (allItems) in
                self.allItems = allItems
                self.updateTotalLabels(false)
                self.tableView.reloadData()
            }
        }
        
    }
    
    //MARK: Helper Functions
    
    
    private func updateTotalLabels (_ isEmpty: Bool) {
        
        if isEmpty {
            totalItemsLabel.text = "0"
            basketTotalPriceLabel.text = returnBasketTotalPrice()
        } else {
            totalItemsLabel.text = "\(allItems.count)"
            basketTotalPriceLabel.text = returnBasketTotalPrice()
        }
        
        checkoutButtonStatusUpdate()
    }
    
    private func returnBasketTotalPrice() -> String {
        var totalPrice = 0.0
        
        for item in allItems {
            totalPrice += item.price
        }
        
        return "Total Price: " + convertToCurrency(totalPrice)
    }
    
    private func emptyTheBasket() {
        
        purchasedItemIds.removeAll()
        allItems.removeAll()
        tableView.reloadData()
        
        basket!.itemIds = []
        
        updateBasketInFirestore(basket!, withValues: [kITEMIDS : basket!.itemIds]) { (error) in
            
            if error != nil {
                print("Error Updating Basket ", error!.localizedDescription)
            }
            
            self.getBasketItems()
        }
        
    }
    
    private func addItemsToPurchaseHistory(_ itemIds: [String]) {
        
        if MUser.currentUser() != nil {
            let newItemIds = itemIds
            
            updateCurrentUserInFirestore(withValues: [kPURCHASEDITEMIDS : newItemIds]) { (error) in
                if error != nil {
                    print("Error Adding Purchased Items ", error!.localizedDescription)
                }
                self.emptyTheBasket()
            }
        }
        
    }
    
    //MARK: Navigation
    
    private func showItemView(withItem: Item) {
        
        let itemVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "itemView") as! ItemViewController
        itemVC.item = withItem
        
        self.navigationController?.pushViewController(itemVC, animated: true)
        
    }
    
    //MARK: Control checkoutButton
    
    private func checkoutButtonStatusUpdate() {
        
        checkOutButtonOutlet.isEnabled = allItems.count > 0
        
        if checkOutButtonOutlet.isEnabled {
            checkOutButtonOutlet.backgroundColor = UIColor.red
        } else {
            disableCheckoutButton()
        }
        
    }
    
    private func disableCheckoutButton() {
        checkOutButtonOutlet.isEnabled = false
        checkOutButtonOutlet.backgroundColor = UIColor.darkGray
        
        
    }
    
    private func removeItemFromBasket(itemId: String) {
        
        for i in 0..<basket!.itemIds.count {
            
            if itemId == basket!.itemIds[i] {
                basket!.itemIds.remove(at: i)
                
                return
            }
        }
    }
    
    
    private func finishPayment(token: STPToken) {
        
        self.totalPrice = 0
        
        for item in allItems {
            purchasedItemIds.append(item.id)
            self.totalPrice += Int(item.price)
        }
        
        self.totalPrice = self.totalPrice * 100
        
        StripeClient.sharedClient.createAndConfirmPayment(token, amount: totalPrice) { (error) in
            
            if error == nil {
                
                self.addItemsToPurchaseHistory(self.purchasedItemIds)
              //  self.emptyTheBasket()
                //show notification
                self.showNotification(text: "Payment Succesful", isError: false)
            } else {
                self.showNotification(text: error!.localizedDescription, isError: true)
                print("Error ", error!.localizedDescription)
            }
        }
        
    }
    
    private func showNotification(text: String, isError: Bool) {
        
        if isError {
            
            self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
            
        } else {
            self.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
            
        }
        
        
        self.hud.textLabel.text = text
        self.hud.show(in: self.view)
        self.hud.dismiss(afterDelay: 2.0)
        
    }
    
    private func showPaymentOptions() {
        
        let alertController = UIAlertController(title: "Payment Options", message: "Choose Prefered Payment Option", preferredStyle: .actionSheet)
        
        let cardAction = UIAlertAction(title: "Pay With Card", style: .default) { (action) in
            
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "cardInfoVC") as! CardInfoViewController
            
            vc.delegate = self
            self.present(vc, animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(cardAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
        
    }
    
}

    extension BasketViewController: UITableViewDataSource, UITableViewDelegate {
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return allItems.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ItemTableViewCell
            
            cell.generateCell(allItems[indexPath.row])
            
            return cell
        }
        //MARK: UITableview Delegate
        
        func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
            return true
        }
        
        func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            
            if editingStyle == .delete {
                
                let itemToDelete = allItems[indexPath.row]
                
                allItems.remove(at: indexPath.row)
                tableView.reloadData()
                
                removeItemFromBasket(itemId: itemToDelete.id)
                
                updateBasketInFirestore(basket!, withValues: [kITEMIDS : basket!.itemIds]) { (error) in
                    
                    if error != nil {
                        print("Error Updating The Basket", error!.localizedDescription)
                    }
                    self.getBasketItems()
                }
            }
        }
        
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            
            tableView.deselectRow(at: indexPath, animated: true)
            showItemView(withItem: allItems[indexPath.row])
            
        }
    }
    

extension BasketViewController: CardInfoViewControllerDelegate {
    
    func didClickDone(_ token: StripePayments.STPToken) {
        finishPayment(token: token)
    }
    
    func didClickCancel() {
        showNotification(text: "Payment Canceled", isError: true)
    }
}

