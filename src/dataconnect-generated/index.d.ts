import { ConnectorConfig, DataConnect, QueryRef, QueryPromise, ExecuteQueryOptions, MutationRef, MutationPromise, DataConnectSettings } from 'firebase/data-connect';

export const connectorConfig: ConnectorConfig;
export const dataConnectSettings: DataConnectSettings;

export type TimestampString = string;
export type UUIDString = string;
export type Int64String = string;
export type DateString = string;




export interface CreateListingData {
  harvestListing_insert: HarvestListing_Key;
}

export interface CreateListingVariables {
  species: string;
  quantity: number;
  price: number;
}

export interface CreateNotificationData {
  notification_insert: Notification_Key;
}

export interface CreateNotificationVariables {
  userId: UUIDString;
  message: string;
}

export interface CreateOrderData {
  order_insert: Order_Key;
}

export interface CreateOrderVariables {
  listingId: UUIDString;
  quantity: number;
  total: number;
}

export interface CreatePondData {
  pond_insert: Pond_Key;
}

export interface CreatePondVariables {
  name: string;
  location: string;
  capacity?: number | null;
}

export interface CreateRecommendationData {
  smartRecommendation_insert: SmartRecommendation_Key;
}

export interface CreateRecommendationVariables {
  pondId: UUIDString;
  message: string;
  priority: string;
}

export interface CreateSensorReadingData {
  sensorReading_insert: SensorReading_Key;
}

export interface CreateSensorReadingVariables {
  pondId: UUIDString;
  ph: number;
  temp: number;
  turb: number;
  dissolvedOxygen: number;
  nh3: number;
}

export interface CreateUserData {
  user_insert: User_Key;
}

export interface DeleteListingData {
  harvestListing_delete?: HarvestListing_Key | null;
}

export interface DeleteListingVariables {
  id: UUIDString;
}

export interface DeleteNotificationData {
  notification_delete?: Notification_Key | null;
}

export interface DeleteNotificationVariables {
  id: UUIDString;
}

export interface DeleteOrderData {
  order_delete?: Order_Key | null;
}

export interface DeleteOrderVariables {
  id: UUIDString;
}

export interface DeletePondData {
  pond_delete?: Pond_Key | null;
}

export interface DeletePondVariables {
  id: UUIDString;
}

export interface DeleteRecommendationData {
  smartRecommendation_delete?: SmartRecommendation_Key | null;
}

export interface DeleteRecommendationVariables {
  id: UUIDString;
}

export interface DeleteSensorReadingData {
  sensorReading_delete?: SensorReading_Key | null;
}

export interface DeleteSensorReadingVariables {
  id: UUIDString;
}

export interface DeleteUserData {
  user_delete?: User_Key | null;
}

export interface GetCurrentUserData {
  user?: {
    email: string;
    displayName?: string | null;
    role: string;
  };
}

export interface GetListingData {
  harvestListing?: {
    species: string;
    pricePerUnit: number;
  };
}

export interface GetListingVariables {
  id: UUIDString;
}

export interface GetNotificationData {
  notification?: {
    message: string;
    isRead: boolean;
  };
}

export interface GetNotificationVariables {
  id: UUIDString;
}

export interface GetOrderData {
  order?: {
    status: string;
    totalAmount: number;
  };
}

export interface GetOrderVariables {
  id: UUIDString;
}

export interface GetPondData {
  pond?: {
    name: string;
    location: string;
    capacity?: number | null;
  };
}

export interface GetPondVariables {
  id: UUIDString;
}

export interface GetRecommendationData {
  smartRecommendation?: {
    message: string;
    priority: string;
  };
}

export interface GetRecommendationVariables {
  id: UUIDString;
}

export interface GetSensorReadingData {
  sensorReading?: {
    ph: number;
    temperature: number;
  };
}

export interface GetSensorReadingVariables {
  id: UUIDString;
}

export interface HarvestListing_Key {
  id: UUIDString;
  __typename?: 'HarvestListing_Key';
}

export interface ListAvailableListingsData {
  harvestListings: ({
    species: string;
    pricePerUnit: number;
  })[];
}

export interface ListMyNotificationsData {
  notifications: ({
    message: string;
    isRead: boolean;
  })[];
}

export interface ListMyOrdersData {
  orders: ({
    listing: {
      species: string;
    };
    status: string;
  })[];
}

export interface ListMyPondsData {
  ponds: ({
    name: string;
    location: string;
  })[];
}

export interface ListPondReadingsData {
  sensorReadings: ({
    timestamp: TimestampString;
    ph: number;
    temperature: number;
  })[];
}

export interface ListPondReadingsVariables {
  pondId: UUIDString;
}

export interface ListRecommendationsData {
  smartRecommendations: ({
    message: string;
    priority: string;
  })[];
}

export interface ListUsersData {
  users: ({
    displayName?: string | null;
    role: string;
  })[];
}

export interface MarkNotificationReadData {
  notification_update?: Notification_Key | null;
}

export interface MarkNotificationReadVariables {
  id: UUIDString;
}

export interface Notification_Key {
  id: UUIDString;
  __typename?: 'Notification_Key';
}

export interface Order_Key {
  id: UUIDString;
  __typename?: 'Order_Key';
}

export interface Pond_Key {
  id: UUIDString;
  __typename?: 'Pond_Key';
}

export interface SensorReading_Key {
  id: UUIDString;
  __typename?: 'SensorReading_Key';
}

export interface SmartRecommendation_Key {
  id: UUIDString;
  __typename?: 'SmartRecommendation_Key';
}

export interface UpdateListingData {
  harvestListing_update?: HarvestListing_Key | null;
}

export interface UpdateListingVariables {
  id: UUIDString;
  status: string;
}

export interface UpdateOrderData {
  order_update?: Order_Key | null;
}

export interface UpdateOrderVariables {
  id: UUIDString;
  status: string;
}

export interface UpdatePondData {
  pond_update?: Pond_Key | null;
}

export interface UpdatePondVariables {
  id: UUIDString;
  capacity?: number | null;
}

export interface UpdateRecommendationData {
  smartRecommendation_update?: SmartRecommendation_Key | null;
}

export interface UpdateRecommendationVariables {
  id: UUIDString;
  priority: string;
}

export interface UpdateSensorReadingData {
  sensorReading_update?: SensorReading_Key | null;
}

export interface UpdateSensorReadingVariables {
  id: UUIDString;
  ph: number;
}

export interface UpdateUserData {
  user_update?: User_Key | null;
}

export interface UpdateUserVariables {
  displayName: string;
}

export interface User_Key {
  id: UUIDString;
  __typename?: 'User_Key';
}

interface CreateUserRef {
  /* Allow users to create refs without passing in DataConnect */
  (): MutationRef<CreateUserData, undefined>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect): MutationRef<CreateUserData, undefined>;
  operationName: string;
}
export const createUserRef: CreateUserRef;

export function createUser(): MutationPromise<CreateUserData, undefined>;
export function createUser(dc: DataConnect): MutationPromise<CreateUserData, undefined>;

interface UpdateUserRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: UpdateUserVariables): MutationRef<UpdateUserData, UpdateUserVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: UpdateUserVariables): MutationRef<UpdateUserData, UpdateUserVariables>;
  operationName: string;
}
export const updateUserRef: UpdateUserRef;

export function updateUser(vars: UpdateUserVariables): MutationPromise<UpdateUserData, UpdateUserVariables>;
export function updateUser(dc: DataConnect, vars: UpdateUserVariables): MutationPromise<UpdateUserData, UpdateUserVariables>;

interface DeleteUserRef {
  /* Allow users to create refs without passing in DataConnect */
  (): MutationRef<DeleteUserData, undefined>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect): MutationRef<DeleteUserData, undefined>;
  operationName: string;
}
export const deleteUserRef: DeleteUserRef;

export function deleteUser(): MutationPromise<DeleteUserData, undefined>;
export function deleteUser(dc: DataConnect): MutationPromise<DeleteUserData, undefined>;

interface GetCurrentUserRef {
  /* Allow users to create refs without passing in DataConnect */
  (): QueryRef<GetCurrentUserData, undefined>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect): QueryRef<GetCurrentUserData, undefined>;
  operationName: string;
}
export const getCurrentUserRef: GetCurrentUserRef;

export function getCurrentUser(options?: ExecuteQueryOptions): QueryPromise<GetCurrentUserData, undefined>;
export function getCurrentUser(dc: DataConnect, options?: ExecuteQueryOptions): QueryPromise<GetCurrentUserData, undefined>;

interface ListUsersRef {
  /* Allow users to create refs without passing in DataConnect */
  (): QueryRef<ListUsersData, undefined>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect): QueryRef<ListUsersData, undefined>;
  operationName: string;
}
export const listUsersRef: ListUsersRef;

export function listUsers(options?: ExecuteQueryOptions): QueryPromise<ListUsersData, undefined>;
export function listUsers(dc: DataConnect, options?: ExecuteQueryOptions): QueryPromise<ListUsersData, undefined>;

interface CreatePondRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: CreatePondVariables): MutationRef<CreatePondData, CreatePondVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: CreatePondVariables): MutationRef<CreatePondData, CreatePondVariables>;
  operationName: string;
}
export const createPondRef: CreatePondRef;

export function createPond(vars: CreatePondVariables): MutationPromise<CreatePondData, CreatePondVariables>;
export function createPond(dc: DataConnect, vars: CreatePondVariables): MutationPromise<CreatePondData, CreatePondVariables>;

interface UpdatePondRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: UpdatePondVariables): MutationRef<UpdatePondData, UpdatePondVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: UpdatePondVariables): MutationRef<UpdatePondData, UpdatePondVariables>;
  operationName: string;
}
export const updatePondRef: UpdatePondRef;

export function updatePond(vars: UpdatePondVariables): MutationPromise<UpdatePondData, UpdatePondVariables>;
export function updatePond(dc: DataConnect, vars: UpdatePondVariables): MutationPromise<UpdatePondData, UpdatePondVariables>;

interface DeletePondRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: DeletePondVariables): MutationRef<DeletePondData, DeletePondVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: DeletePondVariables): MutationRef<DeletePondData, DeletePondVariables>;
  operationName: string;
}
export const deletePondRef: DeletePondRef;

export function deletePond(vars: DeletePondVariables): MutationPromise<DeletePondData, DeletePondVariables>;
export function deletePond(dc: DataConnect, vars: DeletePondVariables): MutationPromise<DeletePondData, DeletePondVariables>;

interface GetPondRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetPondVariables): QueryRef<GetPondData, GetPondVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: GetPondVariables): QueryRef<GetPondData, GetPondVariables>;
  operationName: string;
}
export const getPondRef: GetPondRef;

export function getPond(vars: GetPondVariables, options?: ExecuteQueryOptions): QueryPromise<GetPondData, GetPondVariables>;
export function getPond(dc: DataConnect, vars: GetPondVariables, options?: ExecuteQueryOptions): QueryPromise<GetPondData, GetPondVariables>;

interface ListMyPondsRef {
  /* Allow users to create refs without passing in DataConnect */
  (): QueryRef<ListMyPondsData, undefined>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect): QueryRef<ListMyPondsData, undefined>;
  operationName: string;
}
export const listMyPondsRef: ListMyPondsRef;

export function listMyPonds(options?: ExecuteQueryOptions): QueryPromise<ListMyPondsData, undefined>;
export function listMyPonds(dc: DataConnect, options?: ExecuteQueryOptions): QueryPromise<ListMyPondsData, undefined>;

interface CreateSensorReadingRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: CreateSensorReadingVariables): MutationRef<CreateSensorReadingData, CreateSensorReadingVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: CreateSensorReadingVariables): MutationRef<CreateSensorReadingData, CreateSensorReadingVariables>;
  operationName: string;
}
export const createSensorReadingRef: CreateSensorReadingRef;

export function createSensorReading(vars: CreateSensorReadingVariables): MutationPromise<CreateSensorReadingData, CreateSensorReadingVariables>;
export function createSensorReading(dc: DataConnect, vars: CreateSensorReadingVariables): MutationPromise<CreateSensorReadingData, CreateSensorReadingVariables>;

interface UpdateSensorReadingRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: UpdateSensorReadingVariables): MutationRef<UpdateSensorReadingData, UpdateSensorReadingVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: UpdateSensorReadingVariables): MutationRef<UpdateSensorReadingData, UpdateSensorReadingVariables>;
  operationName: string;
}
export const updateSensorReadingRef: UpdateSensorReadingRef;

export function updateSensorReading(vars: UpdateSensorReadingVariables): MutationPromise<UpdateSensorReadingData, UpdateSensorReadingVariables>;
export function updateSensorReading(dc: DataConnect, vars: UpdateSensorReadingVariables): MutationPromise<UpdateSensorReadingData, UpdateSensorReadingVariables>;

interface DeleteSensorReadingRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: DeleteSensorReadingVariables): MutationRef<DeleteSensorReadingData, DeleteSensorReadingVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: DeleteSensorReadingVariables): MutationRef<DeleteSensorReadingData, DeleteSensorReadingVariables>;
  operationName: string;
}
export const deleteSensorReadingRef: DeleteSensorReadingRef;

export function deleteSensorReading(vars: DeleteSensorReadingVariables): MutationPromise<DeleteSensorReadingData, DeleteSensorReadingVariables>;
export function deleteSensorReading(dc: DataConnect, vars: DeleteSensorReadingVariables): MutationPromise<DeleteSensorReadingData, DeleteSensorReadingVariables>;

interface GetSensorReadingRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetSensorReadingVariables): QueryRef<GetSensorReadingData, GetSensorReadingVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: GetSensorReadingVariables): QueryRef<GetSensorReadingData, GetSensorReadingVariables>;
  operationName: string;
}
export const getSensorReadingRef: GetSensorReadingRef;

export function getSensorReading(vars: GetSensorReadingVariables, options?: ExecuteQueryOptions): QueryPromise<GetSensorReadingData, GetSensorReadingVariables>;
export function getSensorReading(dc: DataConnect, vars: GetSensorReadingVariables, options?: ExecuteQueryOptions): QueryPromise<GetSensorReadingData, GetSensorReadingVariables>;

interface ListPondReadingsRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: ListPondReadingsVariables): QueryRef<ListPondReadingsData, ListPondReadingsVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: ListPondReadingsVariables): QueryRef<ListPondReadingsData, ListPondReadingsVariables>;
  operationName: string;
}
export const listPondReadingsRef: ListPondReadingsRef;

export function listPondReadings(vars: ListPondReadingsVariables, options?: ExecuteQueryOptions): QueryPromise<ListPondReadingsData, ListPondReadingsVariables>;
export function listPondReadings(dc: DataConnect, vars: ListPondReadingsVariables, options?: ExecuteQueryOptions): QueryPromise<ListPondReadingsData, ListPondReadingsVariables>;

interface CreateRecommendationRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: CreateRecommendationVariables): MutationRef<CreateRecommendationData, CreateRecommendationVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: CreateRecommendationVariables): MutationRef<CreateRecommendationData, CreateRecommendationVariables>;
  operationName: string;
}
export const createRecommendationRef: CreateRecommendationRef;

export function createRecommendation(vars: CreateRecommendationVariables): MutationPromise<CreateRecommendationData, CreateRecommendationVariables>;
export function createRecommendation(dc: DataConnect, vars: CreateRecommendationVariables): MutationPromise<CreateRecommendationData, CreateRecommendationVariables>;

interface UpdateRecommendationRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: UpdateRecommendationVariables): MutationRef<UpdateRecommendationData, UpdateRecommendationVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: UpdateRecommendationVariables): MutationRef<UpdateRecommendationData, UpdateRecommendationVariables>;
  operationName: string;
}
export const updateRecommendationRef: UpdateRecommendationRef;

export function updateRecommendation(vars: UpdateRecommendationVariables): MutationPromise<UpdateRecommendationData, UpdateRecommendationVariables>;
export function updateRecommendation(dc: DataConnect, vars: UpdateRecommendationVariables): MutationPromise<UpdateRecommendationData, UpdateRecommendationVariables>;

interface DeleteRecommendationRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: DeleteRecommendationVariables): MutationRef<DeleteRecommendationData, DeleteRecommendationVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: DeleteRecommendationVariables): MutationRef<DeleteRecommendationData, DeleteRecommendationVariables>;
  operationName: string;
}
export const deleteRecommendationRef: DeleteRecommendationRef;

export function deleteRecommendation(vars: DeleteRecommendationVariables): MutationPromise<DeleteRecommendationData, DeleteRecommendationVariables>;
export function deleteRecommendation(dc: DataConnect, vars: DeleteRecommendationVariables): MutationPromise<DeleteRecommendationData, DeleteRecommendationVariables>;

interface GetRecommendationRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetRecommendationVariables): QueryRef<GetRecommendationData, GetRecommendationVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: GetRecommendationVariables): QueryRef<GetRecommendationData, GetRecommendationVariables>;
  operationName: string;
}
export const getRecommendationRef: GetRecommendationRef;

export function getRecommendation(vars: GetRecommendationVariables, options?: ExecuteQueryOptions): QueryPromise<GetRecommendationData, GetRecommendationVariables>;
export function getRecommendation(dc: DataConnect, vars: GetRecommendationVariables, options?: ExecuteQueryOptions): QueryPromise<GetRecommendationData, GetRecommendationVariables>;

interface ListRecommendationsRef {
  /* Allow users to create refs without passing in DataConnect */
  (): QueryRef<ListRecommendationsData, undefined>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect): QueryRef<ListRecommendationsData, undefined>;
  operationName: string;
}
export const listRecommendationsRef: ListRecommendationsRef;

export function listRecommendations(options?: ExecuteQueryOptions): QueryPromise<ListRecommendationsData, undefined>;
export function listRecommendations(dc: DataConnect, options?: ExecuteQueryOptions): QueryPromise<ListRecommendationsData, undefined>;

interface CreateListingRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: CreateListingVariables): MutationRef<CreateListingData, CreateListingVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: CreateListingVariables): MutationRef<CreateListingData, CreateListingVariables>;
  operationName: string;
}
export const createListingRef: CreateListingRef;

export function createListing(vars: CreateListingVariables): MutationPromise<CreateListingData, CreateListingVariables>;
export function createListing(dc: DataConnect, vars: CreateListingVariables): MutationPromise<CreateListingData, CreateListingVariables>;

interface UpdateListingRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: UpdateListingVariables): MutationRef<UpdateListingData, UpdateListingVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: UpdateListingVariables): MutationRef<UpdateListingData, UpdateListingVariables>;
  operationName: string;
}
export const updateListingRef: UpdateListingRef;

export function updateListing(vars: UpdateListingVariables): MutationPromise<UpdateListingData, UpdateListingVariables>;
export function updateListing(dc: DataConnect, vars: UpdateListingVariables): MutationPromise<UpdateListingData, UpdateListingVariables>;

interface DeleteListingRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: DeleteListingVariables): MutationRef<DeleteListingData, DeleteListingVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: DeleteListingVariables): MutationRef<DeleteListingData, DeleteListingVariables>;
  operationName: string;
}
export const deleteListingRef: DeleteListingRef;

export function deleteListing(vars: DeleteListingVariables): MutationPromise<DeleteListingData, DeleteListingVariables>;
export function deleteListing(dc: DataConnect, vars: DeleteListingVariables): MutationPromise<DeleteListingData, DeleteListingVariables>;

interface GetListingRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetListingVariables): QueryRef<GetListingData, GetListingVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: GetListingVariables): QueryRef<GetListingData, GetListingVariables>;
  operationName: string;
}
export const getListingRef: GetListingRef;

export function getListing(vars: GetListingVariables, options?: ExecuteQueryOptions): QueryPromise<GetListingData, GetListingVariables>;
export function getListing(dc: DataConnect, vars: GetListingVariables, options?: ExecuteQueryOptions): QueryPromise<GetListingData, GetListingVariables>;

interface ListAvailableListingsRef {
  /* Allow users to create refs without passing in DataConnect */
  (): QueryRef<ListAvailableListingsData, undefined>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect): QueryRef<ListAvailableListingsData, undefined>;
  operationName: string;
}
export const listAvailableListingsRef: ListAvailableListingsRef;

export function listAvailableListings(options?: ExecuteQueryOptions): QueryPromise<ListAvailableListingsData, undefined>;
export function listAvailableListings(dc: DataConnect, options?: ExecuteQueryOptions): QueryPromise<ListAvailableListingsData, undefined>;

interface CreateOrderRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: CreateOrderVariables): MutationRef<CreateOrderData, CreateOrderVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: CreateOrderVariables): MutationRef<CreateOrderData, CreateOrderVariables>;
  operationName: string;
}
export const createOrderRef: CreateOrderRef;

export function createOrder(vars: CreateOrderVariables): MutationPromise<CreateOrderData, CreateOrderVariables>;
export function createOrder(dc: DataConnect, vars: CreateOrderVariables): MutationPromise<CreateOrderData, CreateOrderVariables>;

interface UpdateOrderRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: UpdateOrderVariables): MutationRef<UpdateOrderData, UpdateOrderVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: UpdateOrderVariables): MutationRef<UpdateOrderData, UpdateOrderVariables>;
  operationName: string;
}
export const updateOrderRef: UpdateOrderRef;

export function updateOrder(vars: UpdateOrderVariables): MutationPromise<UpdateOrderData, UpdateOrderVariables>;
export function updateOrder(dc: DataConnect, vars: UpdateOrderVariables): MutationPromise<UpdateOrderData, UpdateOrderVariables>;

interface DeleteOrderRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: DeleteOrderVariables): MutationRef<DeleteOrderData, DeleteOrderVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: DeleteOrderVariables): MutationRef<DeleteOrderData, DeleteOrderVariables>;
  operationName: string;
}
export const deleteOrderRef: DeleteOrderRef;

export function deleteOrder(vars: DeleteOrderVariables): MutationPromise<DeleteOrderData, DeleteOrderVariables>;
export function deleteOrder(dc: DataConnect, vars: DeleteOrderVariables): MutationPromise<DeleteOrderData, DeleteOrderVariables>;

interface GetOrderRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetOrderVariables): QueryRef<GetOrderData, GetOrderVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: GetOrderVariables): QueryRef<GetOrderData, GetOrderVariables>;
  operationName: string;
}
export const getOrderRef: GetOrderRef;

export function getOrder(vars: GetOrderVariables, options?: ExecuteQueryOptions): QueryPromise<GetOrderData, GetOrderVariables>;
export function getOrder(dc: DataConnect, vars: GetOrderVariables, options?: ExecuteQueryOptions): QueryPromise<GetOrderData, GetOrderVariables>;

interface ListMyOrdersRef {
  /* Allow users to create refs without passing in DataConnect */
  (): QueryRef<ListMyOrdersData, undefined>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect): QueryRef<ListMyOrdersData, undefined>;
  operationName: string;
}
export const listMyOrdersRef: ListMyOrdersRef;

export function listMyOrders(options?: ExecuteQueryOptions): QueryPromise<ListMyOrdersData, undefined>;
export function listMyOrders(dc: DataConnect, options?: ExecuteQueryOptions): QueryPromise<ListMyOrdersData, undefined>;

interface CreateNotificationRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: CreateNotificationVariables): MutationRef<CreateNotificationData, CreateNotificationVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: CreateNotificationVariables): MutationRef<CreateNotificationData, CreateNotificationVariables>;
  operationName: string;
}
export const createNotificationRef: CreateNotificationRef;

export function createNotification(vars: CreateNotificationVariables): MutationPromise<CreateNotificationData, CreateNotificationVariables>;
export function createNotification(dc: DataConnect, vars: CreateNotificationVariables): MutationPromise<CreateNotificationData, CreateNotificationVariables>;

interface MarkNotificationReadRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: MarkNotificationReadVariables): MutationRef<MarkNotificationReadData, MarkNotificationReadVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: MarkNotificationReadVariables): MutationRef<MarkNotificationReadData, MarkNotificationReadVariables>;
  operationName: string;
}
export const markNotificationReadRef: MarkNotificationReadRef;

export function markNotificationRead(vars: MarkNotificationReadVariables): MutationPromise<MarkNotificationReadData, MarkNotificationReadVariables>;
export function markNotificationRead(dc: DataConnect, vars: MarkNotificationReadVariables): MutationPromise<MarkNotificationReadData, MarkNotificationReadVariables>;

interface DeleteNotificationRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: DeleteNotificationVariables): MutationRef<DeleteNotificationData, DeleteNotificationVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: DeleteNotificationVariables): MutationRef<DeleteNotificationData, DeleteNotificationVariables>;
  operationName: string;
}
export const deleteNotificationRef: DeleteNotificationRef;

export function deleteNotification(vars: DeleteNotificationVariables): MutationPromise<DeleteNotificationData, DeleteNotificationVariables>;
export function deleteNotification(dc: DataConnect, vars: DeleteNotificationVariables): MutationPromise<DeleteNotificationData, DeleteNotificationVariables>;

interface GetNotificationRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetNotificationVariables): QueryRef<GetNotificationData, GetNotificationVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: GetNotificationVariables): QueryRef<GetNotificationData, GetNotificationVariables>;
  operationName: string;
}
export const getNotificationRef: GetNotificationRef;

export function getNotification(vars: GetNotificationVariables, options?: ExecuteQueryOptions): QueryPromise<GetNotificationData, GetNotificationVariables>;
export function getNotification(dc: DataConnect, vars: GetNotificationVariables, options?: ExecuteQueryOptions): QueryPromise<GetNotificationData, GetNotificationVariables>;

interface ListMyNotificationsRef {
  /* Allow users to create refs without passing in DataConnect */
  (): QueryRef<ListMyNotificationsData, undefined>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect): QueryRef<ListMyNotificationsData, undefined>;
  operationName: string;
}
export const listMyNotificationsRef: ListMyNotificationsRef;

export function listMyNotifications(options?: ExecuteQueryOptions): QueryPromise<ListMyNotificationsData, undefined>;
export function listMyNotifications(dc: DataConnect, options?: ExecuteQueryOptions): QueryPromise<ListMyNotificationsData, undefined>;

