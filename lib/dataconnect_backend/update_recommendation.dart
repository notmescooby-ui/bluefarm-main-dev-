part of 'generated.dart';

class UpdateRecommendationVariablesBuilder {
  String id;
  String priority;

  final FirebaseDataConnect _dataConnect;
  UpdateRecommendationVariablesBuilder(this._dataConnect, {required  this.id,required  this.priority,});
  Deserializer<UpdateRecommendationData> dataDeserializer = (dynamic json)  => UpdateRecommendationData.fromJson(jsonDecode(json));
  Serializer<UpdateRecommendationVariables> varsSerializer = (UpdateRecommendationVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<UpdateRecommendationData, UpdateRecommendationVariables>> execute() {
    return ref().execute();
  }

  MutationRef<UpdateRecommendationData, UpdateRecommendationVariables> ref() {
    UpdateRecommendationVariables vars= UpdateRecommendationVariables(id: id,priority: priority,);
    return _dataConnect.mutation("UpdateRecommendation", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class UpdateRecommendationSmartRecommendationUpdate {
  final String id;
  UpdateRecommendationSmartRecommendationUpdate.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpdateRecommendationSmartRecommendationUpdate otherTyped = other as UpdateRecommendationSmartRecommendationUpdate;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  const UpdateRecommendationSmartRecommendationUpdate({
    required this.id,
  });
}

@immutable
class UpdateRecommendationData {
  final UpdateRecommendationSmartRecommendationUpdate? smartRecommendation_update;
  UpdateRecommendationData.fromJson(dynamic json):
  
  smartRecommendation_update = json['smartRecommendation_update'] == null ? null : UpdateRecommendationSmartRecommendationUpdate.fromJson(json['smartRecommendation_update']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpdateRecommendationData otherTyped = other as UpdateRecommendationData;
    return smartRecommendation_update == otherTyped.smartRecommendation_update;
    
  }
  @override
  int get hashCode => smartRecommendation_update.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (smartRecommendation_update != null) {
      json['smartRecommendation_update'] = smartRecommendation_update!.toJson();
    }
    return json;
  }

  const UpdateRecommendationData({
    this.smartRecommendation_update,
  });
}

@immutable
class UpdateRecommendationVariables {
  final String id;
  final String priority;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  UpdateRecommendationVariables.fromJson(Map<String, dynamic> json):
  
  id = nativeFromJson<String>(json['id']),
  priority = nativeFromJson<String>(json['priority']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpdateRecommendationVariables otherTyped = other as UpdateRecommendationVariables;
    return id == otherTyped.id && 
    priority == otherTyped.priority;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, priority.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['priority'] = nativeToJson<String>(priority);
    return json;
  }

  const UpdateRecommendationVariables({
    required this.id,
    required this.priority,
  });
}

