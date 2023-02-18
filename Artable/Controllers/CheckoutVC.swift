//
//  CheckoutVC.swift
//  Artable
//
//  Created by Hardi B. Salih on 18.02.2023.
//

import UIKit
import Stripe
import FirebaseFunctions
import PassKit


class CheckoutVC: UIViewController, CartItemDelegate {
    // Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var paymentMethodBtn: UIButton!
    @IBOutlet weak var shippingMethodBtn: UIButton!
    @IBOutlet weak var subtotalLbl: UILabel!
    @IBOutlet weak var processingFeeLbl: UILabel!
    @IBOutlet weak var shippingCostLbl: UILabel!
    @IBOutlet weak var totalLbl: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // Variables
    var paymentContext: STPPaymentContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupPaymentInfo()
        setupStripeConfig()
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: Identifiers.CartItemCell, bundle: nil), forCellReuseIdentifier: Identifiers.CartItemCell)
    }
    
    func setupPaymentInfo() {
        subtotalLbl.text = StripeCart.subtotal.penniesToFormattedCurrency()
        processingFeeLbl.text = StripeCart.processingFees.penniesToFormattedCurrency()
        shippingCostLbl.text = StripeCart.shippingFees.penniesToFormattedCurrency()
        totalLbl.text = StripeCart.total.penniesToFormattedCurrency()
    }
    
    func setupStripeConfig() {
        let config = STPPaymentConfiguration.shared
        config.requiredBillingAddressFields = .none
        config.requiredShippingAddressFields = [.postalAddress]

        let customerContext = STPCustomerContext(keyProvider: StripeApi)
        paymentContext = STPPaymentContext(customerContext: customerContext, configuration: config, theme: .defaultTheme)

        paymentContext.paymentAmount = StripeCart.total
        paymentContext.delegate = self
        paymentContext.hostViewController = self
    }
    
    @IBAction func placeOrderClicked(_ sender: Any) {
        paymentContext.requestPayment()
        activityIndicator.startAnimating()
    }
    
    @IBAction func paymentMethodClicked(_ sender: Any) {
        paymentContext.pushPaymentOptionsViewController()
    }
    
    @IBAction func shippingMethodClicked(_ sender: Any) {
        paymentContext.pushShippingViewController()
    }
    
    func removeItem(product: Product) {
        StripeCart.removeItemFromCart(item: product)
        tableView.reloadData()
        setupPaymentInfo()
        paymentContext.paymentAmount = StripeCart.total
    }
}

extension CheckoutVC : STPPaymentContextDelegate {
    
    func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
        
        // Updating the selected payment method
        if let paymentMethod = paymentContext.selectedPaymentOption {
            paymentMethodBtn.setTitle(paymentMethod.label, for: .normal)
        } else {
            paymentMethodBtn.setTitle("Select Method", for: .normal)
        }
        
        // Updating the selected shipping method
        if let shippingMethod = paymentContext.selectedShippingMethod {
            shippingMethodBtn.setTitle(shippingMethod.label, for: .normal)
            StripeCart.shippingFees = Int(Double(truncating: shippingMethod.amount) * 100)
            setupPaymentInfo()
        } else {
            shippingMethodBtn.setTitle("Select Method", for: .normal)
        }
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPPaymentStatusBlock) {
        let idempotency = UUID().uuidString.replacingOccurrences(of: "-", with: "")
        
        let data : [String: Any] = [
            "total" : StripeCart.total,
            "customer_id" : UserService.user.stripeId,
            "idempotency" : idempotency
        ]

        Functions.functions().httpsCallable("createPaymentIntent").call(data) { (result, error) in

            if let error = error {
                debugPrint(error.localizedDescription)
                self.simpleAlert(title: "Error", msg: "Unable to make charge.")
                completion(STPPaymentStatus.error, error)
                return
            }
            
            
            // Request Stripe payment intent, and return client secret.
            guard let clientSecret = result?.data as? String else {
                return
            }
            
            // The client secret can be used to complete a payment from your frontend.
            // Once the client secret is obtained, create paymentIntentParams
            let paymentIntentParams = STPPaymentIntentParams(clientSecret: clientSecret)
            paymentIntentParams.paymentMethodId = paymentResult.paymentMethod?.stripeId
            
            // Confirm the PaymentIntent
            STPPaymentHandler.shared().confirmPayment(paymentIntentParams, with: paymentContext) { status, paymentIntent, error in
                switch status {
                case .succeeded:
                    StripeCart.clearCart()
                    self.tableView.reloadData()
                    self.setupPaymentInfo()
                    completion(.success, nil)
                case .failed:
                    completion(.error, error)
                case .canceled:
                    completion(.userCancellation, nil)
                @unknown default:
                    completion(.error, nil)
                }
            }
        }
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFinishWith status: STPPaymentStatus, error: Error?) {
        let title: String
        let message: String
        
        activityIndicator.stopAnimating()
        
        switch status {
        case .error:
            title = "Error"
            message = error?.localizedDescription ?? ""
        case .success:
            title = "Success!"
            message = "Thank you for your purchase."
        case .userCancellation:
            return
        }
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default) { (action) in
            self.navigationController?.popViewController(animated: true)
        }
        
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFailToLoadWithError error: Error) {
        activityIndicator.stopAnimating()
        
        let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            self.navigationController?.popViewController(animated: true)
        }
        let retry = UIAlertAction(title: "Retry", style: .default) { (action) in
            self.paymentContext.retryLoading()
        }
        
        alertController.addAction(cancel)
        alertController.addAction(retry)
        present(alertController, animated: true, completion: nil)
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didUpdateShippingAddress address: STPAddress, completion: @escaping STPShippingMethodsCompletionBlock) {
        
        let upsGround = PKShippingMethod()
        upsGround.amount = 0
        upsGround.label = "UPS Ground"
        upsGround.detail = "Arrives in 3-5 days"
        upsGround.identifier = "ups_ground"

        let fedEx = PKShippingMethod()
        fedEx.amount = 6.99
        fedEx.label = "FedEx"
        fedEx.detail = "Arrives tomorrow"
        fedEx.identifier = "fedex"

        if address.country == "US" {
            completion(.valid, nil, [upsGround, fedEx], fedEx)
        } else {
            completion(.invalid, nil, nil, nil)
        }
    }
}

extension CheckoutVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StripeCart.cartItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.CartItemCell, for: indexPath) as? CartItemCell {
            
            let product = StripeCart.cartItems[indexPath.row]
            cell.configureCell(product: product, delegate: self)
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}
