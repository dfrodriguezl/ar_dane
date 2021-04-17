import 'package:flutter/material.dart';
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import 'package:flutter/services.dart';

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

  @override
  _ARCoreScreenState createState() => _ARCoreScreenState();
}

class _ARCoreScreenState extends State<ARCoreScreen> {
  ArCoreController arCoreController;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('AR CNPV 2018',style:TextStyle(
              color: kPrimaryColor)),
          backgroundColor: Colors.white,
        ),
        body: ArCoreView(
          onArCoreViewCreated: _onArCoreViewCreated,
          enableTapRecognizer: true,
        ),
      ),
    );
  }

  void _onArCoreViewCreated(ArCoreController controller) {
    arCoreController = controller;

    // arCoreController.onNodeTap = (name) => onTapHandler(name);
    // arCoreController.onPlaneTap = _handleOnPlaneTap;

    _addSphere(arCoreController);
    _addCylindre(arCoreController);
    _addCube(arCoreController);
  }

  Future _addSphere(ArCoreController controller) async {
    final ByteData textureBytes = await rootBundle.load('assets/earth.jpg');

    final material = ArCoreMaterial(
        color: Color.fromARGB(120, 66, 134, 244),
        textureBytes: textureBytes.buffer.asUint8List());
    final sphere = ArCoreSphere(
      materials: [material],
      radius: 0.1,
    );
    final node = ArCoreNode(
      shape: sphere,
      position: vector.Vector3(0, 0, -1.5),
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
          AlertDialog(content: Text('onNodeTap on $name')),
    );
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
  @override
  void dispose() {
    arCoreController.dispose();
    super.dispose();
  }
}