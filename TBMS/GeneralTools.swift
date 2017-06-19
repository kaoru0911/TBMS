//
//  GeneralTools.swift
//  TBMS
//
//  Created by 倪僑德 on 2017/6/13.
//  Copyright © 2017年 Ryder Tsai. All rights reserved.
//

import Foundation
import GooglePlacePicker

// MARK: - 待建立.swift的model
class GeneralToolModels {
    
    func imageGeneratore(selectedCountry: String) -> UIImage {
        
        let countryName = selectedCountry + "img.jpg"
        
        guard let image = UIImage(named: countryName) else {
            print("沒圖片唷")
            let imageBlank = UIImage()
            return imageBlank
        }
        return image
    }
    
    func selectCountryTypeTrasformer(selectedCountry: String) -> BoundsCoordinate! {
        
        let countryList: [String: BoundsCoordinate] = ["台灣":.臺灣,"日本":.日本,"香港":.香港,"韓國":.韓國,"中國":.中國,
                                                       "新加坡":.新加坡,"泰國":.泰國,"菲律賓":.菲律賓,
                                                       "英國":.英國,"法國":.法國,"德國":.德國,"西班牙":.西班牙,
                                                       "瑞士":.瑞士,"冰島":.冰島,"芬蘭":.芬蘭,"義大利":.義大利,
                                                       "美國":.美國,"加拿大":.加拿大,
                                                       "委內瑞拉":.委內瑞拉,"巴西":.巴西,"阿根廷":.阿根廷,
                                                       "澳大利亞":.澳洲,"紐西蘭":.新西蘭 ]
        
        let country = countryList[selectedCountry]
        return country!
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

enum BoundsCoordinate: String {
    
    case 香港 = "22.2768196,114.1681163,16z",
    日本 = "35.668864,139.4611935,10z",
    韓國 = "37.5647689,126.7093638,10z",
    中國 = "39.9375346,115.837023,9z",
    臺灣 = "25.0498002,121.5363940,11z",
    新加坡 = "1.3122663,103.8353844,12.73z",
    泰國 = "13.7244426,100.3529157,10z",
    菲律賓 = "14.5964879,120.9094042,12z",
    英國 = "51.528308,-0.3817961,10z",
    法國 = "48.8587741,2.2074741,11z",
    德國 = "59.3258414,17.7073729,10z",
    西班牙 = "40.4378698,-3.8196207,11z",
    瑞士 = "46.9545845,7.2547869,11z",
    冰島 = "64.1322134,-21.9925226,11z",
    芬蘭 = "60.1637088,24.7600957,10z",
    義大利 = "41.9097306,12.2558141,10z",
    美國 = "38.8993276,-77.0847778,12z",
    加拿大 = "45.2487862,-76.3606792,9z",
    委內瑞拉 = "10.4683612,-67.0304525,11z",
    巴西 = "-15.6936233,-47.9963963,10.25z",
    阿根廷 = "-34.6156541,-58.5734051,11z",
    澳洲 = "-35.2813043,149.1204446,15z",
    新西蘭 = "-41.2442852,174.6217707,11z"
}

enum Space {
    case positive, negative
}