//
//  AppDelegate.swift
//  MovieTheatr
//
//  Created by Joseph Vallillo on 2/4/16.
//  Copyright © 2016 Joseph Vallillo. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let apiKey = "24a6701d1ec2cfac5d3ff405a4f5ee2e"
    let baseURLString = "http://api.themoviedb.org/3/"
    let baseURLSecureString = "https://api.themoviedb.org/3/"
    
    var sharedSession = NSURLSession.sharedSession()
    var requestToken: String? = nil
    var sessionID: String? = nil
    var userID: Int? = nil
    
    var config = Config()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        config.updateIfDaysSinceUpdateExceeds(7)
        
        return true
    }

}


// MARK: - Escape HTML Parameters

extension AppDelegate {
    
    /* Helper function: Given a dictionary of parameters, convert to a string for a url */
    func tmdbURLFromParameters(parameters: [String:AnyObject], withPathExtension: String? = nil) -> NSURL {
        
        let components = NSURLComponents()
        components.scheme = Constants.TMDB.APIScheme
        components.host = Constants.TMDB.APIHost
        components.path = Constants.TMDB.APIPath + (withPathExtension ?? "")
        components.queryItems = [NSURLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.URL!
    }
    
    func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }

}

