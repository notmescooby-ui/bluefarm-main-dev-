part of 'generated.dart';

class CreateListingVariablesBuilder {
  String species;
  int quantity;
  double price;

  final FirebaseDataConnect _dataConnect;
  CreateListingVariablesBuilder(this._dataConnect, {required  this.species,required  this.quantity,required  this.price,});
  Deserializer<CreateListingData> dataDeserializer = (dynamic json)  => CreateListingData.fromJson(jsonDecode(json));
  Serializer<CreateListingVariables> varsSerializer = (CreateListingVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<CreateListingData, CreateListingVariables>> execute() {
    return ref().execute();
  }

  MutationRef<CreateListingData, CreateListingVariables> ref() {
    CreateListingVariables vars= CreateListingVariables(species: species,quantity: quantity,price: price,);
    return _dataConnect.mutation("CreateListing", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class CreateListingHarvestListingInsert {
  final String id;
  CreateListingHarvestListingInsert.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateListingHarvestListingInsert otherTyped = other as CreateListingHarvestListingInsert;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  const CreateListingHarvestListingInsert({
    required this.id,
  });
}

@immutable
class CreateListingData {
  final CreateListingHarvestListingInsert harvestListing_insert;
  CreateListingData.fromJson(dynamic json):
  
  harvestListing_insert = CreateListingHarvestListingInsert.fromJson(json['harvestListing_insert']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateListingData otherTyped = other as CreateListingData;
    return harvestListing_insert == otherTyped.harvestListing_insert;
    
  }
  @override
  int get hashCode => harvestListing_insert.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['harvestListing_insert'] = harvestListing_insert.toJson();
    return json;
  }

  const CreateListingData({
    required this.harvestListing_insert,
  });
}

@immutable
class CreateListingVariables {
  final String species;
  final int quantity;
  final double price;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  CreateListingVariables.fromJson(Map<String, dynamic> json):
  
  species = nativeFromJson<String>(json['species']),
  quantity = nativeFromJson<int>(json['quantity']),
  price = nativeFromJson<double>(json['price']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateListingVariables otherTyped = other as CreateListingVariables;
    return species == otherTyped.species && 
    quantity == otherTyped.quantity && 
    price == otherTyped.price;
    
  }
  @override
  int get hashCode => Object.hashAll([species.hashCode, quantity.hashCode, price.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['species'] = nativeToJson<String>(species);
    json['quantity'] = nativeToJson<int>(quantity);
    json['price'] = nativeToJson<double>(price);
    return json;
  }

  const CreateListingVariables({
    required this.species,
    required this.quantity,
    required this.price,
  });
}

