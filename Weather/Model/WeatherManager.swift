import Foundation

protocol WeatherManagerDelegate
{
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager
{
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=553e1454e196b1d3c4bbd15819174ee2&units=metric"
    
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(cityName: String)
    {
        let urlString = "\(weatherURL)&q=\(cityName)"
        perfrormRequest(with: urlString)
    }
    
    func fetchWeather(latitude: Double, longtitude: Double)
    {
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longtitude)"
        perfrormRequest(with: urlString)
    }
    
    func perfrormRequest(with urlString: String)
    {
        if let url = URL(string: urlString)
        {
            let session = URLSession(configuration: .default)
            
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil
                {
                    delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data
                {
                  if let weather = parseJSON(safeData)
                  {
                    delegate?.didUpdateWeather(self, weather: weather)
                  }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(_ weatherData: Data) -> WeatherModel?
    {
        let decoder = JSONDecoder()
        do
        {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            return weather
        }
        catch
        {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
