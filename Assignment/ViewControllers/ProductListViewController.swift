//
//  ProductListViewController.swift
//  Assignment
//
//  Created by Obulisudharson on 14/08/23.
//

import UIKit
import CoreData

class ProductListViewController: UIViewController {
    
    var productListViewModel : ProductListViewModel?
    @IBOutlet weak var productsTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    private let searchController = UISearchController(searchResultsController: nil)
    var isDataLoading = false
    var indicator: UIActivityIndicatorView?
    var isGroupedList: Bool?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setNavigationItems()
        self.setupUI()
        self.registerCells()
        self.getProducts(searchKeyword: "")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.backgroundColor = .clear
    }
    
    func setNavigationItems() {
        //set bar title
        self.title = NSLocalizedString("List", comment: "")
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
    }
   
    func setupUI() {
        self.productListViewModel?.isGrouped = self.isGroupedList
        self.addBackButton()
        self.addSortButton()
        self.setupSearchBar()
        self.view.layoutIfNeeded()
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: productsTableView.frame.width, height: 50))
        let indicatorFrame = CGRect(x:0, y:0, width:44, height: 44)
        self.indicator = UIActivityIndicatorView.init(frame : indicatorFrame)
        self.indicator?.center = footerView.center
        self.indicator?.color = UIColor.getDefaultColor()
        footerView.addSubview(self.indicator!)
        footerView.backgroundColor = UIColor.clear
        self.productsTableView.tableFooterView = footerView
    }
    
    private func setupSearchBar() {
        searchController.searchBar.delegate = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search for Products"
        searchController.searchBar.barTintColor = UIColor.white
        searchController.searchBar.returnKeyType = .done
        definesPresentationContext = true
        self.productsTableView.tableHeaderView = searchController.searchBar
    }
    
    func registerCells() {
        productsTableView.register(ProductListTableViewCell.nib, forCellReuseIdentifier: ProductListTableViewCell.identifier)
    }
    
    func addBackButton(){
        let backButtonView = UIView.init(frame: CGRect(x: 0, y: 0, width: 52, height: 52))
        let backButton = UIButton.init(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
        backButton.addTarget(self, action: #selector(self.backButtonTapped(button:)), for: .touchUpInside)
        backButton.layer.cornerRadius = backButton.frame.width / 2
        backButton.backgroundColor = UIColor.clear
        let backImage = UIImage.init(named: "backButton")
        backButton.setImage(backImage, for: .normal)
        backButtonView.backgroundColor = UIColor.clear
        backButtonView.addSubview(backButton)
        let navBarButtonItem = UIBarButtonItem()
        navBarButtonItem.customView = backButtonView
        self.navigationItem.leftBarButtonItem = navBarButtonItem
        
    }
    
    @objc func backButtonTapped(button: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func addSortButton() {
        let sortButtonView = UIView.init(frame: CGRect(x: 0, y: 0, width: 62, height: 52))
        let sortButton = UIButton.init(frame: CGRect(x: 0, y: 5, width:55, height: 30))
        sortButton.addTarget(self, action: #selector(self.sortButtonTapped(button:)), for: .touchUpInside)
        sortButton.backgroundColor = UIColor(red: 184.0/255.0, green: 35.0/255.0, blue: 142.0/255.0, alpha: 1.0)
        sortButton.layer.cornerRadius = 4
        sortButton.setTitle("Sort By", for: .normal)
        sortButton.setTitleColor(UIColor.white, for: .normal)
        sortButton.titleLabel?.font = .systemFont(ofSize: 14.0)
        sortButtonView.backgroundColor = UIColor.clear
        sortButtonView.addSubview(sortButton)
        let navBarButtonItem = UIBarButtonItem()
        navBarButtonItem.customView = sortButtonView
        self.navigationItem.rightBarButtonItem = navBarButtonItem
    }
    
    @objc func sortButtonTapped(button: UIButton) {
        if let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SortOrderViewController") as? SortOrderViewController {
            vc.delegate = self
            self.navigationController?.present(vc, animated: true)
        }
    }

    @objc func getProducts(searchKeyword: String) {
        if let reachability = Reachability(), reachability.isReachable == false {
            UIAlertController.showError(message: NSLocalizedString("GenericNetworkError", comment: ""), from: self)
            return
        }
        self.indicator?.startAnimating()
        /*** initial search ***/
        /*** for initial loading, default keyword "Batman" is selected inside VM ***/
        productListViewModel?.getProductList(searchKeyword: searchKeyword, completionHandler: {[weak self] (error, isChanged) in
            DispatchQueue.main.async { () -> Void in
                self?.indicator?.stopAnimating()
                if isChanged == true {
                    self?.productsTableView.reloadData()
                    if(self?.productListViewModel?.itemsNew?.count ?? 0) == 0 {
                        self?.productsTableView.showEmptyAlert()
                    }
                    else {
                        self?.productsTableView.removeEmptyAlert()
                    }
                }
                if let error = error {
                    UIAlertController.showError(message: error.localizedDescription, from: self)
                }
            }
        })
    }
    
    func navigateToProductDetails(product: ProductModel?) {
        if let product = product {
            if let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ProductDetailViewController") as? ProductDetailViewController {
                vc.productDetails = product
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
    }

}

// MARK: - UITableView Data Source
extension ProductListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if (isGroupedList ?? false) == true {
            return productListViewModel?.itemsNew?.count ?? 0
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (isGroupedList ?? false) == true {
            return productListViewModel?.itemsNew?[section].values.count ?? 0
        } else {
            return productListViewModel?.items.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ProductListTableViewCell.identifier,
                                                       for: indexPath) as? ProductListTableViewCell else {
                                                        fatalError("Unable to dequeue ContactTableViewCell.")
        }
        if (isGroupedList ?? false) == true {
            cell.populateData(item: productListViewModel?.itemsNew?[indexPath.section].values[indexPath.row])
        } else {
            cell.populateData(item: productListViewModel?.items[indexPath.row])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 188
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (isGroupedList ?? false) == true {
            return 50
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 50))
        
        let label = UILabel()
        label.frame = CGRect.init(x: 5, y: 5, width: headerView.frame.width-10, height: headerView.frame.height-10)
        label.text = productListViewModel?.itemsNew?[section].key.uppercased() ?? ""
        label.font = .systemFont(ofSize: 16)
        label.textColor = .darkGray
        headerView.backgroundColor = .white
        headerView.addSubview(label)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let product: ProductModel?
        if (isGroupedList ?? false) == true {
            product = productListViewModel?.itemsNew?[indexPath.section].values[indexPath.row]
        } else {
            product = productListViewModel?.items[indexPath.row]
        }
        self.navigateToProductDetails(product: product)
    }
    
}

extension ProductListViewController: UIScrollViewDelegate {

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isDataLoading = false
    }

    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        isDataLoading = false
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.isDragging == false {
            // In case of pagination API can be called from here
        }
    }

    //Pagination
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false {
            // In case of pagination API can be called from here
        }
    }
}

extension ProductListViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let textToSearch = searchBar.text, textToSearch.count >= 3 else {
            if (searchBar.text?.isEmpty == true) {
                productListViewModel?.searchKeyWord = ""
                self.perform(#selector(getProducts(searchKeyword:)), with: "", afterDelay: 0.5)
            }
            return
        }
        /*** request for searched data ***/
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(getProducts(searchKeyword:)), object: productListViewModel?.searchKeyWord)
        productListViewModel?.searchKeyWord = textToSearch
        self.perform(#selector(getProducts(searchKeyword:)), with: textToSearch, afterDelay: 0.5)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        productListViewModel?.searchKeyWord = ""
        self.perform(#selector(getProducts(searchKeyword:)), with: "", afterDelay: 0.5)
    }
}

extension ProductListViewController: SortOrderViewControllerDelegate {
    func selectedSortOrder(type: Int) {
        switch type {
        case 0:
            productListViewModel?.sortByNameAscending()
        case 1:
            productListViewModel?.sortByNameDescending()
        case 2:
            productListViewModel?.sortByAscendingOrder()
        case 3:
            productListViewModel?.sortByDescendingOrder()
        case 4:
            productListViewModel?.sortByRatingAscending()
        default:
            productListViewModel?.sortByNameAscending()
        }
        self.productsTableView.reloadData()

    }
}

