//
//  ViewController.swift
//  Prayer
//
//  Created by abbas on 13/06/2024.
//

import UIKit
import CoreLocation
import Foundation

enum PrayerType: String{
    case fajr
    case dhuhr
    case asr
    case maghreb
    case isha
}
struct PrayerTimesResponse: Codable{
    let code: Int
    let status: String
    let data: PrayerData
}
struct PrayerData: Codable{
    let timings: PrayerTimings
}
struct PrayerTimings: Codable{
    let Fajr: String
    let Dhuhr: String
    let Asr: String
    let Maghrib: String
    let Isha: String
}

struct Prayer{
    var name: String
    var time: String

}

//MARK: - ViewController

class ViewController: UIViewController {
    
    var prayerTimes: PrayerTimings? {
        didSet{
            if let prayerTimes = prayerTimes{
                prayers = [
                    Prayer(name: "Fajr", time: prayerTimes.Fajr),
                    Prayer(name: "Dhuhr", time: prayerTimes.Dhuhr),
                    Prayer(name: "Asr", time: prayerTimes.Asr),
                    Prayer(name: "Maghrib", time: prayerTimes.Maghrib),
                    Prayer(name: "Isha", time: prayerTimes.Isha)
                ]
                tablView.reloadData()
            }
        }
    }
    
    var nextPrayerTitle: String{
        if let timeUntilNextPrayer = timeUntilNextPrayer{
            "\(nextPrayer.rawValue.capitalized): \(formattedTime(timeInterval: timeUntilNextPrayer))"
            
            
        }else {
            "Impossible de calculer le temps restant jusqu'a la prochaine prière"
        }
        
        
    }
    
    
   
    let locationManager =  CLLocationManager()
    var lat = 0.0
    var lon = 0.0
    var dateToDay = Date.now
    var prayers: [Prayer] = []
    var timeUntilNextPrayer: TimeInterval?
    var timer = Timer()
    
  
    //let timer2 = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { timer in
        
        //print("Timer fired!")
    //}
    var nextPrayer = PrayerType.fajr
  
   

    @Published var location: CLLocation?
    
    @IBOutlet weak var countryName: UILabel!
    @IBOutlet weak var cityName: UILabel!
    @IBOutlet weak var tablView: UITableView!
    
    @IBOutlet weak var nextPriere: UILabel!
    
    @IBOutlet weak var timeOfNextPrayer: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        tablView.dataSource = self
         timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        

        

    }
    @objc func update(){
        if timeUntilNextPrayer != nil{
            self.timeUntilNextPrayer = timeToNextPrayer(prayerTimes: prayerTimes!)
            self.timeOfNextPrayer.text = self.formattedTime(timeInterval: self.timeUntilNextPrayer!)

            
        }
    }

    func getFormattedDate() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM, HH:mm" // Format : jour mois, heure:minute
        formatter.locale = Locale(identifier: "fr_FR") // Pour formater en français
        return formatter.string(from: date)
    }
    
    func formattedTime(timeInterval: TimeInterval) -> String{
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
       // self.nextPriere.text = timeUntilNextPrayer?.description

        return formatter.string(from: timeInterval)!
    }
    
    func nextPrayerString(prayer: PrayerTimings) -> PrayerType? {
        let currentDate = Date.now
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let currentTimeString = dateFormatter.string(from: currentDate)
        
        var nextPrayer: PrayerType? = nil
        var nexPrayerTime: String? = nil
        
        let prayers: [PrayerType: String] = [
            PrayerType.fajr: prayerTimes!.Fajr,
            PrayerType.dhuhr: prayerTimes!.Dhuhr,
            PrayerType.asr: prayerTimes!.Asr,
            PrayerType.maghreb: prayerTimes!.Maghrib,
            PrayerType.isha: prayerTimes!.Isha
            
        ]
        for (key,prayerTime) in prayers {
            if prayerTime > currentTimeString {
                if nextPrayer == nil{
                    nextPrayer = key
                    nexPrayerTime = prayerTime
                }else{
                    if let nextPrayerTime = nexPrayerTime, prayerTime < nextPrayerTime {
                        nextPrayer = key
                        nexPrayerTime = prayerTime
                    }
                }
            }
        }
        if let nextPrayer = nextPrayer{
            return nextPrayer
        }else{
            return nil
        }
        
    }
    
    func timeToNextPrayer(prayerTimes: PrayerTimings) -> TimeInterval?{
        let currentDate = Date()
        let calendar = Calendar.current
        _ = calendar.component(.hour, from: currentDate)
        _ = calendar.component(.minute, from: currentDate)
        
        var dateComponents = DateComponents()
        dateComponents.year = calendar.component(.year, from: currentDate)
        dateComponents.month = calendar.component(.month, from: currentDate)
        dateComponents.day = calendar.component(.day, from: currentDate)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        guard let fajrDate = dateFormatter.date(from: prayerTimes.Fajr),
             let dhuhrDate = dateFormatter.date(from: prayerTimes.Dhuhr),
              let asrDate = dateFormatter.date(from: prayerTimes.Asr),
              let maghrebDate = dateFormatter.date(from: prayerTimes.Maghrib),
              let ishaDate = dateFormatter.date(from: prayerTimes.Isha)
        else{
            print("erreur: impossible de convertir de convertire les heures de priere en format date ")
            return nil
        }
        
        let fajrComponement = calendar.dateComponents([.hour, .minute], from: fajrDate)
        let dhuhrComponement = calendar.dateComponents([.hour , .minute], from: dhuhrDate)
        let asrComponement = calendar.dateComponents([.hour, .minute], from: asrDate)
        let maghrebComponement = calendar.dateComponents([.hour, .minute], from: maghrebDate)
        let ishaComponement = calendar.dateComponents([.hour, .minute], from: ishaDate)
        
        dateComponents.hour = fajrComponement.hour
        dateComponents.minute = fajrComponement.minute
        
        guard let fajr = calendar.date(from: dateComponents),
              let dhuhr = calendar.date(bySettingHour: dhuhrComponement.hour!, minute: dhuhrComponement.minute!, second: 0, of: currentDate),
              let asr = calendar.date(bySettingHour: asrComponement.hour!, minute: asrComponement.minute!, second: 0, of: currentDate),
              let maghreb = calendar.date(bySettingHour: maghrebComponement.hour!, minute: maghrebComponement.minute!, second: 0, of: currentDate),
              let isha = calendar.date(bySettingHour: ishaComponement.hour!, minute: ishaComponement.minute!, second: 0, of: currentDate)
              
        else{
            print("Erreur: imossible de cree les date des heur de priere")
            return nil
        }
        
        let prayerTimesArray = [fajr, dhuhr, asr,maghreb,isha]
        let futurePrayers = prayerTimesArray.filter { $0 > currentDate}
        if let nextPrayerTime = futurePrayers.first {
            let timeRemaining = nextPrayerTime.timeIntervalSince(currentDate)
            return timeRemaining
        }else{
            print("Aucune prochaine prière future.")
            return nil
        }
 
    }


}


//MARK: - CLLocationManagerDelegate

extension ViewController: CLLocationManagerDelegate{
   
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        if let lat = locations.last{
            let latitude = lat.coordinate.latitude
            let longitude = lat.coordinate.longitude
           // reverseGeocode(latitude: latitude, longitude: longitude)
            self.location = lat
            reverseGeocode(latitude: latitude, longitude: longitude)
            fetchrayerTimes(latitude: latitude, longitude: longitude, date: dateToDay.formatted())
        }
        return
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print("\(error) impossible de recup la loca")
    }
    
    func reverseGeocode(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: latitude, longitude: longitude)
        
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            self.lat = location.coordinate.latitude
            self.lon = location.coordinate.longitude
            if let placemark = placemarks?.last {
             
                let cityName = placemark.locality ?? "" // Nom de la ville
                let countryName = placemark.country ?? "" // Nom du pays
                
                    self.cityName.text = cityName
                self.countryName.text = countryName
                    print(cityName)
                    //self.countryName = countryName

            }
        }
    }
    
    func fetchrayerTimes(latitude: CLLocationDegrees,longitude: CLLocationDegrees, date: String ){
        let urlString = "https://api.aladhan.com/v1/timingsByCity?city=\(latitude)&country=\(longitude)&date=\(date)"
        
        guard let url = URL(string: urlString) else{
            print("Erreur: URL non valide")
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error{
                print("Erreur de requête : \(error.localizedDescription)")
                
                return
            }
            guard let data = data else{
                print("Aucune donnée reçue pour les horaires de prière.")
                
                return
            }
            do {
                let prayerTimesResponse = try JSONDecoder().decode(PrayerTimesResponse.self, from: data)
                let prayerTimes = prayerTimesResponse.data.timings
                
                DispatchQueue.main.async {
                    self.prayerTimes = prayerTimes
                    self.timeUntilNextPrayer = self.timeToNextPrayer(prayerTimes: prayerTimes)
                    if let nextPrayer = self.nextPrayerString(prayer: prayerTimes){
                        self.nextPriere.text = nextPrayer.rawValue
                        self.timeOfNextPrayer.text = self.formattedTime(timeInterval: self.timeUntilNextPrayer!)
                        
                    }
                }
            }catch {
                print("erreur")
            }
        }.resume()
    }
   
}

// MARK: - UITableViewDataSource

extension ViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return prayers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier", for: indexPath)
        let prayer = prayers[indexPath.row]
            
            
            cell.textLabel?.text = "\(prayer.name) \(prayer.time)"
            return cell
            
    }
    
    
}

