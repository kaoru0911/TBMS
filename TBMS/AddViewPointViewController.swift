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
    @IBOutlet weak var addSpotBtn: UIButton!
    @IBOutlet weak var saveSpotBtn: UIButton!
    
    @IBOutlet weak var spotSearchBtn: UIButton!
    var selectedCountry : String!
    
    var placeIdStorage:String!
    var tmpPlaceData : GMSPlace!
    var tmpPlaceDataStorage = [GMSPlace]()
    var attractionStorage = [Attraction]()
    var sharedData = DataManager.shareDataManager
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        placesClient = GMSPlacesClient.shared()
        
        addSpotBtn.layer.cornerRadius = 5.0
        saveSpotBtn.layer.cornerRadius = 5.0
        spotSearchBtn.layer.cornerRadius = 5.0
        imageView.image = UIImage(named: "GoogleMapLogo")
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(addNewAttractionFromPocket(notification:)),
                                               name: NSNotification.Name(rawValue: "PocketSpotTVCDisappear"),
                                               object: nil)
    }
    
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
    var listArray: NSMutableArray = []
    var placesClient: GMSPlacesClient!
    
    //    func goSetStartPointPage() {
    //
    //        let storyboard = UIStoryboard(name: "Main", bundle: nil)
    //        let setStartPointViewController = storyboard.instantiateViewController(withIdentifier :"SetStartPointViewController") as! SetStartPointViewController
    //
    //        self.navigationController?.pushViewController(setStartPointViewController, animated: true)
    //    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: viewPointTableViewCell = tableView.dequeueReusableCell(withIdentifier: "viewPointTableViewCell") as! viewPointTableViewCell
        
        cell.noCellLabel.text = "\(indexPath.row + 1 ). "
        cell.spotCellLabel.text = attractionStorage[indexPath.row].attrctionName
        //        cell.textLabel?.text = "\(listArray.object(at: indexPath.row))"
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        self.listArray.removeObject(at: indexPath.row)
        attractionStorage.remove(at: indexPath.row)
        
        self.spotTableView.reloadData()
        
    }
    
    // 畫面精進，讓點選後的灰色不會卡在選擇列上，灰色會閃一下就消失
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func addSpotBtn(_ sender: Any) {
        
        
        // 檢查是否有存在相同景點
        var spotExistedChecking = false
        
        // 檢查是否有空字串
        guard spotTextView.text != "" else{
            return
        }
        
        // 尋訪若有相同景點字串，即跳出
        for  i in 0..<listArray.count {
            let spotExisted:String = listArray[i] as! String
            guard spotExisted != spotTextView.text else {
                spotExistedChecking = true
                return
            }
        }
        
        // 若沒有相同景點字串，可加入TableView陣列
        if spotExistedChecking == false {
            listArray.add(spotTextView.text)
            
            var attr = Attraction()
            attr.setValueToAttractionObject(place: tmpPlaceData)
            attractionStorage.append(attr)
            
            print(listArray)
            self.spotTableView.reloadData();
        }
    }
    
    func showAlertMessage(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message:message, preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "確定", style: .default, handler: nil)
        
        alert.addAction(ok)
        
        self.present(alert,animated: true,completion: nil)
    }
    
    
    @IBAction func searchBtn(_ sender: Any) {
        
        let pickerGenerator = GooglePlacePickerGenerator()
        let placePicker = pickerGenerator.generatePlacePicker(selectedCountry: sharedData.chooseCountry)
        
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
            print("Place address \(String(describing: place.formattedAddress))")
            print("Place attributions \(String(describing: place.attributions))")
            print("placeID=\(place.placeID)")
            
            self.tmpPlaceData = place
        })
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "GoToSetStartPoint" {
            
//            guard attractionStorage != nil else { return }
            guard attractionStorage.isEmpty != true else { return }
            
            let vc = segue.destination as! SetStartPointViewController
            vc.attractionsList = attractionStorage
            
        } else if segue.identifier == "ShowStorageAttration" {
            
            let nextPage = segue.destination as! PocketSpotTVC
            nextPage.selectedCountry = sharedData.chooseCountry
            nextPage.selectedProcess = "開始規劃"
            nextPage.scheduleAttractions = attractionStorage
        }
    }
}

extension AddViewPointViewController {
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    }
    
    
    
    func addNewAttractionFromPocket( notification:Notification ) {
        
        
        if !sharedData.isLogin {
            showAlertMessage(title: "", message: "請先登入會員")
            return
        }
        
        attractionStorage += ( notification.object as! [Attraction] )
        
        var cellTextArray = [String]()
        for attr in attractionStorage {
            let name = attr.attrctionName
            cellTextArray.append(name ?? "")
        }
        listArray = cellTextArray as! NSMutableArray
        
        self.spotTableView.reloadData()
    }
}
