///[]
import 'dart:io';
import 'package:pie_chart/pie_chart.dart';

import 'package:band_names/models/band.dart';
import 'package:band_names/services/socket_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


///[]


///[]
class HomePage extends StatefulWidget {

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Band> bands = [];
///[]
///
  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context, listen: false );
    socketService.socket.on('active-bands', ( payload ) {
      this.bands = ( payload as List )
        .map((band) => Band.fromMap(band))
        .toList();
        setState(() {});
    });

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: Text('BandNames', style: TextStyle( color: Colors.black87 ) ),
        backgroundColor: Colors.white,
        actions: [
          Container(
            margin: EdgeInsets.only( right: 10 ),
            child: ( socketService.serverStatus == ServerStatus.Online ) ?
            Icon(Icons.check_circle, color: Colors.blue )
            : Icon( Icons.offline_bolt, color: Colors.red),
          )
        ],
      ),
      body: Column(
        children: [

          _showGraph(),
          Expanded(
            child: ListView.builder(
              itemCount: bands.length,
              itemBuilder: ( _, int i) => bandTile( bands[i] )
            )
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 1,
        child: Icon( Icons.add ),
        onPressed: addNewBand,
      ),
    );
  }


  Widget bandTile( Band band) {
    final socketService = Provider.of<SocketService>(context, listen: false);
    return Dismissible(
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) {
        socketService.socket.emit('delete-band', { 'id': band.id });
      },
      background: Container(
        color: Colors.red,
        padding: EdgeInsets.only( left: 8.0 ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text('Delete Band', style: TextStyle( color: Colors.white ))
        ),
      ),
      key: Key(band.id),
      child: ListTile(
        leading: CircleAvatar(
          child: Text( band.name.substring(0,2) ),
        ),
        title: Text( band.name ),
        trailing: Text('${ band.votes}', style: TextStyle( fontSize: 20 )),
        onTap: () {
          socketService.socket.emit('vote-band', {'id':band.id} );
        },
      ),
    );
  }

  addNewBand() {
    final textController = new TextEditingController();

    if ( Platform.isAndroid) {
      return showDialog(
        context: context,
        builder: ( context ) {
          return AlertDialog(
            title: Text('New band name'),
            content: TextField(
              controller: textController,
            ),
            actions: [
              MaterialButton(
                child: Text('Add'),
                elevation: 5,
                textColor: Colors.blue,
                onPressed: () => addBandToList(textController.text)
              )
            ],
          );
        }
      );
    }

    showCupertinoDialog(
      context: context,
      builder: (_) {
        return CupertinoAlertDialog(
          title: Text('New band name'),
          content: CupertinoTextField(
            controller: textController,
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: Text('Add'),
              onPressed: () => addBandToList(textController.text)
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              child: Text('Dismiss'),
              onPressed: () => Navigator.pop(context)
            )
          ],
        );
      }
    );

  }


  void addBandToList( String name ) {
    if ( name.length > 1 ) {
      final socketService = Provider.of<SocketService>(context, listen: false);
      socketService.socket.emit('add-band', {'name': name });
    }

    Navigator.pop(context);
  }

  Widget _showGraph() {
    Map<String, double> dataMap = {};
    bands.forEach((band) {
      dataMap.putIfAbsent(band.name, () => band.votes.toDouble());
    });

    return Container(
      width: double.infinity,
      height: 200,
      child: PieChart(dataMap: dataMap)
    );

  }
}