part of 'generated.dart';

class GetSensorReadingVariablesBuilder {
  String id;

  final FirebaseDataConnect _dataConnect;
  GetSensorReadingVariablesBuilder(this._dataConnect, {required  this.id,});
  Deserializer<GetSensorReadingData> dataDeserializer = (dynamic json)  => GetSensorReadingData.fromJson(jsonDecode(json));
  Serializer<GetSensorReadingVariables> varsSerializer = (GetSensorReadingVariables vars) => jsonEncode(vars.toJson());
  Future<QueryResult<GetSensorReadingData, GetSensorReadingVariables>> execute({QueryFetchPolicy fetchPolicy = QueryFetchPolicy.preferCache}) {
    return ref().execute(fetchPolicy: fetchPolicy);
  }

  QueryRef<GetSensorReadingData, GetSensorReadingVariables> ref() {
    GetSensorReadingVariables vars= GetSensorReadingVariables(id: id,);
    return _dataConnect.query("GetSensorReading", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class GetSensorReadingSensorReading {
  final double ph;
  final double temperature;
  GetSensorReadingSensorReading.fromJson(dynamic json):
  
  ph = nativeFromJson<double>(json['ph']),
  temperature = nativeFromJson<double>(json['temperature']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetSensorReadingSensorReading otherTyped = other as GetSensorReadingSensorReading;
    return ph == otherTyped.ph && 
    temperature == otherTyped.temperature;
    
  }
  @override
  int get hashCode => Object.hashAll([ph.hashCode, temperature.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['ph'] = nativeToJson<double>(ph);
    json['temperature'] = nativeToJson<double>(temperature);
    return json;
  }

  const GetSensorReadingSensorReading({
    required this.ph,
    required this.temperature,
  });
}

@immutable
class GetSensorReadingData {
  final GetSensorReadingSensorReading? sensorReading;
  GetSensorReadingData.fromJson(dynamic json):
  
  sensorReading = json['sensorReading'] == null ? null : GetSensorReadingSensorReading.fromJson(json['sensorReading']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetSensorReadingData otherTyped = other as GetSensorReadingData;
    return sensorReading == otherTyped.sensorReading;
    
  }
  @override
  int get hashCode => sensorReading.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (sensorReading != null) {
      json['sensorReading'] = sensorReading!.toJson();
    }
    return json;
  }

  const GetSensorReadingData({
    this.sensorReading,
  });
}

@immutable
class GetSensorReadingVariables {
  final String id;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  GetSensorReadingVariables.fromJson(Map<String, dynamic> json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetSensorReadingVariables otherTyped = other as GetSensorReadingVariables;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  const GetSensorReadingVariables({
    required this.id,
  });
}

