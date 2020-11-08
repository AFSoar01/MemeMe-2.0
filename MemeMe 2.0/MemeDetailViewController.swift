//
//  MemeDetailViewController.swift
//  MemeMe 2.0
//
//  Created by John Fowler on 11/5/20.
//

import Foundation
import UIKit

//
//  ViewController.swift
//  MemeMe 2.0
//
//  Created by John Fowler on 10/30/20.
//

import UIKit

class MemeDetailViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {
    
    
    
    @IBOutlet weak var imageViewer: UIImageView!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    
    //If a user selects a meme object from a table or collection view, we need to pass it to the meme editor
    //This is a variable that will store the object

    
    var meme: Meme?
    
  
    //MARK: - Control the View
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.imageViewer!.image = meme?.memedImage
        //subscribeToKeyBoardNotifications()
        shareButton.isEnabled = true

        }
        
    
    
    override func viewDidLoad() {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super .viewWillDisappear(animated)
        //unsubscribeFromKeyBoardNotifications()
    }
    
    //Dismiss the view
    
    @IBAction func dismissEditor(){
        //self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
        self.navigationController?.isNavigationBarHidden = false
        
        
    }
   
   
    func shareAlert() {
        let alert = UIAlertController(title: "MemeMe", message: "Please Select An Image.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
}





//MARK: - Share the Meme Object

extension MemeDetailViewController {
    @IBAction func share() {
        
        if self.imageViewer.image == nil {
            shareAlert()
        }
        
        else {
            
            //Define an instance of the ActivityViewController

            let item = [meme?.memedImage]
            let activityController = UIActivityViewController(activityItems: item, applicationActivities: nil)
            
            
            //Present the ActivityViewController
            self.present(activityController, animated: true, completion: nil)
            
            //Completion handler
            activityController.completionWithItemsHandler = { (activityType: UIActivity.ActivityType?, completed:                         Bool, arrayReturnedItems: [Any]?, error: Error?) in
                if completed {
                    print("share completed")
                    //self.save()
                    self.navigationController?.popViewController(animated: true)
                    return
                } else {
                    print("cancel")
                }
                if let shareError = error {
                    print("error while sharing: \(shareError.localizedDescription)")
                }
            }
        }
    }
    
}
