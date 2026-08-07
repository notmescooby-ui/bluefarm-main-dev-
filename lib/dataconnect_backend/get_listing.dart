part of 'generated.dart';

class GetListingVariablesBuilder {
  String id;

  final FirebaseDataConnect _dataConnect;
  GetListingVariablesBuilder(this._dataConnect, {required  this.id,});
  Deserializer<GetListingData> dataDeserializer = (dynamic json)  => GetListingData.fromJson(jsonDecode(json));
  Serializer<GetListingVariables> varsSerializer = (GetListingVariables vars) => jsonEncode(vars.toJson());
  Future<QueryResult<GetListingData, GetListingVariables>> execute({QueryFetchPolicy fetchPolicy = QueryFetchPolicy.preferCache}) {
    return ref().execute(fetchPolicy: fetchPolicy);
  }

  QueryRef<GetListingData, GetListingVariables> ref() {
    GetListingVariables vars= GetListingVariables(id: id,);
    return _dataConnect.query("GetListing", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class GetListingHarvestListing {
  final String species;
  final double pricePerUnit;
  GetListingHarvestListing.fromJson(dynamic json):
  
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

    final GetListingHarvestListing otherTyped = other as GetListingHarvestListing;
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

  const GetListingHarvestListing({
    required this.species,
    required this.pricePerUnit,
  });
}

@immutable
class GetListingData {
  final GetListingHarvestListing? harvestListing;
  GetListingData.fromJson(dynamic json):
  
  harvestListing = json['harvestListing'] == null ? null : GetListingHarvestListing.fromJson(json['harvestListing']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetListingData otherTyped = other as GetListingData;
    return harvestListing == otherTyped.harvestListing;
    
  }
  @override
  int get hashCode => harvestListing.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (harvestListing != null) {
      json['harvestListing'] = harvestListing!.toJson();
    }
    return json;
  }

  const GetListingData({
    this.harvestListing,
  });
}

@immutable
class GetListingVariables {
  final String id;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  GetListingVariables.fromJson(Map<String, dynamic> json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetListingVariables otherTyped = other as GetListingVariables;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  const GetListingVariables({
    required this.id,
  });
}

