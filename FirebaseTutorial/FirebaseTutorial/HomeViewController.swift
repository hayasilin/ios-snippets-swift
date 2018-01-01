//
//  HomeViewController.swift
//  FirebaseTutorial
//
//  Created by James Dacombe on 16/11/2016.
//  Copyright © 2016 AppCoda. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth


class HomeViewController: UIViewController {

    @IBOutlet weak var resultLabel: UILabel!
    var ref: DatabaseReference = Database.database().reference().ref.child("condition")
    
    public var jokeREf: DatabaseReference = Database.database().reference().ref.child("jokes")
    
    var userDisplayName: String?
    
    private let BASE_URL = "https://swiftdemo-aca7b.firebaseio.com"
//    private let USER_URL = FirebaseApp(url: "\(BASE_URL)/users")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            print("auth = \(auth)")
//            print("user = \(user)")
        }
        
        if Auth.auth().currentUser != nil {
            print("User is signed in")
            let user = Auth.auth().currentUser
            if let user = user {
                let uid = user.uid
                print("uid = \(uid)")
                let email = user.email
                print("email = \(email ?? "no email")")
//                let phtotURL = user.photoURL
//                print("photoURL = \(phtotURL)")
                userDisplayName = user.displayName
                
            }
        }else{
            print("No user is signed")
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        ref.child("condition").observe(.value) { (snap: DataSnapshot) in
//
//            let description = snap.value.debugDescription
//            self.resultLabel.text = description
//            print("snap description = \(description)")
//        }
        
    }
    
    @IBAction func deleteJoke(_ sender: UIButton)
    {
        let firebaseNewJoke = jokeREf.childByAutoId()
        firebaseNewJoke.removeValue()
    }
    
    
    func saveJoke(){
        let jokeText = "Third joke"
        
        if jokeText != "" {
            let newJoke: Dictionary<String, AnyObject> = [
                "jokeText": jokeText as AnyObject,
                "votes": 0 as AnyObject,
                "author": userDisplayName as AnyObject
            ]
            
            createNewJoke(joke: newJoke)
        }
    }
    
    func createNewJoke(joke: Dictionary<String, AnyObject>) {
        let firebaseNewJoke = jokeREf.childByAutoId()
        firebaseNewJoke.setValue(joke)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func setDisplayName(_ sender: UIButton)
    {
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = "111111"
        changeRequest?.commitChanges(completion: { (error) in
            print(error.debugDescription)
        })
        
        saveJoke()
    }
    
    
    @IBAction func foggyButton(_ sender: UIButton) {
        ref.setValue("foggy")
    }
    @IBAction func sunnyButton(_ sender: UIButton) {
        ref.setValue("sunny")
    }
    
    @IBAction func logOutAction(sender: AnyObject)
    {
        if Auth.auth().currentUser != nil {
            do {
                try Auth.auth().signOut()
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignUp")
                present(vc, animated: true, completion: nil)
                
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
}
