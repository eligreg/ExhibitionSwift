//
//  ExhibitionDownloader.swift
//  Exhibition
//
//  Created by Eli Gregory on 12/27/16.
//  Copyright © 2016 Eli Gregory. All rights reserved.
//

import Foundation

public typealias XDownloaderProtocol = ExhibitionDownloaderProtocol

public protocol ExhibitionDownloaderProtocol {
    func downloadImage(image: ExhibitionImageProtocol, results: @escaping ((UIImage?, Error?)->()))
}

public typealias XDownloader = ExhibitionDownloader

public class ExhibitionDownloader: ExhibitionDownloaderProtocol {
    
    public func downloadImage(image: ExhibitionImageProtocol, results: @escaping ((UIImage?, Error?)->())) {
        
        guard let url = image.url else {
            return
        }
        
        let imageRequest: URLRequest = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: imageRequest, completionHandler: { data, response, error in
            
            if let data = data {
                let img = UIImage(data: data)
                results(img, error)
            }
            else {
                results(nil, error)
            }
        })
        
        task.resume()
    }
}
