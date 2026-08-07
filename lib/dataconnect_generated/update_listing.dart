part of 'generated.dart';

class UpdateListingVariablesBuilder {
  String id;
  String status;

  final FirebaseDataConnect _dataConnect;
  UpdateListingVariablesBuilder(this._dataConnect, {required  this.id,required  this.status,});
  Deserializer<UpdateListingData> dataDeserializer = (dynamic json)  => UpdateListingData.fromJson(jsonDecode(json));
  Serializer<UpdateListingVariables> varsSerializer = (UpdateListingVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<UpdateListingData, UpdateListingVariables>> execute() {
    return ref().execute();
  }

  MutationRef<UpdateListingData, UpdateListingVariables> ref() {
    UpdateListingVariables vars= UpdateListingVariables(id: id,status: status,);
    return _dataConnect.mutation("UpdateListing", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class UpdateListingHarvestListingUpdate {
  final String id;
  UpdateListingHarvestListingUpdate.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpdateListingHarvestListingUpdate otherTyped = other as UpdateListingHarvestListingUpdate;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  const UpdateListingHarvestListingUpdate({
    required this.id,
  });
}

@immutable
class UpdateListingData {
  final UpdateListingHarvestListingUpdate? harvestListing_update;
  UpdateListingData.fromJson(dynamic json):
  
  harvestListing_update = json['harvestListing_update'] == null ? null : UpdateListingHarvestListingUpdate.fromJson(json['harvestListing_update']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpdateListingData otherTyped = other as UpdateListingData;
    return harvestListing_update == otherTyped.harvestListing_update;
    
  }
  @override
  int get hashCode => harvestListing_update.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (harvestListing_update != null) {
      json['harvestListing_update'] = harvestListing_update!.toJson();
    }
    return json;
  }

  const UpdateListingData({
    this.harvestListing_update,
  });
}

@immutable
class UpdateListingVariables {
  final String id;
  final String status;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  UpdateListingVariables.fromJson(Map<String, dynamic> json):
  
  id = nativeFromJson<String>(json['id']),
  status = nativeFromJson<String>(json['status']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpdateListingVariables otherTyped = other as UpdateListingVariables;
    return id == otherTyped.id && 
    status == otherTyped.status;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, status.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['status'] = nativeToJson<String>(status);
    return json;
  }

  const UpdateListingVariables({
    required this.id,
    required this.status,
  });
}

