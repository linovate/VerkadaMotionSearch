//  CustomCell.swift
//  VerkadaMotionSearch
//  Created by lordofming on 4/4/19.
//  Copyright © 2019 lordofming. All rights reserved.

import UIKit

class CustomCell: UITableViewCell {
    
    let cellView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Default Text"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = UIColor.black
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        
        return label
    }()
    
    let subTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "default text"
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.textColor = UIColor.gray
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        return label
    }()
    
    //    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    func setup() {
        
        backgroundColor = UIColor(red: 245, green: 245, blue: 245, alpha: 1)
        
        addSubview(cellView)
        cellView.addSubview(titleLabel)
        cellView.addSubview(subTitleLabel)
        
        cellView.setAnchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 4, paddingLeft: 8, paddingBottom: 4, paddingRight: 8)
        
        titleLabel.setAnchor(top: cellView.topAnchor, left: cellView.leftAnchor, bottom: subTitleLabel.topAnchor, right: cellView.rightAnchor, paddingTop: 5, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, height: 50)
        
        subTitleLabel.setAnchor(top: titleLabel.bottomAnchor, left: cellView.leftAnchor, bottom: cellView.bottomAnchor, right: cellView.rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 8, paddingRight: 8, height: 20)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


extension UIView {
    
    func setAnchor(top: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?,
                   bottom: NSLayoutYAxisAnchor?, right: NSLayoutXAxisAnchor?,
                   paddingTop: CGFloat, paddingLeft: CGFloat, paddingBottom: CGFloat,
                   paddingRight: CGFloat, width: CGFloat = 0, height: CGFloat = 0) {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        
        if let left = left {
            self.leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        
        if let bottom = bottom {
            self.bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        
        if let right = right {
            self.rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        
        if width != 0 {
            self.widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if height != 0 {
            self.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
    
    /*
      Tell Xcode you want code to execute only on iOS 11.0 or later
      ref: https://www.hackingwithswift.com/new-syntax-swift-2-availability-checking
     more on this:
     In that code, #available is going to check whether we're on iOS 9 or later, or any other unknown platforms like watchOS – that's the * at the end, and it's required. And that's it: all the code you'll put in place of "// use UIStackView" effectively has elevated rights to use iOS 9.0-only technology, whether that's classes, methods or enums.
     
     If code inside a method should only be run on certain iOS versions, you can also use #available with guard to produce code like this:
     
     guard #available(iOS 9, *) else {
     return
     }
     
     The power of #available is that the compiler can now check and enforce API usage on older operating systems, which previously was entirely human – it's a huge improvement, and one I know will catch on quickly.
     */
    var safeTopAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return safeAreaLayoutGuide.topAnchor
        }
        return topAnchor
    }
    
    var safeLeftAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *) {
            return safeAreaLayoutGuide.leftAnchor
        }
        return leftAnchor
    }
    
    var safeBottomAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return safeAreaLayoutGuide.bottomAnchor
        }
        return bottomAnchor
    }
    
    var safeRightAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *) {
            return safeAreaLayoutGuide.rightAnchor
        }
        return rightAnchor
    }
    
}
