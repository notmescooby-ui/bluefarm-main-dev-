part of 'generated.dart';

class ListMyPondsVariablesBuilder {
  
  final FirebaseDataConnect _dataConnect;
  ListMyPondsVariablesBuilder(this._dataConnect, );
  Deserializer<ListMyPondsData> dataDeserializer = (dynamic json)  => ListMyPondsData.fromJson(jsonDecode(json));
  
  Future<QueryResult<ListMyPondsData, void>> execute({QueryFetchPolicy fetchPolicy = QueryFetchPolicy.preferCache}) {
    return ref().execute(fetchPolicy: fetchPolicy);
  }

  QueryRef<ListMyPondsData, void> ref() {
    
    return _dataConnect.query("ListMyPonds", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class ListMyPondsPonds {
  final String name;
  final String location;
  ListMyPondsPonds.fromJson(dynamic json):
  
  name = nativeFromJson<String>(json['name']),
  location = nativeFromJson<String>(json['location']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListMyPondsPonds otherTyped = other as ListMyPondsPonds;
    return name == otherTyped.name && 
    location == otherTyped.location;
    
  }
  @override
  int get hashCode => Object.hashAll([name.hashCode, location.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['name'] = nativeToJson<String>(name);
    json['location'] = nativeToJson<String>(location);
    return json;
  }

  const ListMyPondsPonds({
    required this.name,
    required this.location,
  });
}

@immutable
class ListMyPondsData {
  final List<ListMyPondsPonds> ponds;
  ListMyPondsData.fromJson(dynamic json):
  
  ponds = (json['ponds'] as List<dynamic>)
        .map((e) => ListMyPondsPonds.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListMyPondsData otherTyped = other as ListMyPondsData;
    return ponds == otherTyped.ponds;
    
  }
  @override
  int get hashCode => ponds.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['ponds'] = ponds.map((e) => e.toJson()).toList();
    return json;
  }

  const ListMyPondsData({
    required this.ponds,
  });
}

