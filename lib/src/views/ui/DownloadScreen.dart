


import 'package:flutter/material.dart';
import 'package:flutter_app/src/views/ui/InitialMap.dart';
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

class DownloadScreen extends StatefulWidget {

  @override
  _DownloadScreenState createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {

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
                )
              ],
            )
            // child:
          )

        )
    );
  }
}

/// Construct a color from a hex code string, of the format #RRGGBB.
Color hexToColor(String code) {
  return new Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
}

Widget showDialogDeptos(BuildContext context){
  showDialog(
      context: context,
      builder: (BuildContext contextDialog) {
        return AlertDialog(
          title: Text("Descargar departamento", style: TextStyle(color:hexToColor("#B91450") ),),
          content: SelectFormField(
            type: SelectFormFieldType.dropdown, // or can be dialog
            initialValue: '11',
            items: _items,
            onChanged: (val) => showSnackBar(val,context),
            onSaved: (val) => print(val),
          ),
        );
      });
}

void showSnackBar(String value,BuildContext context)
{
  final snackBar = SnackBar(content: Text(value));
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
  print(value);

}

