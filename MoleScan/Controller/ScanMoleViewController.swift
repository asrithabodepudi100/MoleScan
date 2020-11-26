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
    @IBOutlet weak var bodyImageVew: UIImageView!
    
    @IBOutlet weak var instructionsBackgroundBox: UIView!
    
    //VARIABLES
    let realm = try! Realm()
    let vc = UIImagePickerController()
    var moleImage = UIImage()

    
    //TAP VARIABLES
    var tap = UITapGestureRecognizer()
    var moleThatHasBeenDiagnosedToPass = MoleEntry()
    let shapeLayer = CAShapeLayer()
    var point = CGPoint(x: 0, y: 0)
    var moleLayers: [CAShapeLayer] = []
    var molePaths: [CGPoint] = []
    
    
    //MENU VARIABLES
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var menuTransparentView: UIView!
    var inital: CGFloat!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        takePhotoButton.layer.cornerRadius = 15
        takePhotoButtonBackgroundView.layer.cornerRadius = 15
        instructionsBackgroundBox.layer.cornerRadius = 15
        
        vc.allowsEditing = true
        vc.delegate = self
        
        self.inital = self.menuView.frame.origin.x
        menuTransparentView.isUserInteractionEnabled = false
        menuTransparentView.backgroundColor = UIColor.clear
        
        
            let gesture = UITapGestureRecognizer(target: self, action: #selector(self.someAction(_:)))
            // or for swift 2 +
            _ = UITapGestureRecognizer(target: self, action:  #selector (self.someAction (_:)))
            self.menuTransparentView.addGestureRecognizer(gesture)
    }
  
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.layer.addSublayer(shapeLayer)
        tap = UITapGestureRecognizer(target: self, action: #selector(ScanMoleViewController.tappedMe))
        bodyImageVew.addGestureRecognizer(tap)
        bodyImageVew.isUserInteractionEnabled = true
        
        //load and place already existing dots on body
        if realm.objects(MoleEntry.self).count != 0 {
            for object in realm.objects(MoleEntry.self) {
                let mole = CGPoint(x: CGFloat(object.positionOnBodyXCoordinate), y: CGFloat(object.positionOnBodyYCoordinate))
                let circlePath = UIBezierPath(arcCenter: mole, radius: CGFloat(5), startAngle: CGFloat(0), endAngle: CGFloat(Double.pi * 2), clockwise: true)
                let moleLayer = CAShapeLayer()
                molePaths.append(mole)
                moleLayer.path = circlePath.cgPath
                if object.diagnosis == "The image below may show a benign mole. We recommend you contact a dermatologist for an evaluation if concerns about your mole persist."{
                    
                    moleLayer.fillColor = #colorLiteral(red: 0, green: 0.3884513974, blue: 0, alpha: 1)
                    moleLayer.strokeColor = #colorLiteral(red: 0, green: 0.3884513974, blue: 0, alpha: 1)
                }
                else if object.diagnosis == "The image below may show a malignant mole. We recommend you contact a dermatologist at your earliest convenience."{
                    moleLayer.fillColor = #colorLiteral(red: 0.9983811975, green: 0.3601943254, blue: 0.2774392366, alpha: 1)
                    moleLayer.strokeColor = #colorLiteral(red: 0.9983811975, green: 0.3601943254, blue: 0.2774392366, alpha: 1)
                }
                moleLayer.lineWidth = 3.0
                moleLayers.append(moleLayer)
                view.layer.addSublayer(moleLayer)
            }
        }
    }
    
    //When user taps on screen, draw purple circle
    @objc func tappedMe(){
        point = tap.location(in: self.view)
        let circlePath = UIBezierPath(arcCenter: point, radius: CGFloat(10), startAngle: CGFloat(0), endAngle: CGFloat(Double.pi * 2), clockwise: true)
        shapeLayer.path = circlePath.cgPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        shapeLayer.lineWidth = 3.0
    }
    
    //When user taps on image, pull up data for that mole if one exists at that spot
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let point = touch!.location(in: self.view)
        for layer in moleLayers {
            if layer.path!.contains(point){
                for object in realm.objects(MoleEntry.self) {
                    let mole = CGPoint(x: CGFloat(object.positionOnBodyXCoordinate), y: CGFloat(object.positionOnBodyYCoordinate))
                    if mole == molePaths[moleLayers.firstIndex(of: layer)!] {
                        moleThatHasBeenDiagnosedToPass = object
                        guard let displayDiagnosisViewController = storyboard?.instantiateViewController(withIdentifier: "DisplayDiagnosisViewController")
                                as? DisplayDiagnosisViewController else {
                            assertionFailure("No view controller ID ReactionViewController in storyboard")
                            return
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1 , execute: {
                            displayDiagnosisViewController.modalPresentationStyle = .fullScreen
                            displayDiagnosisViewController.backingImage = self.view.asImage()
                            displayDiagnosisViewController.passedInMole = self.moleThatHasBeenDiagnosedToPass
                            print (self.moleThatHasBeenDiagnosedToPass.diagnosis)
                            displayDiagnosisViewController.LoadExistingDiagnosis = true
                            self.present(displayDiagnosisViewController, animated: false, completion: nil)
                        })
                    }
                }
            }
        }
    }
    
    @IBAction func takePhotoButtonPressed(_ sender: UIButton) {
        presentDisplayDiagnosisViewController()
        takePhotoOfMole()
    }
    
    func presentDisplayDiagnosisViewController(){
        
        if point != CGPoint(x: 0, y: 0){
            guard let displayDiagnosisVC = storyboard?.instantiateViewController(withIdentifier: "DisplayDiagnosisViewController")
                    as? DisplayDiagnosisViewController else {
                
                assertionFailure("No view controller ID DisplayDiagnosisViewController in storyboard")
                return
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1 , execute: {
                displayDiagnosisVC.modalPresentationStyle = .fullScreen
                displayDiagnosisVC.pictureOfMole = self.moleImage
                displayDiagnosisVC.backingImage = self.view.asImage()
                displayDiagnosisVC.xcood = Double (self.point.x)
                displayDiagnosisVC.ycood = Double (self.point.y)
                self.present(displayDiagnosisVC, animated: false, completion: nil)
            })
            
        }
        else{
            let alert = UIAlertController(title: "Please select a spot on the  body", message: "You must select where your mole is present.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            
            self.present(alert, animated: true)
            
        }
        
        
    }
}
    
    //MARK: - Image Picker Delegate
    
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


//MARK: - Menu Methods Delegate

extension ScanMoleViewController {
    @IBAction func openMenuButtonPressed(_ sender: UIButton) {
        self.menuView.alpha = 1
       UIView.animate(withDuration: 0.3) {
           self.menuTransparentView.backgroundColor = UIColor.black
           self.menuTransparentView.alpha = 0.5
        }
        menuTransparentView.isUserInteractionEnabled = true

       
         UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut) {
             self.menuView.frame.origin.x = self.view.frame.origin.x
         } completion: { _ in ()
              
       }
        tabBarController?.tabBar.backgroundColor = UIColor.clear
        
    }
    
    @objc func someAction(_ sender:UITapGestureRecognizer){
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut) {
            self.menuView.frame.origin.x = self.inital
        } completion: { _ in ()
            
        }
        menuTransparentView.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.3) {
           self.menuTransparentView.backgroundColor = UIColor.clear
        }

    }
}
