# dataconnect_generated SDK

## Installation
```sh
flutter pub get firebase_data_connect
flutterfire configure
```
For more information, see [Flutter for Firebase installation documentation](https://firebase.google.com/docs/data-connect/flutter-sdk#use-core).

## Data Connect instance
Each connector creates a static class, with an instance of the `DataConnect` class that can be used to connect to your Data Connect backend and call operations.

### Connecting to the emulator

```dart
String host = 'localhost'; // or your host name
int port = 9399; // or your port number
ExampleConnector.instance.dataConnect.useDataConnectEmulator(host, port);
```

You can also call queries and mutations by using the connector class.
## Queries

### GetCurrentUser
#### Required Arguments
```dart
// No required arguments
ExampleConnector.instance.getCurrentUser().execute();
```



#### Return Type
`execute()` returns a `QueryResult<GetCurrentUserData, void>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await ExampleConnector.instance.getCurrentUser();
GetCurrentUserData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
final ref = ExampleConnector.instance.getCurrentUser().ref();
ref.execute();

ref.subscribe(...);
```


### ListUsers
#### Required Arguments
```dart
// No required arguments
ExampleConnector.instance.listUsers().execute();
```



#### Return Type
`execute()` returns a `QueryResult<ListUsersData, void>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await ExampleConnector.instance.listUsers();
ListUsersData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
final ref = ExampleConnector.instance.listUsers().ref();
ref.execute();

ref.subscribe(...);
```


### GetPond
#### Required Arguments
```dart
String id = ...;
ExampleConnector.instance.getPond(
  id: id,
).execute();
```



#### Return Type
`execute()` returns a `QueryResult<GetPondData, GetPondVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await ExampleConnector.instance.getPond(
  id: id,
);
GetPondData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String id = ...;

final ref = ExampleConnector.instance.getPond(
  id: id,
).ref();
ref.execute();

ref.subscribe(...);
```


### ListMyPonds
#### Required Arguments
```dart
// No required arguments
ExampleConnector.instance.listMyPonds().execute();
```



#### Return Type
`execute()` returns a `QueryResult<ListMyPondsData, void>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await ExampleConnector.instance.listMyPonds();
ListMyPondsData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
final ref = ExampleConnector.instance.listMyPonds().ref();
ref.execute();

ref.subscribe(...);
```


### GetSensorReading
#### Required Arguments
```dart
String id = ...;
ExampleConnector.instance.getSensorReading(
  id: id,
).execute();
```



#### Return Type
`execute()` returns a `QueryResult<GetSensorReadingData, GetSensorReadingVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await ExampleConnector.instance.getSensorReading(
  id: id,
);
GetSensorReadingData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String id = ...;

final ref = ExampleConnector.instance.getSensorReading(
  id: id,
).ref();
ref.execute();

ref.subscribe(...);
```


### ListPondReadings
#### Required Arguments
```dart
String pondId = ...;
ExampleConnector.instance.listPondReadings(
  pondId: pondId,
).execute();
```



#### Return Type
`execute()` returns a `QueryResult<ListPondReadingsData, ListPondReadingsVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await ExampleConnector.instance.listPondReadings(
  pondId: pondId,
);
ListPondReadingsData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String pondId = ...;

final ref = ExampleConnector.instance.listPondReadings(
  pondId: pondId,
).ref();
ref.execute();

ref.subscribe(...);
```


### GetRecommendation
#### Required Arguments
```dart
String id = ...;
ExampleConnector.instance.getRecommendation(
  id: id,
).execute();
```



#### Return Type
`execute()` returns a `QueryResult<GetRecommendationData, GetRecommendationVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await ExampleConnector.instance.getRecommendation(
  id: id,
);
GetRecommendationData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String id = ...;

final ref = ExampleConnector.instance.getRecommendation(
  id: id,
).ref();
ref.execute();

ref.subscribe(...);
```


### ListRecommendations
#### Required Arguments
```dart
// No required arguments
ExampleConnector.instance.listRecommendations().execute();
```



#### Return Type
`execute()` returns a `QueryResult<ListRecommendationsData, void>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await ExampleConnector.instance.listRecommendations();
ListRecommendationsData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
final ref = ExampleConnector.instance.listRecommendations().ref();
ref.execute();

ref.subscribe(...);
```


### GetListing
#### Required Arguments
```dart
String id = ...;
ExampleConnector.instance.getListing(
  id: id,
).execute();
```



#### Return Type
`execute()` returns a `QueryResult<GetListingData, GetListingVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await ExampleConnector.instance.getListing(
  id: id,
);
GetListingData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String id = ...;

final ref = ExampleConnector.instance.getListing(
  id: id,
).ref();
ref.execute();

ref.subscribe(...);
```


### ListAvailableListings
#### Required Arguments
```dart
// No required arguments
ExampleConnector.instance.listAvailableListings().execute();
```



#### Return Type
`execute()` returns a `QueryResult<ListAvailableListingsData, void>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await ExampleConnector.instance.listAvailableListings();
ListAvailableListingsData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
final ref = ExampleConnector.instance.listAvailableListings().ref();
ref.execute();

ref.subscribe(...);
```


### GetOrder
#### Required Arguments
```dart
String id = ...;
ExampleConnector.instance.getOrder(
  id: id,
).execute();
```



#### Return Type
`execute()` returns a `QueryResult<GetOrderData, GetOrderVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await ExampleConnector.instance.getOrder(
  id: id,
);
GetOrderData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String id = ...;

final ref = ExampleConnector.instance.getOrder(
  id: id,
).ref();
ref.execute();

ref.subscribe(...);
```


### ListMyOrders
#### Required Arguments
```dart
// No required arguments
ExampleConnector.instance.listMyOrders().execute();
```



#### Return Type
`execute()` returns a `QueryResult<ListMyOrdersData, void>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await ExampleConnector.instance.listMyOrders();
ListMyOrdersData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
final ref = ExampleConnector.instance.listMyOrders().ref();
ref.execute();

ref.subscribe(...);
```


### GetNotification
#### Required Arguments
```dart
String id = ...;
ExampleConnector.instance.getNotification(
  id: id,
).execute();
```



#### Return Type
`execute()` returns a `QueryResult<GetNotificationData, GetNotificationVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await ExampleConnector.instance.getNotification(
  id: id,
);
GetNotificationData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String id = ...;

final ref = ExampleConnector.instance.getNotification(
  id: id,
).ref();
ref.execute();

ref.subscribe(...);
```


### ListMyNotifications
#### Required Arguments
```dart
// No required arguments
ExampleConnector.instance.listMyNotifications().execute();
```



#### Return Type
`execute()` returns a `QueryResult<ListMyNotificationsData, void>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

/// Result of a query request. Created to hold extra variables in the future.
class QueryResult<Data, Variables> extends OperationResult<Data, Variables> {
  QueryResult(super.dataConnect, super.data, super.ref);
}

final result = await ExampleConnector.instance.listMyNotifications();
ListMyNotificationsData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
final ref = ExampleConnector.instance.listMyNotifications().ref();
ref.execute();

ref.subscribe(...);
```

## Mutations

### CreateUser
#### Required Arguments
```dart
// No required arguments
ExampleConnector.instance.createUser().execute();
```



#### Return Type
`execute()` returns a `OperationResult<CreateUserData, void>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await ExampleConnector.instance.createUser();
CreateUserData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
final ref = ExampleConnector.instance.createUser().ref();
ref.execute();
```


### UpdateUser
#### Required Arguments
```dart
String displayName = ...;
ExampleConnector.instance.updateUser(
  displayName: displayName,
).execute();
```



#### Return Type
`execute()` returns a `OperationResult<UpdateUserData, UpdateUserVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await ExampleConnector.instance.updateUser(
  displayName: displayName,
);
UpdateUserData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String displayName = ...;

final ref = ExampleConnector.instance.updateUser(
  displayName: displayName,
).ref();
ref.execute();
```


### DeleteUser
#### Required Arguments
```dart
// No required arguments
ExampleConnector.instance.deleteUser().execute();
```



#### Return Type
`execute()` returns a `OperationResult<DeleteUserData, void>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await ExampleConnector.instance.deleteUser();
DeleteUserData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
final ref = ExampleConnector.instance.deleteUser().ref();
ref.execute();
```


### CreatePond
#### Required Arguments
```dart
String name = ...;
String location = ...;
ExampleConnector.instance.createPond(
  name: name,
  location: location,
).execute();
```

#### Optional Arguments
We return a builder for each query. For CreatePond, we created `CreatePondBuilder`. For queries and mutations with optional parameters, we return a builder class.
The builder pattern allows Data Connect to distinguish between fields that haven't been set and fields that have been set to null. A field can be set by calling its respective setter method like below:
```dart
class CreatePondVariablesBuilder {
  ...
   CreatePondVariablesBuilder capacity(double? t) {
   _capacity.value = t;
   return this;
  }

  ...
}
ExampleConnector.instance.createPond(
  name: name,
  location: location,
)
.capacity(capacity)
.execute();
```

#### Return Type
`execute()` returns a `OperationResult<CreatePondData, CreatePondVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await ExampleConnector.instance.createPond(
  name: name,
  location: location,
);
CreatePondData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String name = ...;
String location = ...;

final ref = ExampleConnector.instance.createPond(
  name: name,
  location: location,
).ref();
ref.execute();
```


### UpdatePond
#### Required Arguments
```dart
String id = ...;
ExampleConnector.instance.updatePond(
  id: id,
).execute();
```

#### Optional Arguments
We return a builder for each query. For UpdatePond, we created `UpdatePondBuilder`. For queries and mutations with optional parameters, we return a builder class.
The builder pattern allows Data Connect to distinguish between fields that haven't been set and fields that have been set to null. A field can be set by calling its respective setter method like below:
```dart
class UpdatePondVariablesBuilder {
  ...
   UpdatePondVariablesBuilder capacity(double? t) {
   _capacity.value = t;
   return this;
  }

  ...
}
ExampleConnector.instance.updatePond(
  id: id,
)
.capacity(capacity)
.execute();
```

#### Return Type
`execute()` returns a `OperationResult<UpdatePondData, UpdatePondVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await ExampleConnector.instance.updatePond(
  id: id,
);
UpdatePondData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String id = ...;

final ref = ExampleConnector.instance.updatePond(
  id: id,
).ref();
ref.execute();
```


### DeletePond
#### Required Arguments
```dart
String id = ...;
ExampleConnector.instance.deletePond(
  id: id,
).execute();
```



#### Return Type
`execute()` returns a `OperationResult<DeletePondData, DeletePondVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await ExampleConnector.instance.deletePond(
  id: id,
);
DeletePondData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String id = ...;

final ref = ExampleConnector.instance.deletePond(
  id: id,
).ref();
ref.execute();
```


### CreateSensorReading
#### Required Arguments
```dart
String pondId = ...;
double ph = ...;
double temp = ...;
double turb = ...;
double do = ...;
double nh3 = ...;
ExampleConnector.instance.createSensorReading(
  pondId: pondId,
  ph: ph,
  temp: temp,
  turb: turb,
  do: do,
  nh3: nh3,
).execute();
```



#### Return Type
`execute()` returns a `OperationResult<CreateSensorReadingData, CreateSensorReadingVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await ExampleConnector.instance.createSensorReading(
  pondId: pondId,
  ph: ph,
  temp: temp,
  turb: turb,
  do: do,
  nh3: nh3,
);
CreateSensorReadingData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String pondId = ...;
double ph = ...;
double temp = ...;
double turb = ...;
double do = ...;
double nh3 = ...;

final ref = ExampleConnector.instance.createSensorReading(
  pondId: pondId,
  ph: ph,
  temp: temp,
  turb: turb,
  do: do,
  nh3: nh3,
).ref();
ref.execute();
```


### UpdateSensorReading
#### Required Arguments
```dart
String id = ...;
double ph = ...;
ExampleConnector.instance.updateSensorReading(
  id: id,
  ph: ph,
).execute();
```



#### Return Type
`execute()` returns a `OperationResult<UpdateSensorReadingData, UpdateSensorReadingVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await ExampleConnector.instance.updateSensorReading(
  id: id,
  ph: ph,
);
UpdateSensorReadingData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String id = ...;
double ph = ...;

final ref = ExampleConnector.instance.updateSensorReading(
  id: id,
  ph: ph,
).ref();
ref.execute();
```


### DeleteSensorReading
#### Required Arguments
```dart
String id = ...;
ExampleConnector.instance.deleteSensorReading(
  id: id,
).execute();
```



#### Return Type
`execute()` returns a `OperationResult<DeleteSensorReadingData, DeleteSensorReadingVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await ExampleConnector.instance.deleteSensorReading(
  id: id,
);
DeleteSensorReadingData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String id = ...;

final ref = ExampleConnector.instance.deleteSensorReading(
  id: id,
).ref();
ref.execute();
```


### CreateRecommendation
#### Required Arguments
```dart
String pondId = ...;
String message = ...;
String priority = ...;
ExampleConnector.instance.createRecommendation(
  pondId: pondId,
  message: message,
  priority: priority,
).execute();
```



#### Return Type
`execute()` returns a `OperationResult<CreateRecommendationData, CreateRecommendationVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await ExampleConnector.instance.createRecommendation(
  pondId: pondId,
  message: message,
  priority: priority,
);
CreateRecommendationData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String pondId = ...;
String message = ...;
String priority = ...;

final ref = ExampleConnector.instance.createRecommendation(
  pondId: pondId,
  message: message,
  priority: priority,
).ref();
ref.execute();
```


### UpdateRecommendation
#### Required Arguments
```dart
String id = ...;
String priority = ...;
ExampleConnector.instance.updateRecommendation(
  id: id,
  priority: priority,
).execute();
```



#### Return Type
`execute()` returns a `OperationResult<UpdateRecommendationData, UpdateRecommendationVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await ExampleConnector.instance.updateRecommendation(
  id: id,
  priority: priority,
);
UpdateRecommendationData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String id = ...;
String priority = ...;

final ref = ExampleConnector.instance.updateRecommendation(
  id: id,
  priority: priority,
).ref();
ref.execute();
```


### DeleteRecommendation
#### Required Arguments
```dart
String id = ...;
ExampleConnector.instance.deleteRecommendation(
  id: id,
).execute();
```



#### Return Type
`execute()` returns a `OperationResult<DeleteRecommendationData, DeleteRecommendationVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await ExampleConnector.instance.deleteRecommendation(
  id: id,
);
DeleteRecommendationData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String id = ...;

final ref = ExampleConnector.instance.deleteRecommendation(
  id: id,
).ref();
ref.execute();
```


### CreateListing
#### Required Arguments
```dart
String species = ...;
int quantity = ...;
double price = ...;
ExampleConnector.instance.createListing(
  species: species,
  quantity: quantity,
  price: price,
).execute();
```



#### Return Type
`execute()` returns a `OperationResult<CreateListingData, CreateListingVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await ExampleConnector.instance.createListing(
  species: species,
  quantity: quantity,
  price: price,
);
CreateListingData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String species = ...;
int quantity = ...;
double price = ...;

final ref = ExampleConnector.instance.createListing(
  species: species,
  quantity: quantity,
  price: price,
).ref();
ref.execute();
```


### UpdateListing
#### Required Arguments
```dart
String id = ...;
String status = ...;
ExampleConnector.instance.updateListing(
  id: id,
  status: status,
).execute();
```



#### Return Type
`execute()` returns a `OperationResult<UpdateListingData, UpdateListingVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await ExampleConnector.instance.updateListing(
  id: id,
  status: status,
);
UpdateListingData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String id = ...;
String status = ...;

final ref = ExampleConnector.instance.updateListing(
  id: id,
  status: status,
).ref();
ref.execute();
```


### DeleteListing
#### Required Arguments
```dart
String id = ...;
ExampleConnector.instance.deleteListing(
  id: id,
).execute();
```



#### Return Type
`execute()` returns a `OperationResult<DeleteListingData, DeleteListingVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await ExampleConnector.instance.deleteListing(
  id: id,
);
DeleteListingData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String id = ...;

final ref = ExampleConnector.instance.deleteListing(
  id: id,
).ref();
ref.execute();
```


### CreateOrder
#### Required Arguments
```dart
String listingId = ...;
int quantity = ...;
double total = ...;
ExampleConnector.instance.createOrder(
  listingId: listingId,
  quantity: quantity,
  total: total,
).execute();
```



#### Return Type
`execute()` returns a `OperationResult<CreateOrderData, CreateOrderVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await ExampleConnector.instance.createOrder(
  listingId: listingId,
  quantity: quantity,
  total: total,
);
CreateOrderData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String listingId = ...;
int quantity = ...;
double total = ...;

final ref = ExampleConnector.instance.createOrder(
  listingId: listingId,
  quantity: quantity,
  total: total,
).ref();
ref.execute();
```


### UpdateOrder
#### Required Arguments
```dart
String id = ...;
String status = ...;
ExampleConnector.instance.updateOrder(
  id: id,
  status: status,
).execute();
```



#### Return Type
`execute()` returns a `OperationResult<UpdateOrderData, UpdateOrderVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await ExampleConnector.instance.updateOrder(
  id: id,
  status: status,
);
UpdateOrderData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String id = ...;
String status = ...;

final ref = ExampleConnector.instance.updateOrder(
  id: id,
  status: status,
).ref();
ref.execute();
```


### DeleteOrder
#### Required Arguments
```dart
String id = ...;
ExampleConnector.instance.deleteOrder(
  id: id,
).execute();
```



#### Return Type
`execute()` returns a `OperationResult<DeleteOrderData, DeleteOrderVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await ExampleConnector.instance.deleteOrder(
  id: id,
);
DeleteOrderData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String id = ...;

final ref = ExampleConnector.instance.deleteOrder(
  id: id,
).ref();
ref.execute();
```


### CreateNotification
#### Required Arguments
```dart
String userId = ...;
String message = ...;
ExampleConnector.instance.createNotification(
  userId: userId,
  message: message,
).execute();
```



#### Return Type
`execute()` returns a `OperationResult<CreateNotificationData, CreateNotificationVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await ExampleConnector.instance.createNotification(
  userId: userId,
  message: message,
);
CreateNotificationData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String userId = ...;
String message = ...;

final ref = ExampleConnector.instance.createNotification(
  userId: userId,
  message: message,
).ref();
ref.execute();
```


### MarkNotificationRead
#### Required Arguments
```dart
String id = ...;
ExampleConnector.instance.markNotificationRead(
  id: id,
).execute();
```



#### Return Type
`execute()` returns a `OperationResult<MarkNotificationReadData, MarkNotificationReadVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await ExampleConnector.instance.markNotificationRead(
  id: id,
);
MarkNotificationReadData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String id = ...;

final ref = ExampleConnector.instance.markNotificationRead(
  id: id,
).ref();
ref.execute();
```


### DeleteNotification
#### Required Arguments
```dart
String id = ...;
ExampleConnector.instance.deleteNotification(
  id: id,
).execute();
```



#### Return Type
`execute()` returns a `OperationResult<DeleteNotificationData, DeleteNotificationVariables>`
```dart
/// Result of an Operation Request (query/mutation).
class OperationResult<Data, Variables> {
  OperationResult(this.dataConnect, this.data, this.ref);
  Data data;
  OperationRef<Data, Variables> ref;
  FirebaseDataConnect dataConnect;
}

final result = await ExampleConnector.instance.deleteNotification(
  id: id,
);
DeleteNotificationData data = result.data;
final ref = result.ref;
```

#### Getting the Ref
Each builder returns an `execute` function, which is a helper function that creates a `Ref` object, and executes the underlying operation.
An example of how to use the `Ref` object is shown below:
```dart
String id = ...;

final ref = ExampleConnector.instance.deleteNotification(
  id: id,
).ref();
ref.execute();
```

