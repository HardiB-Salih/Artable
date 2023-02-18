//
//  CartItemCell.swift
//  Artable
//
//  Created by Hardi B. Salih on 18.02.2023.
//

import UIKit

protocol CartItemDelegate : AnyObject {
    func removeItem(product: Product)
}

class CartItemCell: UITableViewCell {
    // Outlets
    @IBOutlet weak var productImg: RoundedImageView!
    @IBOutlet weak var productTitleLbl: UILabel!
    @IBOutlet weak var removeItemBtn: UIButton!
    
    // Variables
    private var item: Product!
    weak var delegate : CartItemDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCell(product: Product, delegate: CartItemDelegate) {
        self.delegate = delegate
        self.item = product
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        
        if let price = formatter.string(from: product.price as NSNumber) {
            productTitleLbl.text = "\(product.name) \(price)"
        }
        
        if let url = URL(string: product.imageUrl) {
            productImg.kf.setImage(with: url)
        }
    }

    
    @IBAction func removeItemClicked(_ sender: Any) {
        delegate?.removeItem(product: item)
    }
}
