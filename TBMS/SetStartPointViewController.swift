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
        
        print(attractionsList.first!.attrctionName!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
<<<<<<< HEAD
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
=======
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
    
>>>>>>> 3912fc87e07f80bd01048c416e9827171ea69347
    
    @IBAction func chooseStartingBtnPressed(_ sender: UIButton) {
        
        let config = GMSPlacePickerConfig(viewport: nil)
        let placePicker = GMSPlacePicker(config: config)
        
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
        
        let bestRoutePoductor = BestRouteCalculator(startingPoint: startPoint, attractionsList: attractionsList)
        bestRoutePoductor.getBestRoute { (bestRouteAttrList) in
            
            self.attractionsListToNextPage = bestRouteAttrList
            self.getTotalRouteInformation( completion: { _ in
                
                self.performSegue(withIdentifier: self.keyNextPageSegID, sender: nil)
            })
        }
    }
    
    func getTotalRouteInformation(completion: @escaping ()->Void ) {
        
        var origin = attractionsListToNextPage.first!
        var attractionsNumber = attractionsListToNextPage.count
        
        for i in 1...attractionsListToNextPage.count-1 {
            let destination = attractionsListToNextPage[i]
            routesDetails = [LegsData]()
            
            let routeGenerator = GoogleDirectionCaller()
            routeGenerator.parametersSetting.travelMod = expectedTravelMode
            routeGenerator.getRouteInformation(origin: origin.placeID,
                                               destination: destination.placeID,
                                               completion: { (route) in
                                                self.routesDetails.append(route)
                                                attractionsNumber -= 1
                                                print(attractionsNumber)
                                                if attractionsNumber == 1 {
                                                    completion()
                                                }
            })
            origin = destination
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc : RearrangeScheduleVC = segue.destination as! RearrangeScheduleVC
        vc.routesDetails = routesDetails
        vc.attractions = attractionsListToNextPage
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
