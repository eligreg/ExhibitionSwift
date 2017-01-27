//
//  ExhibitionItem.swift
//  Exhibition
//
//  Created by Eli Gregory on 1/13/17.
//  Copyright © 2017 Eli Gregory. All rights reserved.
//

import Foundation

class ExhibitionItem: UIScrollView, UIScrollViewDelegate {
    
    weak var controller: ExhibitionController?
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        
        return imageView
    }()
    
    var contentFrame = CGRect.zero
    
    var image:ExhibitionImageProtocol
    
    var activity: ExhibititionActivityIndicatorViewProtocol?
    
    var loaded = false
    var active = false
    var retrys = 0
    
    init(img: ExhibitionImageProtocol, frame: CGRect) {
        
        image = img
        
        super.init(frame: frame)
        
        delegate = self
        isMultipleTouchEnabled = true
        minimumZoomScale = 1.0
        maximumZoomScale = 3.0
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(scrollViewDoubleTapped(_:)))
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.numberOfTouchesRequired = 1
        addGestureRecognizer(doubleTapRecognizer)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTapped(_:)))
        addGestureRecognizer(tapRecognizer)
        
        tapRecognizer.require(toFail: doubleTapRecognizer)
        
        addSubview(imageView)
        imageView.frame = bounds
        
        contentFrame = frame
    }
    
    internal func set(image img: UIImage?) {
        loaded = img != nil
        active = false
        imageView.image = img ?? controller?.config.generalTheme.errorImage
        activity?.stopAnimating()
    }
    
    internal func insertActivityAndAnimate() {
        
        if let activityView = activity as? UIView, !subviews.contains(activityView) {
            
            addSubview(activityView)
            
            activityView.translatesAutoresizingMaskIntoConstraints = false
            
            self.addConstraint(NSLayoutConstraint(item: activityView,
                                                  attribute: .centerX,
                                                  relatedBy: .equal,
                                                  toItem: self,
                                                  attribute: .centerX,
                                                  multiplier: 1,
                                                  constant: 0))
            
            self.addConstraint(NSLayoutConstraint(item: activityView,
                                                  attribute: .centerY,
                                                  relatedBy: .equal,
                                                  toItem: self,
                                                  attribute: .centerY,
                                                  multiplier: 1,
                                                  constant: 0))
            
            activityView.addConstraint(NSLayoutConstraint(item: activityView,
                                                          attribute: .width,
                                                          relatedBy: .equal,
                                                          toItem: nil,
                                                          attribute: .notAnAttribute,
                                                          multiplier: 1.0,
                                                          constant: activityView.bounds.width))
            
            activityView.addConstraint(NSLayoutConstraint(item: activityView,
                                                          attribute: .height,
                                                          relatedBy: .equal,
                                                          toItem: nil,
                                                          attribute: .notAnAttribute,
                                                          multiplier: 1.0,
                                                          constant: activityView.bounds.height))
        }
        
        activity?.startAnimating()
    }

    public func loadImage() {
        
        retrys += 1
        active = true
        
        insertActivityAndAnimate()
        
        if let img = image.image {
            set(image: img)
        }
        else if let key = image.url {
            if let img = self.controller?.imageCache.retrieveImage(forKey: key.absoluteString) {
                set(image: img)
            }
            else {
                controller?.imageDownloader.downloadImage(image: image, results: { img, error in
                    if self.image.shouldCache, let imgage = img {
                        self.controller?.imageCache.set(image: imgage, forKey: key.absoluteString)
                    }
                    DispatchQueue.main.async {
                        self.set(image: img != nil ? img : nil) // TODO replace with failed image
                    }
                })
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func zoomOut() {
        self.zoom(to: imageView.frame, animated: true)
    }
    
    func zoomIn(toRect rect: CGRect) {
        zoom(to: rect, animated: true)
    }

    func scrollViewDoubleTapped(_ recognizer: UITapGestureRecognizer) {
        
        guard loaded else {
            return
        }
        
        let pointInView = recognizer.location(in: imageView)
        let newZoomScale = zoomScale > minimumZoomScale ? minimumZoomScale : maximumZoomScale
        
        let width = frame.size.width / newZoomScale
        let height = frame.size.height / newZoomScale
        let x = pointInView.x - (width / 2.0)
        let y = pointInView.y - (height / 2.0)
        
        let rectToZoomTo = CGRect(x: x, y: y, width: width, height: height)
        
        if newZoomScale == minimumZoomScale {
            zoomOut()
        }
        else {
            zoomIn(toRect: rectToZoomTo)
        }
    }
    
    func viewTapped(_ recognizer: UITapGestureRecognizer) {
        
        // Retry download
        guard !loaded && retrys < 3 && !active else {
            return
        }
        
        if zoomScale > minimumZoomScale {
            zoomOut()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.loadImage()
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImageView()
    }
    
    func centerImageView() {
        let boundsSize = frame.size
        var imageViewFrame = imageView.frame
        
        if imageViewFrame.size.width < boundsSize.width {
            imageViewFrame.origin.x = (boundsSize.width - imageViewFrame.size.width) / 2.0
        } else {
            imageViewFrame.origin.x = 0.0
        }
        
        if imageViewFrame.size.height < boundsSize.height {
            imageViewFrame.origin.y = (boundsSize.height - imageViewFrame.size.height) / 2.0
        } else {
            imageViewFrame.origin.y = 0.0
        }
        
        imageView.frame = imageViewFrame
    }
}
