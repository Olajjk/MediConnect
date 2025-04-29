import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;

class PushNotification {
  String? _fcmToken;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  PushNotification(String? fcmToken) {
    this._fcmToken = fcmToken;
    _initializeNotifications();
    _requestPermission();
    //_getFCMToken();
    _initFirebaseListeners();
  }

  //Initialisation des notifications locales
  void _initializeNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/logo');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Demande la permission pour recevoir des notifications
  void _requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("Permission accordée");
    } else {
      print("Permission refusée");
    }
  }

  // Récupération du token FCM
  void _getFCMToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      _fcmToken = token;
      print("Token FCM : $token");
    } else {
      print("Impossible de récupérer le token !");
    }
  }

  // Écoute les notifications entrantes
  void _initFirebaseListeners() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print(
        "Notification reçue en foreground : ${message.notification?.title}",
      );
      _showForegroundNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Notification ouverte : ${message.data}");
      _handleNotificationClick(message);
    });

    FirebaseMessaging.instance.getInitialMessage().then((
      RemoteMessage? message,
    ) {
      if (message != null) {
        print("Notification reçue en mode terminé : ${message.data}");
        _handleNotificationClick(message);
      }
    });
  }

  // Afficher une notification locale
  void _showForegroundNotification(RemoteMessage message) {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@drawable/logo',
        );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    _flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title ?? "Titre inconnu",
      message.notification?.body ?? "Contenu inconnu",
      platformDetails,
    );
  }

  void _handleNotificationClick(RemoteMessage message) {
    /*
    * On va gérer le click sur la notification ici
    * */
  }

  // Envoyer une notification FCM
  Future<void> sendNotification(String title, String body) async {
    if (_fcmToken == null) {
      print("Aucun token FCM disponible !");
      return;
    }

    String accessToken = await _getAccessToken();
    String url =
        'https://fcm.googleapis.com/v1/projects/bmfp-7813f/messages:send';

    Map<String, dynamic> message = {
      "message": {
        "token": _fcmToken,
        "notification": {"title": title, "body": body},
        //"data": {"rendezvousId": idRendezvous},
        "android": {"priority": "high"},
      },
    };

    final response = await http.post(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $accessToken",
      },
      body: jsonEncode(message),
    );

    if (response.statusCode == 200) {
      print("Notification envoyée !");
    } else {
      print("Erreur (${response.statusCode}) : ${response.body}");
    }
  }

  // Obtenir un token d'accès Firebase
  Future<String> _getAccessToken() async {
    final serviceAccountJson = jsonDecode(
      await rootBundle.loadString('assets/keys/bmfp-7813f-221ca7dac7cb.json'),
    );

    List<String> scopes = [
      "https://www.googleapis.com/auth/firebase.messaging",
    ];
    final credentials = auth.ServiceAccountCredentials.fromJson(
      serviceAccountJson,
    );
    final client = await auth.clientViaServiceAccount(credentials, scopes);
    final accessCredentials = await auth
        .obtainAccessCredentialsViaServiceAccount(credentials, scopes, client);

    client.close();
    return accessCredentials.accessToken.data;
  }
}
