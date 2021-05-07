// import 'package:flappy_search_bar/flappy_search_bar.dart';
// import 'package:flappy_search_bar/search_bar_style.dart';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app/models/DbHelper.dart';
import 'package:flutter_app/models/Manzana.dart';
import 'package:flutter_app/models/address.dart';
import 'package:flutter_app/services/http_service.dart';
import 'package:flutter_app/src/views/ui/ARCoreScreen.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:flutter_map_location/flutter_map_location.dart';
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:dart_jts/dart_jts.dart' as jts;
import 'package:vector_math/vector_math_64.dart' as vector;
import 'package:flutter/services.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'example_popup.dart';


List<Polygon> centroidsManzanas = <Polygon>[];
List<Manzana> manzanas = [];
List<ListTile> leyenda = [];

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
  List<Address> filteredSearchHistory = [];
  final MapController mapController = MapController();
  FloatingSearchBarController controller = FloatingSearchBarController();
  double latBef = null;
  double lonBef = null;

  //libs to tutorial
  TutorialCoachMark tutorialCoachMark;
  List<TargetFocus> targets = [];
  GlobalKey keyCurrentLoc = GlobalKey();
  GlobalKey _keyMarker = GlobalKey();
  GlobalKey _key2SearchBar = GlobalKey();



  // void main() async {
  //   await getMarkersCentroids();
  // }



  @override
  Widget build(BuildContext context) {

    actualizarLeyenda();

    // requestPermissions();
    //
    //
    //
    //
    //
    // _createFolder();

    final List<Marker> userLocationMarkers = <Marker>[];
    GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
    // List<Marker> centroidsManzanas
    // final PopupController _popupLayerController = PopupController();
    // final PopupSnap popupSnap;
    //
    // MapPageScaffold(this.popupSnap);

    // dbHelper.initDb();
    // List<Marker> centroidsManzanas;

    // main();
    // showTutorial(context);

    return Scaffold(
      // appBar: AppBar(
      //   title: Text("Buscar ubicación...",
      //   style: TextStyle(
      //   color: Color(0xffffffff),
      // ),),
      // backgroundColor: Colors.transparent,
      // actions: [
      //   IconButton(
      //       icon: Icon(Icons.search),
      //       onPressed: (){
      //         final snackBar = SnackBar(
      //           content: Text('Buscar!!!'),
      //           action: SnackBarAction(
      //             label: 'Atrás',
      //             onPressed: () {
      //               // Some code to undo the change.
      //             },
      //           ),
      //         );
      //
      //         // Find the ScaffoldMessenger in the widget tree
      //         // and use it to show a SnackBar.
      //         ScaffoldMessenger.of(context).showSnackBar(snackBar);
      //       })
      // ],),
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
      body: Stack(
        children: <Widget>[
          Padding(
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
                            onTap: (point) {
                              identify(point);
                            }
                          ),
                          layers: [
                            TileLayerOptions(
                                urlTemplate: "https://tiles.wmflabs.org/bw-mapnik/{z}/{x}/{y}.png",
                                subdomains: ['a', 'b', 'c']
                            ),
                            PolygonLayerOptions(

                                polygons: centroidsManzanas
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
                              onLocationRequested: (LatLngData ld)  async {
                                if (ld == null || ld.location == null) {
                                  return;
                                }
                                mapController?.move(ld.location, 18.0);
                                double buffer = 0.00135000135*2;
                                if(lonBef != ld.location.longitude && latBef != ld.location.latitude){
                                  lonBef = ld.location.longitude;
                                  latBef = ld.location.latitude;
                                  await getMarkersCentroids(ld.location.latitude - buffer,ld.location.longitude - buffer,ld.location.latitude + buffer,ld.location.longitude + buffer);
                                  // print(lonBef);
                                  // print(latBef);
                                }



                              },
                              buttonBuilder: (BuildContext context,
                                  ValueNotifier<LocationServiceStatus> status,
                                  Function onPressed) {
                                return Align(

                                  alignment: Alignment.bottomRight,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 100.0, right: 16.0),
                                    child: Column(
                                        children: [
                                          SizedBox(height: 10),
                                          FloatingActionButton(
                                            elevation: 10000,
                                            key: keyCurrentLoc,
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
                                            key: _keyMarker,
                                            elevation: 50,
                                            heroTag: "btn2",
                                            backgroundColor: hexToColor("#B91450"),
                                            onPressed: () {
                                              Navigator.push(context,
                                                  MaterialPageRoute(
                                                      builder: (_) => ARCoreScreen(markersAround: manzanas)
                                                  )
                                              );
                                            },
                                            child: Icon(Icons.add_location_alt_outlined,
                                              color: Color(0xffffffff),),
                                          ),
                                          SizedBox(height: 10),
                                          FloatingActionButton(
                                            heroTag: "btn3",
                                            backgroundColor: hexToColor("#B91450"),
                                            onPressed: () {
                                              showMaterialModalBottomSheet(
                                                  // elevation: 10,
                                                context: context,
                                                builder: (contextB) => Container(
                                                  width: 300,
                                                  height: 300,
                                                  child: ListView(
                                                          children: leyenda,
                                                        )
                                                  // width: 300,
                                                  // height: 300,
                                                  // child: Column(
                                                  //   mainAxisAlignment: MainAxisAlignment.center,
                                                  //   children: [
                                                  //     // Text("Leyenda (Número de viviendas)",style: TextStyle(color: Colors.black),),
                                                  //     ListView(
                                                  //       children: leyenda,
                                                  //     ),
                                                  //   ],
                                                  // )
                                                  // child: new ListView(
                                                  //   children: leyenda,
                                                  // ),
                                                // child:new ListView(
                                                //   children: leyenda
                                                // )
                                              )
                                              );
                                              // Navigator.push(context,
                                              //     MaterialPageRoute(
                                              //         builder: (_) => ARCoreScreen(markersAround: manzanas)
                                              //     )
                                              // );
                                            },
                                            child: Icon(Icons.format_list_bulleted,
                                              color: Color(0xffffffff),),
                                          ),
                                          // FloatingActionButton(
                                          //   heroTag: "btn3",
                                          //   backgroundColor: hexToColor("#B91450"),
                                          //   onPressed: () {
                                          //     // Navigator.push(context,
                                          //     //     MaterialPageRoute(
                                          //     //         builder: (_) => ARCoreScreen()));
                                          //   },
                                          //   child: Icon(Icons.menu,
                                          //     color: Color(0xffffffff),),
                                          // )
                                        ]),


                                  ),
                                );
                              },
                            ),
                            // MarkerLayerOptions(
                            //   markers: centroidsManzanas,
                            // ),

                            // PopupMarkerLayerOptions(
                            //   markers: centroidsManzanas,
                            //   // popupSnap: widget.popupSnap,
                            //   popupController: _popupLayerController,
                            //   popupBuilder: (BuildContext _, Marker marker) => ExamplePopup(marker),
                            // ),
                          ],
                        )
                    )
                  ]
              )
          ),
          buildFloatingSearchBar(context)
         // Padding(
         //   padding: const EdgeInsets.only(top: 30.0, left: 10.0),
         //     child: Column(
         //         children: [
         //           SizedBox(height: 10),
         //           Builder(
         //             builder: (context) =>
         //                 FloatingActionButton(
         //                   heroTag: "btn3",
         //                   backgroundColor: hexToColor("#B91450"),
         //                   onPressed: () {
         //                     // _scaffoldKey.currentState.openDrawer();
         //                     Scaffold.of(context).openDrawer();
         //                     // Navigator.push(context,
         //                     //     MaterialPageRoute(
         //                     //         builder: (_) => ARCoreScreen()));
         //                   },
         //                   child: Icon(Icons.menu,
         //                     color: Color(0xffffffff),),
         //                 )
         //           )
         //
         //         ]
         //     )
         // ),
         //  SafeArea(
         //    child: Padding(
         //      padding: EdgeInsets.only(top: 5, left:75,right: 20),
         //      child: SearchBar(
         //        searchBarStyle: SearchBarStyle(
         //          borderRadius: BorderRadius.circular(100),
         //          backgroundColor: Color(0x9Efffff9)
         //        ),
         //        cancellationWidget: Text("ok"),
         //
         //
         //      ),
         //
         //    )
         //  )


        ]
      )


    );




  }

  void _gotoLocation(double lat,double long, LatLngBounds ext) {
    //check if map is ready to move camera...
    // if(this.isMapRead) {
      mapController.move(LatLng(lat, long), mapController?.zoom);
      mapController.fitBounds(ext);
    // }
  }


  Widget buildFloatingSearchBar(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    final HttpService httpService = HttpService();

    return FloatingSearchBar(
      key: _key2SearchBar,
      controller: controller,
      hint: 'Buscar sitio...',
      hintStyle: TextStyle(
        color: Colors.white
      ),
      queryStyle: TextStyle(
          color: Colors.white
      ),
      scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
      transitionDuration: const Duration(milliseconds: 800),
      transitionCurve: Curves.easeInOut,
      physics: const BouncingScrollPhysics(),
      axisAlignment: isPortrait ? 0.0 : -1.0,
      openAxisAlignment: 0.0,
      width: isPortrait ? 600 : 500,
      debounceDelay: const Duration(milliseconds: 500),
      backgroundColor: hexToColor("#B91450"),
      iconColor: Colors.white,
      // leadingActions: [
      // FloatingSearchBarAction(
      //                   // heroTag: "btn3",
      //                   // backgroundColor: hexToColor("#B91450"),
      //                   // onPressed: () {
      //                   //   // _scaffoldKey.currentState.openDrawer();
      //                   //   Scaffold.of(context).openDrawer();
      //                   //   // Navigator.push(context,
      //                   //   //     MaterialPageRoute(
      //                   //   //         builder: (_) => ARCoreScreen()));
      //                   // },
      //                   child: Icon(Icons.menu,
      //                     color: Color(0xffffffff),),
      //                 )
      // ],
      onQueryChanged: (query) async {
        // Call your model, bloc, controller here.
        // setState((){
        //
        // })
        filteredSearchHistory = await httpService.getPosts(query);
        // updateSearch(as);

        // print(query);
      },
      // Specify a custom transition to be used for
      // animating between opened and closed stated.
      transition: CircularFloatingSearchBarTransition(),
      actions: [
        FloatingSearchBarAction(
          showIfOpened: false,
          child: CircularButton(
            icon: const Icon(Icons.place),
            onPressed: () {},
          ),
        ),
        FloatingSearchBarAction.searchToClear(
          showIfClosed: false,
        ),
      ],
      builder: (context, transition) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Material(
            color: Colors.white,
            elevation: 4.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: filteredSearchHistory.map(
                  (add) => Card(
                      child: ListTile(
                    title: Text(add.display_name),
                    leading: const Icon(Icons.history),
                    onTap:(){
                      final snackBar = SnackBar(content: Text(add.display_name));
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      double lat = double.parse(add.lat);
                      double lon = double.parse(add.lon);
                      List<String> bb_list = add.bounding_box.map((s) => s as String).toList();
                      LatLng corner1 = new LatLng(double.parse(bb_list[0]),double.parse(bb_list[3]));
                      LatLng corner2 = new LatLng(double.parse(bb_list[1]),double.parse(bb_list[2]));
                      LatLngBounds extent = new LatLngBounds(corner1,corner2);
                      // List<String> bbs = (jsonDecode(add.bounding_box) as List<dynamic>).cast<String>();
                      // print(bb_list);
                      _gotoLocation(lat,lon,extent);
                      controller.close();
                    },
                  ))
              ).toList()
              // Colors.accents.map((color) {
              //   return Container(height: 112, color: color);
              // }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget updateSearch(List<Address> addresses){
    return ListView.builder(
      itemCount: addresses.length,
      itemBuilder: (content,index) {
        return ListTile(
          title: Text(addresses[index].display_name),
          subtitle: Text(addresses[index].display_name),
        );
      },
    );
  }

  void showTutorial(BuildContext context){
    targets.add(
      TargetFocus(
        identify: "Target 1",
        keyTarget: keyCurrentLoc,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Mi ubicación actual",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20.0),
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.only(top: 10.0),
                  //   child: Text(
                  //     "Mi ubicación actual",
                  //     style: TextStyle(color: Colors.black),
                  //   ),
                  // )
                ],
              )
            )
          ),

        ]
      ),

    );

    targets.add(
        TargetFocus(
            identify: "Target 2",
            keyTarget: _keyMarker,
            contents: [
              TargetContent(
                  align: ContentAlign.bottom,
                  child: Container(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "Definir manualmente",
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20.0),
                          ),
                          // Padding(
                          //   padding: const EdgeInsets.only(top: 10.0),
                          //   child: Text(
                          //     "Mi ubicación actual",
                          //     style: TextStyle(color: Colors.black),
                          //   ),
                          // )
                        ],
                      )
                  )
              ),

            ]
        )
    );

    // targets.add(
    //     TargetFocus(
    //         identify: "Target 3",
    //         keyTarget: _key2SearchBar,
    //         contents: [
    //           TargetContent(
    //               align: ContentAlign.bottom,
    //               child: Container(
    //                   child: Column(
    //                     mainAxisSize: MainAxisSize.min,
    //                     crossAxisAlignment: CrossAxisAlignment.center,
    //                     mainAxisAlignment: MainAxisAlignment.center,
    //                     children: <Widget>[
    //                       Text(
    //                         "Buscar un sitio",
    //                         style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20.0),
    //                       ),
    //                       // Padding(
    //                       //   padding: const EdgeInsets.only(top: 10.0),
    //                       //   child: Text(
    //                       //     "Mi ubicación actual",
    //                       //     style: TextStyle(color: Colors.black),
    //                       //   ),
    //                       // )
    //                     ],
    //                   )
    //               )
    //           ),
    //
    //         ]
    //     )
    // );

    tutorialCoachMark = TutorialCoachMark(
        context,
        targets: targets,
        // colorShadow: Color(0x80000000),
        textStyleSkip: TextStyle(
          color: Colors.white
        )
    )..show();
  }


}

getMarkersCentroids(double startLat, double startLon,double endLat, double endLon) async {
  centroidsManzanas = await getCentroids(startLat, startLon,endLat, endLon);
  // print(centroidsManzanas);
  // setState(() {});
}



/// Construct a color from a hex code string, of the format #RRGGBB.
Color hexToColor(String code) {
  return new Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
}

/// Get centroids
Future<List<Polygon>> getCentroids(double startLat, double startLon,double endLat, double endLon) async {
  // Future<List<Marker>> markersCnpv = Future;
  List<Marker> ms = <Marker>[];
  List<Polygon> ps = <Polygon>[];
  manzanas = await Manzana().retrieveManzanas( startLat,  startLon, endLat, endLon);

  manzanas.forEach((element) {
    // print(element.geometry);
    List<LatLng> verticesPolygon = <LatLng>[];
    jts.Geometry polygon = jts.WKBReader().read(element.geometry);
    List<jts.Coordinate> coordinatesPolygon = polygon.getCoordinates();
    coordinatesPolygon.forEach((coord) {
      LatLng vertice = new LatLng(coord.y,coord.x);
      verticesPolygon.add(vertice);
    });
    Color color = null;
    int indicator = element.tvivienda;


    indicator>0 && indicator <= 57?color=Color(0xfffeebe3):
    indicator>57 && indicator<= 192?color=Color(0xfffbb4b9):
    indicator>192 && indicator <= 543?color=Color(0xfff768a1):
    indicator>543 && indicator <= 1796?color=Color(0xffc51b8a):
    indicator>1796 && indicator <= 4618?color=Color(0xff7a0177):0;


    Polygon mapPol = new Polygon(points:verticesPolygon,color: color);
    // print(polygon.getCoordinates());
    // Marker m = Marker(
    //   width: 20.0,
    //   height: 20.0,
    //   point: LatLng(element.latitud, element.longitud),
    //     builder: (ctx) =>
    //         Container(
    //           child: Icon(Icons.location_on)
    //         )
    //   // builder: (ctx) => {}
    // );

    ps.add(mapPol);
    print("Elemento manzana: ${element.cod_dane_a}");
  });

  // markersCnpv = ms as Future<List<Marker>>;
  return Future((){
    return ps;
  });


}

void actualizarLeyenda(){
  leyenda = [];
  leyenda.add(ListTile(title:Text("Leyenda (Número de viviendas)", style: TextStyle(fontWeight: FontWeight.bold),),));
  leyenda.add(ListTile(title:Text("0 - 57"),leading: ClipRRect(
    borderRadius: BorderRadius.circular(20.0),//or 15.0
    child: Container(
      height: 40.0,
      width: 40.0,
      color: Color(0xfffeebe3),
    ),
  ),));
  leyenda.add(ListTile(title:Text("57 - 192"),leading: ClipRRect(
    borderRadius: BorderRadius.circular(20.0),//or 15.0
    child: Container(
      height: 40.0,
      width: 40.0,
      color: Color(0xfffbb4b9),
    ),
  ),));
  leyenda.add(ListTile(title:Text("192 - 543"),leading: ClipRRect(
    borderRadius: BorderRadius.circular(20.0),//or 15.0
    child: Container(
      height: 40.0,
      width: 40.0,
      color: Color(0xfff768a1),
    ),
  ),));
  leyenda.add(ListTile(title:Text("543 - 1796"),leading: ClipRRect(
    borderRadius: BorderRadius.circular(20.0),//or 15.0
    child: Container(
      height: 40.0,
      width: 40.0,
      color: Color(0xffc51b8a),
    ),
  ),));
  leyenda.add(ListTile(title:Text("1796 - 4618"),leading: ClipRRect(
    borderRadius: BorderRadius.circular(20.0),//or 15.0
    child: Container(
      height: 40.0,
      width: 40.0,
      color: Color(0xff7a0177),
    ),
  ),));
}

void identify(LatLng pnt){
  print("Point");
  print(pnt);
  jts.Point pntIdentify = new jts.Point(jts.Coordinate(pnt.longitude,pnt.latitude),jts.PrecisionModel(),4326);
  //Validar cual polígono se selecciono
  for(final mz in centroidsManzanas){
    List<LatLng> points = mz.points;
    List<jts.Coordinate> coordsArray = [];
    points.forEach((p){
      coordsArray.add(jts.Coordinate(p.longitude,p.latitude));
    });
    jts.LinearRing ringPol = new jts.LinearRing(coordsArray,jts.PrecisionModel(),4326);
    jts.Polygon polJts = new jts.Polygon(ringPol,jts.PrecisionModel(),4326);
    bool intersects = false;
    intersects = polJts.intersects(pntIdentify);
    if(intersects){
      print("Manzana click");
      print(mz);
      break;
    }
  }

}








