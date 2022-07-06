//
//  ViewController.swift
//  TodoList
//
//  Created by 김소현 on 2022/07/05.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var editButton: UIBarButtonItem!
    // 메모리가 해제되지 않도록 strong으로 선언!
    
    var doneButton : UIBarButtonItem?
    
    var tasks = [Task](){
        didSet {
            self.saveTasks()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTap))
        self.doneButton?.tintColor = .darkGray
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.loadTasks()
    }
    
    @objc func doneButtonTap(){
        self.navigationItem.leftBarButtonItem = editButton
        self.tableView.setEditing(false, animated: true)
    }

    @IBAction func tapEditButton(_ sender: UIBarButtonItem) {
        guard !self.tasks.isEmpty else { return }
        self.navigationItem.leftBarButtonItem = doneButton
        self.tableView.setEditing(true, animated: true)
    }
    
    @IBAction func tapAddButton(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "오늘의 할 일은? 🐜", message: nil, preferredStyle: .alert)
        let registerButton = UIAlertAction(title: "🙆‍♀️", style: .default, handler: { [weak self]_ in
            // debugPrint("\(alert.textFields?[0].text)")
            guard let title = alert.textFields?[0].text else { return }
            let task = Task(title: title, done: false)
            self?.tasks.append(task)
            self?.tableView.reloadData()
        })
        let cancelButton = UIAlertAction(title: "🙅‍♀️", style: .cancel, handler: nil)
        alert.addAction(cancelButton)
        alert.addAction(registerButton)
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "개미의 할 일을 입력해주세요. :)"
        })
        self.present(alert, animated: true, completion: nil)
    }
    
    func saveTasks() {
        let data = self.tasks.map{
            [
                "title": $0.title,
                "done": $0.done
            ]
        }
        let userDefaults = UserDefaults.standard
        userDefaults.set(data, forKey: "tasks")
    }
    
    func loadTasks() {
        let userDefaults = UserDefaults.standard
        guard let data = userDefaults.object(forKey: "tasks") as? [[String: Any]] else { return }
        self.tasks = data.compactMap {
            guard let title = $0["title"] as? String else {return nil}
            guard let done = $0["done"] as? Bool else {return nil}
            return Task(title: title, done: done)
        }
    }
}

// 코드의 가독성을 위해 extension을 사용
extension ViewController: UITableViewDataSource {
    // UITableViewDataSource protocol을 사용하려면 아래의 두 함수를 꼭 정의해야 함
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // numberOfRowsInSection : 각 섹션에 표시할 행의 개수
        return self.tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let task = self.tasks[indexPath.row]
        cell.textLabel?.text = task.title
        
        if task.done {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        self.tasks.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        
        if self.tasks.isEmpty {
            self.doneButtonTap()
            // 모든 셀들이 삭제되면 편집 모드를 빠져나오도록
        }
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
        // 재정렬 가능하도록
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // table cell 이 재정렬 된 순서로, 할 일을 저장하는 배열도 재정렬 되도록
        var tasks = self.tasks
        let task = tasks[sourceIndexPath.row] // 배열의 indexPath에 접근
        tasks.remove(at: sourceIndexPath.row) // 원래 할 일을 삭제
        tasks.insert(task, at: destinationIndexPath.row)
        self.tasks = tasks // 재정렬된 배열을 넘겨준다.
    }
}

/*
 
  cellForRowAt : 특정 섹션의 n번째 row를 그리는데 필요한 cell을 반환하는 함수
 
  재사용 가능한 테이블뷰 객체를 반환하고, 이를 테이블 뷰에 추가하는 메소드
  큐를 활용하여 셀의 재사용을 함! 메모리 낭비를 방지하기 위하여 재사용
  스크롤을 내리는 과정에서, 셀의 재사용을 통해 1억개 데이터도 -> 셀 5개로 표현 가능
  withIdentifier 식별자를 통해 재사용 대상을 탐색, indexPath를 통해 필요에 의해 재사용을 계속함
  
 
 */


extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var task = self.tasks[indexPath.row]
        task.done = !task.done
        self.tasks[indexPath.row] = task
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}
