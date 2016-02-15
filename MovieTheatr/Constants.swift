//
//  Constants.swift
//  MovieTheatr
//
//  Created by Joseph Vallillo on 2/8/16.
//  Copyright © 2016 Joseph Vallillo. All rights reserved.
//

import UIKit

//MARK: - Constants

struct Constants {
    
    //MARK: - TMDB
    struct TMDB {
        static let APIScheme = "https"
        static let APIHost = "api.themoviedb.org"
        static let APIPath = "/3"
    }
    
    //MARK: - TMDB Parameter Keys
    struct TMDBParameterKeys {
        static let APIKey = "api_key"
        static let RequestToken = "request_token"
        static let Success = "success"
        static let SessionID = "session_id"
        static let UserID = "id"
        static let Username = "username"
        static let Password = "password"
        static let Results = "results"
    }
    
    //MARK: - TMDB Parameter Values
    struct TMDBParameterValues {
        static let APIKey = "24a6701d1ec2cfac5d3ff405a4f5ee2e"
    }
    
    // MARK: UI
    struct UI {
        static let LoginColorTop = UIColor(red: 0.345, green: 0.839, blue: 0.988, alpha: 1.0).CGColor
        static let LoginColorBottom = UIColor(red: 0.023, green: 0.569, blue: 0.910, alpha: 1.0).CGColor
        static let GreyColor = UIColor(red: 0.702, green: 0.863, blue: 0.929, alpha:1.0)
        static let BlueColor = UIColor(red: 0.0, green:0.502, blue:0.839, alpha: 1.0)
    }
    
    // MARK: Selectors
    struct Selectors {
        static let KeyboardWillShow: Selector = "keyboardWillShow:"
        static let KeyboardWillHide: Selector = "keyboardWillHide:"
        static let KeyboardDidShow: Selector = "keyboardDidShow:"
        static let KeyboardDidHide: Selector = "keyboardDidHide:"
    }
}
