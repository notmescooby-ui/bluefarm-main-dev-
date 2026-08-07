part of 'generated.dart';

class GetPondVariablesBuilder {
  String id;

  final FirebaseDataConnect _dataConnect;
  GetPondVariablesBuilder(this._dataConnect, {required  this.id,});
  Deserializer<GetPondData> dataDeserializer = (dynamic json)  => GetPondData.fromJson(jsonDecode(json));
  Serializer<GetPondVariables> varsSerializer = (GetPondVariables vars) => jsonEncode(vars.toJson());
  Future<QueryResult<GetPondData, GetPondVariables>> execute({QueryFetchPolicy fetchPolicy = QueryFetchPolicy.preferCache}) {
    return ref().execute(fetchPolicy: fetchPolicy);
  }

  QueryRef<GetPondData, GetPondVariables> ref() {
    GetPondVariables vars= GetPondVariables(id: id,);
    return _dataConnect.query("GetPond", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class GetPondPond {
  final String name;
  final String location;
  final double? capacity;
  GetPondPond.fromJson(dynamic json):
  
  name = nativeFromJson<String>(json['name']),
  location = nativeFromJson<String>(json['location']),
  capacity = json['capacity'] == null ? null : nativeFromJson<double>(json['capacity']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetPondPond otherTyped = other as GetPondPond;
    return name == otherTyped.name && 
    location == otherTyped.location && 
    capacity == otherTyped.capacity;
    
  }
  @override
  int get hashCode => Object.hashAll([name.hashCode, location.hashCode, capacity.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['name'] = nativeToJson<String>(name);
    json['location'] = nativeToJson<String>(location);
    if (capacity != null) {
      json['capacity'] = nativeToJson<double?>(capacity);
    }
    return json;
  }

  const GetPondPond({
    required this.name,
    required this.location,
    this.capacity,
  });
}

@immutable
class GetPondData {
  final GetPondPond? pond;
  GetPondData.fromJson(dynamic json):
  
  pond = json['pond'] == null ? null : GetPondPond.fromJson(json['pond']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetPondData otherTyped = other as GetPondData;
    return pond == otherTyped.pond;
    
  }
  @override
  int get hashCode => pond.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (pond != null) {
      json['pond'] = pond!.toJson();
    }
    return json;
  }

  const GetPondData({
    this.pond,
  });
}

@immutable
class GetPondVariables {
  final String id;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  GetPondVariables.fromJson(Map<String, dynamic> json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetPondVariables otherTyped = other as GetPondVariables;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  const GetPondVariables({
    required this.id,
  });
}

