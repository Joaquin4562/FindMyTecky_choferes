import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'dart:async';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InterChocPage extends StatefulWidget {
  @override
  _InterChocPageState createState() => _InterChocPageState();
}

class _InterChocPageState extends State<InterChocPage> {

  bool disabledApagar = true;
  bool disabledEncender = false;
  Location location = new Location();
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  StreamSubscription<LocationData> locationSubscription;
  bool usado = false;
  String dropdownValue = 'Escoja una ruta';
  final databaseReference = Firestore.instance;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;  
    
    return Scaffold(
      body: Container(
        width: width,
        decoration: BoxDecoration(
          color: Colors.black,
          image: DecorationImage(
              image: AssetImage("assets/fondo.png"), fit: BoxFit.cover),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: width - 200,
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: AssetImage('assets/logo.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(
              height: 50,
            ),
            Divider(),
            Text(
              'Hola! RECUERDA PRESIONAR EL BOTON DE ENCENDIDO para que los pasajeros sepan tu ubicación',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            DropdownButton<String>(
              value: dropdownValue,
              icon: Icon(Icons.arrow_downward),
              iconSize: 24,
              elevation: 16,
              style: TextStyle(color: Colors.blueGrey),
              underline: Container(
                height: 2,
                color: Colors.blueGrey,
              ),
              onChanged: (String newValue) {
                setState(() {
                  dropdownValue = newValue;
                });
              },
              items: <String>['Escoja una ruta', 'Centro', 'Linares', 'Rotaria']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            Divider(),
           _encender(),
           Divider(),
           _apagar(),
          ],
        ),
      ),
    );
  }

  Widget _encender() {
    return Container(
      height: 50,
      width: 300,
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            spreadRadius: 0,
            offset: Offset(0, 4.0))
      ]),
      child: RaisedButton(
        child: Text(
          'ENCENDER',
          style: TextStyle(fontSize: 16),
        ),
        elevation: (10),
        color: Colors.greenAccent,
        textColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        onPressed: disabledEncender ? null : _disponibilidadEncender(),
      ),
    );
  }

 Widget _apagar() {
    return Container(
      height: 50,
      width: 300,
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            spreadRadius: 0,
            offset: Offset(0, 4.0))
      ]),
      child: RaisedButton(
        child: Text(
          'APAGAR',
          style: TextStyle(fontSize: 16),
        ),
        elevation: (10),
        color: Colors.redAccent,
        textColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        onPressed: disabledApagar ? null : _disponibilidadApagar(),
      ),
    );
  }

  Function _disponibilidadEncender() 
  {
    return(){
      if(dropdownValue != 'Escoja una ruta')
      {
        setState(() {
        disabledEncender = true;
        disabledApagar = false;         
        });   
        print('Hola desde encender'); 
        _ubicaciones();         
      }
      else
      {
        Fluttertoast.showToast(
        msg: "Por favor seleccione una ruta",
        backgroundColor: Colors.white,
        fontSize: 20,
        gravity: ToastGravity.TOP,
        textColor: Colors.black,
        );
      }
    };
      
  }

  Function _disponibilidadApagar() 
  {
    return(){
        setState(() {
          disabledEncender = false;
          disabledApagar = true;         
        });   
        print('Hola desde apagar'); 
        locationSubscription.pause();         
      };
  }

  void updateData (LocationData datos) { 
    try { 
      databaseReference.collection('Transportes').document('$dropdownValue').updateData({ 'latitud' : '${datos.latitude}','longitud' : '${datos.longitude}'}); 
    } 
    catch(e) 
    { 
      print(e.toString()); 
    } 
  }

  void _ubicaciones() async
  {
    if(usado == false)
    {
      usado = true;
      _serviceEnabled = await location.serviceEnabled();
      
      if(!_serviceEnabled) 
      {
        _serviceEnabled = await location.requestService();

        if (!_serviceEnabled) 
        {
          return;
        }
      }

      _permissionGranted = await location.hasPermission();

      if (_permissionGranted == PermissionStatus.denied) 
      {
        _permissionGranted = await location.requestPermission();

        if (_permissionGranted != PermissionStatus.granted) 
        {
          return;
        }
      }

      locationSubscription = location.onLocationChanged.listen((_locationData) {updateData(_locationData);});
    }
    else
    {
      locationSubscription.resume();
    }
    
    }

  }

