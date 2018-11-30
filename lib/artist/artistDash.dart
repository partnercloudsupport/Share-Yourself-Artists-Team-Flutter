import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:share_yourself_artists_team_flutter/artist/artistSendArt.dart';
import 'package:share_yourself_artists_team_flutter/artist/artistUploadImage.dart';
import 'package:share_yourself_artists_team_flutter/authentication/inMemory.dart';
import 'package:share_yourself_artists_team_flutter/user/drawer.dart';

class ArtistDash extends StatefulWidget {
  ArtistDash();

  @override
  _ArtistDashState createState() => new _ArtistDashState();
}

class _ArtistDashState extends State<ArtistDash> {
  double _screenWidth;
  bool _cardView = true;
  String _uid;

  @override
  void initState() {
    super.initState();

    // Grab the saved uid of current user from memory
    loadUid().then((uid) {
      print('init: current uid: ${uid}');
      _uid = uid;
    });
  }

  void _navigateUpload() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ArtistUploadImage()),
    );
  }

  void _navigateSend(AsyncSnapshot<QuerySnapshot> snapshot, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ArtistSendArt(
                snapshot: snapshot,
                index: index,
              )),
    );
  }

  Widget _buildList(BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot,
      int index, int len) {
    int newIndex = len - index - 1;
    String artImage = snapshot.data.documents[newIndex]['url'].toString();
    String artTitle = snapshot.data.documents[newIndex]['art_title'].toString();
    String artDescription =
        snapshot.data.documents[newIndex]['description'].toString();
    int uploadDate = snapshot.data.documents[newIndex]['upload_date'];

    DateTime upload =
        DateTime.fromMillisecondsSinceEpoch(uploadDate, isUtc: false);
    String dateString = upload.month.toString() +
        '-' +
        upload.day.toString() +
        '-' +
        upload.year.toString();

    if (!_cardView) {
      return new Column(
        children: <Widget>[
          Dismissible(
            // Show a red background as the item is swiped away
            background: Container(
              color: Colors.green,
            ),
            key: Key(artTitle + Random().nextInt(1000000).toString()),
            onDismissed: (direction) {
              // send to business
              _navigateSend(snapshot, index);
            },
            child: ListTile(
              title: Text(artTitle),
              subtitle: Text(artDescription),
            ),
          ),
          new Divider(
            height: 5.0,
          ),
        ],
      );
    } else {
      return new Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: _screenWidth * .1),
            ),
            Image.network(
              artImage,
              width: MediaQuery.of(context).size.width * .75,
            ),
            ListTile(
              title: Text(
                artTitle,
                textAlign: TextAlign.center,
              ),
              subtitle: Text(dateString, textAlign: TextAlign.center),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  artDescription,
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 4.0),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.send),
                  color: Color.fromRGBO(255, 160, 0, 1.0),
                  onPressed: () {
                    _navigateSend(snapshot, newIndex);
                  },
                ),
              ],
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = 'Dashboard';
    _screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        title: new Image.asset('images/logo.png'),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: _cardView ? Icon(Icons.list) : Icon(Icons.image),
            onPressed: () {
              setState(() {
                _cardView = !_cardView;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.file_upload),
            onPressed: () {
              _navigateUpload();
            },
          ),
        ],
      ),
      drawer: NavDrawer(),
      body: StreamBuilder(
        stream: Firestore.instance
            .collection('art')
            .where('artist_id', isEqualTo: '${_uid}')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Text("Loading..."),
              ],
            );
          }
          if (snapshot.data.documents.length == 0) {
            return new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Text("No Art, Why dont you upload some!"),
              ],
            );
          }
          return new Container(
            child: ListView.builder(
              itemBuilder: (BuildContext ctxt, int index) => _buildList(
                  context, snapshot, index, snapshot.data.documents.length),
              itemCount: snapshot.data.documents.length,
            ),
          );
        },
      ),
    );
  }
}
