part of 'generated.dart';

class GetOrderVariablesBuilder {
  String id;

  final FirebaseDataConnect _dataConnect;
  GetOrderVariablesBuilder(this._dataConnect, {required  this.id,});
  Deserializer<GetOrderData> dataDeserializer = (dynamic json)  => GetOrderData.fromJson(jsonDecode(json));
  Serializer<GetOrderVariables> varsSerializer = (GetOrderVariables vars) => jsonEncode(vars.toJson());
  Future<QueryResult<GetOrderData, GetOrderVariables>> execute({QueryFetchPolicy fetchPolicy = QueryFetchPolicy.preferCache}) {
    return ref().execute(fetchPolicy: fetchPolicy);
  }

  QueryRef<GetOrderData, GetOrderVariables> ref() {
    GetOrderVariables vars= GetOrderVariables(id: id,);
    return _dataConnect.query("GetOrder", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class GetOrderOrder {
  final String status;
  final double totalAmount;
  GetOrderOrder.fromJson(dynamic json):
  
  status = nativeFromJson<String>(json['status']),
  totalAmount = nativeFromJson<double>(json['totalAmount']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetOrderOrder otherTyped = other as GetOrderOrder;
    return status == otherTyped.status && 
    totalAmount == otherTyped.totalAmount;
    
  }
  @override
  int get hashCode => Object.hashAll([status.hashCode, totalAmount.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['status'] = nativeToJson<String>(status);
    json['totalAmount'] = nativeToJson<double>(totalAmount);
    return json;
  }

  const GetOrderOrder({
    required this.status,
    required this.totalAmount,
  });
}

@immutable
class GetOrderData {
  final GetOrderOrder? order;
  GetOrderData.fromJson(dynamic json):
  
  order = json['order'] == null ? null : GetOrderOrder.fromJson(json['order']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetOrderData otherTyped = other as GetOrderData;
    return order == otherTyped.order;
    
  }
  @override
  int get hashCode => order.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (order != null) {
      json['order'] = order!.toJson();
    }
    return json;
  }

  const GetOrderData({
    this.order,
  });
}

@immutable
class GetOrderVariables {
  final String id;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  GetOrderVariables.fromJson(Map<String, dynamic> json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final GetOrderVariables otherTyped = other as GetOrderVariables;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  const GetOrderVariables({
    required this.id,
  });
}

