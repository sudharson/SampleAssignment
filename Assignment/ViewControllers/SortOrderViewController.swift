//
//  SortOrderViewController.swift
//  Assignment
//
//  Created by Obulisudharson on 16/08/23.
//

import UIKit

protocol SortOrderViewControllerDelegate {
    func selectedSortOrder(type: Int)
}

class SortOrderViewController: UIViewController {
    
    @IBOutlet weak var sortListTableView: UITableView!
    var sortByList: Array<String>?
    var delegate: SortOrderViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        sortListTableView.register(UITableViewCell.self,
                               forCellReuseIdentifier: "TableViewCell")
        sortByList = ["Name: A -> Z", "Name: Z -> A", "Price: Low -> High", "Price: High -> Low", "Rating"]
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: - UITableView Data Source
extension SortOrderViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sortByList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell",
                                                 for: indexPath)
        cell.textLabel?.text = self.sortByList?[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Sort By"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.selectedSortOrder(type: indexPath.row)
        self.dismiss(animated: true)
    }
    
}
