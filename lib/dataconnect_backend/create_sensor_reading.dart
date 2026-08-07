part of 'generated.dart';

class CreateSensorReadingVariablesBuilder {
  String pondId;
  double ph;
  double temp;
  double turb;
  double dissolvedOxygen;
  double nh3;

  final FirebaseDataConnect _dataConnect;
  CreateSensorReadingVariablesBuilder(this._dataConnect, {required  this.pondId,required  this.ph,required  this.temp,required  this.turb,required  this.dissolvedOxygen,required  this.nh3,});
  Deserializer<CreateSensorReadingData> dataDeserializer = (dynamic json)  => CreateSensorReadingData.fromJson(jsonDecode(json));
  Serializer<CreateSensorReadingVariables> varsSerializer = (CreateSensorReadingVariables vars) => jsonEncode(vars.toJson());
  Future<OperationResult<CreateSensorReadingData, CreateSensorReadingVariables>> execute() {
    return ref().execute();
  }

  MutationRef<CreateSensorReadingData, CreateSensorReadingVariables> ref() {
    CreateSensorReadingVariables vars= CreateSensorReadingVariables(pondId: pondId,ph: ph,temp: temp,turb: turb,dissolvedOxygen: dissolvedOxygen,nh3: nh3,);
    return _dataConnect.mutation("CreateSensorReading", dataDeserializer, varsSerializer, vars);
  }
}

@immutable
class CreateSensorReadingSensorReadingInsert {
  final String id;
  CreateSensorReadingSensorReadingInsert.fromJson(dynamic json):
  
  id = nativeFromJson<String>(json['id']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateSensorReadingSensorReadingInsert otherTyped = other as CreateSensorReadingSensorReadingInsert;
    return id == otherTyped.id;
    
  }
  @override
  int get hashCode => id.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['id'] = nativeToJson<String>(id);
    return json;
  }

  const CreateSensorReadingSensorReadingInsert({
    required this.id,
  });
}

@immutable
class CreateSensorReadingData {
  final CreateSensorReadingSensorReadingInsert sensorReading_insert;
  CreateSensorReadingData.fromJson(dynamic json):
  
  sensorReading_insert = CreateSensorReadingSensorReadingInsert.fromJson(json['sensorReading_insert']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateSensorReadingData otherTyped = other as CreateSensorReadingData;
    return sensorReading_insert == otherTyped.sensorReading_insert;
    
  }
  @override
  int get hashCode => sensorReading_insert.hashCode;
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['sensorReading_insert'] = sensorReading_insert.toJson();
    return json;
  }

  const CreateSensorReadingData({
    required this.sensorReading_insert,
  });
}

@immutable
class CreateSensorReadingVariables {
  final String pondId;
  final double ph;
  final double temp;
  final double turb;
  final double dissolvedOxygen;
  final double nh3;
  @Deprecated('fromJson is deprecated for Variable classes as they are no longer required for deserialization.')
  CreateSensorReadingVariables.fromJson(Map<String, dynamic> json):
  
  pondId = nativeFromJson<String>(json['pondId']),
  ph = nativeFromJson<double>(json['ph']),
  temp = nativeFromJson<double>(json['temp']),
  turb = nativeFromJson<double>(json['turb']),
  dissolvedOxygen = nativeFromJson<double>(json['dissolvedOxygen']),
  nh3 = nativeFromJson<double>(json['nh3']);
  @override
  bool operator ==(Object other) {
    if(identical(this, other)) {
      return true;
    }
    if(other.runtimeType != runtimeType) {
      return false;
    }

    final CreateSensorReadingVariables otherTyped = other as CreateSensorReadingVariables;
    return pondId == otherTyped.pondId && 
    ph == otherTyped.ph && 
    temp == otherTyped.temp && 
    turb == otherTyped.turb && 
    dissolvedOxygen {
      == otherTyped.
    } dissolvedOxygen {
      && 
    nh3 == otherTyped.nh3;
    } }
  @override
  int get hashCode => Object.hashAll([pondId.hashCode, ph.hashCode, temp.hashCode, turb.hashCode, dissolvedOxygen.hashCode, nh3.hashCode]);
  

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['pondId'] = nativeToJson<String>(pondId);
    json['ph'] = nativeToJson<double>(ph);
    json['temp'] = nativeToJson<double>(temp);
    json['turb'] = nativeToJson<double>(turb);
    json['dissolvedOxygen'] = nativeToJson<double>(dissolvedOxygen);
    json['nh3'] = nativeToJson<double>(nh3);
    return json;
  }

  const CreateSensorReadingVariables({
    required this.pondId,
    required this.ph,
    required this.temp,
    required this.turb,
    required this.dissolvedOxygen,
    required this.nh3,
  });
}

