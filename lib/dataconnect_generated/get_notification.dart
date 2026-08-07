part of 'generated.dart';

class GetNotificationVariablesBuilder {
  String id;

  final FirebaseDataConnect _dataConnect;
  GetNotificationVariablesBuilder(this._dataConnect, {required  this.id,});
  Deserializer<GetNotificationData> dataDeserializer = (dynamic json)  => GetNotificationData.fromJson(jsonDecode(json));
  Serializer<GetNotificationVariables> varsSerializer = (GetNotificationVariables vars) => jsonEncode(vars.toJson());
  Future<QueryResult<GetNotificationData, GetNotificationVariables>> execute({QueryFetchPolicy fetchPolicy = QueryFetchPolicy.preferCache}) {
    return ref().execute(fetchPolicy: fetchPolicy);
  }

  QueryRef<GetNotificationData, GetNotificationVariables> ref() {
    GetNotificationVariables vars= GetNotificationVariables(id: id,);
    return _dataConnect.query("GetNotification", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class GetNotificationNotification {
  final String message;
  final bool isRead;
  GetNotificationNotification.fromJson(dynamic json):
  
  message = nativeFromJson<String>(json['message']),
  isRead = nativeFromJson<bool>(json['isRead']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetNotificationNotification otherTyped = other as GetNotificationNotification;
    return message == otherTyped.message && 
    isRead == otherTyped.isRead;
    
  }
  @override
  int get hashCode => Object.hashAll([message.hashCode, isRead.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['message'] = nativeToJson<String>(message);
    json['isRead'] = nativeToJson<bool>(isRead);
    return json;
  }

  const GetNotificationNotification({
    required this.message,
    required this.isRead,
  });
}

@immutable
class GetNotificationData {
  final GetNotificationNotification? notification;
  GetNotificationData.fromJson(dynamic json):
  
  notification = json['notification'] == null ? null : GetNotificationNotification.fromJson(json['notification']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetNotificationData otherTyped = other as GetNotificationData;
    return notification == otherTyped.notification;
    
  }
  @override
  int get hashCode => notification.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (notification != null) {
      json['notification'] = notification!.toJson();
    }
    return json;
  }

  const GetNotificationData({
    this.notification,
  });
}

@immutable
class GetNotificationVariables {
  final String id;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  GetNotificationVariables.fromJson(Map<String, dynamic> json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetNotificationVariables otherTyped = other as GetNotificationVariables;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  const GetNotificationVariables({
    required this.id,
  });
}

