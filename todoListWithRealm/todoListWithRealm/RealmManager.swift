import UIKit
import RealmSwift

class RealmManager {
    
    static let shared = RealmManager()
    let realm = try! Realm()
    
    
    func insertObject(desc: String) {
        let task = Task(desc: desc)
        
        try! realm.write({
            realm.add(task)
            print(task.desc)
        })
    }
    
    func editObject(eidtTextFiled: String, index: Int){
        let tasks = realm.objects(Task.self)
        
        try! realm.write({
            tasks[index].desc = eidtTextFiled
        })
    }
    
    func editManyObjectsThroughFloatingButton(selectedTasks: [Task]) {
        
        for selectedTask in selectedTasks {
            
            let theTask = realm.object(ofType: Task.self, forPrimaryKey: selectedTask.id)
            try! realm.write({
                theTask?.isDone.toggle()
            })
        }
    }
    
    func deleteObject(index: Int){
        let tasks = realm.objects(Task.self)
        
        try! realm.write({
            realm.delete(tasks[index])
        })
    }
    
    func deleteFinishedObjects() {
        let tasks = realm.objects(Task.self)
        try! realm.write({
            tasks.forEach { task in
                if task.isDone {
                    realm.delete(task)
                }
            }
        })
    }
    
    func reset(withTypes types: [Object.Type]) {
        try! realm.write {
            types.forEach { objectType in
                let objects = realm.objects(objectType)
                realm.delete(objects)
            }
        }
    }
     
    func getRealmLocation() {
        print("Realm Path : \(String(describing: realm.configuration.fileURL?.absoluteURL))")
    }
     
}
