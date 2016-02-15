//
//  Config.swift
//  MovieTheatr
//
//  Created by Joseph Vallillo on 2/4/16.
//  Copyright © 2016 Joseph Vallillo. All rights reserved.
//

import UIKit
import Foundation

//MARK: - File Support
private let _documentsDirectoryURL: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first! as NSURL
private let _fileURL: NSURL = _documentsDirectoryURL.URLByAppendingPathComponent("TheMovieDB-Context")

//MARK: - Config

class Config: NSObject, NSCoding {
    
    //MARK: - Properties
    
    var baseImageURLString = "http://image.tmdb.org/t/p/"
    var baseImageSecureURLString = "https://image.tmdb.org/t/p/"
    var posterSizes = ["w92", "w154", "w185", "w342", "w500", "w780", "original"]
    var profileSizes = ["w45", "w185", "h632", "original"]
    var dateUpdated: NSDate? = nil
    
    var daysSinceLastUpdate: Int? {
        if let lastUpdate = dateUpdated {
            return Int(NSDate().timeIntervalSinceDate(lastUpdate)) / 60*60*24
        } else {
            return nil
        }
    }
    
    //MARK: - Init
    override init() {}
    convenience init?(dictionary: [String : AnyObject]) {
        self.init()
        
        if let imageDictionary = dictionary["images"] as? [String : AnyObject] {
            
            if let urlString = imageDictionary["base_url"] as? String {
                baseImageURLString = urlString
            } else {return nil}
            
            if let urlString = imageDictionary["secure_base_url"] as? String {
                baseImageSecureURLString = urlString
            } else {return nil}
            
            if let posterSizesArray = imageDictionary["poster_sizes"] as? [String] {
                posterSizes = posterSizesArray
            } else {return nil}
            
            if let profileSizesArray = imageDictionary["profile_sizes"] as? [String] {
                profileSizes = profileSizesArray
            } else {return nil}
            
            dateUpdated = NSDate()
            
        } else {
            return nil
        }
    }
    
    func updateIfDaysSinceUpdateExceeds(days: Int) {
        
        // If the config is up to date then return
        if let daysSinceLastUpdate = daysSinceLastUpdate {
            if (daysSinceLastUpdate <= days) {
                return
            }
        } else {
            updateConfiguration()
        }
    }
    
    func updateConfiguration() {
        
        /* TASK: Get TheMovieDB configuration, and update the config */
        
        /* Grab the app delegate and session */
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let session = NSURLSession.sharedSession()
        
        /* 1. Set the parameters */
        let methodParameters = [
            "api_key": appDelegate.apiKey
        ]
        
        /* 2. Build the URL */
        let urlString = appDelegate.baseURLSecureString + "configuration" + appDelegate.escapedParameters(methodParameters)
        let url = NSURL(string: urlString)!
        
        /* 3. Configure the request */
        let request = NSMutableURLRequest(URL: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
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
            
            /* Parse the data! */
            let parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! NSDictionary
            } catch {
                parsedResult = nil
                print("Could not parse the data as JSON: '\(data)'")
                return
            }
            
            /* 6. Use the data! */
            if let newConfig = Config(dictionary: parsedResult as! [String : AnyObject]) {
                appDelegate.config = newConfig
                appDelegate.config.save()
            } else {
                print("Could not parse config")
            }
        }
        
        /* 7. Start the request */
        task.resume()
    }
    
    // MARK: NSCoding
    
    let BaseImageURLStringKey = "config.base_image_url_string_key"
    let SecureBaseImageURLStringKey =  "config.secure_base_image_url_key"
    let PosterSizesKey = "config.poster_size_key"
    let ProfileSizesKey = "config.profile_size_key"
    let DateUpdatedKey = "config.date_update_key"
    
    required init(coder aDecoder: NSCoder) {
        baseImageURLString = aDecoder.decodeObjectForKey(BaseImageURLStringKey) as! String
        baseImageSecureURLString = aDecoder.decodeObjectForKey(SecureBaseImageURLStringKey) as! String
        posterSizes = aDecoder.decodeObjectForKey(PosterSizesKey) as! [String]
        profileSizes = aDecoder.decodeObjectForKey(ProfileSizesKey) as! [String]
        dateUpdated = aDecoder.decodeObjectForKey(DateUpdatedKey) as? NSDate
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(baseImageURLString, forKey: BaseImageURLStringKey)
        aCoder.encodeObject(baseImageSecureURLString, forKey: SecureBaseImageURLStringKey)
        aCoder.encodeObject(posterSizes, forKey: PosterSizesKey)
        aCoder.encodeObject(profileSizes, forKey: ProfileSizesKey)
        aCoder.encodeObject(dateUpdated, forKey: DateUpdatedKey)
    }
    
    func save() {
        NSKeyedArchiver.archiveRootObject(self, toFile: _fileURL.path!)
    }
    
    class func unarchivedInstance() -> Config? {
        
        if NSFileManager.defaultManager().fileExistsAtPath(_fileURL.path!) {
            return NSKeyedUnarchiver.unarchiveObjectWithFile(_fileURL.path!) as? Config
        } else {
            return nil
        }
    }

}