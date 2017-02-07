//
//  ExhibitionController.swift
//  Exhibition
//
//  Created by Eli Gregory on 12/27/16.
//  Copyright © 2016 Eli Gregory. All rights reserved.
//

import Foundation

typealias XController = ExhibitionController

open class ExhibitionController: UIViewController, UIScrollViewDelegate {
    
    public let config: ExhibitionConfig
    
    public let nwButton: UIButton = UIButton(type: .custom)
    public let neButton: UIButton = UIButton(type: .custom)
    public let swButton: UIButton = UIButton(type: .custom)
    public let seButton: UIButton = UIButton(type: .custom)
    
    public typealias ButtonClosure = (_ button: UIButton, _ controller: ExhibitionController) -> ()
    
    public var nwClosure: ButtonClosure? = { button, controller in
        controller.dismiss(animated: true, completion: nil)
    }
    
    public var neClosure: ButtonClosure?
    public var swClosure: ButtonClosure?
    public var seClosure: ButtonClosure?
    
    public var imageCache: ExhibitionCacheProtocol
    
    public var imageDownloader: ExhibitionDownloaderProtocol
    
    public typealias ActivityViewGenerator = (_ controller: ExhibitionController, _ sized: CGSize) -> (ExhibititionActivityIndicatorViewProtocol)
    
    public var newActivityView: ActivityViewGenerator = { controller, sized in
        return ExhibitionActivityIndicatorView(sized: sized.width,
                                               config: controller.config)
    }
    
    fileprivate var exhibitionItems = [ExhibitionItem]()
    
    public lazy var pageControl: UIPageControl = { [unowned self] in
        let pageControl = UIPageControl()
        pageControl.hidesForSinglePage = true
        
        return pageControl
    }()
    
    public lazy var scrollView: UIScrollView = { [unowned self] in
        let scrollView = UIScrollView()
        scrollView.frame = self.screenBounds
        scrollView.isPagingEnabled = false
        scrollView.delegate = self
        scrollView.isUserInteractionEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.decelerationRate = UIScrollViewDecelerationRateFast
        scrollView.isPagingEnabled = true
        
        return scrollView
    }()
    
    public init(with images: [ExhibitionImageProtocol],
                config: ExhibitionConfig = ExhibitionConfig(),
                cache: ExhibitionCacheProtocol = ExhibitionCache(),
                downloader: ExhibitionDownloaderProtocol = ExhibitionDownloader())
    {
        self.config = config
        self.imageCache = cache
        self.imageDownloader = downloader
        super.init(nibName: nil, bundle: nil)
        
        for image in images {
            self.append(exhibitionImage: image)
        }
    }
    
    // MARK: UIViewController Lifecycle
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        nwButton.addTarget(self, action: #selector(userTappedButton), for: .touchUpInside)
        neButton.addTarget(self, action: #selector(userTappedButton), for: .touchUpInside)
        swButton.addTarget(self, action: #selector(userTappedButton), for: .touchUpInside)
        seButton.addTarget(self, action: #selector(userTappedButton), for: .touchUpInside)
        
        self.setupLayout()
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateSubviews()
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    public func append(exhibitionImage image: ExhibitionImageProtocol, scrollToLast: Bool = false) {
        let item = ExhibitionItem(img: image, frame: frameForIndex(imageCount))
        let w = self.config.activityTheme.itemActivitySize
        item.activity = newActivityView(self, CGSize(width:w, height:w))
        exhibitionItems.append(item)
        adjustScrollViewContentSize()
        scrollView.addSubview(item)
        item.controller = self
        item.loadImage()
        updatePageControl()
        if scrollToLast {
            self.scrollToLast()
        }
    }
    
    public func removeCurrentExhibitionImage() -> ExhibitionImageProtocol? {
        guard !scrollView.isDragging && !scrollView.isDecelerating && exhibitionItems.count > 0 else {
            return nil
        }
        
        scrollView.isScrollEnabled = false
        
        var afterIndex = currentIndex

        var remove: ExhibitionImageProtocol?
        
        if exhibitionItems.contains(currentItem) && exhibitionItems[currentIndex] == currentItem {
            let removeItem = exhibitionItems.remove(at: currentIndex)
            removeItem.removeFromSuperview()
            remove = removeItem.image
        }
        
        for i in 0..<imageCount {
            let item = exhibitionItems[i]
            UIView.animate(withDuration: 0.2, animations: {
                item.frame = self.frameForIndex(i)
            })
        }
        
        afterIndex = min(exhibitionItems.count-1, afterIndex)
        
        adjustScrollViewContentSize()
        updateScrollViewItems()
        updatePageControl()
        
        scrollView.isScrollEnabled = true
        
        scroll(toIndex: afterIndex)
        
        return remove
    }
    
    fileprivate func adjustScrollViewContentSize() {
        scrollView.contentSize = CGSize(width: self.screenBounds.size.width * CGFloat(imageCount),
                                        height: self.screenBounds.size.height)
    }
    
    public func scroll(toIndex index: Int) {
        scrollView.setContentOffset(CGPoint(x: CGFloat(index) * scrollView.bounds.size.width, y: 0.0), animated: true)
    }
    
    public func scrollToLast() {
        scroll(toIndex: max(imageCount-1, 0))
    }
    
    public var currentIndex: Int {
        return Int((self.scrollView.contentOffset.x / self.scrollView.bounds.size.width) + 0.5)
    }
    
    fileprivate var currentItem: ExhibitionItem {
        return exhibitionItems[currentIndex]
    }
    
    public var currentImage: ExhibitionImageProtocol {
        return currentItem.image
    }
    
    public var imageCount: Int {
        return exhibitionItems.count
    }
    
    fileprivate func frameForIndex(_ idx: Int) -> CGRect {
        return CGRect(origin: CGPoint(x: self.screenBounds.size.width * CGFloat(idx), y: self.screenBounds.origin.y),
                      size: self.screenBounds.size)
        
    }
    
    internal func alpha(forItemIndex idx: Int) -> CGFloat {
        
        let width = scrollView.frame.size.width
        let realOffset = scrollView.contentOffset.x
        let desiredOffset = CGFloat(idx) * width
        let delta = fabs(realOffset - desiredOffset) / width

        return max(1.0 - delta, 0.0)
    }
    
    internal func updatePageControl() {
        pageControl.currentPage = currentIndex
        pageControl.numberOfPages = imageCount
    }
    
    fileprivate var controllerActivity: UIViewController?
    
    public var isControllerEnabled: Bool {
        return controllerActivity == nil
    }
    
    public func enableControllerInteractions() {
        
        guard let controller = controllerActivity else {
            return
        }
        
        nwButton.isEnabled = true
        neButton.isEnabled = true
        swButton.isEnabled = true
        seButton.isEnabled = true
        
        controller.dismiss(animated: true, completion: {
            self.controllerActivity = nil
        })
    }
    
    public func disableControllerInteractions() {
        
        guard controllerActivity == nil else {
            return
        }

        let w = self.config.activityTheme.controllerActivitySize
        let activity = newActivityView(self, CGSize(width:w, height:w))
        
        controllerActivity = UIViewController()
        controllerActivity?.view.backgroundColor = self.config.activityTheme.controllerBackgroundColor
        controllerActivity?.modalPresentationStyle = .custom
        controllerActivity?.modalTransitionStyle = .crossDissolve
        
        if let activityView = activity as? UIView {
            controllerActivity?.view.addSubview(activityView)
            activityView.center = controllerActivity?.view.center ?? .zero
        }
        
        nwButton.isEnabled = false
        neButton.isEnabled = false
        swButton.isEnabled = false
        seButton.isEnabled = false
        
        activity.startAnimating()

        if let controller = controllerActivity {
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    // MARK: UIScrollViewDelegate
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        guard exhibitionItems.count > 0 else {
            return
        }
        
        updateScrollViewItems()
        
        updatePageControl()
    }
    
    internal func updateScrollViewItems() {
        
        guard exhibitionItems.count > 0 else {
            return
        }
        
        let idx = currentIndex
        
        let prev: ExhibitionItem? = (currentIndex - 1 >= 0) ? exhibitionItems[idx - 1] : nil
        let current: ExhibitionItem = exhibitionItems[idx]
        let next: ExhibitionItem? = (currentIndex + 1 < imageCount) ? exhibitionItems[idx + 1] : nil
        
        current.alpha = alpha(forItemIndex: idx)
        
        let prevAlpha = alpha(forItemIndex: idx - 1)
        let nextAlpha = alpha(forItemIndex: idx + 1)
        
        prev?.alpha = prevAlpha
        next?.alpha = nextAlpha
        
        if prevAlpha <= 0.0 && prev?.zoomScale != prev?.minimumZoomScale {
            prev?.zoomOut()
        }
        
        if nextAlpha <= 0.0 && next?.zoomScale != next?.minimumZoomScale {
            next?.zoomOut()
        }
    }
    
    // MARK: Subviews
        
    public func setupLayout() {
        
        self.view.addSubview(scrollView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addConstraint(NSLayoutConstraint(item: scrollView,
                                                   attribute: .leading,
                                                   relatedBy: .equal,
                                                   toItem: self.view,
                                                   attribute: .leading,
                                                   multiplier: 1,
                                                   constant: 0))
        
        self.view.addConstraint(NSLayoutConstraint(item: scrollView,
                                                   attribute: .top,
                                                   relatedBy: .equal,
                                                   toItem: self.view,
                                                   attribute: .top,
                                                   multiplier: 1,
                                                   constant: 0))
        
        self.view.addConstraint(NSLayoutConstraint(item: scrollView,
                                                   attribute: .trailing,
                                                   relatedBy: .equal,
                                                   toItem: self.view,
                                                   attribute: .trailing,
                                                   multiplier: 1,
                                                   constant: 0))
        
        self.view.addConstraint(NSLayoutConstraint(item: scrollView,
                                                   attribute: .bottom,
                                                   relatedBy: .equal,
                                                   toItem: self.view,
                                                   attribute: .bottom,
                                                   multiplier: 1,
                                                   constant: 0))
        
        self.view.addSubview(pageControl)
        
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addConstraint(NSLayoutConstraint(item: pageControl,
                                                   attribute: .bottom,
                                                   relatedBy: .equal,
                                                   toItem: self.view,
                                                   attribute: .bottom,
                                                   multiplier: 1,
                                                   constant: -self.config.buttonsTheme.bumper))
        
        self.view.addConstraint(NSLayoutConstraint(item: pageControl,
                                                   attribute: .centerX,
                                                   relatedBy: .equal,
                                                   toItem: self.view,
                                                   attribute: .centerX,
                                                   multiplier: 1,
                                                   constant: 0))
        
        self.view.addSubview(nwButton)
        self.view.addSubview(neButton)
        self.view.addSubview(swButton)
        self.view.addSubview(seButton)
        
        nwButton.translatesAutoresizingMaskIntoConstraints = false
        neButton.translatesAutoresizingMaskIntoConstraints = false
        swButton.translatesAutoresizingMaskIntoConstraints = false
        seButton.translatesAutoresizingMaskIntoConstraints = false
        
        var constraints = [NSLayoutConstraint]()
        
        constraints.append(NSLayoutConstraint(item: nwButton,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: self.view,
                                              attribute: .leading,
                                              multiplier: 1,
                                              constant: self.config.buttonsTheme.bumper))
        
        constraints.append(NSLayoutConstraint(item: nwButton,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: self.view,
                                              attribute: .top,
                                              multiplier: 1,
                                              constant: self.config.buttonsTheme.bumper))
        
        constraints.append(NSLayoutConstraint(item: neButton,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: self.view,
                                              attribute: .trailing,
                                              multiplier: 1,
                                              constant: -self.config.buttonsTheme.bumper))
        
        constraints.append(NSLayoutConstraint(item: neButton,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: self.view,
                                              attribute: .top,
                                              multiplier: 1,
                                              constant: self.config.buttonsTheme.bumper))
        
        constraints.append(NSLayoutConstraint(item: swButton,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: self.view,
                                              attribute: .leading,
                                              multiplier: 1,
                                              constant: self.config.buttonsTheme.bumper))
        
        constraints.append(NSLayoutConstraint(item: swButton,
                                              attribute: .bottom,
                                              relatedBy: .equal,
                                              toItem: self.view,
                                              attribute: .bottom,
                                              multiplier: 1,
                                              constant: -self.config.buttonsTheme.bumper))
        
        constraints.append(NSLayoutConstraint(item: seButton,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: self.view,
                                              attribute: .trailing,
                                              multiplier: 1,
                                              constant: -self.config.buttonsTheme.bumper))
        
        constraints.append(NSLayoutConstraint(item: seButton,
                                              attribute: .bottom,
                                              relatedBy: .equal,
                                              toItem: self.view,
                                              attribute: .bottom,
                                              multiplier: 1,
                                              constant: -self.config.buttonsTheme.bumper))
        
        self.view.addConstraints(constraints)
    }
    
    public func updateSubviews() {
        
        // TODO Account for Images
        
        nwButton.frame = CGRect(origin: CGPoint.zero, size: self.config.nwButton.size)
        nwButton.setTitle(self.config.nwButton.title, for: .normal)
        nwButton.setImageWithInsets(image: self.config.nwButton.image, for: .normal)
        nwButton.setImageWithInsets(image: self.config.nwButton.imageHighlighted, for: .highlighted)
        nwButton.contentMode = .center
        nwButton.isEnabled = self.config.nwButton.enabled
        nwButton.isHidden = !self.config.nwButton.visible
        nwButton.setTitleColor(self.config.buttonsTheme.buttonsTitleColor, for: .normal)
        nwButton.setTitleColor(self.config.buttonsTheme.buttonsTitleColorHighlighted, for: .highlighted)
        nwButton.layer.shadowColor = self.config.buttonsTheme.buttonsDropShadowColor.cgColor
        nwButton.layer.shadowOpacity = self.config.buttonsTheme.buttonsDropShadowOpacity
        nwButton.layer.shadowRadius = self.config.buttonsTheme.buttonsDropShadowRadius
        nwButton.layer.shadowOffset = self.config.buttonsTheme.buttonsDropShadowOffset
        
        neButton.frame = CGRect(origin: CGPoint.zero, size: self.config.neButton.size)
        neButton.setTitle(self.config.neButton.title, for: .normal)
        neButton.setImageWithInsets(image: self.config.neButton.image, for: .normal)
        neButton.setImageWithInsets(image: self.config.neButton.imageHighlighted, for: .highlighted)
        neButton.contentMode = .center
        neButton.isEnabled = self.config.neButton.enabled
        neButton.isHidden = !self.config.neButton.visible
        neButton.setTitleColor(self.config.buttonsTheme.buttonsTitleColor, for: .normal)
        neButton.setTitleColor(self.config.buttonsTheme.buttonsTitleColorHighlighted, for: .highlighted)
        neButton.layer.shadowColor = self.config.buttonsTheme.buttonsDropShadowColor.cgColor
        neButton.layer.shadowOpacity = self.config.buttonsTheme.buttonsDropShadowOpacity
        neButton.layer.shadowRadius = self.config.buttonsTheme.buttonsDropShadowRadius
        neButton.layer.shadowOffset = self.config.buttonsTheme.buttonsDropShadowOffset
        
        swButton.frame = CGRect(origin: CGPoint.zero, size: self.config.swButton.size)
        swButton.setTitle(self.config.swButton.title, for: .normal)
        swButton.setImageWithInsets(image: self.config.swButton.image, for: .normal)
        swButton.setImageWithInsets(image: self.config.swButton.imageHighlighted, for: .highlighted)
        swButton.contentMode = .center
        swButton.isEnabled = self.config.swButton.enabled
        swButton.isHidden = !self.config.swButton.visible
        swButton.setTitleColor(self.config.buttonsTheme.buttonsTitleColor, for: .normal)
        swButton.setTitleColor(self.config.buttonsTheme.buttonsTitleColorHighlighted, for: .highlighted)
        swButton.layer.shadowColor = self.config.buttonsTheme.buttonsDropShadowColor.cgColor
        swButton.layer.shadowOpacity = self.config.buttonsTheme.buttonsDropShadowOpacity
        swButton.layer.shadowRadius = self.config.buttonsTheme.buttonsDropShadowRadius
        swButton.layer.shadowOffset = self.config.buttonsTheme.buttonsDropShadowOffset
        
        seButton.frame = CGRect(origin: CGPoint.zero, size: self.config.seButton.size)
        seButton.setTitle(self.config.seButton.title, for: .normal)
        seButton.setImageWithInsets(image: self.config.seButton.image, for: .normal)
        seButton.setImageWithInsets(image: self.config.seButton.imageHighlighted, for: .highlighted)
        seButton.contentMode = .center
        seButton.isEnabled = self.config.seButton.enabled
        seButton.isHidden = !self.config.seButton.visible
        seButton.setTitleColor(self.config.buttonsTheme.buttonsTitleColor, for: .normal)
        seButton.setTitleColor(self.config.buttonsTheme.buttonsTitleColorHighlighted, for: .highlighted)
        seButton.layer.shadowColor = self.config.buttonsTheme.buttonsDropShadowColor.cgColor
        seButton.layer.shadowOpacity = self.config.buttonsTheme.buttonsDropShadowOpacity
        seButton.layer.shadowRadius = self.config.buttonsTheme.buttonsDropShadowRadius
        seButton.layer.shadowOffset = self.config.buttonsTheme.buttonsDropShadowOffset
        
        pageControl.pageIndicatorTintColor = self.config.pageControlTheme.pageIndicatorColor
        pageControl.currentPageIndicatorTintColor = self.config.pageControlTheme.currentPageIndicatorColor
        
        view.backgroundColor = config.generalTheme.backgroundColor
    }
    
    internal func userTappedButton(_ sender: UIButton) {
        if sender == nwButton {
            nwClosure?(sender, self)
        }
        else if sender == neButton {
            neClosure?(sender, self)
        }
        else if sender == swButton {
            swClosure?(sender, self)
        }
        else if sender == seButton {
            seClosure?(sender, self)
        }
    }
    
    var screenBounds: CGRect {
        return UIScreen.main.bounds
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open var prefersStatusBarHidden: Bool {
        return config.hidesStatusBar
    }
}

