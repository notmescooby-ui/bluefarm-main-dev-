part of 'generated.dart';

class UpdatePondVariablesBuilder {
  String id;
  final Optional<double> _capacity = Optional.optional(nativeFromJson, nativeToJson);

  final FirebaseDataConnect _dataConnect;  UpdatePondVariablesBuilder capacity(double? t) {
   _capacity.value = t;
   return this;
  }

  UpdatePondVariablesBuilder(this._dataConnect, {required  this.id,});
  Deserializer<UpdatePondData> dataDeserializer = (dynamic json)  => UpdatePondData.fromJson(jsonDecode(json));
  Serializer<UpdatePondVariables> varsSerializer = (UpdatePondVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<UpdatePondData, UpdatePondVariables>> execute() {
    return ref().execute();
  }

  MutationRef<UpdatePondData, UpdatePondVariables> ref() {
    UpdatePondVariables vars= UpdatePondVariables(id: id,capacity: _capacity,);
    return _dataConnect.mutation("UpdatePond", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class UpdatePondPondUpdate {
  final String id;
  UpdatePondPondUpdate.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpdatePondPondUpdate otherTyped = other as UpdatePondPondUpdate;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  const UpdatePondPondUpdate({
    required this.id,
  });
}

@immutable
class UpdatePondData {
  final UpdatePondPondUpdate? pond_update;
  UpdatePondData.fromJson(dynamic json):
  
  pond_update = json['pond_update'] == null ? null : UpdatePondPondUpdate.fromJson(json['pond_update']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpdatePondData otherTyped = other as UpdatePondData;
    return pond_update == otherTyped.pond_update;
    
  }
  @override
  int get hashCode => pond_update.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (pond_update != null) {
      json['pond_update'] = pond_update!.toJson();
    }
    return json;
  }

  const UpdatePondData({
    this.pond_update,
  });
}

@immutable
class UpdatePondVariables {
  final String id;
  late final Optional<double>capacity;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  UpdatePondVariables.fromJson(Map<String, dynamic> json):
  
  id = nativeFromJson<String>(json['id']) {
  
  
  
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

    final UpdatePondVariables otherTyped = other as UpdatePondVariables;
    return id == otherTyped.id && 
    capacity == otherTyped.capacity;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, capacity.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    if(capacity.state == OptionalState.set) {
      json['capacity'] = capacity.toJson();
    }
    return json;
  }

  const UpdatePondVariables({
    required this.id,
    required this.capacity,
  });
}

