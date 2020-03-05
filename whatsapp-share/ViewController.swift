//
//  ViewController.swift
//  whatsapp-share
//
//  Created by Alisher Aidarkhan on 3/5/20.
//  Copyright © 2020 adrlab. All rights reserved.
//
// DO NOT FORGET ADD UIDocumentInteractionControllerDelegate

import UIKit

class ViewController: UIViewController, UIDocumentInteractionControllerDelegate {

    @IBOutlet weak var urlTextField: UITextField!
    
    //UIDocumentInteractionController property
    var documentationInteractionController: UIDocumentInteractionController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Connecting interaction controller delegate
        self.documentationInteractionController?.delegate = self
    }

    @IBAction func buttonTapped(_ sender: UIButton) {
        //Get file URL from texField
        let textFieldString = urlTextField.text!
        //Creating audioURL type of URL
        if let audioUrl = URL(string: textFieldString) {
            //Find Documents destination on device
            let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            //Appending filename to Document path
            let destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent)
            //Check file existing
            if FileManager.default.fileExists(atPath: destinationUrl.path) {
                print("file exist")
                //Function that show Sharing view. Should pass destinationUrl
                self.showShareView(destinationUrl)
                //Deleting downloaded file if neded
                //do { try FileManager.default.removeItem(atPath: destinationUrl.path) }
                //catch { print(error) }
            }
            else {
                print("file does not exist")
                //Function downloads file from URL which is in textField.
                //Function takes audio file url, where is it located and
                //destination url which is where application should save file.
                //In our case it is Documents folder of application
                self.downloadFile(audioUrl, destinationUrl)
                
                //After downloading application calls showShareView function
                //to show Sharing view. It takes destinationUrl which is
                //destination to the file in application (Documents/filename)
                DispatchQueue.main.async {
                    self.showShareView(destinationUrl)
                }
            }
        }
    }
    
    //MARK: - Audio downloading function from web URL
    func downloadFile(_ audioURL: URL, _ destinationUrl: URL) {
        //In this function application downloads file from web URL(audioURL) and
        //saves file to Document folder(destinationUrl) with his original name
        URLSession.shared.downloadTask(with: audioURL) { location, response, error in
            guard let location = location, error == nil else { return }
            do { try FileManager.default.moveItem(at: location, to: destinationUrl) }
            catch { print(error) }
        }.resume()
    }
    
    //MARK: - Sharing view showing function
    func showShareView(_ destinationUrl: URL) {
        //Firstly application checks is whatsapp installed on phone.
        //If you does not need this checking you can delete
        // !!! IF YOU NEED CHECKING, DOES NOT FORGET IMPORTING IN info.plist FILE LSApplicationQueriesSchemes AS ARRAY
        // AND ADD ARRAY ITEM whatsapp AS A STRING !!!
        if let aString = URL(string: "whatsapp://app") {
            if UIApplication.shared.canOpenURL(aString) {
                //This is whatsapp integrating settings
                self.documentationInteractionController?.uti = "net.whatsapp.audio"
                //Integrating sharing file with destinationUrl property value
                self.documentationInteractionController = UIDocumentInteractionController(url: destinationUrl)
                self.documentationInteractionController?.presentOpenInMenu(from: CGRect(x: 0, y: 0, width: 0, height: 0), in: self.view, animated: true)
            } else {
                //If whatsapp is not installed, application shows error modal view
                let alert = UIAlertController(title: "Error", message: "No WhatsApp installed on your iPhone.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                    NSLog("The \"OK\" alert occured.")
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
}

