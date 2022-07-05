//
//  ViewController.swift
//  TodoList
//
//  Created by 김소현 on 2022/07/05.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var tasks = [Task]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
    }

    @IBAction func tapEditButton(_ sender: UIBarButtonItem) {

    }
    
    @IBAction func tapAddButton(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "할 일 등록", message: nil, preferredStyle: .alert)
        let registerButton = UIAlertAction(title: "등록", style: .default, handler: { [weak self]_ in
            // debugPrint("\(alert.textFields?[0].text)")
            guard let title = alert.textFields?[0].text else { return }
            let task = Task(title: title, done: false)
            self?.tasks.append(task)
            self?.tableView.reloadData()
        })
        let cancelButton = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alert.addAction(cancelButton)
        alert.addAction(registerButton)
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "할 일을 입력해주세요. :)"
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
        return cell
    }
}

/*
 
  cellForRowAt : 특정 섹션의 n번째 row를 그리는데 필요한 cell을 반환하는 함수
 
  재사용 가능한 테이블뷰 객체를 반환하고, 이를 테이블 뷰에 추가하는 메소드
  큐를 활용하여 셀의 재사용을 함! 메모리 낭비를 방지하기 위하여 재사용
  스크롤을 내리는 과정에서, 셀의 재사용을 통해 1억개 데이터도 -> 셀 5개로 표현 가능
  withIdentifier 식별자를 통해 재사용 대상을 탐색, indexPath를 통해 필요에 의해 재사용을 계속함
  
 
 */
