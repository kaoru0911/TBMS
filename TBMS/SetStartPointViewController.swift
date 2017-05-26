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
//    @IBOutlet weak var startingPointText: UITextField!
    
    @IBOutlet weak var chooseStartingPtBtn: UIButton!
    @IBOutlet weak var goToNextPage: UIButton!
    
    let keyNextPageSegID = "goToRearrangeScheduleVC"
    
    var startPoint : Attraction!
    var attractionsList : [Attraction]!
    var totalTrafficDetail : [LegsData]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        goToNextPage.isHidden = true
        chosenStartingPoint.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func chooseStartingBtnPressed(_ sender: UIButton) {
        
        let config = GMSPlacePickerConfig(viewport: nil)
        let placePicker = GMSPlacePicker(config: config)
        
        print("選起始點囉")
        
        placePicker.pickPlace(callback: { (place, error) -> Void in
            
            print("進入閉包囉")
            
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
        
    }
    
    func getTotalRouteInformation() {
        
        var origin : Attraction!
        var attractionNumber = attractionsList.count
        
        for place in attractionsList {
            
            guard origin != nil else {
                origin = place
                return
            }
            
            let routeGenerator = GoogleDirectionCaller()
            totalTrafficDetail = [LegsData]()
            routeGenerator.getRouteInformation(origin: origin.placeID, destination: place.placeID, completion: { (route) in
                
                self.totalTrafficDetail.append(routeGenerator.route)
                attractionNumber -= 1
                if attractionNumber == 0 {
                    self.performSegue(withIdentifier: self.keyNextPageSegID, sender: nil)
                }
            })
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc : RearrangeScheduleVC = segue.destination as! RearrangeScheduleVC
        vc.totalTrafficDetail = totalTrafficDetail
        vc.attractions = attractionsList
    }
}

struct Attraction {
    
    var attrctionName : String!
    var placeID : String!
    var coordinate : CLLocationCoordinate2D!
    var address : String?
    var phoneNumber : String?
    
    mutating func setValueToAttractionObject (place:GMSPlace) {
        
        attrctionName = place.name
        coordinate = place.coordinate
        placeID = place.placeID
        
        if let phoneNumber = place.phoneNumber { self.phoneNumber = phoneNumber }
        if let address = place.formattedAddress { self.address = address }
    }
}
