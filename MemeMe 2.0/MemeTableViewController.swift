//
//  MemeTableViewController.swift
//  MemeMe 2.0
//
//  Created by John Fowler on 11/1/20.
//
import Foundation
import UIKit

// MARK: - ViewController: UITableViewController

class MemeTableViewController: UITableViewController {
    
    // MARK: Properties
    
    // Get ahold of some memes, for the table
    // This is an array of meme instances
    // Creates an object that is a a delegate, then makes a variable AppDelegate that is downcast?? as AppDelegate
    // Then returns the .memes object from the AppDelegate

    @IBOutlet var appsTableView: UITableView?
    
    var memes: [Meme]! {
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        return appDelegate.memes
        
    }
    
    // Reloads the data on the table view after each save/share
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
   
    }
    
    
    // MARK: Table View Data Source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.memes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
    
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemeCell")!
        let meme = self.memes[(indexPath as NSIndexPath).row]
        tableView.delegate = self
        // Set the name and image
        cell.textLabel?.text = meme.topText
        cell.imageView?.image = meme.memedImage
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let detailController = self.storyboard!.instantiateViewController(withIdentifier: "MemeDetailViewController") as! MemeDetailViewController
            detailController.meme = self.memes[(indexPath as NSIndexPath).row]
        self.navigationController!.pushViewController(detailController, animated: true)
 
    }
}

