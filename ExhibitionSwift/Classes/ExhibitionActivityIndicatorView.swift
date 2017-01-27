//
//  ExhibitionActivityIndicatorView.swift
//  Exhibition
//
//  Created by Eli Gregory on 12/27/16.
//  Copyright © 2016 Eli Gregory. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

public typealias XActivityView = ExhibitionActivityIndicatorView

public class ExhibitionActivityIndicatorView: UIView {
    
    let activity: UIActivityIndicatorView
    
    public init(sized: CGFloat = 30.0, config: ExhibitionConfig) {
        
        // Scaling
        let minSize = CGFloat(30.0)
        let size = max(sized, minSize)
        let scale = ((size / 1.5) / 20.0)
        
        // Scale Activity Indicator
        self.activity = UIActivityIndicatorView(activityIndicatorStyle: .white)
        self.activity.transform = CGAffineTransform(scaleX: scale, y: scale)
        self.activity.sizeToFit()
        self.activity.clipsToBounds = false
        self.activity.layer.masksToBounds = false
        
        // Init
        super.init(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: size, height: size)))
        
        // Visuals
        self.layer.cornerRadius = sized / 2.0
        self.backgroundColor = config.activityTheme.backgroundColor
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowRadius = 5.0
        self.activity.color = config.activityTheme.foregroundColor
        
        // Subview
        self.addSubview(self.activity)
        
        self.activity.center = self.center
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        activity.removeFromSuperview()
    }
}

extension ExhibitionActivityIndicatorView: ExhibititionActivityIndicatorViewProtocol {
    
    public func startAnimating() {
        self.alpha = 1.0
        self.activity.startAnimating()
    }
    
    public func stopAnimating() {
        self.activity.stopAnimating()
        self.hide()
    }
    
    public func hide() {
        self.alpha = 0.0
    }
}

public typealias XActivityProtocol = ExhibititionActivityIndicatorViewProtocol

public protocol ExhibititionActivityIndicatorViewProtocol {
    func startAnimating()
    func stopAnimating()
    var center: CGPoint { get set }
}
