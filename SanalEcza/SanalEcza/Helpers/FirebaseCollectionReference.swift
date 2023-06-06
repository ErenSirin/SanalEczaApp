//
//  FirebaseCollectionReference.swift
//  SanalEcza
//
//  Created by Cevher Şirin on 5.04.2023.
//

import Foundation
import FirebaseFirestore

enum FCollectionReference: String {
    case User
    case Category
    case Items
    case Basket
    
}

func FirebaseReference(_ collectionReference: FCollectionReference) ->
    CollectionReference {
        
        return Firestore.firestore().collection(collectionReference.rawValue)
    
}
