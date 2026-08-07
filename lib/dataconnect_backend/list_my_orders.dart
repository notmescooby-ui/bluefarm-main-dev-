part of 'generated.dart';

class ListMyOrdersVariablesBuilder {
  
  final FirebaseDataConnect _dataConnect;
  ListMyOrdersVariablesBuilder(this._dataConnect, );
  Deserializer<ListMyOrdersData> dataDeserializer = (dynamic json)  => ListMyOrdersData.fromJson(jsonDecode(json));
  
  Future<QueryResult<ListMyOrdersData, void>> execute({QueryFetchPolicy fetchPolicy = QueryFetchPolicy.preferCache}) {
    return ref().execute(fetchPolicy: fetchPolicy);
  }

  QueryRef<ListMyOrdersData, void> ref() {
    
    return _dataConnect.query("ListMyOrders", dataDeserializer, emptySerializer, null);
  }
}

@immutable
class ListMyOrdersOrders {
  final ListMyOrdersOrdersListing listing;
  final String status;
  ListMyOrdersOrders.fromJson(dynamic json):
  
  listing = ListMyOrdersOrdersListing.fromJson(json['listing']),
  status = nativeFromJson<String>(json['status']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListMyOrdersOrders otherTyped = other as ListMyOrdersOrders;
    return listing == otherTyped.listing && 
    status == otherTyped.status;
    
  }
  @override
  int get hashCode => Object.hashAll([listing.hashCode, status.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['listing'] = listing.toJson();
    json['status'] = nativeToJson<String>(status);
    return json;
  }

  const ListMyOrdersOrders({
    required this.listing,
    required this.status,
  });
}

@immutable
class ListMyOrdersOrdersListing {
  final String species;
  ListMyOrdersOrdersListing.fromJson(dynamic json):
  
  species = nativeFromJson<String>(json['species']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListMyOrdersOrdersListing otherTyped = other as ListMyOrdersOrdersListing;
    return species == otherTyped.species;
    
  }
  @override
  int get hashCode => species.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['species'] = nativeToJson<String>(species);
    return json;
  }

  const ListMyOrdersOrdersListing({
    required this.species,
  });
}

@immutable
class ListMyOrdersData {
  final List<ListMyOrdersOrders> orders;
  ListMyOrdersData.fromJson(dynamic json):
  
  orders = (json['orders'] as List<dynamic>)
        .map((e) => ListMyOrdersOrders.fromJson(e))
        .toList();
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final ListMyOrdersData otherTyped = other as ListMyOrdersData;
    return orders == otherTyped.orders;
    
  }
  @override
  int get hashCode => orders.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['orders'] = orders.map((e) => e.toJson()).toList();
    return json;
  }

  const ListMyOrdersData({
    required this.orders,
  });
}

