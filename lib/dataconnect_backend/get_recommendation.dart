part of 'generated.dart';

class GetRecommendationVariablesBuilder {
  String id;

  final FirebaseDataConnect _dataConnect;
  GetRecommendationVariablesBuilder(this._dataConnect, {required  this.id,});
  Deserializer<GetRecommendationData> dataDeserializer = (dynamic json)  => GetRecommendationData.fromJson(jsonDecode(json));
  Serializer<GetRecommendationVariables> varsSerializer = (GetRecommendationVariables vars) => jsonEncode(vars.toJson());
  Future<QueryResult<GetRecommendationData, GetRecommendationVariables>> execute({QueryFetchPolicy fetchPolicy = QueryFetchPolicy.preferCache}) {
    return ref().execute(fetchPolicy: fetchPolicy);
  }

  QueryRef<GetRecommendationData, GetRecommendationVariables> ref() {
    GetRecommendationVariables vars= GetRecommendationVariables(id: id,);
    return _dataConnect.query("GetRecommendation", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class GetRecommendationSmartRecommendation {
  final String message;
  final String priority;
  GetRecommendationSmartRecommendation.fromJson(dynamic json):
  
  message = nativeFromJson<String>(json['message']),
  priority = nativeFromJson<String>(json['priority']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetRecommendationSmartRecommendation otherTyped = other as GetRecommendationSmartRecommendation;
    return message == otherTyped.message && 
    priority == otherTyped.priority;
    
  }
  @override
  int get hashCode => Object.hashAll([message.hashCode, priority.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['message'] = nativeToJson<String>(message);
    json['priority'] = nativeToJson<String>(priority);
    return json;
  }

  const GetRecommendationSmartRecommendation({
    required this.message,
    required this.priority,
  });
}

@immutable
class GetRecommendationData {
  final GetRecommendationSmartRecommendation? smartRecommendation;
  GetRecommendationData.fromJson(dynamic json):
  
  smartRecommendation = json['smartRecommendation'] == null ? null : GetRecommendationSmartRecommendation.fromJson(json['smartRecommendation']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetRecommendationData otherTyped = other as GetRecommendationData;
    return smartRecommendation == otherTyped.smartRecommendation;
    
  }
  @override
  int get hashCode => smartRecommendation.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (smartRecommendation != null) {
      json['smartRecommendation'] = smartRecommendation!.toJson();
    }
    return json;
  }

  const GetRecommendationData({
    this.smartRecommendation,
  });
}

@immutable
class GetRecommendationVariables {
  final String id;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  GetRecommendationVariables.fromJson(Map<String, dynamic> json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetRecommendationVariables otherTyped = other as GetRecommendationVariables;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  const GetRecommendationVariables({
    required this.id,
  });
}

