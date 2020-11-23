//
//  ScanMoleViewController.swift
//  MoleScan
//
//  Created by Asritha Bodepudi on 11/21/20.
//

import UIKit
import RealmSwift

class ScanMoleViewController: UIViewController {
    
//IBOUTLETS
    @IBOutlet weak var takePhotoButton: UIButton!
    @IBOutlet weak var takePhotoButtonBackgroundView: UIView!
    @IBOutlet weak var bodyImageVIew: UIImageView!
    
//VARIABLES
    let realm = try! Realm()
    let vc = UIImagePickerController()
    var moleImage = UIImage()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        takePhotoButton.layer.cornerRadius = 15
        takePhotoButtonBackgroundView.layer.cornerRadius = 15
        
        vc.allowsEditing = true
        vc.delegate = self
    }
    
    
    @IBAction func takePhotoButtonPressed(_ sender: UIButton) {
        takePhotoOfMole()
        
    }
    
    func presentDisplayDiagnosisViewController(){
        guard let displayDiagnosisVC = storyboard?.instantiateViewController(withIdentifier: "DisplayDiagnosisViewController")
                as? DisplayDiagnosisViewController else {
            
            assertionFailure("No view controller ID DisplayDiagnosisViewController in storyboard")
            return
        }
        // Delay the capture of snapshot by 0.1 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1 , execute: {
            displayDiagnosisVC.backingImage =  self.tabBarController?.view.asImage()
            displayDiagnosisVC.pictureOfMole = self.moleImage
            displayDiagnosisVC.modalPresentationStyle = .fullScreen
            self.present(displayDiagnosisVC, animated: false, completion: nil)
        })
        
    }
    
    
}


extension ScanMoleViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    func takePhotoOfMole(){
        let alert = UIAlertController(title: "Take Photo of Mole", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Use Camera", style: .default, handler: { action in
            self.vc.sourceType = .camera
            self.present(self.vc, animated: true)
            
        }))
        alert.addAction(UIAlertAction(title: "Upload from Photos", style: .default, handler: { action in
            self.vc.sourceType = .photoLibrary
            self.present(self.vc, animated: true)
        }))
        alert.view.tintColor = #colorLiteral(red: 0.0009610943962, green: 0.1301756203, blue: 0.4229097962, alpha: 1)
        self.present(alert, animated: true)
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if vc.sourceType == .camera{
            picker.dismiss(animated: true)
            
            guard let image = info[.editedImage] as? UIImage else {
                print("No image found")
                return
            }
            dismiss(animated: true)
            moleImage = image
            presentDisplayDiagnosisViewController()
            
        }
        else if vc.sourceType == .photoLibrary{
            
            
            if let possibleImage = info[.editedImage] as? UIImage {
                moleImage = possibleImage
            } else if let possibleImage = info[.originalImage] as? UIImage {
                moleImage = possibleImage
            } else {
                return
            }
            dismiss(animated: true)
            presentDisplayDiagnosisViewController()
        }
    }
}


