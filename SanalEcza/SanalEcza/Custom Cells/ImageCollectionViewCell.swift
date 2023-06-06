//
//  ImageCollectionViewCell.swift
//  SanalEcza
//
//  Created by Cevher Şirin on 18.04.2023.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    func setupImageWith(itemImage: UIImage) {
        
        imageView.image = itemImage
    }
    
    
}
