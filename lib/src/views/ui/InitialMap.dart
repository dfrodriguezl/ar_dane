import 'package:flutter/material.dart';
import 'package:flutter_app/models/DbHelper.dart';
import 'package:flutter_app/models/Manzana.dart';
import 'package:flutter_app/src/views/ui/ARCoreScreen.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:flutter_map_location/flutter_map_location.dart';
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import 'package:flutter/services.dart';


List<Marker> centroidsManzanas = [];

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

class InitialMap extends StatelessWidget {
  final textLocation = 'This is a map that is showing (-74, 4)';
  // ArCoreController arCoreController;

  DbHelper dbHelper = new DbHelper();

  void main() async {
    await getMarkersCentroids();
  }


  @override
  Widget build(BuildContext context) {
    final MapController mapController = MapController();
    final List<Marker> userLocationMarkers = <Marker>[];
    // List<Marker> centroidsManzanas

    // dbHelper.initDb();
    // List<Marker> centroidsManzanas;

    main();

    return Scaffold(
      appBar: AppBar(
        title: Text("Buscar ubicación...",
        style: TextStyle(
        color: Color(0xffffffff),
      ),),
      backgroundColor: Colors.transparent,
      actions: [
        IconButton(
            icon: Icon(Icons.search),
            onPressed: (){
              final snackBar = SnackBar(
                content: Text('Buscar!!!'),
                action: SnackBarAction(
                  label: 'Atrás',
                  onPressed: () {
                    // Some code to undo the change.
                  },
                ),
              );

              // Find the ScaffoldMessenger in the widget tree
              // and use it to show a SnackBar.
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            })
      ],),
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text('AR CNPV 2018',style: TextStyle(
                color: Color(0xffffffff),
              ),),
              decoration: BoxDecoration(
                color: hexToColor("#B91450"),
              ),
            ),
            ListTile(
              title: Text('Acerca de'),
              onTap: () {
                // Update the state of the app.
                // ...
              },
            ),
            ListTile(
              title: Text('¿Como usar?'),
              onTap: () {
                // Update the state of the app.
                // ...
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(0),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 0, bottom: 0),
              // child: locationText()
              // child: Text('This is a map that is showing (-74, 4).'),
            ),
            Flexible(
              child: FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  plugins: <MapPlugin>[
                    LocationPlugin()
                  ],
                  interactiveFlags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                  center: LatLng(4, -74),
                  zoom: 13.0,
                ),
                layers: [
                  TileLayerOptions(
                      urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: ['a', 'b', 'c']
                  ),
                  MarkerLayerOptions(markers: userLocationMarkers),
                  // MarkerLayerOptions(
                  //   markers: [
                  //     Marker(
                  //       width: 80.0,
                  //       height: 80.0,
                  //       point: LatLng(4, -74),
                  //       builder: (ctx) =>
                  //           Container(
                  //             child: FlutterLogo(),
                  //           ),
                  //     ),
                  //   ],
                  // ),
                  LocationOptions(
                    markers: userLocationMarkers,
                    onLocationUpdate: (LatLngData ld) {
                      print('Location updated: ${ld?.location}');
                    },
                    onLocationRequested: (LatLngData ld) {
                      if (ld == null || ld.location == null) {
                        return;
                      }
                      mapController?.move(ld.location, 16.0);
                    },
                    buttonBuilder: (BuildContext context,
                        ValueNotifier<LocationServiceStatus> status,
                        Function onPressed) {
                      return Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16.0, right: 16.0),
                          child: Column(
                              children: [
                                SizedBox(height: 10),
                                FloatingActionButton(
                                  heroTag: "btn1",
                                  backgroundColor: hexToColor("#B91450"),
                                  child: ValueListenableBuilder<LocationServiceStatus>(
                                      valueListenable: status,
                                      builder: (BuildContext context,
                                          LocationServiceStatus value, Widget child) {
                                        switch (value) {
                                          case LocationServiceStatus.disabled:
                                          case LocationServiceStatus.permissionDenied:
                                          case LocationServiceStatus.unsubscribed:
                                            return const Icon(
                                              Icons.location_disabled,
                                              color: Color(0xffffffff),
                                              // color: Colors.white,
                                            );
                                            break;
                                          default:
                                            return const Icon(
                                              Icons.gps_fixed,
                                              color: Color(0xffffffff),
                                            );
                                            break;
                                        }
                                      }),
                                  onPressed: () => onPressed()),
                                SizedBox(height: 10),
                                FloatingActionButton(
                                  heroTag: "btn2",
                                  backgroundColor: hexToColor("#B91450"),
                                  onPressed: () {
                                    Navigator.push(context, 
                                    MaterialPageRoute(
                                        builder: (_) => ARCoreScreen()));
                                  },
                                  child: Icon(Icons.add_location_alt_outlined,
                                    color: Color(0xffffffff),),
                                  )]),
                        ),
                      );
                    },
                  ),
                MarkerLayerOptions(
                  markers: centroidsManzanas,
                )
                ],
              )
            )
          ]
        )
      )
    );


  }


}

getMarkersCentroids() async {
  centroidsManzanas = await getCentroids();
  // print(centroidsManzanas);
  // setState(() {});
}



/// Construct a color from a hex code string, of the format #RRGGBB.
Color hexToColor(String code) {
  return new Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
}

/// Get centroids
Future<List<Marker>> getCentroids() async {
  // Future<List<Marker>> markersCnpv = Future;
  List<Marker> ms = <Marker>[];
  List<Manzana> manzanas = await Manzana().retrieveManzanas();
  manzanas.forEach((element) {
    Marker m = Marker(
      width: 20.0,
      height: 20.0,
      point: LatLng(element.latitud, element.longitud),
        builder: (ctx) =>
            Container(
              child: Icon(Icons.add)
            )
      // builder: (ctx) => {}
    );
    ms.add(m);
    print("Elemento manzana: ${element.cod_dane_a}");
  });

  // markersCnpv = ms as Future<List<Marker>>;
  return Future((){
    return ms;
  });


}




