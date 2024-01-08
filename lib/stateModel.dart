class StateModel {
  String stateId;
  String stateName;
  List<CityModel> city;

  StateModel({
    required this.stateId,
    required this.stateName,
    required this.city,
  });

  factory StateModel.fromJson(Map<String, dynamic> json) {
    return StateModel(
      stateId: json['stateId'],
      stateName: json['stateName'],
      city: List<CityModel>.from(
        json['city'].map((city) => CityModel.fromJson(city)),
      ),
    );
  }
}

class CityModel {
  String cityId;
  String cityName;

  CityModel({
    required this.cityId,
    required this.cityName,
  });

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      cityId: json['cityId'],
      cityName: json['cityName'],
    );
  }
}
