//
//  JokeTableViewController.swift
//  FirebaseTutorial
//
//  Created by KuanWei on 2017/12/28.
//  Copyright © 2017年 AppCoda. All rights reserved.
//

import UIKit
import Firebase

class JokeTableViewController: UITableViewController {

    var jokes = [Joke]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let home = HomeViewController()
        
        home.jokeREf.observe(.value) { (snapshot: DataSnapshot) in
            
            self.jokes = []
            
            let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            
            for snap in postDict {

                let key = snap.key
                let value = snap.value as? [String: AnyObject] ?? [:]
                let joke = Joke(key: key, dictionary: value)

                self.jokes.insert(joke, at: 0)
            }
            
            self.tableView.reloadData()
            
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return jokes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath) as? JokeTableViewCell else{
            fatalError("Can not dequeu cell")
        }

        let joke = jokes[indexPath.row]
        
        cell.titleLabel.text = joke.jokeText
        cell.voteLabel?.text = String(joke.jokeVotes)
        
//        let vote = Database.database().reference().ref.child("jokes").child("votes").child(joke.jokeKey)
        let vote = Database.database().reference().ref.child("jokes").child(joke.jokeKey)
        
        vote.observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
            
            if let thumbsUpDown = snapshot.value as? NSNull {
                
                // Current user hasn't voted for the joke... yet.
                
                cell.voteImageView.image = UIImage(named: "thumb-down")
            } else {
                
                // Current user voted for the joke!
                
                cell.voteImageView.image = UIImage(named: "thumb-up")
            }
        }
        

        return cell
    }
    
    func updateCell(_ cell: JokeTableViewCell, _ indexPath: IndexPath)
    {
        let joke = jokes[indexPath.row]
        
        let vote = Database.database().reference().ref.child("jokes").child(joke.jokeKey)
//        let voteRef = vote.child("votes")
//        vote.child("votes").setValue(2)
        
        vote.observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
            
            print("snapshot value = \(snapshot.value)")
            
            if let thumbsUpDown = snapshot.value as? NSNull {
                
                cell.voteImageView.image = UIImage(named: "thumb-down")

                joke.addSubtractVote(addVote: true)
                vote.child("votes").setValue(joke.jokeVotes)

            } else {
                DispatchQueue.main.async {
                     cell.voteImageView.image = UIImage(named: "thumb-up")
                }
               
                joke.addSubtractVote(addVote: false)
//                vote.removeValue()
                vote.child("votes").setValue(joke.jokeVotes)
                
            }

        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        
        let cell = tableView.cellForRow(at: indexPath) as! JokeTableViewCell
        
        updateCell(cell, indexPath)
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
}
