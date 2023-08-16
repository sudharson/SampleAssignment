//
//  Extensions.swift
//  Assignment
//
//  Created by Obulisudharson on 14/08/23.
//

import UIKit
import Foundation

extension UIAlertController {
    
    class func showError(message: String, from viewController: UIViewController?, alertAction: UIAlertAction? = nil) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        if let action = alertAction {
            alert.addAction(action)
        } else {
            let action = UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .cancel, handler: nil)
            alert.addAction(action)
        }
        viewController?.present(alert, animated: true, completion: nil)
    }
}

extension NSObject {
    
    class var name: String {
        return String(describing: self)
    }
}

extension UIView {
    
    func applyViewGradient(colors: [CGColor], opacity: Float) {
        let gradientLayer = CAGradientLayer()
        var frame = self.bounds
        frame.size.width = UIScreen.main.bounds.size.width
        gradientLayer.frame = frame
        gradientLayer.colors = colors
        gradientLayer.opacity = opacity
        gradientLayer.startPoint = CGPoint.init(x: 0.0, y: 0.0)
        gradientLayer.endPoint   = CGPoint.init(x: 0.0, y: 1.0)
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
}

extension UIColor {
    
    static func getDefaultColor()-> UIColor {
        return UIColor(red: 153.0/255, green: 35.0/255, blue: 118.0/255, alpha: 1.0)
    }
}

extension UITableView {
    
    func showEmptyAlert() {
        
        let label = UILabel(frame: CGRect(x: 0, y: self.center.y - 100, width: self.frame.width, height: 200))
        label.text = NSLocalizedString("DataEmpty", comment: "")
        label.font = UIFont.boldSystemFont(ofSize: 17.0)
        label.numberOfLines = 2
        label.textColor = UIColor.darkGray
        label.textAlignment = .center
        self.backgroundView = label
        self.separatorStyle = .none
    }
    
    func removeEmptyAlert() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
}

