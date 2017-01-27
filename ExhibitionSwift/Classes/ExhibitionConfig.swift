//
//  ExhibitionConfig.swift
//  Exhibition
//
//  Created by Eli Gregory on 12/27/16.
//  Copyright © 2016 Eli Gregory. All rights reserved.
//

import Foundation
import UIKit

typealias XConfig = ExhibitionConfig

public class ExhibitionConfig {
    
    public init() { }
        
    public var hidesStatusBar: Bool = true
    
    public var nwButton: Button = Button(title: "Exit")
    public var neButton: Button = Button(title: "Share")
    public var swButton: Button = Button(title: "Delete")
    public var seButton: Button = Button(title: "Add")
    
    public var generalTheme: GeneralTheme = GeneralTheme()
    public var buttonsTheme: ButtonsTheme = ButtonsTheme()
    public var activityTheme: ActivityTheme = ActivityTheme()
    public var pageControlTheme: PageControlTheme = PageControlTheme()
    
    public struct Button {
        public var title: String = ""
        public var image: UIImage? = nil
        public var imageHighlighted: UIImage? = nil
        public var enabled: Bool = true
        public var visible: Bool = true
        public var size: CGSize = CGSize(width: 40.0, height: 40.0)
        
        init(title: String) {
            self.title = title
        }
        
        init(image: UIImage) {
            self.image = image
        }
    }
    
    public struct GeneralTheme {
        public var backgroundColor: UIColor = XConfig.bgc
        public var foregroundColor: UIColor = XConfig.fgc
        public var errorImage: UIImage? = UIImage.errorImage
    }
    
    public struct ButtonsTheme {
        public var buttonsFont: UIFont = UIFont.systemFont(ofSize: UIFont.buttonFontSize)
        public var buttonsTitleColor: UIColor = XConfig.fgc
        public var buttonsTitleColorHighlighted: UIColor = XConfig.fgcTransparent
        public var bumper: CGFloat = 10
    }
    
    public struct ActivityTheme {
        public var backgroundColor: UIColor = XConfig.fgc
        public var foregroundColor: UIColor = XConfig.bgc
        public var controllerActivitySize: CGFloat = 42.0
        public var controllerBackgroundColor: UIColor = XConfig.bgcTransparent
        public var itemActivitySize: CGFloat = 30.0
    }
    
    public struct PageControlTheme {
        public var pageIndicatorColor: UIColor = XConfig.fgcTransparent
        public var currentPageIndicatorColor: UIColor = XConfig.fgc
        public var visible: Bool = true
    }

    private static let fgc: UIColor = UIColor(red:(240.0/255.0), green:(240.0/255.0), blue:(240.0/255.0), alpha:1.00) // light gray
    private static let bgc: UIColor = UIColor(red:(15.0/255.0), green:(15.0/255.0), blue:(15.0/255.0), alpha:1.00) // dark gray
    
    private static var fgcTransparent: UIColor {
        var r:CGFloat = 0, g:CGFloat = 0, b:CGFloat = 0, a:CGFloat = 0
        XConfig.fgc.getRed(&r, green: &g, blue: &b, alpha: &a)
        return UIColor(red:r, green:g, blue:b, alpha:0.5)
    }
    
    private static var bgcTransparent: UIColor {
        var r:CGFloat = 0, g:CGFloat = 0, b:CGFloat = 0, a:CGFloat = 0
        XConfig.bgc.getRed(&r, green: &g, blue: &b, alpha: &a)
        return UIColor(red:r, green:g, blue:b, alpha:0.8)
    }
}

