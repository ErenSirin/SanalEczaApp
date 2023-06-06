//
//  Category.swift
//  SanalEcza
//
//  Created by Cevher Şirin on 5.04.2023.
//

import Foundation
import UIKit

class Category {
    
    var id: String
    var name: String
    var image: UIImage?
    var imageName: String?
    
    init(_name: String, _imageName: String) {
        
        id = ""
        name = _name
        imageName = _imageName
        image = UIImage(named: _imageName)
    }
    
    init(_dictionary: NSDictionary) {
        id = _dictionary[kOBJECTID] as! String
        name = _dictionary[kNAME] as! String
        image = UIImage(named: _dictionary[kIMAGENAME] as? String ?? "")
        
    }
    
}

// Download category from firebase

func downloadCategoriesFromFirebase(completion: @escaping (_ categoryArray: [Category]) -> Void) {
    
    var categoryArray : [Category] = []
    FirebaseReference(.Category).getDocuments { (snapshot, error) in
        
        guard let snapshot = snapshot else {
            completion(categoryArray)
            return
        }
        
        if !snapshot.isEmpty {
            
            for categoryDict in snapshot.documents {
                
                categoryArray.append(Category(_dictionary: categoryDict.data() as NSDictionary))
            }
            
        }
        
        completion(categoryArray)
        
    }
    
}



// Save category function

func saveCategoryToFirebase(_ category: Category) {
    
    let id = UUID().uuidString
    category.id = id
    
    FirebaseReference(.Category).document(id).setData(categoryDictionaryFrom(category) as! [String : Any])
}

// HELPERS

func categoryDictionaryFrom(_ category: Category) -> NSDictionary {
    
return NSDictionary(objects: [category.id, category.name, category.imageName],
            forKeys: [kOBJECTID as NSCopying, kNAME as NSCopying, kIMAGENAME as NSCopying])
    
}

// use only one time
//func createCategorySet() {
    
//   let OverTheCounterMedicine = Category(_name: "Over The Counter Medicine", _imageName: "CounterMedicine")
    
   // let PrescriptionMedicine = Category(_name: "Prescription Medicine", _imageName: "Prescription-Medicine")
    
//   let  VitaminsAndSupplements = Category(_name: "Vitamins and Supplements", _imageName: "VitaminsSupplements")
    
//   let ElectronicDevices = Category(_name: "Electronic Devices", _imageName: "Electronics")
    
//   let FirstAidProducts = Category(_name: "First Aid Products", _imageName: "FirstAid")
    
//  let HygieneProducts = Category(_name: "Hygiene Products", _imageName: "Hygiene")
    
//    let BabyProducts = Category(_name: "Baby Products", _imageName: "Baby")
    
//    let arrayOfCategories = [OverTheCounterMedicine, VitaminsAndSupplements, ElectronicDevices, FirstAidProducts, HygieneProducts, BabyProducts]
    
//   for category in arrayOfCategories {
//       saveCategoryToFirebase(cate)
//  }
    
    
    
//   }
