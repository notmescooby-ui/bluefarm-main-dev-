part of 'generated.dart';

class MarkNotificationReadVariablesBuilder {
  String id;

  final FirebaseDataConnect _dataConnect;
  MarkNotificationReadVariablesBuilder(this._dataConnect, {required  this.id,});
  Deserializer<MarkNotificationReadData> dataDeserializer = (dynamic json)  => MarkNotificationReadData.fromJson(jsonDecode(json));
  Serializer<MarkNotificationReadVariables> varsSerializer = (MarkNotificationReadVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<MarkNotificationReadData, MarkNotificationReadVariables>> execute() {
    return ref().execute();
  }

  MutationRef<MarkNotificationReadData, MarkNotificationReadVariables> ref() {
    MarkNotificationReadVariables vars= MarkNotificationReadVariables(id: id,);
    return _dataConnect.mutation("MarkNotificationRead", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class MarkNotificationReadNotificationUpdate {
  final String id;
  MarkNotificationReadNotificationUpdate.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final MarkNotificationReadNotificationUpdate otherTyped = other as MarkNotificationReadNotificationUpdate;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  const MarkNotificationReadNotificationUpdate({
    required this.id,
  });
}

@immutable
class MarkNotificationReadData {
  final MarkNotificationReadNotificationUpdate? notification_update;
  MarkNotificationReadData.fromJson(dynamic json):
  
  notification_update = json['notification_update'] == null ? null : MarkNotificationReadNotificationUpdate.fromJson(json['notification_update']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final MarkNotificationReadData otherTyped = other as MarkNotificationReadData;
    return notification_update == otherTyped.notification_update;
    
  }
  @override
  int get hashCode => notification_update.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (notification_update != null) {
      json['notification_update'] = notification_update!.toJson();
    }
    return json;
  }

  const MarkNotificationReadData({
    this.notification_update,
  });
}

@immutable
class MarkNotificationReadVariables {
  final String id;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  MarkNotificationReadVariables.fromJson(Map<String, dynamic> json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final MarkNotificationReadVariables otherTyped = other as MarkNotificationReadVariables;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  const MarkNotificationReadVariables({
    required this.id,
  });
}

