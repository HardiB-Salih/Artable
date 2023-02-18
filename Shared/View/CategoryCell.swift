//
//  CategoryCell.swift
//  Artable
//
//  Created by Hardi B. Salih on 16.02.2023.
//

import UIKit
import Kingfisher

class CategoryCell: UICollectionViewCell {
    
    @IBOutlet weak var categoryImg: UIImageView!
    @IBOutlet weak var categoryLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        categoryImg.layer.cornerRadius = 5
        categoryImg.layer.cornerCurve = .continuous
    }
    
    func configureCell(category: Category){
        
        categoryLbl.text = category.name
        if let url = URL(string: category.imgUrl) {
            let placeholder = UIImage(named: AppImages.Placeholder)
            categoryImg.kf.indicatorType = .activity
            let options : KingfisherOptionsInfo = [KingfisherOptionsInfoItem.transition(.fade(0.2))]
            categoryImg.kf.setImage(with: url, placeholder: placeholder, options: options)
        }
    }
}




