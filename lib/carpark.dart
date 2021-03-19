 // Model Class for Sqflite
// ToDo: to include prices into car park objects
 class Carpark {

  int _id;
  String _ppCode;
  String _ppName;
  String _latitude;
  String _longitude;

  String _weekdayRate;
  String _satdayRate;
  String _sunPHRate;

  Carpark(this._ppCode, this._ppName, this._latitude, this._longitude, this._weekdayRate, this._satdayRate, this._sunPHRate);

  Carpark.withId(this._id, this._ppCode, this._ppName, this._latitude, this._longitude, this._weekdayRate, this._satdayRate, this._sunPHRate);

  int get id => _id;

  String get ppCode => _ppCode;

  String get ppName => _ppName;

  String get latitude => _latitude;

  String get longitude => _longitude;

  String get weekdayRate => _weekdayRate;

  String get satdayRate => _satdayRate;

  String get sunPHRate => _sunPHRate;

  set ppCode(String newppCode) {
    if (newppCode.length <= 255) {
      this._ppCode = newppCode;
    }
  }

  set ppName(String newppName) {
    if (newppName.length <= 255) {
      this._ppName = newppName;
    }
  }

  set latitude(String newLatitude) {
    if (newLatitude.length <= 255) {
      this._latitude = newLatitude;
    }
  }

  set longitude(String newLongitude) {
    if (newLongitude.length <= 255) {
      this._longitude = newLongitude;
    }
  }

  set weekdayRate(String newWeekdayRate) {
    if (newWeekdayRate.length <= 255) {
      this._weekdayRate = newWeekdayRate;
    }
  }

  set satdayRate(String newSatdayRate) {
    if (newSatdayRate.length <= 255) {
      this._satdayRate = newSatdayRate;
    }
  }

  set sunPHRate(String newSunPHRate) {
    if (newSunPHRate.length <= 255) {
      this._sunPHRate = newSunPHRate;
    }
  }

  // convert a bookmark object into a map object
  Map<String, dynamic> toMap() {

    var map = Map<String, dynamic>();

    map["id"] = _id;

    map["ppCode"] = _ppCode;
    map["ppName"] = _ppName;
    map["latitude"] = _latitude;
    map["longitude"] = _longitude;

    map["weekdayRate"] = _weekdayRate;
    map["satdayRate"] = _satdayRate;
    map["sunPHRate"] = _sunPHRate;

    return map;
  }

  // Extract a Carpark object from a Map object
  Carpark.fromMapObject(Map<String, dynamic> map) {
    this._id = map["id"];
    this._ppCode = map["ppCode"];
    this._ppName = map["ppName"];
    this._latitude = map["latitude"];
    this._longitude = map["longitude"];

    this._weekdayRate = map["weekdayRate"];
    this._satdayRate = map["satdayRate"];
    this._sunPHRate = map["sunPHRate"];
  }

 }