//
//  Movie.swift
//  MovieTheatr
//
//  Created by Joseph Vallillo on 2/6/16.
//  Copyright © 2016 Joseph Vallillo. All rights reserved.
//

import UIKit

//MARK: - Movie

struct Movie {
    
    //MARK: - Properties
    var title = ""
    var id = 0
    var posterPath: String? = nil
    
    //MARK: - Initalizers
    
    init(dictionary: [String : AnyObject]) {
        title = dictionary["title"] as! String
        id = dictionary["id"] as! Int
        posterPath = dictionary["poster_path"] as? String
    }
    
    static func moviesFromResults(results: [[String : AnyObject]]) -> [Movie] {
        var movies = [Movie]()
        
        for result in results {
            movies.append(Movie(dictionary: result))
        }
        
        return movies
    }
}
