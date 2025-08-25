import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/cultural_object_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'cultural_objects_feed_screen.dart';
import '../models/cultural_object.dart'; 

class RutasScreen extends StatefulWidget {
  @override
  _RutasScreenState createState() => _RutasScreenState();
}

class _RutasScreenState extends State<RutasScreen> {
  List<CulturalObject> _culturalObjects = [];
  final double proximityRadius = 100; // meters

  bool _isLoading = false;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
 flutterLocalNotificationsPlugin.initialize(initializationSettings,
 onSelectNotification: (String? payload) async {
 if (payload != null) {
 Navigator.push(context, MaterialPageRoute(builder: (context) => CulturalObjectsFeedScreen()));
 }
      },
 );
  }

  Future<void> _loadCulturalObjects() async {
    setState(() {
      _isLoading = true;
    });
    _culturalObjects = await CulturalObjectService().fetchCulturalObjects();
    setState(() {
      _isLoading = false;
    });
  }

  void _checkProximity() async {
    print('Checking proximity...');
    _determinePosition().then((Position? position) {
      if (position != null) {
        for (var culturalObject in _culturalObjects) {
          double distance = Geolocator.distanceBetween(
            position.latitude,
            position.longitude,
            culturalObject.latitude,
            culturalObject.longitude,
          );
          if (distance < proximityRadius) {
            print('Cultural object "${culturalObject.name}" is within proximity ($distance meters)');
            _sendNotification(culturalObject); // Call the placeholder notification function
          }
        }
      } else {
        print('Could not get position.');
      }
    });
  }

  Future<Position?> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled.');
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission(
      if (permission == LocationPermission.denied) {
        print('Location permissions are denied');
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('Location permissions are permanently denied, we cannot request permissions.');
      return null;
    }

    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  Future<void> _sendNotification(CulturalObject culturalObject) async {
    print('Sending notification...');
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('proximity_notification_channel',
                                  'Proximity Notifications',
                                  channelDescription: 'Notifications for nearby cultural objects',
                                  importance: Importance.high,
                                  priority: Priority.high);
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(0, 'Cultural Object Nearby!', 'You are near ${culturalObject.name}', platformChannelSpecifics, payload: culturalObject.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rutas'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: _isLoading ? CircularProgressIndicator() : Text('Rutas Section (${_culturalObjects.length} objects loaded)'),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _checkProximity,
            child: Text('Check Proximity'),
          ),
        ],
      ),
    );
  }
}