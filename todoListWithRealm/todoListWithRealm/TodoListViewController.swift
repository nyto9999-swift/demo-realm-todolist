import UIKit

class TodoListViewController: UIViewController {
    
    let localRealm = RealmManager.shared
    var tasks = [Task]()
    let backgroundColor:UIColor = .systemGray6
    
    lazy var floatingButton: UIButton = {
        let btnSize:CGFloat = 50
        let margin:CGFloat = 18
        let btn = UIButton(frame: CGRect(x: view.frame.size.width - btnSize - margin, y: view.frame.size.height - btnSize - margin, width: btnSize, height: btnSize ))
        btn.backgroundColor = .systemOrange
        let image = UIImage(systemName: "checkmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25, weight: .medium))
        btn.setImage(image, for: .normal)
        btn.tintColor = .white
        btn.setTitleColor(.white, for: .normal )
        btn.addTarget(self, action: #selector(tappedFloatingButton), for: .touchUpInside)
        //corner & shadow
        btn.isHidden = true
        btn.layer.cornerRadius = 25
        btn.layer.shadowRadius = 7
        btn.layer.shadowOpacity = 0.3
        return btn
    }()
    
    lazy var tableView:UITableView = {
        let tableview = UITableView(frame: view.frame)
        tableview.allowsMultipleSelectionDuringEditing = false
        tableview.allowsMultipleSelection = true
        tableview.tintColor = .systemOrange
        tableview.backgroundColor = backgroundColor
        tableview.register(TodoListTableViewCell.self,
                           forCellReuseIdentifier: "cell")
        tableview.separatorColor = .clear
        return tableview
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tasks = Array(self.localRealm.realm.objects(Task.self))
        localRealm.getRealmLocation()
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(tappedPlusButton)),
            UIBarButtonItem(image: UIImage(systemName: "trash"), style: .done, target: self, action: #selector(tappedTrashButton))
        ]
        
        tableView.backgroundColor = backgroundColor
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
             navigationController?.navigationBar.shadowImage = UIImage()
             navigationController?.navigationBar.isTranslucent = true
             navigationController?.navigationBar.tintColor = .systemOrange
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        view.addSubview(tableView)
        view.addSubview(floatingButton)
    }
    
    
    //MARK: @objc
    @objc func tappedTrashButton() {
        self.localRealm.deleteFinishedObjects()
        self.tasks = Array(self.localRealm.realm.objects(Task.self))
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    @objc func tappedPlusButton() {
        let alert = UIAlertController(title: "新增", message: "新增任務", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "新增任務"
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            print("Text field: \(String(describing: textField!.text))")
            
            self.localRealm.insertObject(desc: (textField?.text!)!)
            self.tasks = Array(self.localRealm.realm.objects(Task.self))
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    @objc func tappedFloatingButton() {
        
        if let selectedRows = tableView.indexPathsForSelectedRows {
            var theseTasksAreDone:[Task] = []
            for ix in selectedRows {
                theseTasksAreDone.append(tasks[ix[1]])
                print(ix)
            }
            self.localRealm.editManyObjectsThroughFloatingButton(selectedTasks: theseTasksAreDone)
            self.tasks = Array(self.localRealm.realm.objects(Task.self))
            DispatchQueue.main.async {
                
                
                self.tableView.reloadData()
                self.floatingButton.isHidden = true
            }
        }
    }
}

extension TodoListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TodoListTableViewCell

        cell.accessoryType = (tasks[indexPath.row].isDone) ? .checkmark : .none
        cell.backgroundColor = backgroundColor
        
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.3)
        cell.selectedBackgroundView = bgColorView
        
        cell.configure(task: tasks[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        
        let deleteAction = UIContextualAction(style: .normal, title: "Delete") { action, view, handler in
            self.localRealm.deleteObject(index: indexPath.row)
            self.tasks = Array(self.localRealm.realm.objects(Task.self))
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            handler(true)
        }
        deleteAction.backgroundColor = .systemOrange

        let editAction = UIContextualAction(style: .normal, title: "Edit") { action, view, handler in
            let alert = UIAlertController(title: "編輯", message: "開始編輯", preferredStyle: .alert)
            
            alert.addTextField { textField in
                textField.text = self.tasks[indexPath.row].desc
            }
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                let textField = alert?.textFields![0]
                self.localRealm.editObject(eidtTextFiled: (textField?.text!)!, index: indexPath.row)
                
                self.tasks = Array(self.localRealm.realm.objects(Task.self))
                DispatchQueue.main.async {
                    
                    self.tableView.reloadData()
                }
            }))
            self.present(alert, animated: true, completion: nil)
            
            handler(true)
        }
        editAction.backgroundColor = .systemBrown
        
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.floatingButton.isHidden = false
        UIView.animate(withDuration: 0.4) {
            tableView.cellForRow(at: indexPath)?.accessoryType = (tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark) ? .none : .checkmark
            tableView.cellForRow(at: indexPath)?.layoutIfNeeded()
       }
      
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        self.floatingButton.isHidden = true
        
        tableView.cellForRow(at: indexPath)?.accessoryType = (tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark) ? .none : .checkmark
    }
}
