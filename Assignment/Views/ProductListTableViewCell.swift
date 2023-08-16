//
//  ProductListTableViewCell.swift
//  Assignment
//
//  Created by Obulisudharson on 14/08/23.
//

import UIKit

class ProductListTableViewCell: UITableViewCell {
    
    static let nib = UINib(nibName: "ProductListTableViewCell", bundle: nil)
    static let identifier = "ProductListTableViewCell"
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var imgViewThumbnail: UIImageView!
    @IBOutlet weak var lblDescriptioin: UILabel!
    @IBOutlet weak var lblRating: UILabel!
    @IBOutlet weak var lblRatingCount: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func populateData(item: ProductModel?) {

        self.lblName.text = item?.title
        self.lblPrice.text = "₹ \(item?.price ?? 0)"
        self.addCellThumbnail(imageUrl: item?.image)
        self.lblDescriptioin.text = item?.description
        self.lblRating.text = "\(item?.rate ?? 0)"
        self.lblRatingCount.text = "(\(item?.count ?? 0))"        
    }
    
    //adds thumbnail image for video cell
    func addCellThumbnail(imageUrl: String?) {
        imgViewThumbnail.contentMode = .scaleAspectFit
        self.imgViewThumbnail.image = UIImage.init(named: "productListHolder")
        if let imageUrl = imageUrl {
            ImageDownloader.shared.downloadImage(imageUrlString: imageUrl) {[weak self] (image, imageURLString) in
                DispatchQueue.main.async {
                    if let image = image, imageUrl == imageURLString {
                        self?.imgViewThumbnail.image = image
                    }
                    else {
                        self?.imgViewThumbnail.image = UIImage.init(named: "productListHolder")
                    }
                }
            }
        }
    }
    
}
