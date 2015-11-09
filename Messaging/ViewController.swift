//
//  ViewController.swift
//  Messaging
//
//  Created by Diego Deveras on 10/10/15.
//  Copyright © 2015 DDev. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var messageTableView: UITableView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var messageViewHeight: NSLayoutConstraint!

    
    var messagesArray:[String] = [String]()
    var senderMessages:[Bool] = [Bool]()
    
    var sender = "deverasd@gmail.com"
    var recipient = "abc123@gmail.com"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.messageTableView.delegate = self
        self.messageTableView.dataSource = self
        self.messageTextField.delegate = self
        
        let tapGesture:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tableViewTapped")
        self.messageTableView.addGestureRecognizer(tapGesture)
        
        self.getParticipants()
        self.retrieveMessages()
    
        self.messageTableView.separatorStyle = UITableViewCellSeparatorStyle.None
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    /*
        This function gets the sender and recipients from the data store and stores them in the variables
    */
    func getParticipants(){
        //TODO: Assign global sender and recipient variables to actual people
    }
    
    /*
        This function gets the messages from Parse
    */
    func retrieveMessages(){
        
        print(self.sender)
        print(self.recipient)
        
        let query1:PFQuery = PFQuery(className: "Message")
        query1.whereKey("Sender", equalTo:self.sender)
        //query1.whereKey("Recipient", equalTo:self.recipient)
        query1.findObjectsInBackgroundWithBlock {(objects: [PFObject]?, error: NSError?) -> Void in
            //Clear messages from array
            self.messagesArray = [String]()
    
            for messageObject in (objects)! {
                let messageText:String? = (messageObject as PFObject)["Text"] as? String
                let messageSender:String? = (messageObject as PFObject)["Sender"] as? String
                
                print(messageObject)
                
                if (messageText != nil){
                    self.messagesArray.append(messageText!)
                    
                    if(messageSender != nil){
                        if(messageSender == self.sender){
                            self.senderMessages.append(true)
                        } else {
                            self.senderMessages.append(false)
                        }
                    }
                }
            }
            
            dispatch_async(dispatch_get_main_queue()){
                self.messageTableView.reloadData();
            }
        }
    }
    
    /*
        This function is the listener for when the send button is pressed, it sends the message
        to the cloud and updates the list
    */
    @IBAction func sendButtonPressed(sender: AnyObject) {
        self.messageTextField.endEditing(true)
        
        
        self.messageTextField.enabled = false
        self.sendButton.enabled = false
        
        //Initializes the Variable
        let newMessage:PFObject = PFObject(className:"Message")
        
        //Set the text
        newMessage["Text"] = self.messageTextField.text
        newMessage["Sender"] = self.sender
        newMessage["Recipient"] = self.recipient
        
        
        //Saves the PFObject
        newMessage.saveInBackgroundWithBlock {(success: Bool, error: NSError?) -> Void in
            
            if (success) {
                self.retrieveMessages()
                print("Saved Successfully")
            } else {
                // There was a problem, check error.description
                NSLog(error!.description)
            }
            
            dispatch_async(dispatch_get_main_queue()){
                self.messageTextField.enabled = true
                self.sendButton.enabled = true
                self.messageTextField.text = ""
            }
        }
        
    }
    
    /*
        This function checks if the user tapped anywhere else from the textfield
        and if it does it deactivates the keyboard
    */
    func tableViewTapped(){
        self.messageTextField.endEditing(true)
    }
    
    //MARK: Textfield Delegate Methods
    
    /*
        This function moves the textfield when it is clicked so the user can enter a message
    */
    func textFieldDidBeginEditing(textField: UITextField) {
        self.view.layoutIfNeeded()
        UIView.animateWithDuration(0.5, animations: {
            
            self.messageViewHeight.constant = 315
            self.view.layoutIfNeeded()
            
            }, completion: nil)
    }
    
    /*
        This function moves the textfield back down to the original height
    */
    func textFieldDidEndEditing(textField: UITextField) {
        self.view.layoutIfNeeded()
        UIView.animateWithDuration(0.5, animations: {
            
            self.messageViewHeight.constant = 60
            self.view.layoutIfNeeded()
            
            }, completion: nil)
    }
    
    
    //MARK: Table View Delegate Methods
    
    /*
        This function displays the table
    */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell = (self.messageTableView.dequeueReusableCellWithIdentifier("MessageCell"))! as UITableViewCell
        cell.textLabel?.text = self.messagesArray[indexPath.row]
        
        
        if(self.senderMessages[indexPath.row]){
            cell.textLabel?.textAlignment = NSTextAlignment.Right
        }
        
        return cell
    }
    
    /*
        This function gets the number of rows in the table
    */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesArray.count
    }

}

