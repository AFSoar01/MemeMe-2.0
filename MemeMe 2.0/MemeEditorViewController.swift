//
//  ViewController.swift
//  MemeMe 2.0
//
//  Created by John Fowler on 10/30/20.
//

import UIKit

class MemeEditorViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {


    
    @IBOutlet weak var imageViewer: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var bottomToolBar: UIToolbar!
    @IBOutlet weak var topToolBar: UIToolbar!
    
    //If a user selects a meme object from a table or collection view, we need to pass it to the meme editor
    //This is a variable that will store the object
    
    var meme: Meme?
    
    
    var finalMemedImage: UIImage!
    
    let memeTextAttributes: [NSAttributedString.Key: Any] = [
        .strokeColor: UIColor.black,
        .foregroundColor: UIColor.white,
        .font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        .strokeWidth: -3.0,
    ]
    
    
    //MARK: - Control the View
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyBoardNotifications()
        shareButton.isEnabled = true
        if !UIImagePickerController.isCameraDeviceAvailable(UIImagePickerController.CameraDevice.front) {
            cameraButton.isEnabled = false
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureText(textField: topTextField, withText: "TOP")
        configureText(textField: bottomTextField, withText: "BOTTOM")
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super .viewWillDisappear(animated)
        unsubscribeFromKeyBoardNotifications()
        self.navigationController?.isNavigationBarHidden = false
    }
    
    //Dismiss the view
    
    @IBAction func dismissEditor(){
        //self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
        //self.navigationController?.isNavigationBarHidden = false
        
        
    }
    
    //Unwrap the selected meme object from the Table and Collection views + configure text if no value sent
    
    func configureText(textField: UITextField, withText text: String) {
        textField.defaultTextAttributes = memeTextAttributes
        textField.text = text
        textField.textAlignment = .center
        textField.delegate = self
    }
    
    
    
    // MARK: - Build the Meme
    
    func subscribeToKeyBoardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    func unsubscribeFromKeyBoardNotifications() {
        NotificationCenter.default.removeObserver(self)
        
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        if bottomTextField.isFirstResponder {
            view.frame.origin.y -= getKeyBoardHeight(notification)
        }
        
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        view.frame.origin.y = 0
    }
    
    func getKeyBoardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
        
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        bottomTextField.resignFirstResponder()
        return true
    }
    
    //Choose to Pick Image from Album
    @IBAction func pickAnImageFromAlbum(_ sender: Any) {
        chooseImageFromCameraOrPhoto(source: .photoLibrary)
    }
    
    //Choose to Pick Image from Camera
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        chooseImageFromCameraOrPhoto(source: .camera)
    }
    
    //Pick Image
    func chooseImageFromCameraOrPhoto(source: UIImagePickerController.SourceType) {
        
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = source
        pickerController.allowsEditing = true
        present(pickerController, animated: true, completion: nil)
        
    }
    
    
    //SHARE BUTTON
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            let croppedImage = cropImage(image: image, rect: imageViewer.frame) // as! CGRect)
            imageViewer.image = croppedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func cropImage(image: UIImage, rect: CGRect) -> UIImage {
        let cgImage = image.cgImage! // better to write "guard" in realm app
        let croppedCGImage = cgImage.cropping(to: rect)
        return UIImage(cgImage: croppedCGImage!)
    }
    
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //Generate the Meme Image
    func generateMemedImage() -> UIImage {
        //Hide the ToolBar and ShareButton
        self.bottomToolBar.isHidden = true
        self.topToolBar.isHidden = true
        //self.shareButton.isHidden = true
        
        //Draw the Image - Make the Meme
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let bigImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        finalMemedImage = bigImage
        UIGraphicsEndImageContext()
        //view
        
        //Return the ToolBar and ShareButton
        self.bottomToolBar.isHidden = false
        //self.shareButton.isHidden = false
        
        return bigImage
    }
    
    
    //Save the meme as a Meme Struct Instance
    func save() {
        // Create the meme
        let meme = Meme(
            topText: topTextField.text!,
            bottomText: bottomTextField!.text!,
            originalImage: imageViewer!.image!,
            memedImage: finalMemedImage!)
        
        // Add it to the memes array in the Application Delegate
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        appDelegate.memes.append(meme)
        print("Saved")
        print(appDelegate.memes.count)
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

extension MemeEditorViewController {
    @IBAction func share() {
        
        if self.imageViewer.image == nil {
            shareAlert()
        }
        
        else {
            
            //Define an instance of the ActivityViewController
            let item = [generateMemedImage()]    //[finalMemedImage]
            let activityController = UIActivityViewController(activityItems: item, applicationActivities: nil)
            
            
            //Present the ActivityViewController
            self.present(activityController, animated: true, completion: nil)
            
            //Completion handler
            activityController.completionWithItemsHandler = { (activityType: UIActivity.ActivityType?, completed:                         Bool, arrayReturnedItems: [Any]?, error: Error?) in
                if completed {
                    print("share completed")
                    self.save()
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
