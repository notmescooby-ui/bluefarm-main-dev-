part of 'generated.dart';

class CreatePondVariablesBuilder {
  String name;
  String location;
  final Optional<double> _capacity = Optional.optional(nativeFromJson, nativeToJson);

  final FirebaseDataConnect _dataConnect;  CreatePondVariablesBuilder capacity(double? t) {
   _capacity.value = t;
   return this;
  }

  CreatePondVariablesBuilder(this._dataConnect, {required  this.name,required  this.location,});
  Deserializer<CreatePondData> dataDeserializer = (dynamic json)  => CreatePondData.fromJson(jsonDecode(json));
  Serializer<CreatePondVariables> varsSerializer = (CreatePondVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<CreatePondData, CreatePondVariables>> execute() {
    return ref().execute();
  }

  MutationRef<CreatePondData, CreatePondVariables> ref() {
    CreatePondVariables vars= CreatePondVariables(name: name,location: location,capacity: _capacity,);
    return _dataConnect.mutation("CreatePond", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class CreatePondPondInsert {
  final String id;
  CreatePondPondInsert.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreatePondPondInsert otherTyped = other as CreatePondPondInsert;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  const CreatePondPondInsert({
    required this.id,
  });
}

@immutable
class CreatePondData {
  final CreatePondPondInsert pond_insert;
  CreatePondData.fromJson(dynamic json):
  
  pond_insert = CreatePondPondInsert.fromJson(json['pond_insert']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreatePondData otherTyped = other as CreatePondData;
    return pond_insert == otherTyped.pond_insert;
    
  }
  @override
  int get hashCode => pond_insert.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['pond_insert'] = pond_insert.toJson();
    return json;
  }

  const CreatePondData({
    required this.pond_insert,
  });
}

@immutable
class CreatePondVariables {
  final String name;
  final String location;
  final Optional<double>capacity;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  CreatePondVariables.fromJson(Map<String, dynamic> json):
  
  name = nativeFromJson<String>(json['name']),
  location = nativeFromJson<String>(json['location']) {
        
  
  
  
    capacity = Optional.optional(nativeFromJson, nativeToJson);
    capacity.value = json['capacity'] == null ? null : nativeFromJson<double>(json['capacity']);
  
  }
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreatePondVariables otherTyped = other as CreatePondVariables;
    return name == otherTyped.name && 
    location == otherTyped.location && 
    capacity == otherTyped.capacity;
    
  }
  @override
  int get hashCode => Object.hashAll([name.hashCode, location.hashCode, capacity.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['name'] = nativeToJson<String>(name);
    json['location'] = nativeToJson<String>(location);
    if(capacity.state == OptionalState.set) {
      json['capacity'] = capacity.toJson();
    }
    return json;
  }

  const CreatePondVariables({
    required this.name,
    required this.location,
    required this.capacity,
  });
}

