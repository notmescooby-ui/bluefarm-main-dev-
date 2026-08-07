part of 'generated.dart';

class CreateOrderVariablesBuilder {
  String listingId;
  int quantity;
  double total;

  final FirebaseDataConnect _dataConnect;
  CreateOrderVariablesBuilder(this._dataConnect, {required  this.listingId,required  this.quantity,required  this.total,});
  Deserializer<CreateOrderData> dataDeserializer = (dynamic json)  => CreateOrderData.fromJson(jsonDecode(json));
  Serializer<CreateOrderVariables> varsSerializer = (CreateOrderVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<CreateOrderData, CreateOrderVariables>> execute() {
    return ref().execute();
  }

  MutationRef<CreateOrderData, CreateOrderVariables> ref() {
    CreateOrderVariables vars= CreateOrderVariables(listingId: listingId,quantity: quantity,total: total,);
    return _dataConnect.mutation("CreateOrder", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class CreateOrderOrderInsert {
  final String id;
  CreateOrderOrderInsert.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateOrderOrderInsert otherTyped = other as CreateOrderOrderInsert;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  const CreateOrderOrderInsert({
    required this.id,
  });
}

@immutable
class CreateOrderData {
  final CreateOrderOrderInsert order_insert;
  CreateOrderData.fromJson(dynamic json):
  
  order_insert = CreateOrderOrderInsert.fromJson(json['order_insert']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateOrderData otherTyped = other as CreateOrderData;
    return order_insert == otherTyped.order_insert;
    
  }
  @override
  int get hashCode => order_insert.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['order_insert'] = order_insert.toJson();
    return json;
  }

  const CreateOrderData({
    required this.order_insert,
  });
}

@immutable
class CreateOrderVariables {
  final String listingId;
  final int quantity;
  final double total;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  CreateOrderVariables.fromJson(Map<String, dynamic> json):
  
  listingId = nativeFromJson<String>(json['listingId']),
  quantity = nativeFromJson<int>(json['quantity']),
  total = nativeFromJson<double>(json['total']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateOrderVariables otherTyped = other as CreateOrderVariables;
    return listingId == otherTyped.listingId && 
    quantity == otherTyped.quantity && 
    total == otherTyped.total;
    
  }
  @override
  int get hashCode => Object.hashAll([listingId.hashCode, quantity.hashCode, total.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['listingId'] = nativeToJson<String>(listingId);
    json['quantity'] = nativeToJson<int>(quantity);
    json['total'] = nativeToJson<double>(total);
    return json;
  }

  const CreateOrderVariables({
    required this.listingId,
    required this.quantity,
    required this.total,
  });
}

