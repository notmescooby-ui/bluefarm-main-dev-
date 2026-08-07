part of 'generated.dart';

class ListMyNotificationsVariablesBuilder {
  
  final FirebaseDataConnect _dataConnect;
  ListMyNotificationsVariablesBuilder(this._dataConnect, );
  Deserializer<ListMyNotificationsData> dataDeserializer = (dynamic json)  => ListMyNotificationsData.fromJson(jsonDecode(json));
  
  Future<QueryResult<ListMyNotificationsData, void>> execute({QueryFetchPolicy fetchPolicy = QueryFetchPolicy.preferCache}) {
    return ref().execute(fetchPolicy: fetchPolicy);
  }

  QueryRef<ListMyNotificationsData, void> ref() {
    
    return _dataConnect.query("ListMyNotifications", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class ListMyNotificationsNotifications {
  final String message;
  final bool isRead;
  ListMyNotificationsNotifications.fromJson(dynamic json):
  
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

    final ListMyNotificationsNotifications otherTyped = other as ListMyNotificationsNotifications;
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

  const ListMyNotificationsNotifications({
    required this.message,
    required this.isRead,
  });
}

@immutable
class ListMyNotificationsData {
  final List<ListMyNotificationsNotifications> notifications;
  ListMyNotificationsData.fromJson(dynamic json):
  
  notifications = (json['notifications'] as List<dynamic>)
        .map((e) => ListMyNotificationsNotifications.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListMyNotificationsData otherTyped = other as ListMyNotificationsData;
    return notifications == otherTyped.notifications;
    
  }
  @override
  int get hashCode => notifications.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['notifications'] = notifications.map((e) => e.toJson()).toList();
    return json;
  }

  const ListMyNotificationsData({
    required this.notifications,
  });
}

