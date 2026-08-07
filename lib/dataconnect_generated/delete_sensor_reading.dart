part of 'generated.dart';

class DeleteSensorReadingVariablesBuilder {
  String id;

  final FirebaseDataConnect _dataConnect;
  DeleteSensorReadingVariablesBuilder(this._dataConnect, {required  this.id,});
  Deserializer<DeleteSensorReadingData> dataDeserializer = (dynamic json)  => DeleteSensorReadingData.fromJson(jsonDecode(json));
  Serializer<DeleteSensorReadingVariables> varsSerializer = (DeleteSensorReadingVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<DeleteSensorReadingData, DeleteSensorReadingVariables>> execute() {
    return ref().execute();
  }

  MutationRef<DeleteSensorReadingData, DeleteSensorReadingVariables> ref() {
    DeleteSensorReadingVariables vars= DeleteSensorReadingVariables(id: id,);
    return _dataConnect.mutation("DeleteSensorReading", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class DeleteSensorReadingSensorReadingDelete {
  final String id;
  DeleteSensorReadingSensorReadingDelete.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final DeleteSensorReadingSensorReadingDelete otherTyped = other as DeleteSensorReadingSensorReadingDelete;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  const DeleteSensorReadingSensorReadingDelete({
    required this.id,
  });
}

@immutable
class DeleteSensorReadingData {
  final DeleteSensorReadingSensorReadingDelete? sensorReading_delete;
  DeleteSensorReadingData.fromJson(dynamic json):
  
  sensorReading_delete = json['sensorReading_delete'] == null ? null : DeleteSensorReadingSensorReadingDelete.fromJson(json['sensorReading_delete']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final DeleteSensorReadingData otherTyped = other as DeleteSensorReadingData;
    return sensorReading_delete == otherTyped.sensorReading_delete;
    
  }
  @override
  int get hashCode => sensorReading_delete.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (sensorReading_delete != null) {
      json['sensorReading_delete'] = sensorReading_delete!.toJson();
    }
    return json;
  }

  const DeleteSensorReadingData({
    this.sensorReading_delete,
  });
}

@immutable
class DeleteSensorReadingVariables {
  final String id;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  DeleteSensorReadingVariables.fromJson(Map<String, dynamic> json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final DeleteSensorReadingVariables otherTyped = other as DeleteSensorReadingVariables;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  const DeleteSensorReadingVariables({
    required this.id,
  });
}

