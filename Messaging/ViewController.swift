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
    @IBOutlet weak var recipientLabel: UILabel!

    var timer: NSTimer!
    var messagesArray:[String] = [String]()
    var senderMessages:[Bool] = [Bool]()
    
    var sender = "deverasd@gmail.com"
    var recipient = "abc123@gmail.com"
    var recipientName = "FUCKING NEIL"
    
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
    
    func refresh(){
        self.retrieveMessages()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /**
     This function automatically scrolls to the bottom of the UI Table View
    */
    func tableViewScrollToBottom(){
        let numberOfSections = self.messageTableView.numberOfSections
        let numberOfRows = self.messageTableView.numberOfRowsInSection(numberOfSections-1)
        
        if numberOfRows > 0 {
            let indexPath = NSIndexPath(forRow: numberOfRows-1, inSection: (numberOfSections-1))
            self.messageTableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
        }
    }
    
    /*
        This function gets the sender and recipients from the data store and stores them in the variables
    */
    func getParticipants(){
        self.view.bringSubviewToFront(self.recipientLabel);
        self.recipientLabel.text? = self.recipientName
    }
    
    /*
        This function gets the messages from Parse
    */
    func retrieveMessages(){
        
        let query1:PFQuery = PFQuery(className: "Message")
        query1.whereKey("Sender", equalTo:self.sender)
        query1.whereKey("Recipient", equalTo:self.recipient)
        
        
        let query2:PFQuery = PFQuery(className:"Message")
        query2.whereKey("Sender", equalTo:self.recipient)
        query2.whereKey("Recipient", equalTo:self.sender)
        
        let compoundQuery = PFQuery.orQueryWithSubqueries([query1, query2])
        compoundQuery.orderByAscending("createdAt")
        compoundQuery.findObjectsInBackgroundWithBlock {(objects: [PFObject]?, error: NSError?) -> Void in
            
            //Clear messages from array
            self.messagesArray = [String]()
    
            for messageObject in (objects)! {
                let messageText:String? = (messageObject as PFObject)["Text"] as? String
                let messageSender:String? = (messageObject as PFObject)["Sender"] as? String
                
                
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
                self.tableViewScrollToBottom()
            }
        }
    }
    
    /*
        This function is the listener for when the send button is pressed, it sends the message
        to the cloud and updates the list
    */
    @IBAction func sendButtonPressed(sender: AnyObject) {
        
        if self.messageTextField.text == "" {
            return
        }
        
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
            
            self.messageViewHeight.constant = 325
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
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.sendButtonPressed(self)
        self.textFieldDidEndEditing(self.messageTextField)
        return true
    }
    
    
    //MARK: Table View Delegate Methods
    
    /*
        This function displays the table
    */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell = (self.messageTableView.dequeueReusableCellWithIdentifier("MessageCell"))! as UITableViewCell
        cell.textLabel?.text = self.messagesArray[indexPath.row]
        
        
        if(self.senderMessages[indexPath.row] == true){
            cell.textLabel?.textAlignment = NSTextAlignment.Right
            cell.textLabel?.backgroundColor = UIColor.whiteColor()
        }else {
            cell.textLabel?.textAlignment = NSTextAlignment.Left
            cell.textLabel?.backgroundColor = UIColor.blueColor()
        }
        
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
        
        
        return cell
    }
    
    /*
        This function gets the number of rows in the table
    */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesArray.count
    }

}

