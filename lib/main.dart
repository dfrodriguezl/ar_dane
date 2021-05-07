// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app/src/views/ui/DownloadScreen.dart';
import 'package:flutter_app/src/views/ui/InitialMap.dart';
import 'package:permission_handler/permission_handler.dart';


const MaterialColor white = const MaterialColor(
  0xFFFFFFFF,
  const <int, Color>{
    50: const Color(0xFFFFFFFF),
    100: const Color(0xFFFFFFFF),
    200: const Color(0xFFFFFFFF),
    300: const Color(0xFFFFFFFF),
    400: const Color(0xFFFFFFFF),
    500: const Color(0xFFFFFFFF),
    600: const Color(0xFFFFFFFF),
    700: const Color(0xFFFFFFFF),
    800: const Color(0xFFFFFFFF),
    900: const Color(0xFFFFFFFF),
  },
);

void main() => runApp(


    new MaterialApp(
      home: new MyApp(),
      theme: ThemeData(
        primarySwatch: white
      ),
    )
);
    // MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    requestPermissions();
    return FutureBuilder(
      // Replace the 3 second delay with your initialization code:
      future: Future.delayed(Duration(seconds: 3)),
      builder: (context, AsyncSnapshot snapshot) {
        // Show splash screen while waiting for app resources to load:
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(home: Splash());
        } else {
          // Loading is done, return the app:
          return MaterialApp(
            home: new DownloadScreen(),
            // home: new InitialMap()
          );
        }
      },
    );

  }
}

class Splash extends StatelessWidget {
  // File f = await getImageFileFromAssets("Splash.png");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: new AssetImage("assets/Splash.png"),
            fit: BoxFit.cover
          ),
        ),
      )
    );
  }
}

_createFolder() async {
  final folderName = "ARCNPV2018";
  final path = Directory("storage/emulated/0/$folderName");
  if ((await path.exists())) {
    final pathDb = Directory("storage/emulated/0/$folderName/db");
    if ((await pathDb.exists())) {
      print("exist db");
    }else{
      print("not exist db");
      pathDb.create();
    }
    // TODO:
    print("exist");
  } else {
    // TODO:
    print("not exist");
    path.create();
  }
}

requestPermissions() async {
  // You can request multiple permissions at once.
  Map<Permission, PermissionStatus> statuses = await [
    Permission.storage,
  ].request();

  if (await Permission.storage.request().isGranted) {
    // Either the permission was already granted before or the user just granted it.
    _createFolder();
  }
  // print(statuses[Permission.location]);
}



// class MyApp extends StatefulWidget {
//   @override
//   Widget build(BuildContext context) {
//     // final wordPair = WordPair.random();
//     return MaterialApp(
//         title: 'Startup Name Generator',
//         theme: ThemeData(          // Add the 3 lines from here...
//           primaryColor: Colors.white,
//         ),
//       home: RandomWords(),
//     );
//   }
// }

// class RandomWords extends StatefulWidget {
//   @override
//   _RandomWordsState createState() => _RandomWordsState();
// }
//
// class _RandomWordsState extends State<RandomWords> {
//   final _suggestions = <WordPair>[];
//   final _saved = <WordPair>{};
//   final _biggerFont = TextStyle(fontSize: 18.0);
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Startup Name Generator'),
//         actions: [
//           IconButton(icon: Icon(Icons.list), onPressed: _pushSaved)
//         ],
//       ),
//       body: _buildSuggestions(),
//     );
//     // return Container();
//   }
//
//   Widget _buildSuggestions() {
//     return ListView.builder(
//         padding: EdgeInsets.all(16.0),
//         itemBuilder: /*1*/ (context, i) {
//           if (i.isOdd) return Divider(); /*2*/
//
//           final index = i ~/ 2; /*3*/
//           if (index >= _suggestions.length) {
//             _suggestions.addAll(generateWordPairs().take(10)); /*4*/
//           }
//           return _buildRow(_suggestions[index]);
//         });
//   }
//
//   Widget _buildRow(WordPair pair) {
//     final alreadySaved = _saved.contains(pair);
//     return ListTile(
//       title: Text(
//         pair.asPascalCase,
//         style: _biggerFont,
//       ),
//       trailing: Icon(
//         alreadySaved ? Icons.favorite : Icons.favorite_border,
//         color: alreadySaved ? Colors.red: null
//       ),
//       onTap: () {
//         setState(() {
//           if(alreadySaved){
//             _saved.remove(pair);
//           }else{
//             _saved.add(pair);
//           }
//         });
//       },
//     );
//   }
//
//   void _pushSaved() {
//     Navigator.of(context).push(
//       MaterialPageRoute<void>(
//         // NEW lines from here...
//         builder: (BuildContext context) {
//           final tiles = _saved.map(
//                 (WordPair pair) {
//               return ListTile(
//                 title: Text(
//                   pair.asPascalCase,
//                   style: _biggerFont,
//                 ),
//               );
//             },
//           );
//           final divided = ListTile.divideTiles(
//             context: context,
//             tiles: tiles,
//           ).toList();
//
//           return Scaffold(
//             appBar: AppBar(
//               title: Text('Saved Suggestions'),
//             ),
//             body: ListView(children: divided),
//           );
//         }, // ...to here.
//       ),
//     );
//   }
// }
