import UIKit
import RealmSwift

class Task:Object {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var desc:String = ""
    @Persisted var createdAt:String = ""
    @Persisted var isDone:Bool = false
    
     convenience init(desc: String) {
        self.init()
         
        let df = DateFormatter()
        df.dateFormat = "yyyy/MM/dd"
        self.createdAt = df.string(from: Date())
        self.desc = desc
    }
}



