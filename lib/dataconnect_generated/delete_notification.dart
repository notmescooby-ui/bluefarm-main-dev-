part of 'generated.dart';

class DeleteNotificationVariablesBuilder {
  String id;

  final FirebaseDataConnect _dataConnect;
  DeleteNotificationVariablesBuilder(this._dataConnect, {required  this.id,});
  Deserializer<DeleteNotificationData> dataDeserializer = (dynamic json)  => DeleteNotificationData.fromJson(jsonDecode(json));
  Serializer<DeleteNotificationVariables> varsSerializer = (DeleteNotificationVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<DeleteNotificationData, DeleteNotificationVariables>> execute() {
    return ref().execute();
  }

  MutationRef<DeleteNotificationData, DeleteNotificationVariables> ref() {
    DeleteNotificationVariables vars= DeleteNotificationVariables(id: id,);
    return _dataConnect.mutation("DeleteNotification", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class DeleteNotificationNotificationDelete {
  final String id;
  DeleteNotificationNotificationDelete.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final DeleteNotificationNotificationDelete otherTyped = other as DeleteNotificationNotificationDelete;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  const DeleteNotificationNotificationDelete({
    required this.id,
  });
}

@immutable
class DeleteNotificationData {
  final DeleteNotificationNotificationDelete? notification_delete;
  DeleteNotificationData.fromJson(dynamic json):
  
  notification_delete = json['notification_delete'] == null ? null : DeleteNotificationNotificationDelete.fromJson(json['notification_delete']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final DeleteNotificationData otherTyped = other as DeleteNotificationData;
    return notification_delete == otherTyped.notification_delete;
    
  }
  @override
  int get hashCode => notification_delete.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (notification_delete != null) {
      json['notification_delete'] = notification_delete!.toJson();
    }
    return json;
  }

  const DeleteNotificationData({
    this.notification_delete,
  });
}

@immutable
class DeleteNotificationVariables {
  final String id;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  DeleteNotificationVariables.fromJson(Map<String, dynamic> json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final DeleteNotificationVariables otherTyped = other as DeleteNotificationVariables;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  const DeleteNotificationVariables({
    required this.id,
  });
}

