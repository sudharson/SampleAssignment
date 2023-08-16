//
//  ProductDetailViewController.swift
//  Assignment
//
//  Created by Obulisudharson on 16/08/23.
//

import UIKit

class ProductDetailViewController: UIViewController {

    @IBOutlet weak var productImgView: UIImageView!
    @IBOutlet weak var productPriceLbl: UILabel!
    @IBOutlet weak var productTitleLbl: UILabel!
    @IBOutlet weak var productRatingLbl: UILabel!
    @IBOutlet weak var productRatingCountLbl: UILabel!
    @IBOutlet weak var productDescriptionLbl: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var productDetails: ProductModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setNavigationItems()
        self.setupUI()
    }
    
    func setNavigationItems() {
        //set bar title
        self.title = NSLocalizedString("Product Details", comment: "")
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        navigationController?.navigationBar.backgroundColor = UIColor(red: 184.0/255.0, green: 35.0/255.0, blue: 142.0/255.0, alpha: 0.7)
    }
    
    func setupUI() {
        self.addBackButton()
        self.productTitleLbl.text = productDetails?.title
        self.productPriceLbl.text = "₹ \(productDetails?.price ?? 0)"
        self.productRatingLbl.text = "\(productDetails?.rate ?? 0)"
        self.productRatingCountLbl.text = "(\(productDetails?.count ?? 0))"
        self.productDescriptionLbl.text = productDetails?.description
        self.addProductImage(imageUrl: productDetails?.image)
        
    }
    
    func addProductImage(imageUrl: String?) {
        productImgView.contentMode = .scaleAspectFit
        self.productImgView.image = UIImage.init(named: "productListHolder")
        if let imageUrl = imageUrl {
            ImageDownloader.shared.downloadImage(imageUrlString: imageUrl) {[weak self] (image, imageURLString) in
                DispatchQueue.main.async {
                    if let image = image, imageUrl == imageURLString {
                        self?.productImgView.image = image
                    }
                    else {
                        self?.productImgView.image = UIImage.init(named: "productListHolder")
                    }
                }
            }
        }
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
