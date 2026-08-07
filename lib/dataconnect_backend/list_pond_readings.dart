part of 'generated.dart';

class ListPondReadingsVariablesBuilder {
  String pondId;

  final FirebaseDataConnect _dataConnect;
  ListPondReadingsVariablesBuilder(this._dataConnect, {required  this.pondId,});
  Deserializer<ListPondReadingsData> dataDeserializer = (dynamic json)  => ListPondReadingsData.fromJson(jsonDecode(json));
  Serializer<ListPondReadingsVariables> varsSerializer = (ListPondReadingsVariables vars) => jsonEncode(vars.toJson());
  Future<QueryResult<ListPondReadingsData, ListPondReadingsVariables>> execute({QueryFetchPolicy fetchPolicy = QueryFetchPolicy.preferCache}) {
    return ref().execute(fetchPolicy: fetchPolicy);
  }

  QueryRef<ListPondReadingsData, ListPondReadingsVariables> ref() {
    ListPondReadingsVariables vars= ListPondReadingsVariables(pondId: pondId,);
    return _dataConnect.query("ListPondReadings", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class ListPondReadingsSensorReadings {
  final Timestamp timestamp;
  final double ph;
  final double temperature;
  ListPondReadingsSensorReadings.fromJson(dynamic json):
  
  timestamp = Timestamp.fromJson(json['timestamp']),
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

    final ListPondReadingsSensorReadings otherTyped = other as ListPondReadingsSensorReadings;
    return timestamp == otherTyped.timestamp && 
    ph == otherTyped.ph && 
    temperature == otherTyped.temperature;
    
  }
  @override
  int get hashCode => Object.hashAll([timestamp.hashCode, ph.hashCode, temperature.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['timestamp'] = timestamp.toJson();
    json['ph'] = nativeToJson<double>(ph);
    json['temperature'] = nativeToJson<double>(temperature);
    return json;
  }

  const ListPondReadingsSensorReadings({
    required this.timestamp,
    required this.ph,
    required this.temperature,
  });
}

@immutable
class ListPondReadingsData {
  final List<ListPondReadingsSensorReadings> sensorReadings;
  ListPondReadingsData.fromJson(dynamic json):
  
  sensorReadings = (json['sensorReadings'] as List<dynamic>)
        .map((e) => ListPondReadingsSensorReadings.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListPondReadingsData otherTyped = other as ListPondReadingsData;
    return sensorReadings == otherTyped.sensorReadings;
    
  }
  @override
  int get hashCode => sensorReadings.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['sensorReadings'] = sensorReadings.map((e) => e.toJson()).toList();
    return json;
  }

  const ListPondReadingsData({
    required this.sensorReadings,
  });
}

@immutable
class ListPondReadingsVariables {
  final String pondId;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  ListPondReadingsVariables.fromJson(Map<String, dynamic> json):
  
  pondId = nativeFromJson<String>(json['pondId']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListPondReadingsVariables otherTyped = other as ListPondReadingsVariables;
    return pondId == otherTyped.pondId;
    
  }
  @override
  int get hashCode => pondId.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['pondId'] = nativeToJson<String>(pondId);
    return json;
  }

  const ListPondReadingsVariables({
    required this.pondId,
  });
}

