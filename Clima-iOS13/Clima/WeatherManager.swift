//
//  WeatherManager.swift
//  Clima
//
//  Created by Jakub Adrian Niemiec on 11/05/2020.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation

protocol WeatherManagerDelegate {
	func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
	func didFailWithError(error: Error)
}

struct WeatherManager {
	let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=58c243985a6654b2151a719f48d13957&units=metric"
	
	var delegate: WeatherManagerDelegate?
	
	func fetchWeather(cityName: String) {
		let urlString = "\(weatherURL)&q=\(cityName)"
		performRequest(with: urlString)
	}
	
	func fetchWeather(latitude: String, longitude: String) {
		let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
		performRequest(with: urlString)
	}
	
	func performRequest(with urlString: String) {
		// 1. Create a URL
		if let url = URL(string: urlString) {
			// 2. Create a URLSession
			let session = URLSession(configuration: .default)
			// 3. Give the session a task
			let task = session.dataTask(with: url) { (data, response, error) in
				if error != nil {
					self.delegate?.didFailWithError(error: error!)
					return
				}
				
				if let safeData = data {
					if let weather = self.parseJSON(safeData) {
						self.delegate?.didUpdateWeather(self, weather: weather)
					}
				}
				
			}
			// 4. Start the task
			task.resume()
		}
	}
	
	func parseJSON(_ weatherData: Data) -> WeatherModel? {
		let decoder = JSONDecoder()
		do {
			let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
			let id = decodedData.weather[0].id
			let temperature = decodedData.main.temp
			let city = decodedData.name
			
			let weather = WeatherModel(conditionId: id, cityName: city, temperature: temperature)
			return weather
			
		} catch {
			delegate?.didFailWithError(error: error)
			return nil
		}
	}
}
