// import 'package:flappy_search_bar/flappy_search_bar.dart';
// import 'package:flappy_search_bar/search_bar_style.dart';
import 'dart:convert';

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
import 'package:vector_math/vector_math_64.dart' as vector;
import 'package:flutter/services.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'example_popup.dart';


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
  List<Address> filteredSearchHistory = [];
  final MapController mapController = MapController();
  FloatingSearchBarController controller = FloatingSearchBarController();

  void main() async {
    await getMarkersCentroids();
  }



  @override
  Widget build(BuildContext context) {

    final List<Marker> userLocationMarkers = <Marker>[];
    GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
    // List<Marker> centroidsManzanas
    // final PopupController _popupLayerController = PopupController();
    // final PopupSnap popupSnap;
    //
    // MapPageScaffold(this.popupSnap);

    // dbHelper.initDb();
    // List<Marker> centroidsManzanas;

    main();

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
                                mapController?.move(ld.location, 18.0);
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
                            MarkerLayerOptions(
                              markers: centroidsManzanas,
                            ),
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

        print(query);
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
                      print(bb_list);
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
              child: Icon(Icons.location_on)
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




