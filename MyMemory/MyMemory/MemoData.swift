//
//  MemoData.swift
//  MyMemory
//
//  Created by bigzero on 2021/07/16.
//

import UIKit
import CoreData

class MemoData {
    var memoIdx : Int?
    var title : String?
    var contents : String?
    var image : UIImage?
    var regdate : Date?

    var objectID: NSManagedObjectID?
}
