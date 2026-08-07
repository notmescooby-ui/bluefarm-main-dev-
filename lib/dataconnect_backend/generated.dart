library dataconnect_generated;
import 'package:firebase_data_connect/firebase_data_connect.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

part 'create_user.dart';

part 'update_user.dart';

part 'delete_user.dart';

part 'get_current_user.dart';

part 'list_users.dart';

part 'create_pond.dart';

part 'update_pond.dart';

part 'delete_pond.dart';

part 'get_pond.dart';

part 'list_my_ponds.dart';

part 'create_sensor_reading.dart';

part 'update_sensor_reading.dart';

part 'delete_sensor_reading.dart';

part 'get_sensor_reading.dart';

part 'list_pond_readings.dart';

part 'create_recommendation.dart';

part 'update_recommendation.dart';

part 'delete_recommendation.dart';

part 'get_recommendation.dart';

part 'list_recommendations.dart';

part 'create_listing.dart';

part 'update_listing.dart';

part 'delete_listing.dart';

part 'get_listing.dart';

part 'list_available_listings.dart';

part 'create_order.dart';

part 'update_order.dart';

part 'delete_order.dart';

part 'get_order.dart';

part 'list_my_orders.dart';

part 'create_notification.dart';

part 'mark_notification_read.dart';

part 'delete_notification.dart';

part 'get_notification.dart';

part 'list_my_notifications.dart';







class ExampleConnector {
  
  
  CreateUserVariablesBuilder createUser () {
    return CreateUserVariablesBuilder(dataConnect, );
  }
  
  
  UpdateUserVariablesBuilder updateUser ({required String displayName, }) {
    return UpdateUserVariablesBuilder(dataConnect, displayName: displayName,);
  }
  
  
  DeleteUserVariablesBuilder deleteUser () {
    return DeleteUserVariablesBuilder(dataConnect, );
  }
  
  
  GetCurrentUserVariablesBuilder getCurrentUser () {
    return GetCurrentUserVariablesBuilder(dataConnect, );
  }
  
  
  ListUsersVariablesBuilder listUsers () {
    return ListUsersVariablesBuilder(dataConnect, );
  }
  
  
  CreatePondVariablesBuilder createPond ({required String name, required String location, }) {
    return CreatePondVariablesBuilder(dataConnect, name: name,location: location,);
  }
  
  
  UpdatePondVariablesBuilder updatePond ({required String id, }) {
    return UpdatePondVariablesBuilder(dataConnect, id: id,);
  }
  
  
  DeletePondVariablesBuilder deletePond ({required String id, }) {
    return DeletePondVariablesBuilder(dataConnect, id: id,);
  }
  
  
  GetPondVariablesBuilder getPond ({required String id, }) {
    return GetPondVariablesBuilder(dataConnect, id: id,);
  }
  
  
  ListMyPondsVariablesBuilder listMyPonds () {
    return ListMyPondsVariablesBuilder(dataConnect, );
  }
  
  
  CreateSensorReadingVariablesBuilder createSensorReading ({required String pondId, required double ph, required double temp, required double turb, required double dissolvedOxygen, required double nh3, }) {
    return CreateSensorReadingVariablesBuilder(dataConnect, pondId: pondId,ph: ph,temp: temp,turb: turb,dissolvedOxygen: dissolvedOxygen,nh3: nh3,);
  }
  
  
  UpdateSensorReadingVariablesBuilder updateSensorReading ({required String id, required double ph, }) {
    return UpdateSensorReadingVariablesBuilder(dataConnect, id: id,ph: ph,);
  }
  
  
  DeleteSensorReadingVariablesBuilder deleteSensorReading ({required String id, }) {
    return DeleteSensorReadingVariablesBuilder(dataConnect, id: id,);
  }
  
  
  GetSensorReadingVariablesBuilder getSensorReading ({required String id, }) {
    return GetSensorReadingVariablesBuilder(dataConnect, id: id,);
  }
  
  
  ListPondReadingsVariablesBuilder listPondReadings ({required String pondId, }) {
    return ListPondReadingsVariablesBuilder(dataConnect, pondId: pondId,);
  }
  
  
  CreateRecommendationVariablesBuilder createRecommendation ({required String pondId, required String message, required String priority, }) {
    return CreateRecommendationVariablesBuilder(dataConnect, pondId: pondId,message: message,priority: priority,);
  }
  
  
  UpdateRecommendationVariablesBuilder updateRecommendation ({required String id, required String priority, }) {
    return UpdateRecommendationVariablesBuilder(dataConnect, id: id,priority: priority,);
  }
  
  
  DeleteRecommendationVariablesBuilder deleteRecommendation ({required String id, }) {
    return DeleteRecommendationVariablesBuilder(dataConnect, id: id,);
  }
  
  
  GetRecommendationVariablesBuilder getRecommendation ({required String id, }) {
    return GetRecommendationVariablesBuilder(dataConnect, id: id,);
  }
  
  
  ListRecommendationsVariablesBuilder listRecommendations () {
    return ListRecommendationsVariablesBuilder(dataConnect, );
  }
  
  
  CreateListingVariablesBuilder createListing ({required String species, required int quantity, required double price, }) {
    return CreateListingVariablesBuilder(dataConnect, species: species,quantity: quantity,price: price,);
  }
  
  
  UpdateListingVariablesBuilder updateListing ({required String id, required String status, }) {
    return UpdateListingVariablesBuilder(dataConnect, id: id,status: status,);
  }
  
  
  DeleteListingVariablesBuilder deleteListing ({required String id, }) {
    return DeleteListingVariablesBuilder(dataConnect, id: id,);
  }
  
  
  GetListingVariablesBuilder getListing ({required String id, }) {
    return GetListingVariablesBuilder(dataConnect, id: id,);
  }
  
  
  ListAvailableListingsVariablesBuilder listAvailableListings () {
    return ListAvailableListingsVariablesBuilder(dataConnect, );
  }
  
  
  CreateOrderVariablesBuilder createOrder ({required String listingId, required int quantity, required double total, }) {
    return CreateOrderVariablesBuilder(dataConnect, listingId: listingId,quantity: quantity,total: total,);
  }
  
  
  UpdateOrderVariablesBuilder updateOrder ({required String id, required String status, }) {
    return UpdateOrderVariablesBuilder(dataConnect, id: id,status: status,);
  }
  
  
  DeleteOrderVariablesBuilder deleteOrder ({required String id, }) {
    return DeleteOrderVariablesBuilder(dataConnect, id: id,);
  }
  
  
  GetOrderVariablesBuilder getOrder ({required String id, }) {
    return GetOrderVariablesBuilder(dataConnect, id: id,);
  }
  
  
  ListMyOrdersVariablesBuilder listMyOrders () {
    return ListMyOrdersVariablesBuilder(dataConnect, );
  }
  
  
  CreateNotificationVariablesBuilder createNotification ({required String userId, required String message, }) {
    return CreateNotificationVariablesBuilder(dataConnect, userId: userId,message: message,);
  }
  
  
  MarkNotificationReadVariablesBuilder markNotificationRead ({required String id, }) {
    return MarkNotificationReadVariablesBuilder(dataConnect, id: id,);
  }
  
  
  DeleteNotificationVariablesBuilder deleteNotification ({required String id, }) {
    return DeleteNotificationVariablesBuilder(dataConnect, id: id,);
  }
  
  
  GetNotificationVariablesBuilder getNotification ({required String id, }) {
    return GetNotificationVariablesBuilder(dataConnect, id: id,);
  }
  
  
  ListMyNotificationsVariablesBuilder listMyNotifications () {
    return ListMyNotificationsVariablesBuilder(dataConnect, );
  }
  

  static ConnectorConfig connectorConfig = ConnectorConfig(
    'asia-south1',
    'example',
    'bluefarm-main',
  );

  ExampleConnector({required this.dataConnect});
  static ExampleConnector get instance {
    
    CacheSettings cacheSettings = CacheSettings(
      maxAge: const Duration(milliseconds:0),
      storage: CacheStorage.persistent,
    );
    
    return ExampleConnector(
        dataConnect: FirebaseDataConnect.instanceFor(
            connectorConfig: connectorConfig,
            
            cacheSettings: cacheSettings,
            
            sdkType: CallerSDKType.generated));
  }

  FirebaseDataConnect dataConnect;
}
