# Generated TypeScript README
This README will guide you through the process of using the generated JavaScript SDK package for the connector `example`. It will also provide examples on how to use your generated SDK to call your Data Connect queries and mutations.

***NOTE:** This README is generated alongside the generated SDK. If you make changes to this file, they will be overwritten when the SDK is regenerated.*

# Table of Contents
- [**Overview**](#generated-javascript-readme)
- [**Accessing the connector**](#accessing-the-connector)
  - [*Connecting to the local Emulator*](#connecting-to-the-local-emulator)
- [**Queries**](#queries)
  - [*GetCurrentUser*](#getcurrentuser)
  - [*ListUsers*](#listusers)
  - [*GetPond*](#getpond)
  - [*ListMyPonds*](#listmyponds)
  - [*GetSensorReading*](#getsensorreading)
  - [*ListPondReadings*](#listpondreadings)
  - [*GetRecommendation*](#getrecommendation)
  - [*ListRecommendations*](#listrecommendations)
  - [*GetListing*](#getlisting)
  - [*ListAvailableListings*](#listavailablelistings)
  - [*GetOrder*](#getorder)
  - [*ListMyOrders*](#listmyorders)
  - [*GetNotification*](#getnotification)
  - [*ListMyNotifications*](#listmynotifications)
- [**Mutations**](#mutations)
  - [*CreateUser*](#createuser)
  - [*UpdateUser*](#updateuser)
  - [*DeleteUser*](#deleteuser)
  - [*CreatePond*](#createpond)
  - [*UpdatePond*](#updatepond)
  - [*DeletePond*](#deletepond)
  - [*CreateSensorReading*](#createsensorreading)
  - [*UpdateSensorReading*](#updatesensorreading)
  - [*DeleteSensorReading*](#deletesensorreading)
  - [*CreateRecommendation*](#createrecommendation)
  - [*UpdateRecommendation*](#updaterecommendation)
  - [*DeleteRecommendation*](#deleterecommendation)
  - [*CreateListing*](#createlisting)
  - [*UpdateListing*](#updatelisting)
  - [*DeleteListing*](#deletelisting)
  - [*CreateOrder*](#createorder)
  - [*UpdateOrder*](#updateorder)
  - [*DeleteOrder*](#deleteorder)
  - [*CreateNotification*](#createnotification)
  - [*MarkNotificationRead*](#marknotificationread)
  - [*DeleteNotification*](#deletenotification)

# Accessing the connector
A connector is a collection of Queries and Mutations. One SDK is generated for each connector - this SDK is generated for the connector `example`. You can find more information about connectors in the [Data Connect documentation](https://firebase.google.com/docs/data-connect#how-does).

You can use this generated SDK by importing from the package `@dataconnect/generated` as shown below. Both CommonJS and ESM imports are supported.

You can also follow the instructions from the [Data Connect documentation](https://firebase.google.com/docs/data-connect/web-sdk#set-client).

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig } from '@dataconnect/generated';

const dataConnect = getDataConnect(connectorConfig);
```

## Connecting to the local Emulator
By default, the connector will connect to the production service.

To connect to the emulator, you can use the following code.
You can also follow the emulator instructions from the [Data Connect documentation](https://firebase.google.com/docs/data-connect/web-sdk#instrument-clients).

```typescript
import { connectDataConnectEmulator, getDataConnect } from 'firebase/data-connect';
import { connectorConfig } from '@dataconnect/generated';

const dataConnect = getDataConnect(connectorConfig);
connectDataConnectEmulator(dataConnect, 'localhost', 9399);
```

After it's initialized, you can call your Data Connect [queries](#queries) and [mutations](#mutations) from your generated SDK.

# Queries

There are two ways to execute a Data Connect Query using the generated Web SDK:
- Using a Query Reference function, which returns a `QueryRef`
  - The `QueryRef` can be used as an argument to `executeQuery()`, which will execute the Query and return a `QueryPromise`
- Using an action shortcut function, which returns a `QueryPromise`
  - Calling the action shortcut function will execute the Query and return a `QueryPromise`

The following is true for both the action shortcut function and the `QueryRef` function:
- The `QueryPromise` returned will resolve to the result of the Query once it has finished executing
- If the Query accepts arguments, both the action shortcut function and the `QueryRef` function accept a single argument: an object that contains all the required variables (and the optional variables) for the Query
- Both functions can be called with or without passing in a `DataConnect` instance as an argument. If no `DataConnect` argument is passed in, then the generated SDK will call `getDataConnect(connectorConfig)` behind the scenes for you.

Below are examples of how to use the `example` connector's generated functions to execute each query. You can also follow the examples from the [Data Connect documentation](https://firebase.google.com/docs/data-connect/web-sdk#using-queries).

## GetCurrentUser
You can execute the `GetCurrentUser` query using the following action shortcut function, or by calling `executeQuery()` after calling the following `QueryRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
getCurrentUser(options?: ExecuteQueryOptions): QueryPromise<GetCurrentUserData, undefined>;

interface GetCurrentUserRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (): QueryRef<GetCurrentUserData, undefined>;
}
export const getCurrentUserRef: GetCurrentUserRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `QueryRef` function.
```typescript
getCurrentUser(dc: DataConnect, options?: ExecuteQueryOptions): QueryPromise<GetCurrentUserData, undefined>;

interface GetCurrentUserRef {
  ...
  (dc: DataConnect): QueryRef<GetCurrentUserData, undefined>;
}
export const getCurrentUserRef: GetCurrentUserRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the getCurrentUserRef:
```typescript
const name = getCurrentUserRef.operationName;
console.log(name);
```

### Variables
The `GetCurrentUser` query has no variables.
### Return Type
Recall that executing the `GetCurrentUser` query returns a `QueryPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `GetCurrentUserData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface GetCurrentUserData {
  user?: {
    email: string;
    displayName?: string | null;
    role: string;
  };
}
```
### Using `GetCurrentUser`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, getCurrentUser } from '@dataconnect/generated';


// Call the `getCurrentUser()` function to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await getCurrentUser();

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await getCurrentUser(dataConnect);

console.log(data.user);

// Or, you can use the `Promise` API.
getCurrentUser().then((response) => {
  const data = response.data;
  console.log(data.user);
});
```

### Using `GetCurrentUser`'s `QueryRef` function

```typescript
import { getDataConnect, executeQuery } from 'firebase/data-connect';
import { connectorConfig, getCurrentUserRef } from '@dataconnect/generated';


// Call the `getCurrentUserRef()` function to get a reference to the query.
const ref = getCurrentUserRef();

// You can also pass in a `DataConnect` instance to the `QueryRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = getCurrentUserRef(dataConnect);

// Call `executeQuery()` on the reference to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeQuery(ref);

console.log(data.user);

// Or, you can use the `Promise` API.
executeQuery(ref).then((response) => {
  const data = response.data;
  console.log(data.user);
});
```

## ListUsers
You can execute the `ListUsers` query using the following action shortcut function, or by calling `executeQuery()` after calling the following `QueryRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
listUsers(options?: ExecuteQueryOptions): QueryPromise<ListUsersData, undefined>;

interface ListUsersRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (): QueryRef<ListUsersData, undefined>;
}
export const listUsersRef: ListUsersRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `QueryRef` function.
```typescript
listUsers(dc: DataConnect, options?: ExecuteQueryOptions): QueryPromise<ListUsersData, undefined>;

interface ListUsersRef {
  ...
  (dc: DataConnect): QueryRef<ListUsersData, undefined>;
}
export const listUsersRef: ListUsersRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the listUsersRef:
```typescript
const name = listUsersRef.operationName;
console.log(name);
```

### Variables
The `ListUsers` query has no variables.
### Return Type
Recall that executing the `ListUsers` query returns a `QueryPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `ListUsersData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface ListUsersData {
  users: ({
    displayName?: string | null;
    role: string;
  })[];
}
```
### Using `ListUsers`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, listUsers } from '@dataconnect/generated';


// Call the `listUsers()` function to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await listUsers();

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await listUsers(dataConnect);

console.log(data.users);

// Or, you can use the `Promise` API.
listUsers().then((response) => {
  const data = response.data;
  console.log(data.users);
});
```

### Using `ListUsers`'s `QueryRef` function

```typescript
import { getDataConnect, executeQuery } from 'firebase/data-connect';
import { connectorConfig, listUsersRef } from '@dataconnect/generated';


// Call the `listUsersRef()` function to get a reference to the query.
const ref = listUsersRef();

// You can also pass in a `DataConnect` instance to the `QueryRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = listUsersRef(dataConnect);

// Call `executeQuery()` on the reference to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeQuery(ref);

console.log(data.users);

// Or, you can use the `Promise` API.
executeQuery(ref).then((response) => {
  const data = response.data;
  console.log(data.users);
});
```

## GetPond
You can execute the `GetPond` query using the following action shortcut function, or by calling `executeQuery()` after calling the following `QueryRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
getPond(vars: GetPondVariables, options?: ExecuteQueryOptions): QueryPromise<GetPondData, GetPondVariables>;

interface GetPondRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetPondVariables): QueryRef<GetPondData, GetPondVariables>;
}
export const getPondRef: GetPondRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `QueryRef` function.
```typescript
getPond(dc: DataConnect, vars: GetPondVariables, options?: ExecuteQueryOptions): QueryPromise<GetPondData, GetPondVariables>;

interface GetPondRef {
  ...
  (dc: DataConnect, vars: GetPondVariables): QueryRef<GetPondData, GetPondVariables>;
}
export const getPondRef: GetPondRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the getPondRef:
```typescript
const name = getPondRef.operationName;
console.log(name);
```

### Variables
The `GetPond` query requires an argument of type `GetPondVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface GetPondVariables {
  id: UUIDString;
}
```
### Return Type
Recall that executing the `GetPond` query returns a `QueryPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `GetPondData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface GetPondData {
  pond?: {
    name: string;
    location: string;
    capacity?: number | null;
  };
}
```
### Using `GetPond`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, getPond, GetPondVariables } from '@dataconnect/generated';

// The `GetPond` query requires an argument of type `GetPondVariables`:
const getPondVars: GetPondVariables = {
  id: ..., 
};

// Call the `getPond()` function to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await getPond(getPondVars);
// Variables can be defined inline as well.
const { data } = await getPond({ id: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await getPond(dataConnect, getPondVars);

console.log(data.pond);

// Or, you can use the `Promise` API.
getPond(getPondVars).then((response) => {
  const data = response.data;
  console.log(data.pond);
});
```

### Using `GetPond`'s `QueryRef` function

```typescript
import { getDataConnect, executeQuery } from 'firebase/data-connect';
import { connectorConfig, getPondRef, GetPondVariables } from '@dataconnect/generated';

// The `GetPond` query requires an argument of type `GetPondVariables`:
const getPondVars: GetPondVariables = {
  id: ..., 
};

// Call the `getPondRef()` function to get a reference to the query.
const ref = getPondRef(getPondVars);
// Variables can be defined inline as well.
const ref = getPondRef({ id: ..., });

// You can also pass in a `DataConnect` instance to the `QueryRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = getPondRef(dataConnect, getPondVars);

// Call `executeQuery()` on the reference to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeQuery(ref);

console.log(data.pond);

// Or, you can use the `Promise` API.
executeQuery(ref).then((response) => {
  const data = response.data;
  console.log(data.pond);
});
```

## ListMyPonds
You can execute the `ListMyPonds` query using the following action shortcut function, or by calling `executeQuery()` after calling the following `QueryRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
listMyPonds(options?: ExecuteQueryOptions): QueryPromise<ListMyPondsData, undefined>;

interface ListMyPondsRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (): QueryRef<ListMyPondsData, undefined>;
}
export const listMyPondsRef: ListMyPondsRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `QueryRef` function.
```typescript
listMyPonds(dc: DataConnect, options?: ExecuteQueryOptions): QueryPromise<ListMyPondsData, undefined>;

interface ListMyPondsRef {
  ...
  (dc: DataConnect): QueryRef<ListMyPondsData, undefined>;
}
export const listMyPondsRef: ListMyPondsRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the listMyPondsRef:
```typescript
const name = listMyPondsRef.operationName;
console.log(name);
```

### Variables
The `ListMyPonds` query has no variables.
### Return Type
Recall that executing the `ListMyPonds` query returns a `QueryPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `ListMyPondsData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface ListMyPondsData {
  ponds: ({
    name: string;
    location: string;
  })[];
}
```
### Using `ListMyPonds`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, listMyPonds } from '@dataconnect/generated';


// Call the `listMyPonds()` function to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await listMyPonds();

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await listMyPonds(dataConnect);

console.log(data.ponds);

// Or, you can use the `Promise` API.
listMyPonds().then((response) => {
  const data = response.data;
  console.log(data.ponds);
});
```

### Using `ListMyPonds`'s `QueryRef` function

```typescript
import { getDataConnect, executeQuery } from 'firebase/data-connect';
import { connectorConfig, listMyPondsRef } from '@dataconnect/generated';


// Call the `listMyPondsRef()` function to get a reference to the query.
const ref = listMyPondsRef();

// You can also pass in a `DataConnect` instance to the `QueryRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = listMyPondsRef(dataConnect);

// Call `executeQuery()` on the reference to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeQuery(ref);

console.log(data.ponds);

// Or, you can use the `Promise` API.
executeQuery(ref).then((response) => {
  const data = response.data;
  console.log(data.ponds);
});
```

## GetSensorReading
You can execute the `GetSensorReading` query using the following action shortcut function, or by calling `executeQuery()` after calling the following `QueryRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
getSensorReading(vars: GetSensorReadingVariables, options?: ExecuteQueryOptions): QueryPromise<GetSensorReadingData, GetSensorReadingVariables>;

interface GetSensorReadingRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetSensorReadingVariables): QueryRef<GetSensorReadingData, GetSensorReadingVariables>;
}
export const getSensorReadingRef: GetSensorReadingRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `QueryRef` function.
```typescript
getSensorReading(dc: DataConnect, vars: GetSensorReadingVariables, options?: ExecuteQueryOptions): QueryPromise<GetSensorReadingData, GetSensorReadingVariables>;

interface GetSensorReadingRef {
  ...
  (dc: DataConnect, vars: GetSensorReadingVariables): QueryRef<GetSensorReadingData, GetSensorReadingVariables>;
}
export const getSensorReadingRef: GetSensorReadingRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the getSensorReadingRef:
```typescript
const name = getSensorReadingRef.operationName;
console.log(name);
```

### Variables
The `GetSensorReading` query requires an argument of type `GetSensorReadingVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface GetSensorReadingVariables {
  id: UUIDString;
}
```
### Return Type
Recall that executing the `GetSensorReading` query returns a `QueryPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `GetSensorReadingData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface GetSensorReadingData {
  sensorReading?: {
    ph: number;
    temperature: number;
  };
}
```
### Using `GetSensorReading`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, getSensorReading, GetSensorReadingVariables } from '@dataconnect/generated';

// The `GetSensorReading` query requires an argument of type `GetSensorReadingVariables`:
const getSensorReadingVars: GetSensorReadingVariables = {
  id: ..., 
};

// Call the `getSensorReading()` function to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await getSensorReading(getSensorReadingVars);
// Variables can be defined inline as well.
const { data } = await getSensorReading({ id: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await getSensorReading(dataConnect, getSensorReadingVars);

console.log(data.sensorReading);

// Or, you can use the `Promise` API.
getSensorReading(getSensorReadingVars).then((response) => {
  const data = response.data;
  console.log(data.sensorReading);
});
```

### Using `GetSensorReading`'s `QueryRef` function

```typescript
import { getDataConnect, executeQuery } from 'firebase/data-connect';
import { connectorConfig, getSensorReadingRef, GetSensorReadingVariables } from '@dataconnect/generated';

// The `GetSensorReading` query requires an argument of type `GetSensorReadingVariables`:
const getSensorReadingVars: GetSensorReadingVariables = {
  id: ..., 
};

// Call the `getSensorReadingRef()` function to get a reference to the query.
const ref = getSensorReadingRef(getSensorReadingVars);
// Variables can be defined inline as well.
const ref = getSensorReadingRef({ id: ..., });

// You can also pass in a `DataConnect` instance to the `QueryRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = getSensorReadingRef(dataConnect, getSensorReadingVars);

// Call `executeQuery()` on the reference to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeQuery(ref);

console.log(data.sensorReading);

// Or, you can use the `Promise` API.
executeQuery(ref).then((response) => {
  const data = response.data;
  console.log(data.sensorReading);
});
```

## ListPondReadings
You can execute the `ListPondReadings` query using the following action shortcut function, or by calling `executeQuery()` after calling the following `QueryRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
listPondReadings(vars: ListPondReadingsVariables, options?: ExecuteQueryOptions): QueryPromise<ListPondReadingsData, ListPondReadingsVariables>;

interface ListPondReadingsRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: ListPondReadingsVariables): QueryRef<ListPondReadingsData, ListPondReadingsVariables>;
}
export const listPondReadingsRef: ListPondReadingsRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `QueryRef` function.
```typescript
listPondReadings(dc: DataConnect, vars: ListPondReadingsVariables, options?: ExecuteQueryOptions): QueryPromise<ListPondReadingsData, ListPondReadingsVariables>;

interface ListPondReadingsRef {
  ...
  (dc: DataConnect, vars: ListPondReadingsVariables): QueryRef<ListPondReadingsData, ListPondReadingsVariables>;
}
export const listPondReadingsRef: ListPondReadingsRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the listPondReadingsRef:
```typescript
const name = listPondReadingsRef.operationName;
console.log(name);
```

### Variables
The `ListPondReadings` query requires an argument of type `ListPondReadingsVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface ListPondReadingsVariables {
  pondId: UUIDString;
}
```
### Return Type
Recall that executing the `ListPondReadings` query returns a `QueryPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `ListPondReadingsData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface ListPondReadingsData {
  sensorReadings: ({
    timestamp: TimestampString;
    ph: number;
    temperature: number;
  })[];
}
```
### Using `ListPondReadings`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, listPondReadings, ListPondReadingsVariables } from '@dataconnect/generated';

// The `ListPondReadings` query requires an argument of type `ListPondReadingsVariables`:
const listPondReadingsVars: ListPondReadingsVariables = {
  pondId: ..., 
};

// Call the `listPondReadings()` function to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await listPondReadings(listPondReadingsVars);
// Variables can be defined inline as well.
const { data } = await listPondReadings({ pondId: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await listPondReadings(dataConnect, listPondReadingsVars);

console.log(data.sensorReadings);

// Or, you can use the `Promise` API.
listPondReadings(listPondReadingsVars).then((response) => {
  const data = response.data;
  console.log(data.sensorReadings);
});
```

### Using `ListPondReadings`'s `QueryRef` function

```typescript
import { getDataConnect, executeQuery } from 'firebase/data-connect';
import { connectorConfig, listPondReadingsRef, ListPondReadingsVariables } from '@dataconnect/generated';

// The `ListPondReadings` query requires an argument of type `ListPondReadingsVariables`:
const listPondReadingsVars: ListPondReadingsVariables = {
  pondId: ..., 
};

// Call the `listPondReadingsRef()` function to get a reference to the query.
const ref = listPondReadingsRef(listPondReadingsVars);
// Variables can be defined inline as well.
const ref = listPondReadingsRef({ pondId: ..., });

// You can also pass in a `DataConnect` instance to the `QueryRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = listPondReadingsRef(dataConnect, listPondReadingsVars);

// Call `executeQuery()` on the reference to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeQuery(ref);

console.log(data.sensorReadings);

// Or, you can use the `Promise` API.
executeQuery(ref).then((response) => {
  const data = response.data;
  console.log(data.sensorReadings);
});
```

## GetRecommendation
You can execute the `GetRecommendation` query using the following action shortcut function, or by calling `executeQuery()` after calling the following `QueryRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
getRecommendation(vars: GetRecommendationVariables, options?: ExecuteQueryOptions): QueryPromise<GetRecommendationData, GetRecommendationVariables>;

interface GetRecommendationRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetRecommendationVariables): QueryRef<GetRecommendationData, GetRecommendationVariables>;
}
export const getRecommendationRef: GetRecommendationRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `QueryRef` function.
```typescript
getRecommendation(dc: DataConnect, vars: GetRecommendationVariables, options?: ExecuteQueryOptions): QueryPromise<GetRecommendationData, GetRecommendationVariables>;

interface GetRecommendationRef {
  ...
  (dc: DataConnect, vars: GetRecommendationVariables): QueryRef<GetRecommendationData, GetRecommendationVariables>;
}
export const getRecommendationRef: GetRecommendationRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the getRecommendationRef:
```typescript
const name = getRecommendationRef.operationName;
console.log(name);
```

### Variables
The `GetRecommendation` query requires an argument of type `GetRecommendationVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface GetRecommendationVariables {
  id: UUIDString;
}
```
### Return Type
Recall that executing the `GetRecommendation` query returns a `QueryPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `GetRecommendationData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface GetRecommendationData {
  smartRecommendation?: {
    message: string;
    priority: string;
  };
}
```
### Using `GetRecommendation`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, getRecommendation, GetRecommendationVariables } from '@dataconnect/generated';

// The `GetRecommendation` query requires an argument of type `GetRecommendationVariables`:
const getRecommendationVars: GetRecommendationVariables = {
  id: ..., 
};

// Call the `getRecommendation()` function to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await getRecommendation(getRecommendationVars);
// Variables can be defined inline as well.
const { data } = await getRecommendation({ id: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await getRecommendation(dataConnect, getRecommendationVars);

console.log(data.smartRecommendation);

// Or, you can use the `Promise` API.
getRecommendation(getRecommendationVars).then((response) => {
  const data = response.data;
  console.log(data.smartRecommendation);
});
```

### Using `GetRecommendation`'s `QueryRef` function

```typescript
import { getDataConnect, executeQuery } from 'firebase/data-connect';
import { connectorConfig, getRecommendationRef, GetRecommendationVariables } from '@dataconnect/generated';

// The `GetRecommendation` query requires an argument of type `GetRecommendationVariables`:
const getRecommendationVars: GetRecommendationVariables = {
  id: ..., 
};

// Call the `getRecommendationRef()` function to get a reference to the query.
const ref = getRecommendationRef(getRecommendationVars);
// Variables can be defined inline as well.
const ref = getRecommendationRef({ id: ..., });

// You can also pass in a `DataConnect` instance to the `QueryRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = getRecommendationRef(dataConnect, getRecommendationVars);

// Call `executeQuery()` on the reference to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeQuery(ref);

console.log(data.smartRecommendation);

// Or, you can use the `Promise` API.
executeQuery(ref).then((response) => {
  const data = response.data;
  console.log(data.smartRecommendation);
});
```

## ListRecommendations
You can execute the `ListRecommendations` query using the following action shortcut function, or by calling `executeQuery()` after calling the following `QueryRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
listRecommendations(options?: ExecuteQueryOptions): QueryPromise<ListRecommendationsData, undefined>;

interface ListRecommendationsRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (): QueryRef<ListRecommendationsData, undefined>;
}
export const listRecommendationsRef: ListRecommendationsRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `QueryRef` function.
```typescript
listRecommendations(dc: DataConnect, options?: ExecuteQueryOptions): QueryPromise<ListRecommendationsData, undefined>;

interface ListRecommendationsRef {
  ...
  (dc: DataConnect): QueryRef<ListRecommendationsData, undefined>;
}
export const listRecommendationsRef: ListRecommendationsRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the listRecommendationsRef:
```typescript
const name = listRecommendationsRef.operationName;
console.log(name);
```

### Variables
The `ListRecommendations` query has no variables.
### Return Type
Recall that executing the `ListRecommendations` query returns a `QueryPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `ListRecommendationsData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface ListRecommendationsData {
  smartRecommendations: ({
    message: string;
    priority: string;
  })[];
}
```
### Using `ListRecommendations`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, listRecommendations } from '@dataconnect/generated';


// Call the `listRecommendations()` function to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await listRecommendations();

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await listRecommendations(dataConnect);

console.log(data.smartRecommendations);

// Or, you can use the `Promise` API.
listRecommendations().then((response) => {
  const data = response.data;
  console.log(data.smartRecommendations);
});
```

### Using `ListRecommendations`'s `QueryRef` function

```typescript
import { getDataConnect, executeQuery } from 'firebase/data-connect';
import { connectorConfig, listRecommendationsRef } from '@dataconnect/generated';


// Call the `listRecommendationsRef()` function to get a reference to the query.
const ref = listRecommendationsRef();

// You can also pass in a `DataConnect` instance to the `QueryRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = listRecommendationsRef(dataConnect);

// Call `executeQuery()` on the reference to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeQuery(ref);

console.log(data.smartRecommendations);

// Or, you can use the `Promise` API.
executeQuery(ref).then((response) => {
  const data = response.data;
  console.log(data.smartRecommendations);
});
```

## GetListing
You can execute the `GetListing` query using the following action shortcut function, or by calling `executeQuery()` after calling the following `QueryRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
getListing(vars: GetListingVariables, options?: ExecuteQueryOptions): QueryPromise<GetListingData, GetListingVariables>;

interface GetListingRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetListingVariables): QueryRef<GetListingData, GetListingVariables>;
}
export const getListingRef: GetListingRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `QueryRef` function.
```typescript
getListing(dc: DataConnect, vars: GetListingVariables, options?: ExecuteQueryOptions): QueryPromise<GetListingData, GetListingVariables>;

interface GetListingRef {
  ...
  (dc: DataConnect, vars: GetListingVariables): QueryRef<GetListingData, GetListingVariables>;
}
export const getListingRef: GetListingRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the getListingRef:
```typescript
const name = getListingRef.operationName;
console.log(name);
```

### Variables
The `GetListing` query requires an argument of type `GetListingVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface GetListingVariables {
  id: UUIDString;
}
```
### Return Type
Recall that executing the `GetListing` query returns a `QueryPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `GetListingData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface GetListingData {
  harvestListing?: {
    species: string;
    pricePerUnit: number;
  };
}
```
### Using `GetListing`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, getListing, GetListingVariables } from '@dataconnect/generated';

// The `GetListing` query requires an argument of type `GetListingVariables`:
const getListingVars: GetListingVariables = {
  id: ..., 
};

// Call the `getListing()` function to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await getListing(getListingVars);
// Variables can be defined inline as well.
const { data } = await getListing({ id: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await getListing(dataConnect, getListingVars);

console.log(data.harvestListing);

// Or, you can use the `Promise` API.
getListing(getListingVars).then((response) => {
  const data = response.data;
  console.log(data.harvestListing);
});
```

### Using `GetListing`'s `QueryRef` function

```typescript
import { getDataConnect, executeQuery } from 'firebase/data-connect';
import { connectorConfig, getListingRef, GetListingVariables } from '@dataconnect/generated';

// The `GetListing` query requires an argument of type `GetListingVariables`:
const getListingVars: GetListingVariables = {
  id: ..., 
};

// Call the `getListingRef()` function to get a reference to the query.
const ref = getListingRef(getListingVars);
// Variables can be defined inline as well.
const ref = getListingRef({ id: ..., });

// You can also pass in a `DataConnect` instance to the `QueryRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = getListingRef(dataConnect, getListingVars);

// Call `executeQuery()` on the reference to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeQuery(ref);

console.log(data.harvestListing);

// Or, you can use the `Promise` API.
executeQuery(ref).then((response) => {
  const data = response.data;
  console.log(data.harvestListing);
});
```

## ListAvailableListings
You can execute the `ListAvailableListings` query using the following action shortcut function, or by calling `executeQuery()` after calling the following `QueryRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
listAvailableListings(options?: ExecuteQueryOptions): QueryPromise<ListAvailableListingsData, undefined>;

interface ListAvailableListingsRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (): QueryRef<ListAvailableListingsData, undefined>;
}
export const listAvailableListingsRef: ListAvailableListingsRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `QueryRef` function.
```typescript
listAvailableListings(dc: DataConnect, options?: ExecuteQueryOptions): QueryPromise<ListAvailableListingsData, undefined>;

interface ListAvailableListingsRef {
  ...
  (dc: DataConnect): QueryRef<ListAvailableListingsData, undefined>;
}
export const listAvailableListingsRef: ListAvailableListingsRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the listAvailableListingsRef:
```typescript
const name = listAvailableListingsRef.operationName;
console.log(name);
```

### Variables
The `ListAvailableListings` query has no variables.
### Return Type
Recall that executing the `ListAvailableListings` query returns a `QueryPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `ListAvailableListingsData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface ListAvailableListingsData {
  harvestListings: ({
    species: string;
    pricePerUnit: number;
  })[];
}
```
### Using `ListAvailableListings`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, listAvailableListings } from '@dataconnect/generated';


// Call the `listAvailableListings()` function to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await listAvailableListings();

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await listAvailableListings(dataConnect);

console.log(data.harvestListings);

// Or, you can use the `Promise` API.
listAvailableListings().then((response) => {
  const data = response.data;
  console.log(data.harvestListings);
});
```

### Using `ListAvailableListings`'s `QueryRef` function

```typescript
import { getDataConnect, executeQuery } from 'firebase/data-connect';
import { connectorConfig, listAvailableListingsRef } from '@dataconnect/generated';


// Call the `listAvailableListingsRef()` function to get a reference to the query.
const ref = listAvailableListingsRef();

// You can also pass in a `DataConnect` instance to the `QueryRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = listAvailableListingsRef(dataConnect);

// Call `executeQuery()` on the reference to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeQuery(ref);

console.log(data.harvestListings);

// Or, you can use the `Promise` API.
executeQuery(ref).then((response) => {
  const data = response.data;
  console.log(data.harvestListings);
});
```

## GetOrder
You can execute the `GetOrder` query using the following action shortcut function, or by calling `executeQuery()` after calling the following `QueryRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
getOrder(vars: GetOrderVariables, options?: ExecuteQueryOptions): QueryPromise<GetOrderData, GetOrderVariables>;

interface GetOrderRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetOrderVariables): QueryRef<GetOrderData, GetOrderVariables>;
}
export const getOrderRef: GetOrderRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `QueryRef` function.
```typescript
getOrder(dc: DataConnect, vars: GetOrderVariables, options?: ExecuteQueryOptions): QueryPromise<GetOrderData, GetOrderVariables>;

interface GetOrderRef {
  ...
  (dc: DataConnect, vars: GetOrderVariables): QueryRef<GetOrderData, GetOrderVariables>;
}
export const getOrderRef: GetOrderRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the getOrderRef:
```typescript
const name = getOrderRef.operationName;
console.log(name);
```

### Variables
The `GetOrder` query requires an argument of type `GetOrderVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface GetOrderVariables {
  id: UUIDString;
}
```
### Return Type
Recall that executing the `GetOrder` query returns a `QueryPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `GetOrderData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface GetOrderData {
  order?: {
    status: string;
    totalAmount: number;
  };
}
```
### Using `GetOrder`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, getOrder, GetOrderVariables } from '@dataconnect/generated';

// The `GetOrder` query requires an argument of type `GetOrderVariables`:
const getOrderVars: GetOrderVariables = {
  id: ..., 
};

// Call the `getOrder()` function to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await getOrder(getOrderVars);
// Variables can be defined inline as well.
const { data } = await getOrder({ id: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await getOrder(dataConnect, getOrderVars);

console.log(data.order);

// Or, you can use the `Promise` API.
getOrder(getOrderVars).then((response) => {
  const data = response.data;
  console.log(data.order);
});
```

### Using `GetOrder`'s `QueryRef` function

```typescript
import { getDataConnect, executeQuery } from 'firebase/data-connect';
import { connectorConfig, getOrderRef, GetOrderVariables } from '@dataconnect/generated';

// The `GetOrder` query requires an argument of type `GetOrderVariables`:
const getOrderVars: GetOrderVariables = {
  id: ..., 
};

// Call the `getOrderRef()` function to get a reference to the query.
const ref = getOrderRef(getOrderVars);
// Variables can be defined inline as well.
const ref = getOrderRef({ id: ..., });

// You can also pass in a `DataConnect` instance to the `QueryRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = getOrderRef(dataConnect, getOrderVars);

// Call `executeQuery()` on the reference to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeQuery(ref);

console.log(data.order);

// Or, you can use the `Promise` API.
executeQuery(ref).then((response) => {
  const data = response.data;
  console.log(data.order);
});
```

## ListMyOrders
You can execute the `ListMyOrders` query using the following action shortcut function, or by calling `executeQuery()` after calling the following `QueryRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
listMyOrders(options?: ExecuteQueryOptions): QueryPromise<ListMyOrdersData, undefined>;

interface ListMyOrdersRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (): QueryRef<ListMyOrdersData, undefined>;
}
export const listMyOrdersRef: ListMyOrdersRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `QueryRef` function.
```typescript
listMyOrders(dc: DataConnect, options?: ExecuteQueryOptions): QueryPromise<ListMyOrdersData, undefined>;

interface ListMyOrdersRef {
  ...
  (dc: DataConnect): QueryRef<ListMyOrdersData, undefined>;
}
export const listMyOrdersRef: ListMyOrdersRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the listMyOrdersRef:
```typescript
const name = listMyOrdersRef.operationName;
console.log(name);
```

### Variables
The `ListMyOrders` query has no variables.
### Return Type
Recall that executing the `ListMyOrders` query returns a `QueryPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `ListMyOrdersData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface ListMyOrdersData {
  orders: ({
    listing: {
      species: string;
    };
    status: string;
  })[];
}
```
### Using `ListMyOrders`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, listMyOrders } from '@dataconnect/generated';


// Call the `listMyOrders()` function to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await listMyOrders();

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await listMyOrders(dataConnect);

console.log(data.orders);

// Or, you can use the `Promise` API.
listMyOrders().then((response) => {
  const data = response.data;
  console.log(data.orders);
});
```

### Using `ListMyOrders`'s `QueryRef` function

```typescript
import { getDataConnect, executeQuery } from 'firebase/data-connect';
import { connectorConfig, listMyOrdersRef } from '@dataconnect/generated';


// Call the `listMyOrdersRef()` function to get a reference to the query.
const ref = listMyOrdersRef();

// You can also pass in a `DataConnect` instance to the `QueryRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = listMyOrdersRef(dataConnect);

// Call `executeQuery()` on the reference to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeQuery(ref);

console.log(data.orders);

// Or, you can use the `Promise` API.
executeQuery(ref).then((response) => {
  const data = response.data;
  console.log(data.orders);
});
```

## GetNotification
You can execute the `GetNotification` query using the following action shortcut function, or by calling `executeQuery()` after calling the following `QueryRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
getNotification(vars: GetNotificationVariables, options?: ExecuteQueryOptions): QueryPromise<GetNotificationData, GetNotificationVariables>;

interface GetNotificationRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetNotificationVariables): QueryRef<GetNotificationData, GetNotificationVariables>;
}
export const getNotificationRef: GetNotificationRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `QueryRef` function.
```typescript
getNotification(dc: DataConnect, vars: GetNotificationVariables, options?: ExecuteQueryOptions): QueryPromise<GetNotificationData, GetNotificationVariables>;

interface GetNotificationRef {
  ...
  (dc: DataConnect, vars: GetNotificationVariables): QueryRef<GetNotificationData, GetNotificationVariables>;
}
export const getNotificationRef: GetNotificationRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the getNotificationRef:
```typescript
const name = getNotificationRef.operationName;
console.log(name);
```

### Variables
The `GetNotification` query requires an argument of type `GetNotificationVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface GetNotificationVariables {
  id: UUIDString;
}
```
### Return Type
Recall that executing the `GetNotification` query returns a `QueryPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `GetNotificationData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface GetNotificationData {
  notification?: {
    message: string;
    isRead: boolean;
  };
}
```
### Using `GetNotification`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, getNotification, GetNotificationVariables } from '@dataconnect/generated';

// The `GetNotification` query requires an argument of type `GetNotificationVariables`:
const getNotificationVars: GetNotificationVariables = {
  id: ..., 
};

// Call the `getNotification()` function to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await getNotification(getNotificationVars);
// Variables can be defined inline as well.
const { data } = await getNotification({ id: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await getNotification(dataConnect, getNotificationVars);

console.log(data.notification);

// Or, you can use the `Promise` API.
getNotification(getNotificationVars).then((response) => {
  const data = response.data;
  console.log(data.notification);
});
```

### Using `GetNotification`'s `QueryRef` function

```typescript
import { getDataConnect, executeQuery } from 'firebase/data-connect';
import { connectorConfig, getNotificationRef, GetNotificationVariables } from '@dataconnect/generated';

// The `GetNotification` query requires an argument of type `GetNotificationVariables`:
const getNotificationVars: GetNotificationVariables = {
  id: ..., 
};

// Call the `getNotificationRef()` function to get a reference to the query.
const ref = getNotificationRef(getNotificationVars);
// Variables can be defined inline as well.
const ref = getNotificationRef({ id: ..., });

// You can also pass in a `DataConnect` instance to the `QueryRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = getNotificationRef(dataConnect, getNotificationVars);

// Call `executeQuery()` on the reference to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeQuery(ref);

console.log(data.notification);

// Or, you can use the `Promise` API.
executeQuery(ref).then((response) => {
  const data = response.data;
  console.log(data.notification);
});
```

## ListMyNotifications
You can execute the `ListMyNotifications` query using the following action shortcut function, or by calling `executeQuery()` after calling the following `QueryRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
listMyNotifications(options?: ExecuteQueryOptions): QueryPromise<ListMyNotificationsData, undefined>;

interface ListMyNotificationsRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (): QueryRef<ListMyNotificationsData, undefined>;
}
export const listMyNotificationsRef: ListMyNotificationsRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `QueryRef` function.
```typescript
listMyNotifications(dc: DataConnect, options?: ExecuteQueryOptions): QueryPromise<ListMyNotificationsData, undefined>;

interface ListMyNotificationsRef {
  ...
  (dc: DataConnect): QueryRef<ListMyNotificationsData, undefined>;
}
export const listMyNotificationsRef: ListMyNotificationsRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the listMyNotificationsRef:
```typescript
const name = listMyNotificationsRef.operationName;
console.log(name);
```

### Variables
The `ListMyNotifications` query has no variables.
### Return Type
Recall that executing the `ListMyNotifications` query returns a `QueryPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `ListMyNotificationsData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface ListMyNotificationsData {
  notifications: ({
    message: string;
    isRead: boolean;
  })[];
}
```
### Using `ListMyNotifications`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, listMyNotifications } from '@dataconnect/generated';


// Call the `listMyNotifications()` function to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await listMyNotifications();

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await listMyNotifications(dataConnect);

console.log(data.notifications);

// Or, you can use the `Promise` API.
listMyNotifications().then((response) => {
  const data = response.data;
  console.log(data.notifications);
});
```

### Using `ListMyNotifications`'s `QueryRef` function

```typescript
import { getDataConnect, executeQuery } from 'firebase/data-connect';
import { connectorConfig, listMyNotificationsRef } from '@dataconnect/generated';


// Call the `listMyNotificationsRef()` function to get a reference to the query.
const ref = listMyNotificationsRef();

// You can also pass in a `DataConnect` instance to the `QueryRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = listMyNotificationsRef(dataConnect);

// Call `executeQuery()` on the reference to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeQuery(ref);

console.log(data.notifications);

// Or, you can use the `Promise` API.
executeQuery(ref).then((response) => {
  const data = response.data;
  console.log(data.notifications);
});
```

# Mutations

There are two ways to execute a Data Connect Mutation using the generated Web SDK:
- Using a Mutation Reference function, which returns a `MutationRef`
  - The `MutationRef` can be used as an argument to `executeMutation()`, which will execute the Mutation and return a `MutationPromise`
- Using an action shortcut function, which returns a `MutationPromise`
  - Calling the action shortcut function will execute the Mutation and return a `MutationPromise`

The following is true for both the action shortcut function and the `MutationRef` function:
- The `MutationPromise` returned will resolve to the result of the Mutation once it has finished executing
- If the Mutation accepts arguments, both the action shortcut function and the `MutationRef` function accept a single argument: an object that contains all the required variables (and the optional variables) for the Mutation
- Both functions can be called with or without passing in a `DataConnect` instance as an argument. If no `DataConnect` argument is passed in, then the generated SDK will call `getDataConnect(connectorConfig)` behind the scenes for you.

Below are examples of how to use the `example` connector's generated functions to execute each mutation. You can also follow the examples from the [Data Connect documentation](https://firebase.google.com/docs/data-connect/web-sdk#using-mutations).

## CreateUser
You can execute the `CreateUser` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
createUser(): MutationPromise<CreateUserData, undefined>;

interface CreateUserRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (): MutationRef<CreateUserData, undefined>;
}
export const createUserRef: CreateUserRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
createUser(dc: DataConnect): MutationPromise<CreateUserData, undefined>;

interface CreateUserRef {
  ...
  (dc: DataConnect): MutationRef<CreateUserData, undefined>;
}
export const createUserRef: CreateUserRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the createUserRef:
```typescript
const name = createUserRef.operationName;
console.log(name);
```

### Variables
The `CreateUser` mutation has no variables.
### Return Type
Recall that executing the `CreateUser` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `CreateUserData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface CreateUserData {
  user_insert: User_Key;
}
```
### Using `CreateUser`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, createUser } from '@dataconnect/generated';


// Call the `createUser()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await createUser();

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await createUser(dataConnect);

console.log(data.user_insert);

// Or, you can use the `Promise` API.
createUser().then((response) => {
  const data = response.data;
  console.log(data.user_insert);
});
```

### Using `CreateUser`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, createUserRef } from '@dataconnect/generated';


// Call the `createUserRef()` function to get a reference to the mutation.
const ref = createUserRef();

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = createUserRef(dataConnect);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.user_insert);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.user_insert);
});
```

## UpdateUser
You can execute the `UpdateUser` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
updateUser(vars: UpdateUserVariables): MutationPromise<UpdateUserData, UpdateUserVariables>;

interface UpdateUserRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: UpdateUserVariables): MutationRef<UpdateUserData, UpdateUserVariables>;
}
export const updateUserRef: UpdateUserRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
updateUser(dc: DataConnect, vars: UpdateUserVariables): MutationPromise<UpdateUserData, UpdateUserVariables>;

interface UpdateUserRef {
  ...
  (dc: DataConnect, vars: UpdateUserVariables): MutationRef<UpdateUserData, UpdateUserVariables>;
}
export const updateUserRef: UpdateUserRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the updateUserRef:
```typescript
const name = updateUserRef.operationName;
console.log(name);
```

### Variables
The `UpdateUser` mutation requires an argument of type `UpdateUserVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface UpdateUserVariables {
  displayName: string;
}
```
### Return Type
Recall that executing the `UpdateUser` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `UpdateUserData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface UpdateUserData {
  user_update?: User_Key | null;
}
```
### Using `UpdateUser`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, updateUser, UpdateUserVariables } from '@dataconnect/generated';

// The `UpdateUser` mutation requires an argument of type `UpdateUserVariables`:
const updateUserVars: UpdateUserVariables = {
  displayName: ..., 
};

// Call the `updateUser()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await updateUser(updateUserVars);
// Variables can be defined inline as well.
const { data } = await updateUser({ displayName: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await updateUser(dataConnect, updateUserVars);

console.log(data.user_update);

// Or, you can use the `Promise` API.
updateUser(updateUserVars).then((response) => {
  const data = response.data;
  console.log(data.user_update);
});
```

### Using `UpdateUser`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, updateUserRef, UpdateUserVariables } from '@dataconnect/generated';

// The `UpdateUser` mutation requires an argument of type `UpdateUserVariables`:
const updateUserVars: UpdateUserVariables = {
  displayName: ..., 
};

// Call the `updateUserRef()` function to get a reference to the mutation.
const ref = updateUserRef(updateUserVars);
// Variables can be defined inline as well.
const ref = updateUserRef({ displayName: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = updateUserRef(dataConnect, updateUserVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.user_update);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.user_update);
});
```

## DeleteUser
You can execute the `DeleteUser` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
deleteUser(): MutationPromise<DeleteUserData, undefined>;

interface DeleteUserRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (): MutationRef<DeleteUserData, undefined>;
}
export const deleteUserRef: DeleteUserRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
deleteUser(dc: DataConnect): MutationPromise<DeleteUserData, undefined>;

interface DeleteUserRef {
  ...
  (dc: DataConnect): MutationRef<DeleteUserData, undefined>;
}
export const deleteUserRef: DeleteUserRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the deleteUserRef:
```typescript
const name = deleteUserRef.operationName;
console.log(name);
```

### Variables
The `DeleteUser` mutation has no variables.
### Return Type
Recall that executing the `DeleteUser` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `DeleteUserData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface DeleteUserData {
  user_delete?: User_Key | null;
}
```
### Using `DeleteUser`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, deleteUser } from '@dataconnect/generated';


// Call the `deleteUser()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await deleteUser();

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await deleteUser(dataConnect);

console.log(data.user_delete);

// Or, you can use the `Promise` API.
deleteUser().then((response) => {
  const data = response.data;
  console.log(data.user_delete);
});
```

### Using `DeleteUser`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, deleteUserRef } from '@dataconnect/generated';


// Call the `deleteUserRef()` function to get a reference to the mutation.
const ref = deleteUserRef();

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = deleteUserRef(dataConnect);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.user_delete);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.user_delete);
});
```

## CreatePond
You can execute the `CreatePond` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
createPond(vars: CreatePondVariables): MutationPromise<CreatePondData, CreatePondVariables>;

interface CreatePondRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: CreatePondVariables): MutationRef<CreatePondData, CreatePondVariables>;
}
export const createPondRef: CreatePondRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
createPond(dc: DataConnect, vars: CreatePondVariables): MutationPromise<CreatePondData, CreatePondVariables>;

interface CreatePondRef {
  ...
  (dc: DataConnect, vars: CreatePondVariables): MutationRef<CreatePondData, CreatePondVariables>;
}
export const createPondRef: CreatePondRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the createPondRef:
```typescript
const name = createPondRef.operationName;
console.log(name);
```

### Variables
The `CreatePond` mutation requires an argument of type `CreatePondVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface CreatePondVariables {
  name: string;
  location: string;
  capacity?: number | null;
}
```
### Return Type
Recall that executing the `CreatePond` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `CreatePondData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface CreatePondData {
  pond_insert: Pond_Key;
}
```
### Using `CreatePond`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, createPond, CreatePondVariables } from '@dataconnect/generated';

// The `CreatePond` mutation requires an argument of type `CreatePondVariables`:
const createPondVars: CreatePondVariables = {
  name: ..., 
  location: ..., 
  capacity: ..., // optional
};

// Call the `createPond()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await createPond(createPondVars);
// Variables can be defined inline as well.
const { data } = await createPond({ name: ..., location: ..., capacity: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await createPond(dataConnect, createPondVars);

console.log(data.pond_insert);

// Or, you can use the `Promise` API.
createPond(createPondVars).then((response) => {
  const data = response.data;
  console.log(data.pond_insert);
});
```

### Using `CreatePond`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, createPondRef, CreatePondVariables } from '@dataconnect/generated';

// The `CreatePond` mutation requires an argument of type `CreatePondVariables`:
const createPondVars: CreatePondVariables = {
  name: ..., 
  location: ..., 
  capacity: ..., // optional
};

// Call the `createPondRef()` function to get a reference to the mutation.
const ref = createPondRef(createPondVars);
// Variables can be defined inline as well.
const ref = createPondRef({ name: ..., location: ..., capacity: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = createPondRef(dataConnect, createPondVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.pond_insert);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.pond_insert);
});
```

## UpdatePond
You can execute the `UpdatePond` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
updatePond(vars: UpdatePondVariables): MutationPromise<UpdatePondData, UpdatePondVariables>;

interface UpdatePondRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: UpdatePondVariables): MutationRef<UpdatePondData, UpdatePondVariables>;
}
export const updatePondRef: UpdatePondRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
updatePond(dc: DataConnect, vars: UpdatePondVariables): MutationPromise<UpdatePondData, UpdatePondVariables>;

interface UpdatePondRef {
  ...
  (dc: DataConnect, vars: UpdatePondVariables): MutationRef<UpdatePondData, UpdatePondVariables>;
}
export const updatePondRef: UpdatePondRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the updatePondRef:
```typescript
const name = updatePondRef.operationName;
console.log(name);
```

### Variables
The `UpdatePond` mutation requires an argument of type `UpdatePondVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface UpdatePondVariables {
  id: UUIDString;
  capacity?: number | null;
}
```
### Return Type
Recall that executing the `UpdatePond` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `UpdatePondData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface UpdatePondData {
  pond_update?: Pond_Key | null;
}
```
### Using `UpdatePond`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, updatePond, UpdatePondVariables } from '@dataconnect/generated';

// The `UpdatePond` mutation requires an argument of type `UpdatePondVariables`:
const updatePondVars: UpdatePondVariables = {
  id: ..., 
  capacity: ..., // optional
};

// Call the `updatePond()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await updatePond(updatePondVars);
// Variables can be defined inline as well.
const { data } = await updatePond({ id: ..., capacity: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await updatePond(dataConnect, updatePondVars);

console.log(data.pond_update);

// Or, you can use the `Promise` API.
updatePond(updatePondVars).then((response) => {
  const data = response.data;
  console.log(data.pond_update);
});
```

### Using `UpdatePond`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, updatePondRef, UpdatePondVariables } from '@dataconnect/generated';

// The `UpdatePond` mutation requires an argument of type `UpdatePondVariables`:
const updatePondVars: UpdatePondVariables = {
  id: ..., 
  capacity: ..., // optional
};

// Call the `updatePondRef()` function to get a reference to the mutation.
const ref = updatePondRef(updatePondVars);
// Variables can be defined inline as well.
const ref = updatePondRef({ id: ..., capacity: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = updatePondRef(dataConnect, updatePondVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.pond_update);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.pond_update);
});
```

## DeletePond
You can execute the `DeletePond` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
deletePond(vars: DeletePondVariables): MutationPromise<DeletePondData, DeletePondVariables>;

interface DeletePondRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: DeletePondVariables): MutationRef<DeletePondData, DeletePondVariables>;
}
export const deletePondRef: DeletePondRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
deletePond(dc: DataConnect, vars: DeletePondVariables): MutationPromise<DeletePondData, DeletePondVariables>;

interface DeletePondRef {
  ...
  (dc: DataConnect, vars: DeletePondVariables): MutationRef<DeletePondData, DeletePondVariables>;
}
export const deletePondRef: DeletePondRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the deletePondRef:
```typescript
const name = deletePondRef.operationName;
console.log(name);
```

### Variables
The `DeletePond` mutation requires an argument of type `DeletePondVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface DeletePondVariables {
  id: UUIDString;
}
```
### Return Type
Recall that executing the `DeletePond` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `DeletePondData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface DeletePondData {
  pond_delete?: Pond_Key | null;
}
```
### Using `DeletePond`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, deletePond, DeletePondVariables } from '@dataconnect/generated';

// The `DeletePond` mutation requires an argument of type `DeletePondVariables`:
const deletePondVars: DeletePondVariables = {
  id: ..., 
};

// Call the `deletePond()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await deletePond(deletePondVars);
// Variables can be defined inline as well.
const { data } = await deletePond({ id: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await deletePond(dataConnect, deletePondVars);

console.log(data.pond_delete);

// Or, you can use the `Promise` API.
deletePond(deletePondVars).then((response) => {
  const data = response.data;
  console.log(data.pond_delete);
});
```

### Using `DeletePond`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, deletePondRef, DeletePondVariables } from '@dataconnect/generated';

// The `DeletePond` mutation requires an argument of type `DeletePondVariables`:
const deletePondVars: DeletePondVariables = {
  id: ..., 
};

// Call the `deletePondRef()` function to get a reference to the mutation.
const ref = deletePondRef(deletePondVars);
// Variables can be defined inline as well.
const ref = deletePondRef({ id: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = deletePondRef(dataConnect, deletePondVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.pond_delete);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.pond_delete);
});
```

## CreateSensorReading
You can execute the `CreateSensorReading` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
createSensorReading(vars: CreateSensorReadingVariables): MutationPromise<CreateSensorReadingData, CreateSensorReadingVariables>;

interface CreateSensorReadingRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: CreateSensorReadingVariables): MutationRef<CreateSensorReadingData, CreateSensorReadingVariables>;
}
export const createSensorReadingRef: CreateSensorReadingRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
createSensorReading(dc: DataConnect, vars: CreateSensorReadingVariables): MutationPromise<CreateSensorReadingData, CreateSensorReadingVariables>;

interface CreateSensorReadingRef {
  ...
  (dc: DataConnect, vars: CreateSensorReadingVariables): MutationRef<CreateSensorReadingData, CreateSensorReadingVariables>;
}
export const createSensorReadingRef: CreateSensorReadingRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the createSensorReadingRef:
```typescript
const name = createSensorReadingRef.operationName;
console.log(name);
```

### Variables
The `CreateSensorReading` mutation requires an argument of type `CreateSensorReadingVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface CreateSensorReadingVariables {
  pondId: UUIDString;
  ph: number;
  temp: number;
  turb: number;
  dissolvedOxygen: number;
  nh3: number;
}
```
### Return Type
Recall that executing the `CreateSensorReading` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `CreateSensorReadingData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface CreateSensorReadingData {
  sensorReading_insert: SensorReading_Key;
}
```
### Using `CreateSensorReading`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, createSensorReading, CreateSensorReadingVariables } from '@dataconnect/generated';

// The `CreateSensorReading` mutation requires an argument of type `CreateSensorReadingVariables`:
const createSensorReadingVars: CreateSensorReadingVariables = {
  pondId: ..., 
  ph: ..., 
  temp: ..., 
  turb: ..., 
  dissolvedOxygen: ..., 
  nh3: ..., 
};

// Call the `createSensorReading()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await createSensorReading(createSensorReadingVars);
// Variables can be defined inline as well.
const { data } = await createSensorReading({ pondId: ..., ph: ..., temp: ..., turb: ..., dissolvedOxygen: ..., nh3: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await createSensorReading(dataConnect, createSensorReadingVars);

console.log(data.sensorReading_insert);

// Or, you can use the `Promise` API.
createSensorReading(createSensorReadingVars).then((response) => {
  const data = response.data;
  console.log(data.sensorReading_insert);
});
```

### Using `CreateSensorReading`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, createSensorReadingRef, CreateSensorReadingVariables } from '@dataconnect/generated';

// The `CreateSensorReading` mutation requires an argument of type `CreateSensorReadingVariables`:
const createSensorReadingVars: CreateSensorReadingVariables = {
  pondId: ..., 
  ph: ..., 
  temp: ..., 
  turb: ..., 
  dissolvedOxygen: ..., 
  nh3: ..., 
};

// Call the `createSensorReadingRef()` function to get a reference to the mutation.
const ref = createSensorReadingRef(createSensorReadingVars);
// Variables can be defined inline as well.
const ref = createSensorReadingRef({ pondId: ..., ph: ..., temp: ..., turb: ..., dissolvedOxygen: ..., nh3: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = createSensorReadingRef(dataConnect, createSensorReadingVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.sensorReading_insert);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.sensorReading_insert);
});
```

## UpdateSensorReading
You can execute the `UpdateSensorReading` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
updateSensorReading(vars: UpdateSensorReadingVariables): MutationPromise<UpdateSensorReadingData, UpdateSensorReadingVariables>;

interface UpdateSensorReadingRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: UpdateSensorReadingVariables): MutationRef<UpdateSensorReadingData, UpdateSensorReadingVariables>;
}
export const updateSensorReadingRef: UpdateSensorReadingRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
updateSensorReading(dc: DataConnect, vars: UpdateSensorReadingVariables): MutationPromise<UpdateSensorReadingData, UpdateSensorReadingVariables>;

interface UpdateSensorReadingRef {
  ...
  (dc: DataConnect, vars: UpdateSensorReadingVariables): MutationRef<UpdateSensorReadingData, UpdateSensorReadingVariables>;
}
export const updateSensorReadingRef: UpdateSensorReadingRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the updateSensorReadingRef:
```typescript
const name = updateSensorReadingRef.operationName;
console.log(name);
```

### Variables
The `UpdateSensorReading` mutation requires an argument of type `UpdateSensorReadingVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface UpdateSensorReadingVariables {
  id: UUIDString;
  ph: number;
}
```
### Return Type
Recall that executing the `UpdateSensorReading` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `UpdateSensorReadingData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface UpdateSensorReadingData {
  sensorReading_update?: SensorReading_Key | null;
}
```
### Using `UpdateSensorReading`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, updateSensorReading, UpdateSensorReadingVariables } from '@dataconnect/generated';

// The `UpdateSensorReading` mutation requires an argument of type `UpdateSensorReadingVariables`:
const updateSensorReadingVars: UpdateSensorReadingVariables = {
  id: ..., 
  ph: ..., 
};

// Call the `updateSensorReading()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await updateSensorReading(updateSensorReadingVars);
// Variables can be defined inline as well.
const { data } = await updateSensorReading({ id: ..., ph: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await updateSensorReading(dataConnect, updateSensorReadingVars);

console.log(data.sensorReading_update);

// Or, you can use the `Promise` API.
updateSensorReading(updateSensorReadingVars).then((response) => {
  const data = response.data;
  console.log(data.sensorReading_update);
});
```

### Using `UpdateSensorReading`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, updateSensorReadingRef, UpdateSensorReadingVariables } from '@dataconnect/generated';

// The `UpdateSensorReading` mutation requires an argument of type `UpdateSensorReadingVariables`:
const updateSensorReadingVars: UpdateSensorReadingVariables = {
  id: ..., 
  ph: ..., 
};

// Call the `updateSensorReadingRef()` function to get a reference to the mutation.
const ref = updateSensorReadingRef(updateSensorReadingVars);
// Variables can be defined inline as well.
const ref = updateSensorReadingRef({ id: ..., ph: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = updateSensorReadingRef(dataConnect, updateSensorReadingVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.sensorReading_update);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.sensorReading_update);
});
```

## DeleteSensorReading
You can execute the `DeleteSensorReading` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
deleteSensorReading(vars: DeleteSensorReadingVariables): MutationPromise<DeleteSensorReadingData, DeleteSensorReadingVariables>;

interface DeleteSensorReadingRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: DeleteSensorReadingVariables): MutationRef<DeleteSensorReadingData, DeleteSensorReadingVariables>;
}
export const deleteSensorReadingRef: DeleteSensorReadingRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
deleteSensorReading(dc: DataConnect, vars: DeleteSensorReadingVariables): MutationPromise<DeleteSensorReadingData, DeleteSensorReadingVariables>;

interface DeleteSensorReadingRef {
  ...
  (dc: DataConnect, vars: DeleteSensorReadingVariables): MutationRef<DeleteSensorReadingData, DeleteSensorReadingVariables>;
}
export const deleteSensorReadingRef: DeleteSensorReadingRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the deleteSensorReadingRef:
```typescript
const name = deleteSensorReadingRef.operationName;
console.log(name);
```

### Variables
The `DeleteSensorReading` mutation requires an argument of type `DeleteSensorReadingVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface DeleteSensorReadingVariables {
  id: UUIDString;
}
```
### Return Type
Recall that executing the `DeleteSensorReading` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `DeleteSensorReadingData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface DeleteSensorReadingData {
  sensorReading_delete?: SensorReading_Key | null;
}
```
### Using `DeleteSensorReading`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, deleteSensorReading, DeleteSensorReadingVariables } from '@dataconnect/generated';

// The `DeleteSensorReading` mutation requires an argument of type `DeleteSensorReadingVariables`:
const deleteSensorReadingVars: DeleteSensorReadingVariables = {
  id: ..., 
};

// Call the `deleteSensorReading()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await deleteSensorReading(deleteSensorReadingVars);
// Variables can be defined inline as well.
const { data } = await deleteSensorReading({ id: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await deleteSensorReading(dataConnect, deleteSensorReadingVars);

console.log(data.sensorReading_delete);

// Or, you can use the `Promise` API.
deleteSensorReading(deleteSensorReadingVars).then((response) => {
  const data = response.data;
  console.log(data.sensorReading_delete);
});
```

### Using `DeleteSensorReading`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, deleteSensorReadingRef, DeleteSensorReadingVariables } from '@dataconnect/generated';

// The `DeleteSensorReading` mutation requires an argument of type `DeleteSensorReadingVariables`:
const deleteSensorReadingVars: DeleteSensorReadingVariables = {
  id: ..., 
};

// Call the `deleteSensorReadingRef()` function to get a reference to the mutation.
const ref = deleteSensorReadingRef(deleteSensorReadingVars);
// Variables can be defined inline as well.
const ref = deleteSensorReadingRef({ id: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = deleteSensorReadingRef(dataConnect, deleteSensorReadingVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.sensorReading_delete);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.sensorReading_delete);
});
```

## CreateRecommendation
You can execute the `CreateRecommendation` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
createRecommendation(vars: CreateRecommendationVariables): MutationPromise<CreateRecommendationData, CreateRecommendationVariables>;

interface CreateRecommendationRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: CreateRecommendationVariables): MutationRef<CreateRecommendationData, CreateRecommendationVariables>;
}
export const createRecommendationRef: CreateRecommendationRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
createRecommendation(dc: DataConnect, vars: CreateRecommendationVariables): MutationPromise<CreateRecommendationData, CreateRecommendationVariables>;

interface CreateRecommendationRef {
  ...
  (dc: DataConnect, vars: CreateRecommendationVariables): MutationRef<CreateRecommendationData, CreateRecommendationVariables>;
}
export const createRecommendationRef: CreateRecommendationRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the createRecommendationRef:
```typescript
const name = createRecommendationRef.operationName;
console.log(name);
```

### Variables
The `CreateRecommendation` mutation requires an argument of type `CreateRecommendationVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface CreateRecommendationVariables {
  pondId: UUIDString;
  message: string;
  priority: string;
}
```
### Return Type
Recall that executing the `CreateRecommendation` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `CreateRecommendationData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface CreateRecommendationData {
  smartRecommendation_insert: SmartRecommendation_Key;
}
```
### Using `CreateRecommendation`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, createRecommendation, CreateRecommendationVariables } from '@dataconnect/generated';

// The `CreateRecommendation` mutation requires an argument of type `CreateRecommendationVariables`:
const createRecommendationVars: CreateRecommendationVariables = {
  pondId: ..., 
  message: ..., 
  priority: ..., 
};

// Call the `createRecommendation()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await createRecommendation(createRecommendationVars);
// Variables can be defined inline as well.
const { data } = await createRecommendation({ pondId: ..., message: ..., priority: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await createRecommendation(dataConnect, createRecommendationVars);

console.log(data.smartRecommendation_insert);

// Or, you can use the `Promise` API.
createRecommendation(createRecommendationVars).then((response) => {
  const data = response.data;
  console.log(data.smartRecommendation_insert);
});
```

### Using `CreateRecommendation`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, createRecommendationRef, CreateRecommendationVariables } from '@dataconnect/generated';

// The `CreateRecommendation` mutation requires an argument of type `CreateRecommendationVariables`:
const createRecommendationVars: CreateRecommendationVariables = {
  pondId: ..., 
  message: ..., 
  priority: ..., 
};

// Call the `createRecommendationRef()` function to get a reference to the mutation.
const ref = createRecommendationRef(createRecommendationVars);
// Variables can be defined inline as well.
const ref = createRecommendationRef({ pondId: ..., message: ..., priority: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = createRecommendationRef(dataConnect, createRecommendationVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.smartRecommendation_insert);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.smartRecommendation_insert);
});
```

## UpdateRecommendation
You can execute the `UpdateRecommendation` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
updateRecommendation(vars: UpdateRecommendationVariables): MutationPromise<UpdateRecommendationData, UpdateRecommendationVariables>;

interface UpdateRecommendationRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: UpdateRecommendationVariables): MutationRef<UpdateRecommendationData, UpdateRecommendationVariables>;
}
export const updateRecommendationRef: UpdateRecommendationRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
updateRecommendation(dc: DataConnect, vars: UpdateRecommendationVariables): MutationPromise<UpdateRecommendationData, UpdateRecommendationVariables>;

interface UpdateRecommendationRef {
  ...
  (dc: DataConnect, vars: UpdateRecommendationVariables): MutationRef<UpdateRecommendationData, UpdateRecommendationVariables>;
}
export const updateRecommendationRef: UpdateRecommendationRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the updateRecommendationRef:
```typescript
const name = updateRecommendationRef.operationName;
console.log(name);
```

### Variables
The `UpdateRecommendation` mutation requires an argument of type `UpdateRecommendationVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface UpdateRecommendationVariables {
  id: UUIDString;
  priority: string;
}
```
### Return Type
Recall that executing the `UpdateRecommendation` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `UpdateRecommendationData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface UpdateRecommendationData {
  smartRecommendation_update?: SmartRecommendation_Key | null;
}
```
### Using `UpdateRecommendation`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, updateRecommendation, UpdateRecommendationVariables } from '@dataconnect/generated';

// The `UpdateRecommendation` mutation requires an argument of type `UpdateRecommendationVariables`:
const updateRecommendationVars: UpdateRecommendationVariables = {
  id: ..., 
  priority: ..., 
};

// Call the `updateRecommendation()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await updateRecommendation(updateRecommendationVars);
// Variables can be defined inline as well.
const { data } = await updateRecommendation({ id: ..., priority: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await updateRecommendation(dataConnect, updateRecommendationVars);

console.log(data.smartRecommendation_update);

// Or, you can use the `Promise` API.
updateRecommendation(updateRecommendationVars).then((response) => {
  const data = response.data;
  console.log(data.smartRecommendation_update);
});
```

### Using `UpdateRecommendation`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, updateRecommendationRef, UpdateRecommendationVariables } from '@dataconnect/generated';

// The `UpdateRecommendation` mutation requires an argument of type `UpdateRecommendationVariables`:
const updateRecommendationVars: UpdateRecommendationVariables = {
  id: ..., 
  priority: ..., 
};

// Call the `updateRecommendationRef()` function to get a reference to the mutation.
const ref = updateRecommendationRef(updateRecommendationVars);
// Variables can be defined inline as well.
const ref = updateRecommendationRef({ id: ..., priority: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = updateRecommendationRef(dataConnect, updateRecommendationVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.smartRecommendation_update);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.smartRecommendation_update);
});
```

## DeleteRecommendation
You can execute the `DeleteRecommendation` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
deleteRecommendation(vars: DeleteRecommendationVariables): MutationPromise<DeleteRecommendationData, DeleteRecommendationVariables>;

interface DeleteRecommendationRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: DeleteRecommendationVariables): MutationRef<DeleteRecommendationData, DeleteRecommendationVariables>;
}
export const deleteRecommendationRef: DeleteRecommendationRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
deleteRecommendation(dc: DataConnect, vars: DeleteRecommendationVariables): MutationPromise<DeleteRecommendationData, DeleteRecommendationVariables>;

interface DeleteRecommendationRef {
  ...
  (dc: DataConnect, vars: DeleteRecommendationVariables): MutationRef<DeleteRecommendationData, DeleteRecommendationVariables>;
}
export const deleteRecommendationRef: DeleteRecommendationRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the deleteRecommendationRef:
```typescript
const name = deleteRecommendationRef.operationName;
console.log(name);
```

### Variables
The `DeleteRecommendation` mutation requires an argument of type `DeleteRecommendationVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface DeleteRecommendationVariables {
  id: UUIDString;
}
```
### Return Type
Recall that executing the `DeleteRecommendation` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `DeleteRecommendationData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface DeleteRecommendationData {
  smartRecommendation_delete?: SmartRecommendation_Key | null;
}
```
### Using `DeleteRecommendation`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, deleteRecommendation, DeleteRecommendationVariables } from '@dataconnect/generated';

// The `DeleteRecommendation` mutation requires an argument of type `DeleteRecommendationVariables`:
const deleteRecommendationVars: DeleteRecommendationVariables = {
  id: ..., 
};

// Call the `deleteRecommendation()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await deleteRecommendation(deleteRecommendationVars);
// Variables can be defined inline as well.
const { data } = await deleteRecommendation({ id: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await deleteRecommendation(dataConnect, deleteRecommendationVars);

console.log(data.smartRecommendation_delete);

// Or, you can use the `Promise` API.
deleteRecommendation(deleteRecommendationVars).then((response) => {
  const data = response.data;
  console.log(data.smartRecommendation_delete);
});
```

### Using `DeleteRecommendation`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, deleteRecommendationRef, DeleteRecommendationVariables } from '@dataconnect/generated';

// The `DeleteRecommendation` mutation requires an argument of type `DeleteRecommendationVariables`:
const deleteRecommendationVars: DeleteRecommendationVariables = {
  id: ..., 
};

// Call the `deleteRecommendationRef()` function to get a reference to the mutation.
const ref = deleteRecommendationRef(deleteRecommendationVars);
// Variables can be defined inline as well.
const ref = deleteRecommendationRef({ id: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = deleteRecommendationRef(dataConnect, deleteRecommendationVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.smartRecommendation_delete);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.smartRecommendation_delete);
});
```

## CreateListing
You can execute the `CreateListing` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
createListing(vars: CreateListingVariables): MutationPromise<CreateListingData, CreateListingVariables>;

interface CreateListingRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: CreateListingVariables): MutationRef<CreateListingData, CreateListingVariables>;
}
export const createListingRef: CreateListingRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
createListing(dc: DataConnect, vars: CreateListingVariables): MutationPromise<CreateListingData, CreateListingVariables>;

interface CreateListingRef {
  ...
  (dc: DataConnect, vars: CreateListingVariables): MutationRef<CreateListingData, CreateListingVariables>;
}
export const createListingRef: CreateListingRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the createListingRef:
```typescript
const name = createListingRef.operationName;
console.log(name);
```

### Variables
The `CreateListing` mutation requires an argument of type `CreateListingVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface CreateListingVariables {
  species: string;
  quantity: number;
  price: number;
}
```
### Return Type
Recall that executing the `CreateListing` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `CreateListingData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface CreateListingData {
  harvestListing_insert: HarvestListing_Key;
}
```
### Using `CreateListing`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, createListing, CreateListingVariables } from '@dataconnect/generated';

// The `CreateListing` mutation requires an argument of type `CreateListingVariables`:
const createListingVars: CreateListingVariables = {
  species: ..., 
  quantity: ..., 
  price: ..., 
};

// Call the `createListing()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await createListing(createListingVars);
// Variables can be defined inline as well.
const { data } = await createListing({ species: ..., quantity: ..., price: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await createListing(dataConnect, createListingVars);

console.log(data.harvestListing_insert);

// Or, you can use the `Promise` API.
createListing(createListingVars).then((response) => {
  const data = response.data;
  console.log(data.harvestListing_insert);
});
```

### Using `CreateListing`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, createListingRef, CreateListingVariables } from '@dataconnect/generated';

// The `CreateListing` mutation requires an argument of type `CreateListingVariables`:
const createListingVars: CreateListingVariables = {
  species: ..., 
  quantity: ..., 
  price: ..., 
};

// Call the `createListingRef()` function to get a reference to the mutation.
const ref = createListingRef(createListingVars);
// Variables can be defined inline as well.
const ref = createListingRef({ species: ..., quantity: ..., price: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = createListingRef(dataConnect, createListingVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.harvestListing_insert);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.harvestListing_insert);
});
```

## UpdateListing
You can execute the `UpdateListing` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
updateListing(vars: UpdateListingVariables): MutationPromise<UpdateListingData, UpdateListingVariables>;

interface UpdateListingRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: UpdateListingVariables): MutationRef<UpdateListingData, UpdateListingVariables>;
}
export const updateListingRef: UpdateListingRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
updateListing(dc: DataConnect, vars: UpdateListingVariables): MutationPromise<UpdateListingData, UpdateListingVariables>;

interface UpdateListingRef {
  ...
  (dc: DataConnect, vars: UpdateListingVariables): MutationRef<UpdateListingData, UpdateListingVariables>;
}
export const updateListingRef: UpdateListingRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the updateListingRef:
```typescript
const name = updateListingRef.operationName;
console.log(name);
```

### Variables
The `UpdateListing` mutation requires an argument of type `UpdateListingVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface UpdateListingVariables {
  id: UUIDString;
  status: string;
}
```
### Return Type
Recall that executing the `UpdateListing` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `UpdateListingData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface UpdateListingData {
  harvestListing_update?: HarvestListing_Key | null;
}
```
### Using `UpdateListing`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, updateListing, UpdateListingVariables } from '@dataconnect/generated';

// The `UpdateListing` mutation requires an argument of type `UpdateListingVariables`:
const updateListingVars: UpdateListingVariables = {
  id: ..., 
  status: ..., 
};

// Call the `updateListing()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await updateListing(updateListingVars);
// Variables can be defined inline as well.
const { data } = await updateListing({ id: ..., status: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await updateListing(dataConnect, updateListingVars);

console.log(data.harvestListing_update);

// Or, you can use the `Promise` API.
updateListing(updateListingVars).then((response) => {
  const data = response.data;
  console.log(data.harvestListing_update);
});
```

### Using `UpdateListing`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, updateListingRef, UpdateListingVariables } from '@dataconnect/generated';

// The `UpdateListing` mutation requires an argument of type `UpdateListingVariables`:
const updateListingVars: UpdateListingVariables = {
  id: ..., 
  status: ..., 
};

// Call the `updateListingRef()` function to get a reference to the mutation.
const ref = updateListingRef(updateListingVars);
// Variables can be defined inline as well.
const ref = updateListingRef({ id: ..., status: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = updateListingRef(dataConnect, updateListingVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.harvestListing_update);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.harvestListing_update);
});
```

## DeleteListing
You can execute the `DeleteListing` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
deleteListing(vars: DeleteListingVariables): MutationPromise<DeleteListingData, DeleteListingVariables>;

interface DeleteListingRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: DeleteListingVariables): MutationRef<DeleteListingData, DeleteListingVariables>;
}
export const deleteListingRef: DeleteListingRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
deleteListing(dc: DataConnect, vars: DeleteListingVariables): MutationPromise<DeleteListingData, DeleteListingVariables>;

interface DeleteListingRef {
  ...
  (dc: DataConnect, vars: DeleteListingVariables): MutationRef<DeleteListingData, DeleteListingVariables>;
}
export const deleteListingRef: DeleteListingRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the deleteListingRef:
```typescript
const name = deleteListingRef.operationName;
console.log(name);
```

### Variables
The `DeleteListing` mutation requires an argument of type `DeleteListingVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface DeleteListingVariables {
  id: UUIDString;
}
```
### Return Type
Recall that executing the `DeleteListing` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `DeleteListingData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface DeleteListingData {
  harvestListing_delete?: HarvestListing_Key | null;
}
```
### Using `DeleteListing`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, deleteListing, DeleteListingVariables } from '@dataconnect/generated';

// The `DeleteListing` mutation requires an argument of type `DeleteListingVariables`:
const deleteListingVars: DeleteListingVariables = {
  id: ..., 
};

// Call the `deleteListing()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await deleteListing(deleteListingVars);
// Variables can be defined inline as well.
const { data } = await deleteListing({ id: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await deleteListing(dataConnect, deleteListingVars);

console.log(data.harvestListing_delete);

// Or, you can use the `Promise` API.
deleteListing(deleteListingVars).then((response) => {
  const data = response.data;
  console.log(data.harvestListing_delete);
});
```

### Using `DeleteListing`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, deleteListingRef, DeleteListingVariables } from '@dataconnect/generated';

// The `DeleteListing` mutation requires an argument of type `DeleteListingVariables`:
const deleteListingVars: DeleteListingVariables = {
  id: ..., 
};

// Call the `deleteListingRef()` function to get a reference to the mutation.
const ref = deleteListingRef(deleteListingVars);
// Variables can be defined inline as well.
const ref = deleteListingRef({ id: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = deleteListingRef(dataConnect, deleteListingVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.harvestListing_delete);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.harvestListing_delete);
});
```

## CreateOrder
You can execute the `CreateOrder` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
createOrder(vars: CreateOrderVariables): MutationPromise<CreateOrderData, CreateOrderVariables>;

interface CreateOrderRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: CreateOrderVariables): MutationRef<CreateOrderData, CreateOrderVariables>;
}
export const createOrderRef: CreateOrderRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
createOrder(dc: DataConnect, vars: CreateOrderVariables): MutationPromise<CreateOrderData, CreateOrderVariables>;

interface CreateOrderRef {
  ...
  (dc: DataConnect, vars: CreateOrderVariables): MutationRef<CreateOrderData, CreateOrderVariables>;
}
export const createOrderRef: CreateOrderRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the createOrderRef:
```typescript
const name = createOrderRef.operationName;
console.log(name);
```

### Variables
The `CreateOrder` mutation requires an argument of type `CreateOrderVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface CreateOrderVariables {
  listingId: UUIDString;
  quantity: number;
  total: number;
}
```
### Return Type
Recall that executing the `CreateOrder` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `CreateOrderData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface CreateOrderData {
  order_insert: Order_Key;
}
```
### Using `CreateOrder`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, createOrder, CreateOrderVariables } from '@dataconnect/generated';

// The `CreateOrder` mutation requires an argument of type `CreateOrderVariables`:
const createOrderVars: CreateOrderVariables = {
  listingId: ..., 
  quantity: ..., 
  total: ..., 
};

// Call the `createOrder()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await createOrder(createOrderVars);
// Variables can be defined inline as well.
const { data } = await createOrder({ listingId: ..., quantity: ..., total: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await createOrder(dataConnect, createOrderVars);

console.log(data.order_insert);

// Or, you can use the `Promise` API.
createOrder(createOrderVars).then((response) => {
  const data = response.data;
  console.log(data.order_insert);
});
```

### Using `CreateOrder`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, createOrderRef, CreateOrderVariables } from '@dataconnect/generated';

// The `CreateOrder` mutation requires an argument of type `CreateOrderVariables`:
const createOrderVars: CreateOrderVariables = {
  listingId: ..., 
  quantity: ..., 
  total: ..., 
};

// Call the `createOrderRef()` function to get a reference to the mutation.
const ref = createOrderRef(createOrderVars);
// Variables can be defined inline as well.
const ref = createOrderRef({ listingId: ..., quantity: ..., total: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = createOrderRef(dataConnect, createOrderVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.order_insert);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.order_insert);
});
```

## UpdateOrder
You can execute the `UpdateOrder` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
updateOrder(vars: UpdateOrderVariables): MutationPromise<UpdateOrderData, UpdateOrderVariables>;

interface UpdateOrderRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: UpdateOrderVariables): MutationRef<UpdateOrderData, UpdateOrderVariables>;
}
export const updateOrderRef: UpdateOrderRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
updateOrder(dc: DataConnect, vars: UpdateOrderVariables): MutationPromise<UpdateOrderData, UpdateOrderVariables>;

interface UpdateOrderRef {
  ...
  (dc: DataConnect, vars: UpdateOrderVariables): MutationRef<UpdateOrderData, UpdateOrderVariables>;
}
export const updateOrderRef: UpdateOrderRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the updateOrderRef:
```typescript
const name = updateOrderRef.operationName;
console.log(name);
```

### Variables
The `UpdateOrder` mutation requires an argument of type `UpdateOrderVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface UpdateOrderVariables {
  id: UUIDString;
  status: string;
}
```
### Return Type
Recall that executing the `UpdateOrder` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `UpdateOrderData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface UpdateOrderData {
  order_update?: Order_Key | null;
}
```
### Using `UpdateOrder`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, updateOrder, UpdateOrderVariables } from '@dataconnect/generated';

// The `UpdateOrder` mutation requires an argument of type `UpdateOrderVariables`:
const updateOrderVars: UpdateOrderVariables = {
  id: ..., 
  status: ..., 
};

// Call the `updateOrder()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await updateOrder(updateOrderVars);
// Variables can be defined inline as well.
const { data } = await updateOrder({ id: ..., status: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await updateOrder(dataConnect, updateOrderVars);

console.log(data.order_update);

// Or, you can use the `Promise` API.
updateOrder(updateOrderVars).then((response) => {
  const data = response.data;
  console.log(data.order_update);
});
```

### Using `UpdateOrder`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, updateOrderRef, UpdateOrderVariables } from '@dataconnect/generated';

// The `UpdateOrder` mutation requires an argument of type `UpdateOrderVariables`:
const updateOrderVars: UpdateOrderVariables = {
  id: ..., 
  status: ..., 
};

// Call the `updateOrderRef()` function to get a reference to the mutation.
const ref = updateOrderRef(updateOrderVars);
// Variables can be defined inline as well.
const ref = updateOrderRef({ id: ..., status: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = updateOrderRef(dataConnect, updateOrderVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.order_update);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.order_update);
});
```

## DeleteOrder
You can execute the `DeleteOrder` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
deleteOrder(vars: DeleteOrderVariables): MutationPromise<DeleteOrderData, DeleteOrderVariables>;

interface DeleteOrderRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: DeleteOrderVariables): MutationRef<DeleteOrderData, DeleteOrderVariables>;
}
export const deleteOrderRef: DeleteOrderRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
deleteOrder(dc: DataConnect, vars: DeleteOrderVariables): MutationPromise<DeleteOrderData, DeleteOrderVariables>;

interface DeleteOrderRef {
  ...
  (dc: DataConnect, vars: DeleteOrderVariables): MutationRef<DeleteOrderData, DeleteOrderVariables>;
}
export const deleteOrderRef: DeleteOrderRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the deleteOrderRef:
```typescript
const name = deleteOrderRef.operationName;
console.log(name);
```

### Variables
The `DeleteOrder` mutation requires an argument of type `DeleteOrderVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface DeleteOrderVariables {
  id: UUIDString;
}
```
### Return Type
Recall that executing the `DeleteOrder` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `DeleteOrderData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface DeleteOrderData {
  order_delete?: Order_Key | null;
}
```
### Using `DeleteOrder`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, deleteOrder, DeleteOrderVariables } from '@dataconnect/generated';

// The `DeleteOrder` mutation requires an argument of type `DeleteOrderVariables`:
const deleteOrderVars: DeleteOrderVariables = {
  id: ..., 
};

// Call the `deleteOrder()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await deleteOrder(deleteOrderVars);
// Variables can be defined inline as well.
const { data } = await deleteOrder({ id: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await deleteOrder(dataConnect, deleteOrderVars);

console.log(data.order_delete);

// Or, you can use the `Promise` API.
deleteOrder(deleteOrderVars).then((response) => {
  const data = response.data;
  console.log(data.order_delete);
});
```

### Using `DeleteOrder`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, deleteOrderRef, DeleteOrderVariables } from '@dataconnect/generated';

// The `DeleteOrder` mutation requires an argument of type `DeleteOrderVariables`:
const deleteOrderVars: DeleteOrderVariables = {
  id: ..., 
};

// Call the `deleteOrderRef()` function to get a reference to the mutation.
const ref = deleteOrderRef(deleteOrderVars);
// Variables can be defined inline as well.
const ref = deleteOrderRef({ id: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = deleteOrderRef(dataConnect, deleteOrderVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.order_delete);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.order_delete);
});
```

## CreateNotification
You can execute the `CreateNotification` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
createNotification(vars: CreateNotificationVariables): MutationPromise<CreateNotificationData, CreateNotificationVariables>;

interface CreateNotificationRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: CreateNotificationVariables): MutationRef<CreateNotificationData, CreateNotificationVariables>;
}
export const createNotificationRef: CreateNotificationRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
createNotification(dc: DataConnect, vars: CreateNotificationVariables): MutationPromise<CreateNotificationData, CreateNotificationVariables>;

interface CreateNotificationRef {
  ...
  (dc: DataConnect, vars: CreateNotificationVariables): MutationRef<CreateNotificationData, CreateNotificationVariables>;
}
export const createNotificationRef: CreateNotificationRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the createNotificationRef:
```typescript
const name = createNotificationRef.operationName;
console.log(name);
```

### Variables
The `CreateNotification` mutation requires an argument of type `CreateNotificationVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface CreateNotificationVariables {
  userId: UUIDString;
  message: string;
}
```
### Return Type
Recall that executing the `CreateNotification` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `CreateNotificationData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface CreateNotificationData {
  notification_insert: Notification_Key;
}
```
### Using `CreateNotification`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, createNotification, CreateNotificationVariables } from '@dataconnect/generated';

// The `CreateNotification` mutation requires an argument of type `CreateNotificationVariables`:
const createNotificationVars: CreateNotificationVariables = {
  userId: ..., 
  message: ..., 
};

// Call the `createNotification()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await createNotification(createNotificationVars);
// Variables can be defined inline as well.
const { data } = await createNotification({ userId: ..., message: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await createNotification(dataConnect, createNotificationVars);

console.log(data.notification_insert);

// Or, you can use the `Promise` API.
createNotification(createNotificationVars).then((response) => {
  const data = response.data;
  console.log(data.notification_insert);
});
```

### Using `CreateNotification`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, createNotificationRef, CreateNotificationVariables } from '@dataconnect/generated';

// The `CreateNotification` mutation requires an argument of type `CreateNotificationVariables`:
const createNotificationVars: CreateNotificationVariables = {
  userId: ..., 
  message: ..., 
};

// Call the `createNotificationRef()` function to get a reference to the mutation.
const ref = createNotificationRef(createNotificationVars);
// Variables can be defined inline as well.
const ref = createNotificationRef({ userId: ..., message: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = createNotificationRef(dataConnect, createNotificationVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.notification_insert);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.notification_insert);
});
```

## MarkNotificationRead
You can execute the `MarkNotificationRead` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
markNotificationRead(vars: MarkNotificationReadVariables): MutationPromise<MarkNotificationReadData, MarkNotificationReadVariables>;

interface MarkNotificationReadRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: MarkNotificationReadVariables): MutationRef<MarkNotificationReadData, MarkNotificationReadVariables>;
}
export const markNotificationReadRef: MarkNotificationReadRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
markNotificationRead(dc: DataConnect, vars: MarkNotificationReadVariables): MutationPromise<MarkNotificationReadData, MarkNotificationReadVariables>;

interface MarkNotificationReadRef {
  ...
  (dc: DataConnect, vars: MarkNotificationReadVariables): MutationRef<MarkNotificationReadData, MarkNotificationReadVariables>;
}
export const markNotificationReadRef: MarkNotificationReadRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the markNotificationReadRef:
```typescript
const name = markNotificationReadRef.operationName;
console.log(name);
```

### Variables
The `MarkNotificationRead` mutation requires an argument of type `MarkNotificationReadVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface MarkNotificationReadVariables {
  id: UUIDString;
}
```
### Return Type
Recall that executing the `MarkNotificationRead` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `MarkNotificationReadData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface MarkNotificationReadData {
  notification_update?: Notification_Key | null;
}
```
### Using `MarkNotificationRead`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, markNotificationRead, MarkNotificationReadVariables } from '@dataconnect/generated';

// The `MarkNotificationRead` mutation requires an argument of type `MarkNotificationReadVariables`:
const markNotificationReadVars: MarkNotificationReadVariables = {
  id: ..., 
};

// Call the `markNotificationRead()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await markNotificationRead(markNotificationReadVars);
// Variables can be defined inline as well.
const { data } = await markNotificationRead({ id: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await markNotificationRead(dataConnect, markNotificationReadVars);

console.log(data.notification_update);

// Or, you can use the `Promise` API.
markNotificationRead(markNotificationReadVars).then((response) => {
  const data = response.data;
  console.log(data.notification_update);
});
```

### Using `MarkNotificationRead`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, markNotificationReadRef, MarkNotificationReadVariables } from '@dataconnect/generated';

// The `MarkNotificationRead` mutation requires an argument of type `MarkNotificationReadVariables`:
const markNotificationReadVars: MarkNotificationReadVariables = {
  id: ..., 
};

// Call the `markNotificationReadRef()` function to get a reference to the mutation.
const ref = markNotificationReadRef(markNotificationReadVars);
// Variables can be defined inline as well.
const ref = markNotificationReadRef({ id: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = markNotificationReadRef(dataConnect, markNotificationReadVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.notification_update);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.notification_update);
});
```

## DeleteNotification
You can execute the `DeleteNotification` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
deleteNotification(vars: DeleteNotificationVariables): MutationPromise<DeleteNotificationData, DeleteNotificationVariables>;

interface DeleteNotificationRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: DeleteNotificationVariables): MutationRef<DeleteNotificationData, DeleteNotificationVariables>;
}
export const deleteNotificationRef: DeleteNotificationRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
deleteNotification(dc: DataConnect, vars: DeleteNotificationVariables): MutationPromise<DeleteNotificationData, DeleteNotificationVariables>;

interface DeleteNotificationRef {
  ...
  (dc: DataConnect, vars: DeleteNotificationVariables): MutationRef<DeleteNotificationData, DeleteNotificationVariables>;
}
export const deleteNotificationRef: DeleteNotificationRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the deleteNotificationRef:
```typescript
const name = deleteNotificationRef.operationName;
console.log(name);
```

### Variables
The `DeleteNotification` mutation requires an argument of type `DeleteNotificationVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface DeleteNotificationVariables {
  id: UUIDString;
}
```
### Return Type
Recall that executing the `DeleteNotification` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `DeleteNotificationData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface DeleteNotificationData {
  notification_delete?: Notification_Key | null;
}
```
### Using `DeleteNotification`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, deleteNotification, DeleteNotificationVariables } from '@dataconnect/generated';

// The `DeleteNotification` mutation requires an argument of type `DeleteNotificationVariables`:
const deleteNotificationVars: DeleteNotificationVariables = {
  id: ..., 
};

// Call the `deleteNotification()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await deleteNotification(deleteNotificationVars);
// Variables can be defined inline as well.
const { data } = await deleteNotification({ id: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await deleteNotification(dataConnect, deleteNotificationVars);

console.log(data.notification_delete);

// Or, you can use the `Promise` API.
deleteNotification(deleteNotificationVars).then((response) => {
  const data = response.data;
  console.log(data.notification_delete);
});
```

### Using `DeleteNotification`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, deleteNotificationRef, DeleteNotificationVariables } from '@dataconnect/generated';

// The `DeleteNotification` mutation requires an argument of type `DeleteNotificationVariables`:
const deleteNotificationVars: DeleteNotificationVariables = {
  id: ..., 
};

// Call the `deleteNotificationRef()` function to get a reference to the mutation.
const ref = deleteNotificationRef(deleteNotificationVars);
// Variables can be defined inline as well.
const ref = deleteNotificationRef({ id: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = deleteNotificationRef(dataConnect, deleteNotificationVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.notification_delete);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.notification_delete);
});
```

