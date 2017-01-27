# ExhibitionSwift

[![CI Status](http://img.shields.io/travis/Eli Gregory/ExhibitionSwift.svg?style=flat)](https://travis-ci.org/Eli Gregory/ExhibitionSwift)
[![Version](https://img.shields.io/cocoapods/v/ExhibitionSwift.svg?style=flat)](http://cocoapods.org/pods/ExhibitionSwift)
[![License](https://img.shields.io/cocoapods/l/ExhibitionSwift.svg?style=flat)](http://cocoapods.org/pods/ExhibitionSwift)
[![Platform](https://img.shields.io/cocoapods/p/ExhibitionSwift.svg?style=flat)](http://cocoapods.org/pods/ExhibitionSwift)

## Requirements

* Swift 3
* >= iOS 7

## Installation

ExhibitionSwift is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "ExhibitionSwift"
```
## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Why

Image gallerys mostly seem to have been built with a certain perogative. Some are designed for locally stored images, others for remote only. Some force upon you a features you might not want - like share button, while others with non-customizable UI elements. Some maintain a static group of images only and others do allow you to add - but to not remove!

My goal in Exhibition was to design an image gallery that's simple to integrate, elegant to use and easily customizable to your app's design.

## Usage

### Configuration

Begin by setting up your controller with a configuration object.

```swift
let config = ExhibitionConfig() 
```

There are four buttons in each corner and a page control. Customize to your liking.

```swift
config.swButton.image = UIImage(named: "deleteButton")
config.swButton.imageHighlighted = UIImage(named: "deleteButtonHighlighted")
config.seButton.image = UIImage(named:"addButton")
config.swButton.imageHighlighted = UIImage(named: "addButtonHighlighted")
config.nwButton.hidden = true
config.neButton.title = "Exit"
config.generalTheme.errorImage = UIImage(named: "failedToLoadImage")
config.generalTheme.backgroundColor = .black
config.generalTheme.foregroundColor = .white
config.buttonsTheme.buttonsTitleColor = .red
config.buttonsTheme.buttonsTitleColorHighlighted = .orange
```

### Downloader

You can write your own Image Networking class by subscribing to `ExhibitionDownloaderProtocol`, or use the built in `ExhibitionDownloader`.

```swift
public protocol ExhibitionDownloaderProtocol {
    func downloadImage(image: ExhibitionImageProtocol, results: @escaping ((UIImage?, Error?)->()))
}
```

### Image Cache

You can write your own Image Cache or integrate with your existing one by subscribing to `ExhibitionCacheProtocol`, or use the built in `ExhibitionCache`.

```swift
public protocol ExhibitionCacheProtocol {
    func set(image img:UIImage, forKey key: String)
    func retrieveImage(forKey key: String) -> UIImage?
}
```

### Exhibition Images

You can integrate the `ExhibitionImageProtocol` directly into your models or use the built in `ExhibitionImage` struct.

```swift
public protocol ExhibitionImageProtocol {
    var image: UIImage? { get }
    var url: URL? { get }
    var shouldCache: Bool { get }
}

// OR

var imgs: [ExhibitionImageProtocol] = [
  ExhibitionImage(string: "https://upload.wikimedia.org/wikipedia/commons/b/b8/ESO_Very_Large_Telescope.jpg")!,
  ExhibitionImage(string: "https://upload.wikimedia.org/wikipedia/commons/f/f0/Moonset_over_ESO's_Very_Large_Telescope.jpg")!,
  ExhibitionImage(string: "https://upload.wikimedia.org/wikipedia/commons/e/e0/Large_Scaled_Forest_Lizard.jpg")!,
  ExhibitionImage(string: "http://bsnscb.com/data/out/113/39939274-large-wallpapers.jpeg")!,
  ExhibitionImage(string: "http://kingofwallpapers.com/lava/lava-003.jpg")!,
  ExhibitionImage(string: "https://www.woolme.com/blog/wp-content/uploads/2016/03/requests-alpaca_2441680k.jpg")!
]

/*
  Optionally:
  ExhibitionImage(url: URL)
  ExhibitionImage(image: UIImage)
*/
```

Finally, build a `ExhibitionController`.

```swift
let controller = ExhibitionController(with: requiredImages,
                                      config: optionalConfig,
                                      cache: optionalCache,
                                      downloader: optionalDownloader
```

Give your buttons something to do.

```swift
controller.neClosure = { button, controller in
  controller.dismiss(animated: true, completion: nil)
}

controller.swClosure = { button, controller in
  controller.disableControllerInteractions()
  let newImageURL = URL(string: "https://www.national-park.com/wp-content/uploads/2016/04/Welcome-to-Death-Valley-National-Park.jpg")!
  let img = ExhibitionImage(url: newImageURL)
  controller.append(exhibitionImage: img, scrollToLast: true)
  controller.enableControllerInteractions()
}

closure.seClosure = { button, controller in
  controller.disableControllerInteractions()
  _ = controller.removeCurrentExhibitionImage() 
  controller.enableControllerInteractions()
}
```

You can even design your own custom UIView subclass activity indicator if you subsribe to `ExhibititionActivityIndicatorViewProtocol` by overriding the `newActivityView` closure:

```swift    
public var newActivityView: ActivityViewGenerator = { controller, sized in
  //...
  // return <ExhibititionActivityIndicatorViewProtocol>
}
    
public typealias ActivityViewGenerator = (_ controller: ExhibitionController, _ sized: CGSize) -> (ExhibititionActivityIndicatorViewProtocol)
```

## Note

Exhibition is currently in Beta and will continue to be developed in the coming months. It has not been tested at industry scale, use at your own risk.

## Author

Eli Gregory, eligreg@gmail.com

## License

ExhibitionSwift is available under the MIT license. See the LICENSE file for more info.
