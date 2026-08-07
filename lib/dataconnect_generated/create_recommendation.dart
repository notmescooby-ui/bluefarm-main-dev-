part of 'generated.dart';

class CreateRecommendationVariablesBuilder {
  String pondId;
  String message;
  String priority;

  final FirebaseDataConnect _dataConnect;
  CreateRecommendationVariablesBuilder(this._dataConnect, {required  this.pondId,required  this.message,required  this.priority,});
  Deserializer<CreateRecommendationData> dataDeserializer = (dynamic json)  => CreateRecommendationData.fromJson(jsonDecode(json));
  Serializer<CreateRecommendationVariables> varsSerializer = (CreateRecommendationVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<CreateRecommendationData, CreateRecommendationVariables>> execute() {
    return ref().execute();
  }

  MutationRef<CreateRecommendationData, CreateRecommendationVariables> ref() {
    CreateRecommendationVariables vars= CreateRecommendationVariables(pondId: pondId,message: message,priority: priority,);
    return _dataConnect.mutation("CreateRecommendation", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class CreateRecommendationSmartRecommendationInsert {
  final String id;
  CreateRecommendationSmartRecommendationInsert.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateRecommendationSmartRecommendationInsert otherTyped = other as CreateRecommendationSmartRecommendationInsert;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  const CreateRecommendationSmartRecommendationInsert({
    required this.id,
  });
}

@immutable
class CreateRecommendationData {
  final CreateRecommendationSmartRecommendationInsert smartRecommendation_insert;
  CreateRecommendationData.fromJson(dynamic json):
  
  smartRecommendation_insert = CreateRecommendationSmartRecommendationInsert.fromJson(json['smartRecommendation_insert']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateRecommendationData otherTyped = other as CreateRecommendationData;
    return smartRecommendation_insert == otherTyped.smartRecommendation_insert;
    
  }
  @override
  int get hashCode => smartRecommendation_insert.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['smartRecommendation_insert'] = smartRecommendation_insert.toJson();
    return json;
  }

  const CreateRecommendationData({
    required this.smartRecommendation_insert,
  });
}

@immutable
class CreateRecommendationVariables {
  final String pondId;
  final String message;
  final String priority;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  CreateRecommendationVariables.fromJson(Map<String, dynamic> json):
  
  pondId = nativeFromJson<String>(json['pondId']),
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

    final CreateRecommendationVariables otherTyped = other as CreateRecommendationVariables;
    return pondId == otherTyped.pondId && 
    message == otherTyped.message && 
    priority == otherTyped.priority;
    
  }
  @override
  int get hashCode => Object.hashAll([pondId.hashCode, message.hashCode, priority.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['pondId'] = nativeToJson<String>(pondId);
    json['message'] = nativeToJson<String>(message);
    json['priority'] = nativeToJson<String>(priority);
    return json;
  }

  const CreateRecommendationVariables({
    required this.pondId,
    required this.message,
    required this.priority,
  });
}

