//
//  AddJokeViewController.swift
//  FirebaseTutorial
//
//  Created by KuanWei on 2017/12/28.
//  Copyright © 2017年 AppCoda. All rights reserved.
//

import UIKit
import Firebase

class AddJokeViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    
    public var jokeREf: DatabaseReference = Database.database().reference().ref.child("jokes")
    
    var userDisplayName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
    
    func saveJoke(){
        let jokeText = textField.text
        
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

    @IBAction func doSaveAction(_ sender: UIButton)
    {
        saveJoke()
        
        navigationController?.popViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
