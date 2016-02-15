//
//  MovieDetailViewController.swift
//  MovieTheatr
//
//  Created by Joseph Vallillo on 2/8/16.
//  Copyright © 2016 Joseph Vallillo. All rights reserved.
//

import UIKit

class MovieDetailViewController: UIViewController {

    // MARK: Properties
    
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var unFavoriteButton: UIButton!
    
    var appDelegate: AppDelegate!
    var session: NSURLSession!
    
    var movie: Movie?
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Get the app delegate */
        appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
        
        /* Get the shared URL session */
        session = NSURLSession.sharedSession()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        /* TASK A: Get favorite movies, then update the favorite buttons */
        if let movie = self.movie {
            
            self.titleLabel.text = movie.title
            self.unFavoriteButton.hidden = true
            
            /* 1. Set the parameters */
            let methodParameters = [
                Constants.TMDBParameterKeys.APIKey : Constants.TMDBParameterValues.APIKey,
                Constants.TMDBParameterKeys.SessionID : self.appDelegate.sessionID!
            ]
            
            /* 2.&3. Build the URL & Configure the request */
            let request = NSURLRequest(URL: appDelegate.tmdbURLFromParameters(methodParameters, withPathExtension: "/account/\(self.appDelegate.userID)/favorite/movies"))
            
            /* 4. Make the request */
            let task = appDelegate.sharedSession.dataTaskWithRequest(request) { (data, response, error) in
                
                
                /* GUARD: Was there an error? */
                guard (error == nil) else {
                    print("GetFavoriteMovies: Print an error message")
                    return
                }
                
                /* GUARD: Did we get a successful 2XX response? */
                guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                    if let response = response as? NSHTTPURLResponse {
                        print("Your request returned an invalid response! Status code: \(response.statusCode)!")
                    } else if let response = response {
                        print("Your request returned an invalid response! Response: \(response)!")
                    } else {
                        print("Your request returned an invalid response!")
                    }
                    return
                }
                
                /* GUARD: Was there any data returned? */
                guard let data = data else {
                    print("No data was returned by the request!")
                    return
                }
                
                /* 5. Parse the data */
                print("getUserID: Parse the data \(data)")
                let parsedResult: AnyObject!
                do {
                    parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
                } catch {
                    print("Could not parse the data as JSON: '\(data)'")
                    return
                }
                
                guard let results = parsedResult[Constants.TMDBParameterKeys.Results] as? [[String : AnyObject]] else {
                    print("Cannot find Results")
                    return
                }
                
                /* 6. Use the data! */
                var isFavorite = false
                let movies = Movie.moviesFromResults(results)
                
                for movie in movies {
                    if movie.id == self.movie?.id {
                        isFavorite = true
                    }
                }
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if isFavorite {
                        self.favoriteButton.hidden = true
                        self.unFavoriteButton.hidden = false
                    } else {
                        self.favoriteButton.hidden = false
                        self.unFavoriteButton.hidden = true
                    }
                })
            }
            
            /* 7. Start the request */
            task.resume()

        }
        
        
        /* TASK B: Get the poster image, then populate the image view */
        if let movie = movie, posterPath = movie.posterPath {
            
            /* 1B. Set the parameters */
            // There are none...
            
            /* 2B. Build the URL */
            let baseURL = NSURL(string: appDelegate.config.baseImageURLString)!
            let url = baseURL.URLByAppendingPathComponent("w342").URLByAppendingPathComponent(posterPath)
            
            /* 3B. Configure the request */
            let request = NSURLRequest(URL: url)
            
            /* 4B. Make the request */
            let task = session.dataTaskWithRequest(request) { (data, response, error) in
                
                /* GUARD: Was there an error? */
                guard (error == nil) else {
                    print("There was an error with your request: \(error)")
                    return
                }
                
                /* GUARD: Did we get a successful 2XX response? */
                guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                    if let response = response as? NSHTTPURLResponse {
                        print("Your request returned an invalid response! Status code: \(response.statusCode)!")
                    } else if let response = response {
                        print("Your request returned an invalid response! Response: \(response)!")
                    } else {
                        print("Your request returned an invalid response!")
                    }
                    return
                }
                
                /* GUARD: Was there any data returned? */
                guard let data = data else {
                    print("No data was returned by the request!")
                    return
                }
                
                /* 5B. Parse the data */
                // No need, the data is already raw image data.
                
                /* 6B. Use the data! */
                if let image = UIImage(data: data) {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.posterImageView!.image = image
                    }
                } else {
                    print("Could not create image from \(data)")
                }
            }
            
            /* 7B. Start the request */
            task.resume()
        }
    }
    
    // MARK: Favorite Actions
    
    @IBAction func unFavoriteButtonTouchUpInside(sender: AnyObject) {
        
        /* TASK: Remove movie as favorite, then update favorite buttons */
        /* 1. Set the parameters */
        let methodParameters = [
            Constants.TMDBParameterKeys.APIKey : Constants.TMDBParameterValues.APIKey,
            Constants.TMDBParameterKeys.SessionID : self.appDelegate.sessionID!
        ]
        
        /* 2.&3. Build the URL & Configure the request */
        let request = NSMutableURLRequest(URL: appDelegate.tmdbURLFromParameters(methodParameters, withPathExtension: "/account/\(self.appDelegate.userID)/favorite"))
        
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"media_type\": \"movie\",\"media_id\": \(self.movie!.id),\"favorite\":false}".dataUsingEncoding(NSUTF8StringEncoding)
        
        /* 4. Make the request */
        let task = appDelegate.sharedSession.dataTaskWithRequest(request) { (data, response, error) in
            
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                print("unfavoriteMovie: Print an error message")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    print("Your request returned an invalid response! Status code: \(response.statusCode)!")
                } else if let response = response {
                    print("Your request returned an invalid response! Response: \(response)!")
                } else {
                    print("Your request returned an invalid response!")
                }
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            
            /* 5. Parse the data */
            print("getUserID: Parse the data \(data)")
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                print("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            guard let status_code = parsedResult["status_code"] as? Int where status_code == 13 else {
                print("Could not find key 'status_code' or unrecognized 'status_code' in  \(parsedResult)")
                return
            }
            
            /* 6. Use the data! */
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.unFavoriteButton.hidden = true
                self.favoriteButton.hidden = false
            })
        }
        
        /* 7. Start the request */
        task.resume()

    }
    
    @IBAction func favoriteButtonTouchUpInside(sender: AnyObject) {
        
        /* TASK: Add movie as favorite, then update favorite buttons */
        /* 1. Set the parameters */
        let methodParameters = [
            "api_key": appDelegate.apiKey,
            "session_id": appDelegate.sessionID!
        ]
        
        /* 2. Build the URL */
        let urlString = appDelegate.baseURLSecureString + "account/\(appDelegate.userID!)/favorite" + appDelegate.escapedParameters(methodParameters)
        let url = NSURL(string: urlString)!
        
        /* 3. Configure the request */
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"media_type\": \"movie\",\"media_id\": \(self.movie!.id),\"favorite\":true}".dataUsingEncoding(NSUTF8StringEncoding)
        
        /* 4. Make the request */
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                print("There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    print("Your request returned an invalid response! Status code: \(response.statusCode)!")
                } else if let response = response {
                    print("Your request returned an invalid response! Response: \(response)!")
                } else {
                    print("Your request returned an invalid response!")
                }
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            
            /* 5. Parse the data */
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                parsedResult = nil
                print("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            /* GUARD: Did we receive the correct status_code? */
            guard let status_code = parsedResult["status_code"] as? Int where status_code == 1 || status_code == 12 else {
                print("Could not find key 'status_code' or unrecognized 'status_code' in  \(parsedResult)")
                return
            }
            
            /* 6. Use the data! */
            dispatch_async(dispatch_get_main_queue()) {
                self.unFavoriteButton.hidden = false
                self.favoriteButton.hidden = true
            }
        }
        
        /* 7. Start the request */
        task.resume()
    }

    
}
