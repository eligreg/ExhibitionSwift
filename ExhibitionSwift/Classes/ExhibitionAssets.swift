//
//  ExhibitionAssets.swift
//  Pods
//
//  Created by Eli Gregory on 1/26/17.
//
//

import Foundation

extension UIColor {
    
    public class var errorTexture: UIColor {
        guard let image = UIImage(named: "errorTexture", in: Bundle(for: ExhibitionController.self), compatibleWith: nil) else {
            return .black
        }
        return UIColor(patternImage: image)
    }
}

extension UIImage {
    
    public class func image(with color:UIColor, sized: CGSize) -> UIImage? {
        
        let rect = CGRect(x: 0.0, y: 0.0, width: sized.width, height: sized.height)
        
        UIGraphicsBeginImageContext(rect.size)
        
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        
        let img = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return img
    }
    
    public class var errorImage: UIImage? {
        let width = UIScreen.main.bounds.size.width
        let height = width * 0.75
        return image(with: .errorTexture, sized: CGSize(width: width, height: height))
    }
    
    fileprivate class func icon(styled style: ButtonIconType,
                           sized size:CGSize,
                           lineColor lColor:UIColor = UIColor.white,
                           fillColor fColor:UIColor = UIColor.clear,
                           lineWeight lWeight:CGFloat = UIScreen.main.scale,
                           whiteSpace wSpace: CGFloat = 0.72) -> UIImage? {
        
        let scale = UIScreen.main.scale
        
        let _x:CGFloat = 0.0
        let _y:CGFloat = 0.0
        let _w:CGFloat = size.width * scale
        let _h:CGFloat = size.height * scale
        
        let linePath = UIBezierPath()
        
        if style != .minus {
            // Vertical Line
            linePath.move(to:    CGPoint(x: (_x + (_w * 0.5)), y: (_y + (_h * wSpace))))
            linePath.addLine(to: CGPoint(x: (_x + (_w * 0.5)), y: (_y + (_h - (_h * wSpace)))))
        }
        
        // Horizontal Line
        linePath.move(to:    CGPoint(x: (_x + (_w * wSpace)),        y: (_y + (_h * 0.5))))
        linePath.addLine(to: CGPoint(x: (_x + (_w - (_w * wSpace))), y: (_y + (_h * 0.5))))
        
        // Circle
        let arcPath = UIBezierPath()
        arcPath.addArc(withCenter: CGPoint(x:(_w * 0.5), y:(_h * 0.5)),
                       radius: (_w * 0.5) - (lWeight / 2.0),
                       startAngle: 0,
                       endAngle: 360,
                       clockwise: true)
        
        linePath.append(arcPath)
        
        if style == .x {
            linePath.rotatePath(byRadians: CGFloat(45.0 / 180.0 * CGFloat.pi))
        }
        
        let lines = CAShapeLayer()
        lines.frame = CGRect(origin: CGPoint(x: 0.0, y:0.0), size: size)
        lines.path = linePath.cgPath
        lines.lineWidth = lWeight
        lines.lineCap = kCALineCapRound
        lines.strokeColor = lColor.cgColor
        lines.fillColor = fColor.cgColor
        lines.masksToBounds = false
        
        let outputSize = CGSize(width: lines.frame.size.width * scale, height: lines.frame.size.height * scale)
        var outputImage: UIImage?
        
        UIGraphicsBeginImageContext(outputSize)
        
        if let context = UIGraphicsGetCurrentContext() {
            lines.render(in: context)
            outputImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
        return outputImage
    }
}

extension UIBezierPath {
    
    fileprivate func rotatePath(byRadians radians: CGFloat) {
        let bounds = self.cgPath.boundingBox
        let center = CGPoint(x:bounds.midX, y:bounds.midY)
        
        let toOrigin = CGAffineTransform(translationX: -center.x, y: -center.y)
        self.apply(toOrigin)

        let rotation = CGAffineTransform(rotationAngle: radians)
        self.apply(rotation)
        
        let fromOrigin = CGAffineTransform(translationX: center.x, y: center.y)
        self.apply(fromOrigin)
    }
}

public enum ButtonIconType {
    case x
    case plus
    case minus
}

extension ExhibitionConfig {
    
    fileprivate static let styledButtonSize: CGFloat = 22.0
    
    public func styleXFor(button b: inout Button, sized size: CGFloat = styledButtonSize) {
        style(button: &b, forType: .x, sized: size)
    }
    
    public func stylePlusFor(button b: inout Button, sized size: CGFloat = styledButtonSize) {
        style(button: &b, forType: .plus, sized: size)
    }
    
    public func styleMinusFor(button b: inout Button, sized size: CGFloat = styledButtonSize) {
        style(button: &b, forType: .minus, sized: size)
    }
    
    public func style(button b: inout Button, forType type: ButtonIconType, sized size: CGFloat = styledButtonSize) {
        
        b.image = UIImage.icon(styled: type,
                               sized: CGSize(width: size, height: size),
                               lineColor: self.buttonsTheme.buttonsTitleColor)
        
        b.imageHighlighted = UIImage.icon(styled: type,
                               sized: CGSize(width: size, height: size),
                               lineColor: self.buttonsTheme.buttonsTitleColorHighlighted)
        
        b.title = ""
    }
}

extension UIButton {
    
    public func setImageWithInsets(image img: UIImage?, for state: UIControlState) {
        
        setImage(img, for: state)

        guard let image = img else {
            return
        }
        
        let scale = UIScreen.main.scale
        let width = image.size.width / scale
        let height = image.size.height / scale
        let left = width / 2.0
        let right = width / 2.0
        let top = height / 2.0
        let bottom = height / 2.0
        imageEdgeInsets = UIEdgeInsetsMake(top, left, bottom, right)
    }
}
