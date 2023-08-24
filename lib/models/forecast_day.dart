// ignore_for_file: public_member_api_docs, sort_constructors_first
class ForecastDay {
  var dateTime;
  var temp;
  String main;
  String description;
  get getDateTime => dateTime;

  set setDateTime(dateTime) => this.dateTime = dateTime;

  get getTemp => temp;

  set setTemp(temp) => this.temp = temp;

  get getMain => main;

  set setMain(main) => this.main = main;

  get getDescription => description;

  set setDescription(description) => this.description = description;
  ForecastDay({
    required this.dateTime,
    required this.temp,
    required this.main,
    required this.description,
  });
}
