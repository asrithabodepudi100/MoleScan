//
//  MyDoctorsViewController.swift
//  MoleScan
//
//  Created by Asritha Bodepudi on 11/7/20.
//

import UIKit
import RealmSwift
import MapKit

class MyDoctorsViewController: UIViewController, UISearchBarDelegate {
/* used for dynamic hieght of text view inside table view cell:
    https://www.swiftdevcenter.com/the-dynamic-height-of-uitextview-inside-uitableviewcell-swift/ */
        
    
    let realm = try! Realm()
    
    @IBOutlet weak var searchForDermatologistsNearMeSearchBar: UISearchBar!
    @IBOutlet weak var addNewDoctorButton: UIButton!
    @IBOutlet weak var contactDoctorButton: UIButton!
    @IBOutlet weak var myDoctorsTableView: UITableView!
    
    @IBOutlet weak var searchForDermatologistsNearMeMapView: MKMapView!
    
    @IBAction func addNewDoctorButtonPressed(_ sender: Any) {
        let newDoctor = Doctor()
        do {
            try realm.write{
                realm.add(newDoctor)
            }
        }
        catch {
            print (error)
        }
        myDoctorsTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchForDermatologistsNearMeSearchBar.delegate = self
        let nib = UINib(nibName: "DoctorTableViewCell", bundle: nil)
        self.myDoctorsTableView.register(nib, forCellReuseIdentifier: "DoctorTableViewCell")
        self.myDoctorsTableView.dataSource = self
        self.myDoctorsTableView.tableFooterView = UIView()
        self.myDoctorsTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.myDoctorsTableView.backgroundColor = UIColor.clear
   
        searchForDermatologistsNearMeSearchBar.backgroundImage = UIImage()
        addNewDoctorButton.layer.cornerRadius = 15
        contactDoctorButton.layer.cornerRadius = 15
        
      
        myDoctorsTableView.reloadData()
        
        searchForDermatologistsNearMeMapView.layer.cornerRadius = 15
        // Set initial location in Honolulu
        let initialLocation = CLLocation(latitude:42.431820, longitude: -71.210030)
        searchForDermatologistsNearMeMapView.centerToLocation(initialLocation)
        
        findDermatologistsNearMe()
       

    }
    // When button "Search" pressed
     func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
         print("end searching --> Close Keyboard")
         self.searchForDermatologistsNearMeSearchBar.endEditing(true)
      
        
        let address = searchForDermatologistsNearMeSearchBar.text ?? "40 Tower Road"

            let geoCoder = CLGeocoder()
           print( geoCoder.geocodeAddressString(address) { (placemarks, error) in
                guard
                    let placemarks = placemarks,
                    let location = placemarks.first?.location
                else {
                    // handle no location found
                    return
                }
                print (location)
            self.searchForDermatologistsNearMeMapView.centerToLocation(location)
            self.findDermatologistsNearMe()
                // Use your location
            })
     }
    
    func findDermatologistsNearMe(){
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = "Dermatology"
        searchRequest.region = searchForDermatologistsNearMeMapView.region
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            guard let response = response else {
                print("Error: \(error?.localizedDescription ?? "Unknown error").")
                return
            }

            for item in response.mapItems {
                self.searchForDermatologistsNearMeMapView.addAnnotation(item.placemark)
            }
        }
    }
  
}

private extension MKMapView {
  func centerToLocation(
    _ location: CLLocation,
    regionRadius: CLLocationDistance = 20000
  ) {
    let coordinateRegion = MKCoordinateRegion(
      center: location.coordinate,
      latitudinalMeters: regionRadius,
      longitudinalMeters: regionRadius)
    setRegion(coordinateRegion, animated: true)
  }
}

//MARK: - MapKit Methods














//MARK: - Table View Datasource Methods

extension MyDoctorsViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
       return realm.objects(Doctor.self).count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DoctorTableViewCell", for: indexPath) as! DoctorTableViewCell
       cell.cellDelegate = self
        cell.selectionStyle = .none
    
      /*  cell.doctorTypeTextView.delegate = self
        cell.doctorTypeTextView.accessibilityIdentifier = "doctorTypeTextView"
        cell.nameTextView.delegate = self
        cell.nameTextView.accessibilityIdentifier = "nameTextView"
        cell.phoneNumberTextView.delegate = self
        cell.phoneNumberTextView.accessibilityIdentifier = "phoneNumberTextView"
        cell.emailTextView.delegate = self
        cell.emailTextView.accessibilityIdentifier = "emailTextView"
        cell.notesTextView.delegate = self
        cell.notesTextView.accessibilityIdentifier = "notesTextView"

     */
        return cell
    }
}




/*
//MARK: - Text View Methods

extension MyDoctorsViewController: UITextViewDelegate{
    
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text == ""
        {
            myDoctorsTableView.reloadData()
        }
        let size = textView.bounds.size
        let newSize = myDoctorsTableView.sizeThatFits(CGSize(width: size.width,
                                                    height: CGFloat.greatestFiniteMagnitude))
        if size.height != newSize.height {
            UIView.setAnimationsEnabled(false)
            myDoctorsTableView.beginUpdates()
            myDoctorsTableView.endUpdates()
            UIView.setAnimationsEnabled(true)
            let cell = UITableViewCell()
            if let thisIndexPath = myDoctorsTableView.indexPath(for: cell) {
                myDoctorsTableView.scrollToRow(at: thisIndexPath, at: .bottom, animated: false)
            }
        }
    }
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        let buttonPosition:CGPoint = textView.convert(CGPoint.zero, to:self.myDoctorsTableView)
        if let indexPath = self.myDoctorsTableView.indexPathForRow(at: buttonPosition){
            do {
                try! realm.write {
                    
                    
                    if textView.accessibilityIdentifier == "doctorTypeTextView"{
                        realm.objects(Doctor.self)[indexPath[1]].doctorType = (textView.text!)
                    }
                    else if textView.accessibilityIdentifier == "nameTextView"{
                        realm.objects(Doctor.self)[indexPath[1]].name = (textView.text!)
                    }
                    else if textView.accessibilityIdentifier == "phoneNumberTextView"{
                        realm.objects(Doctor.self)[indexPath[1]].phone = (textView.text!)
                    }
                    else if textView.accessibilityIdentifier == "emailTextView"{
                        realm.objects(Doctor.self)[indexPath[1]].email = (textView.text!)
                    }
                    else if textView.accessibilityIdentifier == "notesTextView"{
                        realm.objects(Doctor.self)[indexPath[1]].notes = (textView.text!)
                        
                    }
                }
            }
        }
        if textView.text == ""
        {
            myDoctorsTableView.reloadData()
        }
    }
}


//MARK: - Keyboard Methods

extension MyDoctorsViewController
{
    func hideKeyboardWhenUserTapsElsewhereOnScreen()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(MyDoctorsViewController.dismissKeyboard))
        
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
}*/
extension MyDoctorsViewController: GrowingCellProtocol {
    
    func updateHeightOfRow(_ cell: DoctorTableViewCell, _ textView: UITextView) {
        let size = textView.bounds.size
        let newSize = myDoctorsTableView.sizeThatFits(CGSize(width: size.width,
                                                        height: CGFloat.greatestFiniteMagnitude))
        if size.height != newSize.height {
            UIView.setAnimationsEnabled(false)
            myDoctorsTableView?.beginUpdates()
            myDoctorsTableView?.endUpdates()
            UIView.setAnimationsEnabled(true)
            if let thisIndexPath = myDoctorsTableView.indexPath(for: cell) {
                myDoctorsTableView.scrollToRow(at: thisIndexPath, at: .bottom, animated: false)
            }
        }
    }
}
