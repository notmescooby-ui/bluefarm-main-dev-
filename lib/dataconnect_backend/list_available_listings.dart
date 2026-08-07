part of 'generated.dart';

class ListAvailableListingsVariablesBuilder {
  
  final FirebaseDataConnect _dataConnect;
  ListAvailableListingsVariablesBuilder(this._dataConnect, );
  Deserializer<ListAvailableListingsData> dataDeserializer = (dynamic json)  => ListAvailableListingsData.fromJson(jsonDecode(json));
  
  Future<QueryResult<ListAvailableListingsData, void>> execute({QueryFetchPolicy fetchPolicy = QueryFetchPolicy.preferCache}) {
    return ref().execute(fetchPolicy: fetchPolicy);
  }

  QueryRef<ListAvailableListingsData, void> ref() {
    
    return _dataConnect.query("ListAvailableListings", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class ListAvailableListingsHarvestListings {
  final String species;
  final double pricePerUnit;
  ListAvailableListingsHarvestListings.fromJson(dynamic json):
  
  species = nativeFromJson<String>(json['species']),
  pricePerUnit = nativeFromJson<double>(json['pricePerUnit']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListAvailableListingsHarvestListings otherTyped = other as ListAvailableListingsHarvestListings;
    return species == otherTyped.species && 
    pricePerUnit == otherTyped.pricePerUnit;
    
  }
  @override
  int get hashCode => Object.hashAll([species.hashCode, pricePerUnit.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['species'] = nativeToJson<String>(species);
    json['pricePerUnit'] = nativeToJson<double>(pricePerUnit);
    return json;
  }

  const ListAvailableListingsHarvestListings({
    required this.species,
    required this.pricePerUnit,
  });
}

@immutable
class ListAvailableListingsData {
  final List<ListAvailableListingsHarvestListings> harvestListings;
  ListAvailableListingsData.fromJson(dynamic json):
  
  harvestListings = (json['harvestListings'] as List<dynamic>)
        .map((e) => ListAvailableListingsHarvestListings.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListAvailableListingsData otherTyped = other as ListAvailableListingsData;
    return harvestListings == otherTyped.harvestListings;
    
  }
  @override
  int get hashCode => harvestListings.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['harvestListings'] = harvestListings.map((e) => e.toJson()).toList();
    return json;
  }

  const ListAvailableListingsData({
    required this.harvestListings,
  });
}

