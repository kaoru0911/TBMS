//
//  CallGooglePlaceAPI.swift
//  travelToMySelfLayOut
//
//  Created by 倪僑德 on 2017/4/19.
//  Copyright © 2017年 Chiao. All rights reserved.
//

import UIKit
import GooglePlaces
import GooglePlacePicker

class GooglePlaceCaller: NSObject {
    
    let generalModels = GeneralToolModels()
    
    func loadFirstPhotoForPlace(placeID: String, notificationName: String) {
        
        GMSPlacesClient.shared().lookUpPhotos(forPlaceID: placeID) { (photos, error) -> Void in
            
            guard let photos = photos else {
                
                print("ERROR: Photos get fail. /n",
                      "Error Information: /n\(error?.localizedDescription ?? "")")
                return
            }
            
            if let firstPhoto = photos.results.first {
                self.loadImageForMetadata(photoMetadata: firstPhoto,
                                          notificationName: notificationName)
            }
        }
    }
    
    private func loadImageForMetadata(photoMetadata: GMSPlacePhotoMetadata, notificationName: String) {
        
        GMSPlacesClient.shared().loadPlacePhoto(photoMetadata, callback: {
            (photo, error) -> Void in
            
            guard let photo = photo else {
            
                print("ERROR: Photos get fail. /n",
                      "Error Information: /n\(error?.localizedDescription ?? "")")
                return

            }
            
            let image = CustormerImage()
            
            image.image = photo
            image.imageType = .downloadImg
            image.index = self.notificationNameDecodeToIndex(notificationName: notificationName)
            
            
            let name = Notification.Name(notificationName)
            NotificationCenter.default.post(name: name, object: image)
        })
    }
    
    func nameAndIndexEncodeToNotificationName(name: String, index: Int) -> String {
        
        return "\(name)Notification:\(index)"
    }
    
    
    func notificationNameDecodeToIndex(notificationName: String) -> Int {
        
        let notificationElements = notificationName.components(separatedBy: "Notification:")
        
        guard notificationElements.count > 1 else {
            print("ERROR: Notification decode fail.")
            return 0
        }
        
        guard let index = Int(notificationElements[1]) else {
            print("ERROR: Notification decode fail. /n",
                  "The 2nd part of notificationName isn't number.")
            return 0
        }
        
        return index
    }
}

struct GooglePlacePickerGenerator {
    
    func generatePlacePicker(selectedCountry: String) -> GMSPlacePicker {
        
        let commontTools = GeneralToolModels()
        
        let tmpCountry = commontTools.selectCountryTypeTrasformer(selectedCountry: selectedCountry)
        var bounds: GMSCoordinateBounds? = nil
        
        if let country = tmpCountry {
            let coordinateNE = getBoundCoordinate(selectedCountry: country, space: .positive)
            let coordinateWS = getBoundCoordinate(selectedCountry: country, space: .negative)
            
            let path = GMSMutablePath()
            path.add(coordinateNE)
            path.add(coordinateWS)
            
            bounds = GMSCoordinateBounds(path: path)
        }
        
        let config = GMSPlacePickerConfig(viewport: bounds)
        let placePicker = GMSPlacePicker(config: config)
        
        return placePicker
    }
    
    
    private func getBoundCoordinate(selectedCountry: BoundsCoordinate, space: Space) -> CLLocationCoordinate2D {
        
        let seperateResult = selectedCountry.rawValue.components(separatedBy: ",")
        let spaceValue = 0.01
        let lat: Double
        let lng: Double
        
        if space == .positive {
            lat = Double(seperateResult[0])! + spaceValue
            lng = Double(seperateResult[1])! + spaceValue
        } else {
            lat = Double(seperateResult[0])! - spaceValue
            lng = Double(seperateResult[1])! - spaceValue
        }
        
        return CLLocationCoordinate2DMake(lat, lng)
    }
}

class CustormerImage: NSObject {
    var imageType: ImageType = .loadingImg
    var index: Int?
    var image: UIImage?
}

enum ImageType: String {
    case loadingImg, downloadImg
}

//protocol ImageWithTag {
//    
//    var index: Int { get set }
//    var imageType: ImageType { get set }
//    
//    func setValueToIndex(index: Int, imageType: ImageType)
//}
//
//extension ImageWithTag {
//    
//    mutating func setdefaultValue(index: Int, imageType: ImageType) {
//        
//        self.index = index
//        self.imageType = imageType
//    }
//}
//
//extension UIImage {
//    
//    var index: Int! {
//        get {
//            return objc_getAssociatedObject(self, &xoAssociationKey) as? PFObject
//        }
//        set(newValue) {
//            objc_setAssociatedObject(self, &xoAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
//        }
//    }
//    
//}

//public final class ObjectAssociation<T: AnyObject> {
//    
//    private let policy: objc_AssociationPolicy
//    
//    /// - Parameter policy: An association policy that will be used when linking objects.
//    public init(policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN_NONATOMIC) {
//        
//        self.policy = policy
//    }
//    
//    /// Accesses associated object.
//    /// - Parameter index: An object whose associated object is to be accessed.
//    public subscript(index: AnyObject) -> T? {
//        
//        get { return objc_getAssociatedObject(index, Unmanaged.passUnretained(self).toOpaque()) as! T? }
//        set { objc_setAssociatedObject(index, Unmanaged.passUnretained(self).toOpaque(), newValue, policy) }
//    }
//}

