part of 'generated.dart';

class CreateNotificationVariablesBuilder {
  String userId;
  String message;

  final FirebaseDataConnect _dataConnect;
  CreateNotificationVariablesBuilder(this._dataConnect, {required  this.userId,required  this.message,});
  Deserializer<CreateNotificationData> dataDeserializer = (dynamic json)  => CreateNotificationData.fromJson(jsonDecode(json));
  Serializer<CreateNotificationVariables> varsSerializer = (CreateNotificationVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<CreateNotificationData, CreateNotificationVariables>> execute() {
    return ref().execute();
  }

  MutationRef<CreateNotificationData, CreateNotificationVariables> ref() {
    CreateNotificationVariables vars= CreateNotificationVariables(userId: userId,message: message,);
    return _dataConnect.mutation("CreateNotification", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class CreateNotificationNotificationInsert {
  final String id;
  CreateNotificationNotificationInsert.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateNotificationNotificationInsert otherTyped = other as CreateNotificationNotificationInsert;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  const CreateNotificationNotificationInsert({
    required this.id,
  });
}

@immutable
class CreateNotificationData {
  final CreateNotificationNotificationInsert notification_insert;
  CreateNotificationData.fromJson(dynamic json):
  
  notification_insert = CreateNotificationNotificationInsert.fromJson(json['notification_insert']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateNotificationData otherTyped = other as CreateNotificationData;
    return notification_insert == otherTyped.notification_insert;
    
  }
  @override
  int get hashCode => notification_insert.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['notification_insert'] = notification_insert.toJson();
    return json;
  }

  const CreateNotificationData({
    required this.notification_insert,
  });
}

@immutable
class CreateNotificationVariables {
  final String userId;
  final String message;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  CreateNotificationVariables.fromJson(Map<String, dynamic> json):
  
  userId = nativeFromJson<String>(json['userId']),
  message = nativeFromJson<String>(json['message']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateNotificationVariables otherTyped = other as CreateNotificationVariables;
    return userId == otherTyped.userId && 
    message == otherTyped.message;
    
  }
  @override
  int get hashCode => Object.hashAll([userId.hashCode, message.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['userId'] = nativeToJson<String>(userId);
    json['message'] = nativeToJson<String>(message);
    return json;
  }

  const CreateNotificationVariables({
    required this.userId,
    required this.message,
  });
}

