part of 'generated.dart';

class DeleteListingVariablesBuilder {
  String id;

  final FirebaseDataConnect _dataConnect;
  DeleteListingVariablesBuilder(this._dataConnect, {required  this.id,});
  Deserializer<DeleteListingData> dataDeserializer = (dynamic json)  => DeleteListingData.fromJson(jsonDecode(json));
  Serializer<DeleteListingVariables> varsSerializer = (DeleteListingVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<DeleteListingData, DeleteListingVariables>> execute() {
    return ref().execute();
  }

  MutationRef<DeleteListingData, DeleteListingVariables> ref() {
    DeleteListingVariables vars= DeleteListingVariables(id: id,);
    return _dataConnect.mutation("DeleteListing", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class DeleteListingHarvestListingDelete {
  final String id;
  DeleteListingHarvestListingDelete.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final DeleteListingHarvestListingDelete otherTyped = other as DeleteListingHarvestListingDelete;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  const DeleteListingHarvestListingDelete({
    required this.id,
  });
}

@immutable
class DeleteListingData {
  final DeleteListingHarvestListingDelete? harvestListing_delete;
  DeleteListingData.fromJson(dynamic json):
  
  harvestListing_delete = json['harvestListing_delete'] == null ? null : DeleteListingHarvestListingDelete.fromJson(json['harvestListing_delete']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final DeleteListingData otherTyped = other as DeleteListingData;
    return harvestListing_delete == otherTyped.harvestListing_delete;
    
  }
  @override
  int get hashCode => harvestListing_delete.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (harvestListing_delete != null) {
      json['harvestListing_delete'] = harvestListing_delete!.toJson();
    }
    return json;
  }

  const DeleteListingData({
    this.harvestListing_delete,
  });
}

@immutable
class DeleteListingVariables {
  final String id;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  DeleteListingVariables.fromJson(Map<String, dynamic> json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final DeleteListingVariables otherTyped = other as DeleteListingVariables;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  const DeleteListingVariables({
    required this.id,
  });
}

