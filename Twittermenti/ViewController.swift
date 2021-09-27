//
//  ViewController.swift
//  Twittermenti
//
//  Created by Angela Yu on 17/07/2019.
//  Copyright © 2019 London App Brewery. All rights reserved.
//

import UIKit
import SwifteriOS
import CoreML
import SwiftyJSON

class ViewController: UIViewController {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sentimentLabel: UILabel!
    
    let sentimentClassifier = TweetSentimentClassifier()
    
    let swifter = Swifter(consumerKey: K.consumerKey, consumerSecret: K.consumerSecret)
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func predictPressed(_ sender: Any) {
         fetchTweets()
    }
    

    func fetchTweets() {
        if let searchText = textField.text {
            swifter.searchTweet(using: searchText, lang: "en", count: K.tweetCount, tweetMode: .extended) { results, metadata in
             
             var tweets = [TweetSentimentClassifierInput]()
                for i in 0..<K.tweetCount {
                 if let tweet = results[i]["full_text"].string {
                     let tweetClassification = TweetSentimentClassifierInput(text: tweet)
                     tweets.append(tweetClassification)
                 }
             }

            
                self.makePrediction(with: tweets)
             
             
         } failure: { error in
             print("There was an error with Twitter API request, \(error)")
         }
         }
        
    }
    
    func makePrediction(with tweets: [TweetSentimentClassifierInput]) {
        do {
            let predictions = try self.sentimentClassifier.predictions(inputs: tweets)
            
            var sentimentScore = 0
            
            for prediction in predictions {
                let sentiment  = prediction.label
                if sentiment == "Pos" {
                    sentimentScore += 1
                } else if sentiment == "Neg" {
                    sentimentScore -= 1
                }
            }
            print(sentimentScore)
            updateUI(with: sentimentScore)

        } catch {
            print("There was error making prediction \(error)")
        }
    }
    
    func updateUI(with sentimentScore: Int){
        if sentimentScore > 20 {
            self.sentimentLabel.text = "😍"
        } else if sentimentScore > 10 {
            self.sentimentLabel.text = "😄"
        } else if sentimentScore > 0 {
            self.sentimentLabel.text = "🙂"
        } else if sentimentScore == 0 {
            self.sentimentLabel.text = "😐"
        } else if sentimentScore > -10 {
            self.sentimentLabel.text = "😕"
        } else if sentimentScore > -20 {
            self.sentimentLabel.text = "😡"
        } else {
            self.sentimentLabel.text = "🤮"
        }
    }
}

