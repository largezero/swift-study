//
// Created by bigzero on 2021/08/22.
//

import UIKit
import CoreData

class MemoDAO {
    lazy var context: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }()

    func fetch(keyword text: String? = nil) -> [MemoData] {
        var memoList = [MemoData]()

        // 1. 요청 객체 생성
        let fetchRequest: NSFetchRequest<MemoMO> = MemoMO.fetchRequest()

        // 1-1. 최신 글 순으로 정렬하도록 정렬 객체 생성
        let regdateDesc = NSSortDescriptor(key: "regdate", ascending: false)
        fetchRequest.sortDescriptors = [regdateDesc]

        // 1-2. 검색 키워드가 있을 경우 검색 조건 추가
        if let t = text, t.isEmpty == false {
            fetchRequest.predicate = NSPredicate(format: "contents CONTAINS[c] %@", t)
        }

        do {
            let resultset = try context.fetch(fetchRequest)

            // 2. 읽어온 결과 집합을 순회하면서 [MemoData] 타입으로 변환한다.
            for record in resultset {
                // 3. MemoData 객체를 생성한다.
                let data = MemoData()
                // 4. MemoMO 프로퍼티 값을 MemoData 의 프로퍼티로 복사
                data.title = record.title
                data.contents = record.contents
                data.regdate = record.regdate
                data.objectID = record.objectID
                // 4-1 이미지가 있을 때만 복사
                if let image = record.image as Data? {
                    data.image = UIImage(data: image)
                }
                // 5. MemoData 객체를 memoList 배열에 추가
                memoList.append(data)
            }
        } catch let e as NSError {
            NSLog("An error has occured : %s", e.localizedDescription)
        }
        return memoList
    }

    func insert(_ data: MemoData) {
        // 1. 관리 객체 인스턴스 생성
        let object = NSEntityDescription.insertNewObject(forEntityName: "Memo", into: context) as! MemoMO
        // 2. MemomData 로 부터 값을 복사
        object.title = data.title
        object.contents = data.contents
        object.regdate = data.regdate

        if let image = data.image {
            object.image = UIImage.pngData(image)()!
        }
        // 3. 영구 저장소에 변경 사항을 반영한다.
        do {
            try context.save()
        } catch let e as NSError {
            NSLog("An error has occured : %s", e.localizedDescription)
        }
    }

    func delete(_ objectID: NSManagedObjectID) -> Bool {
        // 삭제할 객체를 찾아 컨텍스트에서 삭제
        let object = context.object(with: objectID)
        context.delete(object)

        do {
            try context.save()
            return true
        } catch let e as NSError {
            NSLog("An error has occured : %s", e.localizedDescription)
            return false
        }
    }


}