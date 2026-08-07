part of 'generated.dart';

class ListRecommendationsVariablesBuilder {
  
  final FirebaseDataConnect _dataConnect;
  ListRecommendationsVariablesBuilder(this._dataConnect, );
  Deserializer<ListRecommendationsData> dataDeserializer = (dynamic json)  => ListRecommendationsData.fromJson(jsonDecode(json));
  
  Future<QueryResult<ListRecommendationsData, void>> execute({QueryFetchPolicy fetchPolicy = QueryFetchPolicy.preferCache}) {
    return ref().execute(fetchPolicy: fetchPolicy);
  }

  QueryRef<ListRecommendationsData, void> ref() {
    
    return _dataConnect.query("ListRecommendations", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class ListRecommendationsSmartRecommendations {
  final String message;
  final String priority;
  ListRecommendationsSmartRecommendations.fromJson(dynamic json):
  
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

    final ListRecommendationsSmartRecommendations otherTyped = other as ListRecommendationsSmartRecommendations;
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

  const ListRecommendationsSmartRecommendations({
    required this.message,
    required this.priority,
  });
}

@immutable
class ListRecommendationsData {
  final List<ListRecommendationsSmartRecommendations> smartRecommendations;
  ListRecommendationsData.fromJson(dynamic json):
  
  smartRecommendations = (json['smartRecommendations'] as List<dynamic>)
        .map((e) => ListRecommendationsSmartRecommendations.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListRecommendationsData otherTyped = other as ListRecommendationsData;
    return smartRecommendations == otherTyped.smartRecommendations;
    
  }
  @override
  int get hashCode => smartRecommendations.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['smartRecommendations'] = smartRecommendations.map((e) => e.toJson()).toList();
    return json;
  }

  const ListRecommendationsData({
    required this.smartRecommendations,
  });
}

