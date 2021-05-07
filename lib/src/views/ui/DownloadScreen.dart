


import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/src/views/ui/InitialMap.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:select_form_field/select_form_field.dart';

final List<Map<String, dynamic>> _items = [
  {
    'value': '11',
    'label': 'Bogotá D.C',
  },
  {
    'value': '91',
    'label': 'Amazonas',
  },
  {
    'value': '25',
    'label': 'Cundinamarca',
  },
];

String valueDepto = "11";

class DownloadScreen extends StatefulWidget {

  @override
  _DownloadScreenState createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {

  bool downloading =  false;
  String downloadStr = "No data";
  double download = 0.0;
  double _downloadProgress = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xffffffff),
        body: Center(
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: RichText(text:
                    TextSpan(
                        text: "Descargas",
                        style: TextStyle(
                            fontSize: 30.0,
                            color:  hexToColor("#B91450"),
                            fontWeight: FontWeight.bold
                        )
                    )),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20, bottom:20),
                  child:TextButton.icon(
                    icon: Icon(Icons.cloud_download_outlined ),
                    label: Text("Descargar manzanas/departamento"),
                    style: TextButton.styleFrom(
                      primary: Colors.white,
                      backgroundColor: hexToColor("#B91450"),
                      onSurface: Colors.white,
                      // shadowColor: Colors.black,
                      // textStyle: TextStyle(
                      //   color: Colors.white
                      // )
                    ),
                    onPressed:(){
                      showDialogDeptos(context);
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20, bottom:20),
                  child: TextButton.icon(
                    icon: Icon(Icons.cloud_download_outlined ),
                    label: Text("Descargar manzanas/ubicación"),
                    style: TextButton.styleFrom(
                      primary: Colors.white,
                      backgroundColor: hexToColor("#B91450"),
                      onSurface: Colors.white,
                      // shadowColor: Colors.black,
                      // textStyle: TextStyle(
                      //   color: Colors.white
                      // )
                    ),
                    onPressed:null,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top:30,bottom:30),
                  child: OutlinedButton(
                    child: Text("Ir a mapa"),
                    style: OutlinedButton.styleFrom(
                      primary: hexToColor("#B91450"),
                        side: BorderSide(
                            color: hexToColor("#B91450"),
                            width: 1
                        ),
                      onSurface: hexToColor("#B91450"),
                    ),
                    onPressed: (){
                      Navigator.push(context,
                          MaterialPageRoute(
                              builder: (_) => InitialMap()));
                    },
                  )
                ),
          downloading?Container(
              height:200,
              width:200,
              child: Card(
                  color: Colors.white,
                  child:Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(value:_downloadProgress, valueColor: new AlwaysStoppedAnimation(hexToColor("#B91450")),),
                        SizedBox(height:20),
                        Text(downloadStr,style:TextStyle(color:hexToColor("#B91450")))
                      ]
                  )
              ),
          ):Container(
            child: download==0?Text(" "):download==100?Text("Descarga terminada!!",style:TextStyle(color: hexToColor("#B91450"))):Text("")

          )
              ],
            )
            // child:
          )

        )
    );
  }

  void downloadBD(String ciudad,BuildContext contexts){
    var url_geoportal = "https://geoportal.dane.gov.co/descargas/mgn_cnpv_2018/$ciudad.db";
    File f;
    Dio dio = Dio();
    final dir = Directory("storage/emulated/0/ARCNPV2018/db");
    f = File("${dir.path}/$ciudad.db");
    String fileName = url_geoportal.substring(url_geoportal.lastIndexOf("/") + 1);
    Navigator.pop(contexts);
    // Navigator.of(contexts, rootNavigator: true).pop();
    dio.download(url_geoportal, "${dir.path}/$fileName",onReceiveProgress: (rec,total){
      setState((){
          downloading = true;
          _downloadProgress = (rec/total);
          download = _downloadProgress*100;
          // print(fileName);

          if(download == 100){
            downloadStr = "db descargada";
            downloading = false;
          }else{
            downloadStr = "Descargando " + (download).toStringAsFixed(0) + "%";
          }
          // print(downloadStr);
      });
    });
    print(url_geoportal);

  }

  Widget showDialogDeptos(BuildContext context){

    showDialog(
        context: context,
        builder: (BuildContext contextDialog) {
          return AlertDialog(
              title: Text("Descargar departamento", style: TextStyle(color:hexToColor("#B91450") ),),
              content: Wrap(
                children: [
                  Center(
                      child: Container(
                        child: Column(
                          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          // mainAxisSize: MainAxisSize.min,
                            children: [
                              SelectFormField(
                                type: SelectFormFieldType.dropdown, // or can be dialog
                                initialValue: '11',
                                items: _items,
                                onChanged: (val) => valueDepto = val,
                                onSaved: (val) => print(val),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top:20,bottom:20),
                                child: TextButton.icon(
                                  icon: Icon(Icons.cloud_download_outlined ),
                                  label: Text("Descargar"),
                                  style: TextButton.styleFrom(
                                    primary: Colors.white,
                                    backgroundColor: hexToColor("#B91450"),
                                    onSurface: Colors.white,
                                  ),
                                  onPressed:(){

                                    downloadBD(valueDepto,contextDialog);
                                    // showDialogDeptos(context);
                                  },
                                ),
                              ),

                            ]
                        ),
                      )
                  ),
                  downloading?downloadSection():Container()
                ],
              )
          );
        });
  }

  Widget downloadSection(){
    return Container(
        height:200,
        width:200,
        child: Card(
        color: Colors.pink,
        child:Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        CircularProgressIndicator(backgroundColor: Colors.white,),
    SizedBox(height:20),
    Text(downloadStr,style:TextStyle(color:Colors.white))
    ]
    )
    )
    );
  }
}

/// Construct a color from a hex code string, of the format #RRGGBB.
Color hexToColor(String code) {
  return new Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
}




void showSnackBar(String value,BuildContext context)
{
  Fluttertoast.showToast(
      msg: value,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM
  );
}



