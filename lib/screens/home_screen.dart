import 'dart:async';
import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather/models/current_city_data_model.dart';
import 'package:weather/models/forecast_day.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //Attributes
  Future<CurrentCityDataModel>? currentCityDataModel;
  TextEditingController controller = TextEditingController();
  final Set<String> nameItemsPopupMenuButton = <String>{
    'Settings',
    'Profile',
    'logout'
  };
  String cityName = 'tehran';
  double? lat;
  double? lon;
  Future<CurrentCityDataModel> sendRequestCurrentWeatherData(
      {required String newCityName}) async {
    const String urlBase = 'https://api.openweathermap.org/data/2.5/weather';
    const String appKey = '263c37f66c1d26ad277dc6fab76286b3';
    try {
      Response response = await Dio().get(urlBase, queryParameters: {
        'q': cityName,
        'appid': appKey,
        'units': 'metric',
      });
      print(response.data);
      var apiData = response.data;
      lon = apiData['coord']['lon'];
      lat = apiData['coord']['lat'];
      CurrentCityDataModel newCurrentDataCity = CurrentCityDataModel(
          lon: apiData['coord']['lon'],
          lat: apiData['coord']['lat'],
          weather: apiData['weather'][0]['main'],
          description: apiData['weather'][0]['description'],
          tempMin: apiData['main']['temp_min'],
          tempMax: apiData['main']['temp_max'],
          pressure: apiData['main']['pressure'],
          humidity: apiData['main']['humidity'],
          temp: apiData['main']['temp'],
          windSpeed: apiData['wind']['speed'],
          sunrise: apiData['sys']['sunrise'],
          sunset: apiData['sys']['sunset'],
          cityName: cityName);

      return newCurrentDataCity;
    } catch (e) {
      throw Exception("Error is $e");
    }
  }

  void sendRequestForceCast7Day(
      {required String newLat, required String newLon}) async {
    const String urlBase = 'https://api.openweathermap.org/data/2.5/weather';
    const String appKey = '263c37f66c1d26ad277dc6fab76286b3';
    List<ForecastDay> list = [];

    try {
      Response response = await Dio().get(urlBase, queryParameters: {
        'lat': newLat,
        'lon': newLon,
        'appid': appKey,
        'units': 'metric',
        'exclude': 'minutely,hourly',
      });
      final formatter = DateFormat.MMMd();
      for (int i = 0; i < 8; i++) {
        var model = response.data['daily'][i];
        var dt = formatter.format(
          DateTime.fromMillisecondsSinceEpoch(
            model['dt'] * 1000,
            isUtc: true,
          ),
        );
        ForecastDay forecastDay = ForecastDay(
          dateTime: dt,
          temp: model['temp']['day'],
          main: model['weather'][0]['main'],
          description: model['weather'][0]['description'],
        );
        list.add(forecastDay);
      }
      streamController!.add(list);
    } on DioError catch (e) {
      print(e.response!.statusCode);
      print(e.message);

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message!)));
    }
  }

  StreamController<List<ForecastDay>>? streamController;

  //intState
  @override
  void initState() {
    super.initState();
    currentCityDataModel = sendRequestCurrentWeatherData(newCityName: cityName);
    streamController = StreamController<List<ForecastDay>>();
  }

  IconData setIconWeather({required String description}) {
    if (description == "clear sky") {
      return Icons.sunny;
    } else if (description == "few clouds") {
      return Icons.cloud_outlined;
    } else if (description.contains('clouds')) {
      return Icons.cloud;
    } else if (description.contains('thunderstorm')) {
      return Icons.thunderstorm_rounded;
    } else if (description.contains('drizzle')) {
      return Icons.remove_red_eye_sharp;
    } else if (description.contains('snow')) {
      return Icons.snowing;
    } else if (description.contains('rain')) {
      return Icons.cloudy_snowing;
    } else {
      return Icons.error;
    }
  }

  //Override
  @override
  Widget build(BuildContext context) {
    double heightDevice = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          "Weather App",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
        ),
        actions: <Widget>[
          PopupMenuButton<String>(
            color: Colors.white,
            itemBuilder: (BuildContext context) {
              return nameItemsPopupMenuButton.map((String choice) {
                return PopupMenuItem(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          )
        ],
      ),
      body: FutureBuilder(
        future: currentCityDataModel,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            sendRequestForceCast7Day(
                newLat: lat.toString(), newLon: lon.toString());
            CurrentCityDataModel cityData = snapshot.data!;
            final formatter = DateFormat.jm();
            var sunrise = formatter.format(
              DateTime.fromMillisecondsSinceEpoch(
                cityData.sunrise * 1000,
                isUtc: true,
              ),
            );
            var sunset = formatter.format(
              DateTime.fromMillisecondsSinceEpoch(
                cityData.sunset * 1000,
                isUtc: true,
              ),
            );
            return Container(
              height: heightDevice,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage("assets/img/background.jpg"),
                ),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 5,
                  sigmaY: 5,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              height: 45,
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor:
                                      const MaterialStatePropertyAll(
                                          Colors.white70),
                                  shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                      side: const BorderSide(
                                          color: Colors.blue, width: 2),
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  cityName = controller.text;
                                  currentCityDataModel =
                                      sendRequestCurrentWeatherData(
                                          newCityName: cityName);
                                  setState(() {});
                                },
                                child: const Text('find'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                                child: SizedBox(
                              height: 45,
                              child: TextField(
                                controller: controller,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  filled: true,
                                  hintStyle: TextStyle(
                                      color: Colors.grey[800], height: 0),
                                  hintText: "City Weather...",
                                  fillColor: Colors.white70,
                                ),
                              ),
                            ))
                          ],
                        ),
                        const SizedBox(height: 25),
                        Text(
                          cityData.cityName,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          cityData.description,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 40),
                        Icon(
                          setIconWeather(description: cityData.description),
                          size: 90,
                          color: Colors.yellow[700],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "${cityData.temp}\u00B0",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 40),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(left: 5, right: 5),
                              child: Column(
                                children: [
                                  const Text("max"),
                                  Text(
                                    "${cityData.tempMax}\u00B0",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 2,
                              height: 30,
                              color: Colors.black,
                            ),
                            Container(
                              margin: const EdgeInsets.only(left: 5, right: 5),
                              child: Column(
                                children: [
                                  const Text("min"),
                                  Text(
                                    "${cityData.tempMin}\u00B0",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(
                          height: 5,
                          color: Colors.black,
                        ),
                        SizedBox(
                          height: 100,
                          width: double.infinity,
                          child: StreamBuilder(
                            stream: streamController!.stream,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return ListView.builder(
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: 6,
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      color: Colors.transparent,
                                      width: 80,
                                      child: Container(
                                        color: Colors.transparent,
                                        padding: const EdgeInsets.all(5),
                                        child: const Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Fri, 8Pm",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            Icon(
                                              Icons.cloud,
                                              color: Colors.white,
                                            ),
                                            Text(
                                              "14" + "\u00B0",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              } else {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                            },
                          ),
                        ),
                        const Divider(
                          height: 5,
                          color: Colors.black,
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              SizedBox(
                                height: 100,
                                width: 120,
                                child: SizedBox(
                                  width: 120,
                                  child: Card(
                                      elevation: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(5),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            const Text(
                                              "Wind Speed",
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              "${cityData.windSpeed} m/s",
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )),
                                ),
                              ),
                              SizedBox(
                                height: 100,
                                width: 120,
                                child: SizedBox(
                                  width: 120,
                                  child: Card(
                                      elevation: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(5),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            const Text(
                                              "Humidity",
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              "${cityData.humidity} %",
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )),
                                ),
                              ),
                              SizedBox(
                                height: 100,
                                width: 120,
                                child: SizedBox(
                                  width: 120,
                                  child: Card(
                                      elevation: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(5),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            const Text(
                                              "Sunrise",
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              sunrise,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )),
                                ),
                              ),
                              SizedBox(
                                height: 100,
                                width: 120,
                                child: SizedBox(
                                  width: 120,
                                  child: Card(
                                      elevation: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(5),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            const Text(
                                              "Sunset",
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              sunset,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
