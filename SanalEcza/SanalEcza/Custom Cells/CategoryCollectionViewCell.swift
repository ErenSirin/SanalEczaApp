//
//  CategoryCollectionViewCell.swift
//  SanalEcza
//
//  Created by Cevher Şirin on 5.04.2023.
//

import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    func generateCell(_ category: Category) {
        
            nameLabel.text = category.name
            imageView.image = category.image
        
    }
    
    
}
