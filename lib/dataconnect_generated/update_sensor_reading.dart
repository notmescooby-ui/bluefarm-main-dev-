part of 'generated.dart';

class UpdateSensorReadingVariablesBuilder {
  String id;
  double ph;

  final FirebaseDataConnect _dataConnect;
  UpdateSensorReadingVariablesBuilder(this._dataConnect, {required  this.id,required  this.ph,});
  Deserializer<UpdateSensorReadingData> dataDeserializer = (dynamic json)  => UpdateSensorReadingData.fromJson(jsonDecode(json));
  Serializer<UpdateSensorReadingVariables> varsSerializer = (UpdateSensorReadingVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<UpdateSensorReadingData, UpdateSensorReadingVariables>> execute() {
    return ref().execute();
  }

  MutationRef<UpdateSensorReadingData, UpdateSensorReadingVariables> ref() {
    UpdateSensorReadingVariables vars= UpdateSensorReadingVariables(id: id,ph: ph,);
    return _dataConnect.mutation("UpdateSensorReading", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class UpdateSensorReadingSensorReadingUpdate {
  final String id;
  UpdateSensorReadingSensorReadingUpdate.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpdateSensorReadingSensorReadingUpdate otherTyped = other as UpdateSensorReadingSensorReadingUpdate;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  const UpdateSensorReadingSensorReadingUpdate({
    required this.id,
  });
}

@immutable
class UpdateSensorReadingData {
  final UpdateSensorReadingSensorReadingUpdate? sensorReading_update;
  UpdateSensorReadingData.fromJson(dynamic json):
  
  sensorReading_update = json['sensorReading_update'] == null ? null : UpdateSensorReadingSensorReadingUpdate.fromJson(json['sensorReading_update']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpdateSensorReadingData otherTyped = other as UpdateSensorReadingData;
    return sensorReading_update == otherTyped.sensorReading_update;
    
  }
  @override
  int get hashCode => sensorReading_update.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (sensorReading_update != null) {
      json['sensorReading_update'] = sensorReading_update!.toJson();
    }
    return json;
  }

  const UpdateSensorReadingData({
    this.sensorReading_update,
  });
}

@immutable
class UpdateSensorReadingVariables {
  final String id;
  final double ph;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  UpdateSensorReadingVariables.fromJson(Map<String, dynamic> json):
  
  id = nativeFromJson<String>(json['id']),
  ph = nativeFromJson<double>(json['ph']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final UpdateSensorReadingVariables otherTyped = other as UpdateSensorReadingVariables;
    return id == otherTyped.id && 
    ph == otherTyped.ph;
    
  }
  @override
  int get hashCode => Object.hashAll([id.hashCode, ph.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    json['ph'] = nativeToJson<double>(ph);
    return json;
  }

  const UpdateSensorReadingVariables({
    required this.id,
    required this.ph,
  });
}

