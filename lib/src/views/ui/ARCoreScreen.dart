import 'dart:math';
import 'dart:async';
// import 'info.dart';
// import 'dart:html' as html;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:flutter_app/models/Manzana.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location/flutter_map_location.dart' as loc;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import 'package:flutter/services.dart';
import 'package:latlong/latlong.dart';

import 'InitialMap.dart';

final MaterialColor kPrimaryColor = const MaterialColor(
  0xffbe0c4d,
  const <int, Color>{
    50: const Color(0xffbe0c4d),
    100: const Color(0xffbe0c4d),
    200: const Color(0xffbe0c4d),
    300: const Color(0xffbe0c4d),
    400: const Color(0xffbe0c4d),
    500: const Color(0xffbe0c4d),
    600: const Color(0xffbe0c4d),
    700: const Color(0xffbe0c4d),
    800: const Color(0xffbe0c4d),
    900: const Color(0xffbe0c4d),
  },
);

class ARCoreScreen extends StatefulWidget {

  List<Manzana> markersAround = [];

  ARCoreScreen({Key key,this.markersAround}): super(key:key);

  @override
  _ARCoreScreenState createState() => _ARCoreScreenState();
}

enum WidgetDistance { ready, navigating }
enum WidgetCompass { scanning, directing }

class _ARCoreScreenState extends State<ARCoreScreen> {
  ArCoreController arCoreController;
  WidgetDistance situationDistance = WidgetDistance.navigating;
  WidgetCompass situationCompass = WidgetCompass.directing;
  bool anchorWasFound = false;
  FlutterTts flutterTts;
  int _clearDirection = 0;
  double distance = 0;
  int _distance = 0;
  double targetDegree = 0;
  Timer timer;
  MapController mapController;
  bool addSphere = false;
  // TtsState ttsState = TtsState.stopped;


  //calculation formula of angel between 2 different points
  double angleFromCoordinate(
      double lat1, double long1, double lat2, double long2) {

    double dLon = (long2 - long1);

    double y = sin(dLon) * cos(lat2);
    double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);

    double dOmega = log(tan((lat2/2)+(PI/4)) / tan((lat1/2) + (PI/4)));

    double brng = atan2(dLon, dOmega);
    // double brng = atan2(y, x);

    // brng = vector.degrees(brng);
    // brng = (brng + 360) % 360;
    //brng = 360 - brng; //remove to make clockwise
    return brng;
  }

  Future _speak() async {
    // await flutterTts.setVolume(1.0);
    // await flutterTts.setSpeechRate(0.4);
    // await flutterTts.setPitch(1.0);

    if (distance != 0) {
      // final snackBar = SnackBar(content: Text(distance.toString() + " metros"));
      // print("distance");
      // print(distance);
      // Find the ScaffoldMessenger in the widget tree
      // and use it to show a SnackBar.
      // ScaffoldMessenger.of(context).showSnackBar(snackBar);
      Fluttertoast.showToast(
          msg: _clearDirection.toString() + " grados, " + distance.toString() + " metros",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM
      );
    }
  }


  //device compass
  void calculateDegree(Manzana m,double distance, double td) {
    FlutterCompass.events.listen((event) {

      // setState(() {
        if (targetDegree != null && event != null) {
          _clearDirection = targetDegree.truncate() - event.heading.truncate();
          // _addSphere(arCoreController,distance,td);
          if(!addSphere){
                _addSphere(arCoreController,distance,targetDegree);
                addSphere = true;
              }
          // _addSphere(arCoreController,distance,targetDegree);
          // if(_clearDirection > -45 && _clearDirection < 45){
          //   if(!addSphere){
          //     _addSphere(arCoreController,distance,targetDegree);
          //     addSphere = true;
          //   }
          //
          // }
          // print("clearDirection");
          // print(event.heading.truncate());
        }
      // });
    });
  }

  //distance between faculty and device coordinates
  void _getlocation(List<Manzana> markers) async {
    //if you want to check location service permissions use checkGeolocationPermissionStatus method
    Position position = await Geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    final double _facultypositionlat = 4.715953;
    final double _facultypositionlong = -74.140994;

    distance = await Geolocator.distanceBetween(position.latitude,
              position.longitude, _facultypositionlat, _facultypositionlong);

    targetDegree = angleFromCoordinate(position.latitude, position.longitude,
              _facultypositionlat, _facultypositionlong);

    Manzana m = new Manzana();

    calculateDegree(m,distance,targetDegree);

    // markers.forEach((element) async {
    //   final double _facultypositionlat = element.latitud;
    //   final double _facultypositionlong = element.longitud;
    //
    //   distance = Geolocator.distanceBetween(position.latitude,
    //       position.longitude, _facultypositionlat, _facultypositionlong);
    //
    //   // print("distance");
    //   // print(distance);
    //
    //   targetDegree = angleFromCoordinate(position.latitude, position.longitude,
    //       _facultypositionlat, _facultypositionlong);
    //   // print("targetDegree");
    //   // print(targetDegree);
    //   calculateDegree(element,distance,targetDegree);
    // });
    // print("currentLoc");
    // print(position.latitude);
    // print(position.longitude);
    // print(position.accuracy);


  }

  // //distance between faculty and device coordinates
  // void _getlocation() async {
  //   //if you want to check location service permissions use checkGeolocationPermissionStatus method
  //   Position position = await Geolocator
  //       .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  //
  //   markers.forEach((element) async {
  //     final double _facultypositionlat = element.latitud;
  //     final double _facultypositionlong = element.longitud;
  //
  //     distance = Geolocator.distanceBetween(position.latitude,
  //         position.longitude, _facultypositionlat, _facultypositionlong);
  //
  //     // print("distance");
  //     // print(distance);
  //
  //     targetDegree = angleFromCoordinate(position.latitude, position.longitude,
  //         _facultypositionlat, _facultypositionlong);
  //     // print("targetDegree");
  //     // print(targetDegree);
  //     calculateDegree(element,distance,targetDegree);
  //   });
  //   // print("currentLoc");
  //   // print(position.latitude);
  //   // print(position.longitude);
  //   // print(position.accuracy);
  //
  //
  // }

  @override
  void initState() {
    super.initState();

    _getlocation(widget.markersAround); //first run
    mapController = MapController();
    timer = new Timer.periodic(Duration(seconds: 7), (timer) {
      _getlocation(widget.markersAround);
      // if (distance < 50 && distance != 0 && distance != null) {
      //   setState(() {
      //     situationDistance = WidgetDistance.ready;
      //     situationCompass = WidgetCompass.scanning;
      //   });
      // } else {
      //   setState(() {
      //     _distance = distance.truncate();
      //     situationDistance = WidgetDistance.navigating;
      //     situationCompass = WidgetCompass.directing;
      //   });
        _speak();
      // }
    });

  }

  @override
  void dispose() {
    arCoreController?.dispose();
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          leading: BackButton(
              color: Colors.white,
              onPressed: (){
                Navigator.pop(context,false);
              },
          ),
          // title: Text('AR CNPV 2018',style:TextStyle(
          //     color: kPrimaryColor)),
          backgroundColor: hexToColor("#B91450"),
        ),
        body: new SafeArea(
          child: new Column(
            children: [
              new Expanded(
                  flex: 4,
                  child: ArCoreView(
                    onArCoreViewCreated: _onArCoreViewCreated,
                    enableTapRecognizer: true,
                  )
              ),
              new Expanded(
                flex: 1,
                child: buildMap()
              ),

            ]
          )
        )
      ),
    );
  }

  void _onArCoreViewCreated(ArCoreController controller) {
    arCoreController = controller;

    // arCoreController.
    // _addUbic(controller);
    // arCoreController.

    arCoreController.onNodeTap = (name) => onTapHandler(name);
    // arCoreController.onPlaneTap = _handleOnPlaneTap;

    // _addSphere(arCoreController);
    // _addCylindre(arCoreController);
    // _addCube(arCoreController);
  }

  Future _addUbic(ArCoreController controller) async {
    final ByteData textureBytes = await rootBundle.load('assets/earth.jpg');




    final material = ArCoreMaterial(
        color: Color.fromARGB(120, 66, 134, 244),);
        // textureBytes: textureBytes.buffer.asUint8List());
    final sphere = ArCoreSphere(
      materials: [material],
      radius: 0.1,
    );

    // final targetPosition = anchor

    final node = ArCoreNode(
      shape: sphere,
      position: vector.Vector3(0, 0, -1.5),
    );
    // controller.addArCoreNode(node);
    controller.addArCoreNodeWithAnchor(node);
  }

  Widget buildMap() {

    final List<Marker> userLocationMarkers = <Marker>[];

    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        plugins: <MapPlugin>[
          loc.LocationPlugin()
        ],
        // interactiveFlags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        center: LatLng(4.716079, -74.141053),
        zoom: 18.0,
      ),
      layers: [
        TileLayerOptions(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c']
        ),
        MarkerLayerOptions(markers: userLocationMarkers),
        // // MarkerLayerOptions(
        // //   markers: [
        // //     Marker(
        // //       width: 80.0,
        // //       height: 80.0,
        // //       point: LatLng(4, -74),
        // //       builder: (ctx) =>
        // //           Container(
        // //             child: FlutterLogo(),
        // //           ),
        // //     ),
        // //   ],
        // // ),
        // loc.LocationOptions(
        //   markers: userLocationMarkers,
        //   onLocationUpdate: (LatLngData ld) {
        //     print('Location updated: ${ld?.location}');
        //
        //   },
        //   onLocationRequested: (LatLngData ld)  async {
        //     if (ld == null || ld.location == null) {
        //       return;
        //     }
        //     mapController?.move(ld.location, 18.0);
        //     // double buffer = 0.00135000135;
        //     // if(lonBef != ld.location.longitude && latBef != ld.location.latitude){
        //     //   lonBef = ld.location.longitude;
        //     //   latBef = ld.location.latitude;
        //     //   await getMarkersCentroids(ld.location.latitude - buffer,ld.location.longitude - buffer,ld.location.latitude + buffer,ld.location.longitude + buffer);
        //     //   print(lonBef);
        //     //   print(latBef);
        //     // }
        //
        //
        //
        //   },
        //   // buttonBuilder: (BuildContext context,
        //   //     ValueNotifier<LocationServiceStatus> status,
        //   //     Function onPressed) {
        //   //
        //   // },
        // )
        // PopupMarkerLayerOptions(
        //   markers: centroidsManzanas,
        //   // popupSnap: widget.popupSnap,
        //   popupController: _popupLayerController,
        //   popupBuilder: (BuildContext _, Marker marker) => ExamplePopup(marker),
        // ),
      ],
    );
  }



  Future _addSphere(ArCoreController controller,double distance,double targetDeg) async {
    final ByteData textureBytes = await rootBundle.load('assets/marker.png');

    final material = ArCoreMaterial(
        color: Color.fromARGB(255, 185, 20, 80),
        // textureBytes: textureBytes.buffer.asUint8List()
    );
    final sphere = ArCoreSphere(
      materials: [material],
      radius: 1,
    );

    double degree = (360 - targetDegree*180/PI);
    double y = 0;
    double x = distance * cos(PI * degree / 180);
    double z = -1 * distance * sin(PI * degree / 180);
    print("coordinates");
    print(x);
    print(y);
    print(z);
    final node = ArCoreNode(

      shape: sphere,
      position: vector.Vector3(x, y, z),
      name: "Manzana 1100110000000529656"
    );
    controller.addArCoreNode(node);
  }

  // Future _addSphere(ArCoreHitTestResult hit) async {
  //   final moonMaterial = ArCoreMaterial(color: Colors.grey);
  //
  //   final moonShape = ArCoreSphere(
  //     materials: [moonMaterial],
  //     radius: 0.03,
  //   );
  //
  //   final moon = ArCoreNode(
  //     shape: moonShape,
  //     position: vector.Vector3(0.2, 0, 0),
  //     rotation: vector.Vector4(0, 0, 0, 0),
  //   );
  //
  //   final ByteData textureBytes = await rootBundle.load('assets/earth.jpg');
  //
  //   final earthMaterial = ArCoreMaterial(
  //       color: Color.fromARGB(120, 66, 134, 244),
  //       textureBytes: textureBytes.buffer.asUint8List());
  //
  //   final earthShape = ArCoreSphere(
  //     materials: [earthMaterial],
  //     radius: 0.1,
  //   );
  //
  //   final earth = ArCoreNode(
  //       shape: earthShape,
  //       children: [moon],
  //       position: hit.pose.translation + vector.Vector3(0.0, 1.0, 0.0),
  //       rotation: hit.pose.rotation);
  //
  //   arCoreController.addArCoreNodeWithAnchor(earth);
  // }

  // void _handleOnPlaneTap(List<ArCoreHitTestResult> hits) {
  //   final hit = hits.first;
  //   _addSphere(hit);
  // }


  void _addCylindre(ArCoreController controller) {
    final material = ArCoreMaterial(
      color: Colors.red,
      reflectance: 1.0,
    );
    final cylindre = ArCoreCylinder(
      materials: [material],
      radius: 0.5,
      height: 0.3,
    );
    final node = ArCoreNode(
      shape: cylindre,
      position: vector.Vector3(0.0, -0.5, -2.0),
    );
    controller.addArCoreNode(node);
  }

  void _addCube(ArCoreController controller) {
    final material = ArCoreMaterial(
      color: Color.fromARGB(120, 66, 134, 244),
      metallic: 1.0,
    );
    final cube = ArCoreCube(
      materials: [material],
      size: vector.Vector3(0.5, 0.5, 0.5),
    );
    final node = ArCoreNode(
      shape: cube,
      position: vector.Vector3(-0.5, 0.5, -3.5),
    );
    controller.addArCoreNode(node);
  }

  void onTapHandler(String name) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) =>
          AlertDialog(content: Text('$name')),
    );
  }

  /// Construct a color from a hex code string, of the format #RRGGBB.
  Color hexToColor(String code) {
    return new Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
  }


  // void _handleOnPlaneTap(List<ArCoreHitTestResult> hits) {
  //   final hit = hits.first;
  //
  //   final moonMaterial = ArCoreMaterial(color: Colors.grey);
  //
  //   final moonShape = ArCoreSphere(
  //     materials: [moonMaterial],
  //     radius: 0.03,
  //   );
  //
  //   final moon = ArCoreNode(
  //     shape: moonShape,
  //     position: vector.Vector3(0.2, 0, 0),
  //     rotation: vector.Vector4(0, 0, 0, 0),
  //   );
  //
  //   final earthMaterial = ArCoreMaterial(
  //       color: Color.fromARGB(120, 66, 134, 244));
  //
  //   final earthShape = ArCoreSphere(
  //     materials: [earthMaterial],
  //     radius: 0.1,
  //   );
  //
  //   final earth = ArCoreNode(
  //       shape: earthShape,
  //       children: [moon],
  //       position: plane.pose.translation + vector.Vector3(0.0, 1.0, 0.0),
  //       rotation: plane.pose.rotation);
  //
  //   arCoreController.addArCoreNodeWithAnchor(earth);
  // }
  // @override
  // void dispose() {
  //   arCoreController.dispose();
  //   super.dispose();
  // }
}