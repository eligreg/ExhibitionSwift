//
//  ViewController.swift
//  ExhibitionSwift
//
//  Created by Eli Gregory on 01/23/2017.
//  Copyright (c) 2017 Eli Gregory. All rights reserved.
//

import UIKit
import ExhibitionSwift

class ViewController: UIViewController {
    
    var imgs: [ExhibitionImageProtocol] = [
        ExhibitionImage(string: "https://upload.wikimedia.org/wikipedia/commons/b/b8/ESO_Very_Large_Telescope.jpg")!,
        ExhibitionImage(string: "https://upload.wikimedia.org/wikipedia/commons/f/f0/Moonset_over_ESO's_Very_Large_Telescope.jpg")!,
        ExhibitionImage(string: "https://upload.wikimedia.org/wikipedia/commons/e/e0/Large_Scaled_Forest_Lizard.jpg")!,
        ExhibitionImage(string: "http://bsnscb.com/data/out/113/39939274-large-wallpapers.jpeg")!,
        ExhibitionImage(string: "http://kingofwallpapers.com/lava/lava-003.jpg")!,
        ExhibitionImage(string: "https://www.woolme.com/blog/wp-content/uploads/2016/03/requests-alpaca_2441680k.jpg")!
    ]
    
    let cache = ExhibitionCache()

    var x: ExhibitionController?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let xConfig = ExhibitionConfig()
        
        xConfig.neButton.enabled = false
        xConfig.neButton.visible = false
        
        xConfig.styleXFor(button: &xConfig.nwButton)
        xConfig.styleMinusFor(button: &xConfig.swButton)
        xConfig.stylePlusFor(button: &xConfig.seButton)
        
        var demoImages = [ExhibitionImageProtocol]()
        for _ in 0..<3 {
            if let img = randomExhibitionImage {
                demoImages.append(img)
            }
        }
        
        x = nil
        x = ExhibitionController(with: demoImages, config: xConfig, cache: self.cache)
        
        x?.nwClosure = { button, controller in
            while controller.imageCount > 0 {
                if let deleted = controller.removeCurrentExhibitionImage() {
                    self.imgs.append(deleted)
                }
            }
            controller.dismiss(animated: true, completion: nil)
        }
        
        x?.swClosure = { button, controller in
            controller.disableControllerInteractions()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                controller.enableControllerInteractions()
                if let deleted = controller.removeCurrentExhibitionImage() {
                    self.imgs.append(deleted)
                }
            }
        }
        
        x?.seClosure = { button, controller in
            controller.disableControllerInteractions()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                if let img = self.randomExhibitionImage {
                    controller.append(exhibitionImage: img, scrollToLast: true)
                }
                controller.enableControllerInteractions()
            }
            
        }
        
        self.present(x!, animated: true, completion: nil)
    }
    
    var randomExhibitionImage: ExhibitionImageProtocol? {
        guard imgs.count > 0 else {
            return nil
        }
        
        let randomIndex = Int(arc4random_uniform(UInt32(imgs.count)))
        return imgs.remove(at: randomIndex)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

