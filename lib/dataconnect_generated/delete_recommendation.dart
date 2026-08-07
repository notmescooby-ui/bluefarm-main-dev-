part of 'generated.dart';

class DeleteRecommendationVariablesBuilder {
  String id;

  final FirebaseDataConnect _dataConnect;
  DeleteRecommendationVariablesBuilder(this._dataConnect, {required  this.id,});
  Deserializer<DeleteRecommendationData> dataDeserializer = (dynamic json)  => DeleteRecommendationData.fromJson(jsonDecode(json));
  Serializer<DeleteRecommendationVariables> varsSerializer = (DeleteRecommendationVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<DeleteRecommendationData, DeleteRecommendationVariables>> execute() {
    return ref().execute();
  }

  MutationRef<DeleteRecommendationData, DeleteRecommendationVariables> ref() {
    DeleteRecommendationVariables vars= DeleteRecommendationVariables(id: id,);
    return _dataConnect.mutation("DeleteRecommendation", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class DeleteRecommendationSmartRecommendationDelete {
  final String id;
  DeleteRecommendationSmartRecommendationDelete.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final DeleteRecommendationSmartRecommendationDelete otherTyped = other as DeleteRecommendationSmartRecommendationDelete;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  const DeleteRecommendationSmartRecommendationDelete({
    required this.id,
  });
}

@immutable
class DeleteRecommendationData {
  final DeleteRecommendationSmartRecommendationDelete? smartRecommendation_delete;
  DeleteRecommendationData.fromJson(dynamic json):
  
  smartRecommendation_delete = json['smartRecommendation_delete'] == null ? null : DeleteRecommendationSmartRecommendationDelete.fromJson(json['smartRecommendation_delete']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final DeleteRecommendationData otherTyped = other as DeleteRecommendationData;
    return smartRecommendation_delete == otherTyped.smartRecommendation_delete;
    
  }
  @override
  int get hashCode => smartRecommendation_delete.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (smartRecommendation_delete != null) {
      json['smartRecommendation_delete'] = smartRecommendation_delete!.toJson();
    }
    return json;
  }

  const DeleteRecommendationData({
    this.smartRecommendation_delete,
  });
}

@immutable
class DeleteRecommendationVariables {
  final String id;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  DeleteRecommendationVariables.fromJson(Map<String, dynamic> json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final DeleteRecommendationVariables otherTyped = other as DeleteRecommendationVariables;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  const DeleteRecommendationVariables({
    required this.id,
  });
}

