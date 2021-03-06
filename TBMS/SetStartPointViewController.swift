//
//  SetStartPointViewController.swift
//  TBMS
//
//  Created by Ryder Tsai on 2017/5/12.
//  Copyright © 2017年 Ryder Tsai. All rights reserved.
//

import UIKit
import GooglePlacePicker

class SetStartPointViewController: UIViewController {
    
    @IBOutlet weak var chosenStartingPoint: UILabel!
    @IBOutlet weak var chooseStartingPtBtn: UIButton!
    @IBOutlet weak var goToNextPage: UIButton!
    
    let keyNextPageSegID = "goToRearrangeScheduleVC"
    
    var startPoint : Attraction!
    var attractionsList : [Attraction]!
    var routesDetails : [LegsData]!
    var attractionsListToNextPage : [Attraction]!
    
    let shareData = DataManager.shareDataManager
    let generalModels = GeneralToolModels()
    
    var expectedTravelMode: TravelMod = .walking
    
    override func viewDidLoad() {
        super.viewDidLoad()
        goToNextPage.isHidden = true
        chosenStartingPoint.isHidden = true
        
        goToNextPage.layer.cornerRadius = 5.0
        chooseStartingPtBtn.layer.cornerRadius = 5.0
        
        // dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func travelModeValueChanged(_ sender: UISegmentedControl) {
        
        let index = sender.selectedSegmentIndex
        switch index {
        case 0:
            expectedTravelMode = .walking
        case 1:
            expectedTravelMode = .driving
        case 2:
            expectedTravelMode = .transit
        default:
            expectedTravelMode = .defaultValue
        }
    }
    
    @IBAction func chooseStartingBtnPressed(_ sender: UIButton) {
        
        let pickerGenerator = GooglePlacePickerGenerator()
        let placePicker = pickerGenerator.generatePlacePicker(selectedCountry: shareData.chooseCountry)
        
        placePicker.pickPlace(callback: { (place, error) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
            guard let place = place else {
                print("No place selected")
                return
            }
            
            self.chosenStartingPoint.isHidden = false
            self.goToNextPage.isHidden = false
            
            self.chosenStartingPoint.text = place.name
            self.chooseStartingPtBtn.titleLabel?.text = "重新選擇"
            
            self.startPoint = Attraction()
            self.startPoint.setValueToAttractionObject(place: place)
        })
    }
    
    @IBAction func goToNextPage(_ sender: Any) {
        
        guard startPoint != nil else {
            let alert = generalModels.prepareCommentAlertVC(title: "", message: "你忘了選擇出發地唷", cancelBtnTitle: "OK")
            present(alert, animated: true, completion: nil)
            return
        }
        
        guard attractionsList[0] != nil else {
            print("---attraList first element is nil----")
            return
        }
        
        guard attractionsList.isEmpty == false else {
            print("attraList is empty")
            return
        }
        
        // Present a loading view
        generalModels.customActivityIndicatory(self.view, startAnimate: true)
        
        let bestRoutePoductor = BestRouteCalculator(startingPoint: startPoint, attractionsList: attractionsList)
        
        bestRoutePoductor.getBestRoute {(bestRouteAttrList) in
            
            self.attractionsListToNextPage = bestRouteAttrList
            self.getTotalRouteInformation(completion: { _ in
                
                self.performSegue(withIdentifier: self.keyNextPageSegID, sender: nil)
            })
        }
    }
    
    func getTotalRouteInformation(completion: @escaping ()->Void ) {
        
        var origin = attractionsListToNextPage.first!
        var attractionsNumber = attractionsListToNextPage.count
        routesDetails = [LegsData]()
        print("attrList = \(attractionsListToNextPage.count)")
        
        for _ in 0...attractionsListToNextPage.count-1 {
            let blankLegsData = LegsData()
            routesDetails.append(blankLegsData)
            print("routeDetail = \(routesDetails.count)")
        }
        
        for i in 1...attractionsListToNextPage.count-1 {
            let destination = attractionsListToNextPage[i]
            
            let routeGenerator = GoogleDirectionCaller()
            routeGenerator.parametersSetting.travelMod = expectedTravelMode
            
            routeGenerator.getRouteInformation(origin: origin,
                                               destination: destination,
                                               completion: { (route) in
                                                
                                                print("i=\(i-1)")
                                                print("\(self.routesDetails[i-1].duration ?? "")")
                                                self.routesDetails[i-1] = route
                                                print("\(i-1).\(self.routesDetails[i].duration ?? "")")
                                                attractionsNumber -= 1
                                                print("attractionsNumber=\(attractionsNumber)")
                                                if attractionsNumber == 1 {
                                                    completion()
                                                }
            })
            origin = destination
        }
    }
    
    // For pressing return on the keyboard to dismiss keyboard
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        for textField in self.view.subviews where textField is UITextField {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func hideKeyboard() {
        view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let vc : RearrangeScheduleVC = segue.destination as! RearrangeScheduleVC
        vc.routesDetails = routesDetails
        vc.attractions = attractionsListToNextPage
        vc.selectedTravelMod = expectedTravelMode
        
        generalModels.customActivityIndicatory(self.view, startAnimate: false)
        
        generalModels.printAllAttractionsDetailToDebug(attractions: vc.attractions, debugTitle: "Prepare:")
    }
}

class PlaceObject : NSObject{
    var name : String!
    var location:CLLocationCoordinate2D!
    var trafficTime : Double!
}

struct Attraction {
    
    var attrctionName : String!
    var placeID : String!
    var coordinate : CLLocationCoordinate2D!
    var address : String?
    var phoneNumber : String?
    var trafficTime : Double!
    
    mutating func setValueToAttractionObject (place:GMSPlace) {
        
        attrctionName = place.name
        coordinate = place.coordinate
        placeID = place.placeID
        
        if let phoneNumber = place.phoneNumber { self.phoneNumber = phoneNumber }
        if let address = place.formattedAddress { self.address = address }
    }
}

//extension SetStartPointViewController {
//
//    override func viewWillAppear(_ animated: Bool) {
//        self.tabBarController?.tabBar.isHidden = false
//    }
//}
