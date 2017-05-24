//
//  AddViewPointViewController.swift
//
//
//  Created by Ryder Tsai on 2017/5/12.
//
//

import UIKit
import GoogleMaps
import GooglePlaces
import GooglePlacePicker

class AddViewPointViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var spotTextView: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var spotTableView: UITableView!
    
    var placeIdStorage:String!
    
    var tmpPlaceData : GMSPlace!
    var tmpPlaceDataStorage : [GMSPlace]!
    
    // 用placeID取得google第一張地點照片，並呼叫loadImageForMetadata
    func loadFirstPhotoForPlace(placeID: String) {
        GMSPlacesClient.shared().lookUpPhotos(forPlaceID: self.placeIdStorage) { (photos, error) -> Void in
            if let error = error {
                // TODO: handle the error.
                print("Error: \(error.localizedDescription)")
            } else {
                if let firstPhoto = photos?.results.first {
                    self.loadImageForMetadata(photoMetadata: firstPhoto)
                }
            }
        }
    }
    
    // 選取要從陣列載入的相片，並放在imageView
    func loadImageForMetadata(photoMetadata: GMSPlacePhotoMetadata) {
        GMSPlacesClient.shared().loadPlacePhoto(photoMetadata, callback: {
            (photo, error) -> Void in
            if let error = error {
                // TODO: handle the error.
                print("Error: \(error.localizedDescription)")
            } else {
                self.imageView.image = photo;
                //self.attributionTextView.attributedText = photoMetadata.attributions;
            }
        })
    }
    
    // TableView陣列
    var ListArray: NSMutableArray = []
    var placesClient: GMSPlacesClient!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        placesClient = GMSPlacesClient.shared()
        
        //self.navigationController?.navigationBar.isTranslucent = false
    }
    
    func goSetStartPointPage() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let setStartPointViewController = storyboard.instantiateViewController(withIdentifier :"SetStartPointViewController") as! SetStartPointViewController
        
        let attractionsList = setValueToAttractionsList()
        setStartPointViewController.attractionsList = attractionsList
        
        self.navigationController?.pushViewController(setStartPointViewController, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ListArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: viewPointTableViewCell = tableView.dequeueReusableCell(withIdentifier: "viewPointTableViewCell") as! viewPointTableViewCell
        
        cell.noCellLabel.text = "\(indexPath.row + 1 ). "
        cell.spotCellLabel.text = "\(ListArray.object(at: indexPath.row))"
        //        cell.textLabel?.text = "\(ListArray.object(at: indexPath.row))"
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        self.ListArray.removeObject(at: indexPath.row)
        
        self.spotTableView.reloadData()
        
    }
    
    @IBAction func addSpotBtn(_ sender: Any) {
        
        // 檢查是否有存在相同景點
        var spotExistedChecking = false
        
        // 檢查是否有空字串
        guard spotTextView.text != "" else{
            return
        }
        
        // 尋訪若有相同景點字串，即跳出
        for  i in 0..<ListArray.count {
            let spotExisted:String = ListArray[i] as! String
            guard spotExisted != spotTextView.text else {
                spotExistedChecking = true
                return
            }
        }
        
        // 若沒有相同景點字串，可加入TableView陣列
        if spotExistedChecking == false {
            ListArray.add(spotTextView.text)
            self.spotTableView.reloadData();
            
            tmpPlaceDataStorage.append(tmpPlaceData)
        }
    }
    
    
    @IBAction func searchBtn(_ sender: Any) {
        
        
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
            
            self.spotTextView.text = place.name
            self.placeIdStorage = place.placeID
            
            if(self.placeIdStorage != nil){
                self.loadFirstPhotoForPlace(placeID: self.placeIdStorage)
            } else {
                //..
            }
            
            print("Place name \(place.name)")
            print("Place address \(place.formattedAddress)")
            print("Place attributions \(place.attributions)")
            
            self.tmpPlaceData = place
        })
    }
    
    func setValueToAttractionsList() -> [Attraction] {
        
        var attractionsList = [Attraction]()
        
        for place in tmpPlaceDataStorage {
            var tmpAttraction = Attraction()
            tmpAttraction.setValueToAttractionObject(place: place)
            attractionsList.append(tmpAttraction)
        }
        return attractionsList
    }
}
