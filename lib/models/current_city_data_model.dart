class CurrentCityDataModel {
  double lon;
  double lat;
  String weather;
  String description;
  double tempMin;
  double tempMax;
  int pressure;
  int humidity;
  double temp;
  double windSpeed;
  int sunrise;
  int sunset;
  String cityName;

  get getLon => lon;

  set setLon(lon) => this.lon = lon;

  get getLat => lat;

  set setLat(lat) => this.lat = lat;

  get getWeather => weather;

  set setWeather(weather) => this.weather = weather;

  get getDescription => description;

  set setDescription(description) => this.description = description;

  get getTempMin => tempMin;

  set setTempMin(tempMin) => this.tempMin = tempMin;

  get getTempMax => tempMax;

  set setTempMax(tempMax) => this.tempMax = tempMax;

  get getPressure => pressure;

  set setPressure(pressure) => this.pressure = pressure;

  get getHumidity => humidity;

  set setHumidity(humidity) => this.humidity = humidity;

  get getTemp => temp;

  set setTemp(temp) => this.temp = temp;

  get getWindSpeed => windSpeed;

  set setWindSpeed(windSpeed) => this.windSpeed = windSpeed;

  get getSunrise => sunrise;

  set setSunrise(sunrise) => this.sunrise = sunrise;

  get getSunset => sunset;

  set setSunset(sunset) => this.sunset = sunset;

  get getCityName => cityName;

  set setCityName(cityName) => this.cityName = cityName;

  CurrentCityDataModel({
    required this.lon,
    required this.lat,
    required this.weather,
    required this.description,
    required this.tempMin,
    required this.tempMax,
    required this.pressure,
    required this.humidity,
    required this.temp,
    required this.windSpeed,
    required this.sunrise,
    required this.sunset,
    required this.cityName,
  });
}
