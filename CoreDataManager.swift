//
//  CoreDataManager.swift
//  CoreDataStack
//
//  Created by Varun Rathi on 08/05/19.
//  Copyright © 2019 Varun Rathi. All rights reserved.
//

import Foundation
import CoreData

public class CoreDataManager {

    private lazy var managedObjectModel :NSManagedObjectModel = {
        guard let modelURL = Bundle.main.url(forResource:self.modelName, withExtension:"momd") else {
            fatalError("Unable to find Data Model")
        }
        guard let managedModel = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Unable to load model")
        }
        return managedModel
    }()
    
    

    public let modelName:String?
    init(modelName:String) {
    self.modelName = modelName
}

}
