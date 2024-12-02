import 'dart:convert';

// Helper functions to parse JSON and convert to/from the model
// WeatherResponse weatherResponseFromJson(String str) => WeatherResponse.fromJson(json.decode(str));
// String weatherResponseToJson(WeatherResponse data) => json.encode(data.toJson());

class WeatherResponse {
  WeatherResponse({
    required this.success,
    required this.data,
    required this.msgCode,
    required this.msg,
  });

  bool success;
  Data data;
  int msgCode;
  String msg;

  // Factory constructor to parse JSON into the model
  // Factory constructor to parse JSON into the model
factory WeatherResponse.fromJson(Map<String, dynamic> json) => WeatherResponse(
  success: json["success"],
  data: Data.fromJson(json["data"]),
  msgCode: json["msgCode"],
  msg: json["msg"],
);

  get name => null;

  // factory WeatherResponse.fromJson(Map<String, dynamic> json) => WeatherResponse(
  //       success: json["success"],
  //       data: Data.fromJson(json["data"]),
  //       msgCode: json["msgCode"],
  //       msg: json["msg"],
  //     );

  // Convert model to JSON
  Map<String, dynamic> toJson() => {
        "success": success,
        "data": data.toJson(),
        "msgCode": msgCode,
        "msg": msg,
      };
}

class Data {
  Data({
    required this.coord,
    required this.weather,
    required this.base,
    required this.main,
    required this.visibility,
    required this.wind,
    required this.clouds,
    required this.dt,
    required this.sys,
    required this.timezone,
    required this.id,
    required this.name,
    required this.cod,
  });

  Coord coord;
  List<Weather> weather;
  String base;
  Main main;
  int visibility;
  Wind wind;
  Clouds clouds;
  int dt;
  Sys sys;
  int timezone;
  int id;
  String name;
  int cod;

  // Factory constructor to parse JSON into the Data model
  factory Data.fromJson(Map<String, dynamic> json) => Data(
        coord: Coord.fromJson(json["coord"]),
        weather: List<Weather>.from(json["weather"].map((x) => Weather.fromJson(x))),
        base: json["base"],
        main: Main.fromJson(json["main"]),
        visibility: json["visibility"],
        wind: Wind.fromJson(json["wind"]),
        clouds: Clouds.fromJson(json["clouds"]),
        dt: json["dt"],
        sys: Sys.fromJson(json["sys"]),
        timezone: json["timezone"],
        id: json["id"],
        name: json["name"],
        cod: json["cod"],
      );

  // Convert Data model to JSON
  Map<String, dynamic> toJson() => {
        "coord": coord.toJson(),
        "weather": List<dynamic>.from(weather.map((x) => x.toJson())),
        "base": base,
        "main": main.toJson(),
        "visibility": visibility,
        "wind": wind.toJson(),
        "clouds": clouds.toJson(),
        "dt": dt,
        "sys": sys.toJson(),
        "timezone": timezone,
        "id": id,
        "name": name,
        "cod": cod,
      };
}

class Coord {
  Coord({
    required this.lon,
    required this.lat,
  });

  double lon;
  double lat;

  // Factory constructor to parse JSON into the Coord model
  factory Coord.fromJson(Map<String, dynamic> json) => Coord(
        lon: json["lon"].toDouble(),
        lat: json["lat"].toDouble(),
      );

  // Convert Coord model to JSON
  Map<String, dynamic> toJson() => {
        "lon": lon,
        "lat": lat,
      };
}

class Weather {
  Weather({
    required this.id,
    required this.main,
    required this.description,
    required this.icon,
  });

  int id;
  String main;
  String description;
  String icon;

  // Factory constructor to parse JSON into the Weather model
  factory Weather.fromJson(Map<String, dynamic> json) => Weather(
        id: json["id"],
        main: json["main"],
        description: json["description"],
        icon: json["icon"],
      );

  // Convert Weather model to JSON
  Map<String, dynamic> toJson() => {
        "id": id,
        "main": main,
        "description": description,
        "icon": icon,
      };
}

class Main {
  Main({
    required this.temp,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.pressure,
    required this.humidity,
    required this.seaLevel,
    required this.grndLevel,
  });

  double temp;
  double feelsLike;
  double tempMin;
  double tempMax;
  int pressure;
  int humidity;
  int seaLevel;
  int grndLevel;

  // Factory constructor to parse JSON into the Main model
  factory Main.fromJson(Map<String, dynamic> json) => Main(
        temp: json["temp"].toDouble(),
        feelsLike: json["feels_like"].toDouble(),
        tempMin: json["temp_min"].toDouble(),
        tempMax: json["temp_max"].toDouble(),
        pressure: json["pressure"],
        humidity: json["humidity"],
        seaLevel: json["sea_level"],
        grndLevel: json["grnd_level"],
      );

  // Convert Main model to JSON
  Map<String, dynamic> toJson() => {
        "temp": temp,
        "feels_like": feelsLike,
        "temp_min": tempMin,
        "temp_max": tempMax,
        "pressure": pressure,
        "humidity": humidity,
        "sea_level": seaLevel,
        "grnd_level": grndLevel,
      };
}

class Wind {
  Wind({
    required this.speed,
    required this.deg,
    required this.gust,
  });

  double speed;
  int deg;
  double gust;

  // Factory constructor to parse JSON into the Wind model
  factory Wind.fromJson(Map<String, dynamic> json) => Wind(
        speed: json["speed"].toDouble(),
        deg: json["deg"],
        gust: json["gust"].toDouble(),
      );

  // Convert Wind model to JSON
  Map<String, dynamic> toJson() => {
        "speed": speed,
        "deg": deg,
        "gust": gust,
      };
}

class Clouds {
  Clouds({
    required this.all,
  });

  int all;

  // Factory constructor to parse JSON into the Clouds model
  factory Clouds.fromJson(Map<String, dynamic> json) => Clouds(
        all: json["all"],
      );

  // Convert Clouds model to JSON
  Map<String, dynamic> toJson() => {
        "all": all,
      };
}

class Sys {
  Sys({
    required this.country,
    required this.sunrise,
    required this.sunset,
  });

  String country;
  int sunrise;
  int sunset;

  // Factory constructor to parse JSON into the Sys model
  factory Sys.fromJson(Map<String, dynamic> json) => Sys(
        country: json["country"],
        sunrise: json["sunrise"],
        sunset: json["sunset"],
      );

  // Convert Sys model to JSON
  Map<String, dynamic> toJson() => {
        "country": country,
        "sunrise": sunrise,
        "sunset": sunset,
      };
}
