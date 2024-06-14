//
//  ViewController.swift
//  Prayer
//
//  Created by abbas on 13/06/2024.
//

import UIKit
import CoreLocation

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

class ViewController: UIViewController {
    @Published var prayerTimes: PrayerTimings!

    let locationManager =  CLLocationManager()
    var lat = 0.0
    var lon = 0.0
    var dateToDay = Date.now
    //let locationMana = CLLocation()
    @Published var location: CLLocation?
    
    @IBOutlet weak var countryName: UILabel!
    @IBOutlet weak var cityName: UILabel!
    @IBOutlet weak var prayerTimeName: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self

        locationManager.delegate = self

        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        //reverseGeocode(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(lon))
        fetchrayerTimes(latitude: lat, longitude: lon, date: dateToDay.formatted())

        

    }
    
    @IBOutlet weak var tableView: UITableView!
    
    var strings: [String] = ["aa","bb"]

    func getFormattedDate() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM, HH:mm" // Format : jour mois, heure:minute
        formatter.locale = Locale(identifier: "fr_FR") // Pour formater en français
        return formatter.string(from: dateToDay)
    }

   
}



extension ViewController: CLLocationManagerDelegate{
   
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        if let lat = locations.last{
            var latitude = lat.coordinate.latitude
            var longitude = lat.coordinate.longitude
           // reverseGeocode(latitude: latitude, longitude: longitude)
            self.location = lat
            reverseGeocode(latitude: latitude, longitude: longitude)
            

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
                var prayerTimes = prayerTimesResponse.data.timings
                DispatchQueue.main.async {
                    self.prayerTimes = prayerTimes
                    self.lat = latitude
                    self.lon = longitude
                }
            }catch {
                print("erreur")
            }
        }.resume()
    }
   
}
extension ViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return strings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = strings[indexPath.row]
        return cell
    }
    
    
}

