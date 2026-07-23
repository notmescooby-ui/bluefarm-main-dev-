import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as fba;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Exceptions matching Supabase APIs
class PostgrestException implements Exception {
  final String message;
  PostgrestException(this.message);
  @override
  String toString() => 'PostgrestException: $message';
}

class AuthApiException implements Exception {
  final String message;
  AuthApiException(this.message);
  @override
  String toString() => 'AuthApiException: $message';
}

// Types and Enums matching Supabase APIs
enum OAuthProvider { google }
enum LaunchMode { platformDefault }
enum OtpType { sms }
enum AuthChangeEvent {
  signedIn,
  signedOut,
  mfaChallengeVerified,
  userUpdated,
  tokenRefreshed,
  passwordRecovery
}

class User {
  final String id;
  final String? email;
  final String? phone;
  final Map<String, dynamic> userMetadata;

  User({
    required this.id,
    this.email,
    this.phone,
    this.userMetadata = const {},
  });

  factory User.fromFirebase(fba.User user) {
    return User(
      id: user.uid,
      email: user.email,
      phone: user.phoneNumber,
      userMetadata: {
        'full_name': user.displayName,
      },
    );
  }
}

class Session {
  final User user;
  Session({required this.user});
}

class AuthResponse {
  final User? user;
  final Session? session;
  AuthResponse({this.user, this.session});
}

class AuthState {
  final AuthChangeEvent event;
  final Session? session;
  AuthState(this.event, this.session);
}

class GoTrueClient {
  final fba.FirebaseAuth _auth = fba.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser =>
      _auth.currentUser != null ? User.fromFirebase(_auth.currentUser!) : null;

  String? _lastVerificationId;

  Stream<AuthState> get onAuthStateChange {
    return _auth.authStateChanges().map((fbaUser) {
      if (fbaUser != null) {
        final session = Session(user: User.fromFirebase(fbaUser));
        return AuthState(AuthChangeEvent.signedIn, session);
      } else {
        return AuthState(AuthChangeEvent.signedOut, null);
      }
    });
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    await _auth.signOut();
  }

  Future<void> signInWithOAuth(
    OAuthProvider provider, {
    String? redirectTo,
    LaunchMode authScreenLaunchMode = LaunchMode.platformDefault,
  }) async {
    if (provider == OAuthProvider.google) {
      final googleUser = await _googleSignIn.signIn();
      final googleAuth = await googleUser?.authentication;
      if (googleAuth != null) {
        final credential = fba.GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await _auth.signInWithCredential(credential);
      }
    } else {
      throw UnimplementedError('Auth provider $provider is not implemented.');
    }
  }

  Future<void> signInWithOtp({required String phone}) async {
    final completer = Completer<void>();
    await _auth.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (fba.PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (fba.FirebaseAuthException e) {
        completer.completeError(
            AuthApiException(e.message ?? 'Phone authentication failed.'));
      },
      codeSent: (String verificationId, int? resendToken) {
        _lastVerificationId = verificationId;
        completer.complete();
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _lastVerificationId = verificationId;
      },
    );
    return completer.future;
  }

  Future<AuthResponse> verifyOTP({
    required String phone,
    required String token,
    required OtpType type,
  }) async {
    if (_lastVerificationId == null) {
      throw AuthApiException('No active verification session found.');
    }
    final credential = fba.PhoneAuthProvider.credential(
      verificationId: _lastVerificationId!,
      smsCode: token,
    );
    final userCredential = await _auth.signInWithCredential(credential);
    if (userCredential.user == null) {
      throw AuthApiException('Verification failed: User is null.');
    }
    final user = User.fromFirebase(userCredential.user!);
    return AuthResponse(user: user, session: Session(user: user));
  }
}

class Supabase {
  static final Supabase instance = Supabase._();
  Supabase._();

  final client = SupabaseClient();

  static Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp();
    } catch (e) {
      debugPrint('Firebase initialization warning: $e');
    }
  }
}

class SupabaseClient {
  final auth = GoTrueClient();
  SupabaseQueryBuilder from(String table) => SupabaseQueryBuilder(table);
}

class SupabaseQueryBuilder {
  final String table;
  SupabaseQueryBuilder(this.table);

  PostgrestFilterBuilder select([String? columns]) {
    return PostgrestFilterBuilder(table, columns: columns);
  }

  PostgrestFilterBuilder insert(dynamic data) {
    return PostgrestFilterBuilder(table)..setInsertData(data);
  }

  PostgrestFilterBuilder update(Map<String, dynamic> data) {
    return PostgrestFilterBuilder(table)..setUpdateData(data);
  }

  PostgrestFilterBuilder delete() {
    return PostgrestFilterBuilder(table)..setDelete();
  }

  PostgrestFilterBuilder upsert(dynamic data) {
    return PostgrestFilterBuilder(table)..setUpsertData(data);
  }

  SupabaseStreamBuilder stream({required List<String> primaryKey}) {
    return SupabaseStreamBuilder(table);
  }
}

enum QueryFilterType { eq, gte }

class QueryFilter {
  final String field;
  final dynamic value;
  final QueryFilterType type;
  QueryFilter(this.field, this.value, this.type);
}

class SupabaseStreamBuilder extends Stream<List<Map<String, dynamic>>> {
  final String _table;
  final List<QueryFilter> _filters = [];
  String? _orderByField;
  bool _ascending = true;
  int? _limitCount;

  SupabaseStreamBuilder(this._table);

  String get _mappedTable => _table == 'profiles'
      ? 'users'
      : (_table == 'listings' ? 'harvest_listings' : _table);

  SupabaseStreamBuilder eq(String column, dynamic value) {
    _filters.add(QueryFilter(column, value, QueryFilterType.eq));
    return this;
  }

  SupabaseStreamBuilder order(String column, {required bool ascending}) {
    _orderByField = column;
    _ascending = ascending;
    return this;
  }

  SupabaseStreamBuilder limit(int count) {
    _limitCount = count;
    return this;
  }

  Stream<List<Map<String, dynamic>>> _buildStream() {
    final firestore = FirebaseFirestore.instance;
    Query query = firestore.collection(_mappedTable);

    for (final filter in _filters) {
      if (filter.field == 'id') {
        if (filter.type == QueryFilterType.eq) {
          query = query.where(FieldPath.documentId, isEqualTo: filter.value);
        }
      } else {
        if (filter.type == QueryFilterType.eq) {
          query = query.where(filter.field, isEqualTo: filter.value);
        }
      }
    }

    if (_orderByField != null) {
      query = query.orderBy(_orderByField!, descending: !_ascending);
    }

    if (_limitCount != null) {
      query = query.limit(_limitCount!);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['id'] == null) {
          if (_table == 'sensor_readings') {
            data['id'] = doc.id.hashCode;
          } else {
            data['id'] = doc.id;
          }
        }
        return data;
      }).toList();
    });
  }

  @override
  StreamSubscription<List<Map<String, dynamic>>> listen(
    void Function(List<Map<String, dynamic>> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return _buildStream().listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}

class PostgrestFilterBuilder implements Future<dynamic> {
  final String _table;
  final String? _columns;

  final List<QueryFilter> _filters = [];
  String? _orderByField;
  bool _ascending = true;
  int? _limitCount;

  List<Map<String, dynamic>>? _insertData;
  Map<String, dynamic>? _updateData;
  bool _isUpsert = false;
  bool _isDelete = false;

  PostgrestFilterBuilder(this._table, {String? columns}) : _columns = columns;

  String get _mappedTable => _table == 'profiles'
      ? 'users'
      : (_table == 'listings' ? 'harvest_listings' : _table);

  PostgrestFilterBuilder select([String? columns]) {
    return this;
  }

  PostgrestFilterBuilder eq(String column, dynamic value) {
    _filters.add(QueryFilter(column, value, QueryFilterType.eq));
    return this;
  }

  PostgrestFilterBuilder gte(String column, dynamic value) {
    _filters.add(QueryFilter(column, value, QueryFilterType.gte));
    return this;
  }

  PostgrestFilterBuilder order(String column, {required bool ascending}) {
    _orderByField = column;
    _ascending = ascending;
    return this;
  }

  PostgrestFilterBuilder limit(int count) {
    _limitCount = count;
    return this;
  }

  void setInsertData(dynamic data) {
    if (data is List) {
      _insertData = List<Map<String, dynamic>>.from(data);
    } else if (data is Map) {
      _insertData = [Map<String, dynamic>.from(data)];
    }
  }

  void setUpdateData(Map<String, dynamic> data) {
    _updateData = data;
  }

  void setUpsertData(dynamic data) {
    _isUpsert = true;
    setInsertData(data);
  }

  void setDelete() {
    _isDelete = true;
  }

  Future<dynamic> _future() => _execute();

  @override
  Stream<dynamic> asStream() => _future().asStream();

  @override
  Future<dynamic> catchError(Function onError, {bool Function(Object error)? test}) =>
      _future().catchError(onError, test: test);

  @override
  Future<R> then<R>(FutureOr<R> Function(dynamic value) onValue, {Function? onError}) =>
      _future().then<R>(onValue, onError: onError);

  @override
  Future<dynamic> timeout(Duration timeLimit, {FutureOr<dynamic> Function()? onTimeout}) =>
      _future().timeout(timeLimit, onTimeout: onTimeout);

  @override
  Future<dynamic> whenComplete(FutureOr<void> Function() action) =>
      _future().whenComplete(action);

  Future<Map<String, dynamic>?> maybeSingle() async {
    final result = await _execute();
    if (result is List) {
      return result.isNotEmpty ? result.first : null;
    } else if (result is Map<String, dynamic>) {
      return result;
    }
    return null;
  }

  Future<Map<String, dynamic>> single() async {
    final result = await _execute();
    if (result is List) {
      if (result.isNotEmpty) return result.first;
      throw StateError('No documents found matching the query.');
    } else if (result is Map<String, dynamic>) {
      return result;
    }
    throw StateError('No documents found matching the query.');
  }

  Future<dynamic> _execute() async {
    final firestore = FirebaseFirestore.instance;

    // 1. DELETE
    if (_isDelete) {
      final querySnapshot = await _buildQuery(firestore).get();
      final batch = firestore.batch();
      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      return [];
    }

    // 2. UPDATE
    if (_updateData != null) {
      final querySnapshot = await _buildQuery(firestore).get();
      final batch = firestore.batch();
      for (final doc in querySnapshot.docs) {
        batch.update(doc.reference, _updateData!);
      }
      await batch.commit();
      return querySnapshot.docs.map((doc) {
        final currentData = doc.data() as Map<String, dynamic>;
        if (currentData['id'] == null) {
          currentData['id'] = doc.id;
        }
        return {...currentData, ..._updateData!};
      }).toList();
    }

    // 3. INSERT / UPSERT
    if (_insertData != null) {
      final list = <Map<String, dynamic>>[];
      for (final item in _insertData!) {
        String? docId;
        if (_table == 'profiles' && item['id'] != null) {
          docId = item['id'].toString();
        } else if (item['id'] != null &&
            _table != 'sensor_readings' &&
            item['id'] is String) {
          docId = item['id'].toString();
        } else if (_table == 'device_status' && item['device_id'] != null) {
          docId = item['device_id'].toString();
        }

        final docRef = docId != null
            ? firestore.collection(_mappedTable).doc(docId)
            : firestore.collection(_mappedTable).doc();

        final data = Map<String, dynamic>.from(item);
        if (data['id'] == null) {
          if (_table == 'sensor_readings') {
            data['id'] = docRef.id.hashCode;
          } else {
            data['id'] = docRef.id;
          }
        }

        if (_isUpsert) {
          await docRef.set(data, SetOptions(merge: true));
        } else {
          await docRef.set(data);
        }
        list.add(data);
      }
      return list;
    }

    // 4. SELECT (READ)
    final querySnapshot = await _buildQuery(firestore).get();
    var results = querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['id'] == null) {
        if (_table == 'sensor_readings') {
          data['id'] = doc.id.hashCode;
        } else {
          data['id'] = doc.id;
        }
      }
      return data;
    }).toList();

    // Support profile joins: select('*, profiles(...)')
    if (_columns != null && _columns!.contains('profiles')) {
      final userIds = results
          .map((item) => item['farmer_id'] as String?)
          .whereType<String>()
          .toSet();
      final profilesMap = <String, Map<String, dynamic>>{};
      for (final uid in userIds) {
        final profDoc = await firestore.collection('users').doc(uid).get();
        if (profDoc.exists) {
          final pData = profDoc.data()!;
          pData['id'] = uid;
          profilesMap[uid] = pData;
        }
      }
      results = results.map((item) {
        final farmerId = item['farmer_id'] as String?;
        if (farmerId != null && profilesMap.containsKey(farmerId)) {
          return {
            ...item,
            'profiles': profilesMap[farmerId],
          };
        }
        return item;
      }).toList();
    }

    return results;
  }

  Query _buildQuery(FirebaseFirestore firestore) {
    Query query = firestore.collection(_mappedTable);

    for (final filter in _filters) {
      if (filter.field == 'id') {
        if (filter.type == QueryFilterType.eq) {
          query = query.where(FieldPath.documentId, isEqualTo: filter.value);
        }
      } else {
        if (filter.type == QueryFilterType.eq) {
          query = query.where(filter.field, isEqualTo: filter.value);
        } else if (filter.type == QueryFilterType.gte) {
          query = query.where(filter.field, isGreaterThanOrEqualTo: filter.value);
        }
      }
    }

    if (_orderByField != null) {
      query = query.orderBy(_orderByField!, descending: !_ascending);
    }

    if (_limitCount != null) {
      query = query.limit(_limitCount!);
    }

    return query;
  }
}
