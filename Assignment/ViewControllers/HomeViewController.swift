//
//  HomeViewController.swift
//  Assignment
//
//  Created by Obulisudharson on 16/08/23.
//

import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func groupedListBtnClick(_ sender: Any) {
        //ProductListViewController
        if let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ProductListViewController") as? ProductListViewController {
            vc.productListViewModel = ProductListViewModel()
            vc.isGroupedList = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    @IBAction func listBtnClick(_ sender: Any) {
        if let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ProductListViewController") as? ProductListViewController {
            vc.productListViewModel = ProductListViewModel()
            vc.isGroupedList = false
            self.navigationController?.pushViewController(vc, animated: true)
        }
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
