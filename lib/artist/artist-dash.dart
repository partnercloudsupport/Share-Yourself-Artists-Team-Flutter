import 'package:flutter/material.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_yourself_artists_team_flutter/authentication/authentication.dart';
import 'package:share_yourself_artists_team_flutter/artist/artist-upload-image.dart';
import 'package:share_yourself_artists_team_flutter/artist/send-art.dart';

class ArtistDash extends StatefulWidget {
  final String uid;
  final Authentication authentication;
  final VoidCallback handleSignOut;

  ArtistDash({@required this.uid, this.authentication, this.handleSignOut});

  @override
  _ArtistDashState createState() => new _ArtistDashState();
}

class _ArtistDashState extends State<ArtistDash> {
  double _screenWidth;
  bool _cardView = false;

  @override
  void initState() {
    super.initState();
  }

  void _navigateUpload() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ArtistUploadImage(
            authentication: widget.authentication,
            handleSignOut: widget.handleSignOut,
          )),
    );
  }

  void _navigateSend(AsyncSnapshot<QuerySnapshot> snapshot, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => SendArt(
            snapshot: snapshot,
            index: index,
          )),
    );
  }

  Widget _buildList(BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot, int index) {
    String artImage = snapshot.data.documents[index]['url'].toString();
    String artTitle = snapshot.data.documents[index]['art_title'].toString();
    String artDescription = snapshot.data.documents[index]['description'].toString();
    int uploadDate = snapshot.data.documents[index]['upload_date'];

    DateTime upload = DateTime.fromMillisecondsSinceEpoch(uploadDate, isUtc: false);
    String dateString = upload.month.toString() + '-' + upload.day.toString() + '-' + upload.year.toString();

    if (!_cardView) {
      return new Dismissible(
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
              subtitle:
              Text(
                  dateString,
                  textAlign: TextAlign.center),
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
                  onPressed: () { _navigateSend(snapshot, index); },
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

    return MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            iconTheme: IconThemeData(color: Colors.black),
            backgroundColor: Color.fromRGBO(255, 160, 0, 1.0),
            title: Text(
              title,
              style: TextStyle(
                color: Colors.black,
              ),
            ),
            actions: <Widget>[
              IconButton(
                icon: _cardView ? Icon(Icons.list) : Icon(Icons.image),
                onPressed: () { setState(() {
                  _cardView = !_cardView;
                }); },
              ),
              IconButton(
                  icon: Icon(Icons.file_upload),
                  onPressed: () {_navigateUpload(); },
              ),
            ],
          ),
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                UserAccountsDrawerHeader(
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(255, 160, 0, 1.0),
                  ),
                  accountName: new Text('Artist'),
                  accountEmail: new Text('gmail.com'),
                  currentAccountPicture: new CircleAvatar(
                    backgroundColor: Colors.white,
                    child: new Text('T'),
                  ),
                ),
                ListTile(
                  title: new Text('Log Out'),
                  onTap: () async {
                    await widget.authentication.signOut();
                    widget.handleSignOut();
                  },
                ),
              ],
            ),
          ),
          body: StreamBuilder(
              stream: Firestore.instance
                  .collection('art')
                  .where('artist_id', isEqualTo: 'H2kEJMbkyxUhcAfKH1jcMeDOn442')
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) return new Text('Loading...');
                return new Container(
                  child: ListView.builder(
                    itemBuilder: (BuildContext ctxt, int index) =>
                        _buildList(context, snapshot, index),
                    itemCount: snapshot.data.documents.length,
                  ),
                );
              },
            ),
        ),
      );
  }
}