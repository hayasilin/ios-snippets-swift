//
//  Joke.swift
//  FirebaseTutorial
//
//  Created by KuanWei on 2017/12/28.
//  Copyright © 2017年 AppCoda. All rights reserved.
//

import Foundation
import Firebase

class Joke {
    
    private var ref: DatabaseReference!
    
    private var _jokeKey: String!
    private var _jokeText: String!
    private var _jokeVotes: Int!
    private var _username: String!
    
    var jokeKey: String {
        return _jokeKey
    }
    
    var jokeText: String {
        return _jokeText
    }
    
    var jokeVotes: Int {
        return _jokeVotes
    }
    
    var username: String {
        return _username
    }
    
    init(key:String, dictionary: Dictionary<String, AnyObject>)
    {
        self._jokeKey = key
        
        if let votes = dictionary["votes"] as? Int {
            self._jokeVotes = votes
        }
        
        if let joke = dictionary["jokeText"] as? String {
            self._jokeText = joke
        }
        
        if let user = dictionary["author"] as? String {
            self._username = user
        }
        else{
            self._username = ""
        }
        
        self.ref = Database.database().reference().ref.child("jokes").child(self._jokeKey)
    }
    
    func addSubtractVote(addVote: Bool) {
        
        if addVote {
            _jokeVotes = _jokeVotes + 1
        } else {
            _jokeVotes = _jokeVotes - 1
        }
    }
    
    
}
