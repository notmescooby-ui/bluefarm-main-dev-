part of 'generated.dart';

class DeletePondVariablesBuilder {
  String id;

  final FirebaseDataConnect _dataConnect;
  DeletePondVariablesBuilder(this._dataConnect, {required  this.id,});
  Deserializer<DeletePondData> dataDeserializer = (dynamic json)  => DeletePondData.fromJson(jsonDecode(json));
  Serializer<DeletePondVariables> varsSerializer = (DeletePondVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<DeletePondData, DeletePondVariables>> execute() {
    return ref().execute();
  }

  MutationRef<DeletePondData, DeletePondVariables> ref() {
    DeletePondVariables vars= DeletePondVariables(id: id,);
    return _dataConnect.mutation("DeletePond", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class DeletePondPondDelete {
  final String id;
  DeletePondPondDelete.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final DeletePondPondDelete otherTyped = other as DeletePondPondDelete;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  const DeletePondPondDelete({
    required this.id,
  });
}

@immutable
class DeletePondData {
  final DeletePondPondDelete? pond_delete;
  DeletePondData.fromJson(dynamic json):
  
  pond_delete = json['pond_delete'] == null ? null : DeletePondPondDelete.fromJson(json['pond_delete']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final DeletePondData otherTyped = other as DeletePondData;
    return pond_delete == otherTyped.pond_delete;
    
  }
  @override
  int get hashCode => pond_delete.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (pond_delete != null) {
      json['pond_delete'] = pond_delete!.toJson();
    }
    return json;
  }

  const DeletePondData({
    this.pond_delete,
  });
}

@immutable
class DeletePondVariables {
  final String id;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  DeletePondVariables.fromJson(Map<String, dynamic> json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final DeletePondVariables otherTyped = other as DeletePondVariables;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  const DeletePondVariables({
    required this.id,
  });
}

