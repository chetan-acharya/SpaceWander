import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:permission_handler/permission_handler.dart';
import 'package:pinch_zoom_image/pinch_zoom_image.dart';
import 'package:toast/toast.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class FullScreenPage extends StatelessWidget {
  String imageUrl = '';
  String imageInfo = '';
  bool showInfo = false;
  FullScreenPage({this.imageUrl, this.imageInfo, this.showInfo});
  @override
  Widget build(BuildContext context) {
    if (imageUrl != '') {
      Paint paint = Paint();
      paint.color = Colors.white38;
      return PinchZoomImage(
  image: CachedNetworkImage(
        imageUrl: imageUrl,
        imageBuilder: (context, imageProvider) => Container(
          child: Center(
              child: Text(
            showInfo ? imageInfo : "",
            style: TextStyle(
                color: Colors.black,
                background: paint,
                fontSize: 18,
                fontWeight: FontWeight.w500,
                wordSpacing: 1.0,
                fontStyle: FontStyle.italic),
          )),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.fill,
            ),
          ),
        ),
        placeholder: (context, url) =>
            new ImageLoader(), //CircularProgressIndicator(),
        errorWidget: (context, url, error) => Icon(Icons.error),
      ),
  zoomedBackgroundColor: Color.fromRGBO(240, 240, 240, 1.0),
  hideStatusBarWhileZooming: true,
);
    } else {
      return Text("Jouney of Space is starting...");
    }
  }
}

class ImageLoader extends StatelessWidget {
  const ImageLoader({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(20.5),
        child: Container(
            color: Colors.black,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(26, 20, 26, 20),
                  child: new CircularProgressIndicator(),
                ),
                new Text("A new image of far space coming up...  ",
                    style: TextStyle(color: Colors.white)),
              ],
            )));
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String imageUrl = '';
  bool isInitialized = false;
  String imageInfo = '';
  bool showInfo = false;
  String btnQuality = 'SD';
  String btnShowInfo = 'Info OFF';
  String imageQuality = 'url';
  String _dateTimeString = new DateTime.now().year.toString() +
      '-' +
      new DateTime.now().month.toString() +
      '-' +
      new DateTime.now().day.toString();
  http.Response _response;

  @override
  void initState() {
    super.initState();
    _refresh();
    isInitialized = true;
  }

  Future _refresh() async {
    if (!isInitialized) {
      await Future.delayed(new Duration(milliseconds: 300));
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
            child: new Container(
                color: Colors.black,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                      child: new CircularProgressIndicator(),
                    ),
                    new Text("Connecting to NASA...",
                        style: TextStyle(color: Colors.white)),
                  ],
                )));
      },
    );

    Random day = new Random();
    Random month = new Random();
    Random year = new Random();
    int minday = 1, maxday = 28;
    int dayValue = minday + day.nextInt(maxday - minday);
    int minmonth = 1, maxmonth = 12;
    int monthValue = minmonth + day.nextInt(maxmonth - minmonth);
    int minyear = 2016, maxyear = 2018;
    int yearValue = minyear + day.nextInt(maxyear - minyear);
    _dateTimeString = "$yearValue-$monthValue-$dayValue";

    _response = await http.get(
        'https://api.nasa.gov/planetary/apod?date=$_dateTimeString&api_key=YOUR_NASA_API_KEY');
    Navigator.pop(context);
    Map<String, dynamic> jsonResponse =
        json.decode(_response.body); // JsonDecoder().convert(_response.body);
    // imageUrl = jsonResponse['url'];

    setState(() {
      imageInfo = jsonResponse["explanation"];
      imageUrl = jsonResponse[imageQuality];
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
        // appBar: AppBar(
        //   // Here we take the value from the MyHomePage object that was created by
        //   // the App.build method, and use it to set our appbar title.
        //   title: Text(widget.title),
        // ),
        body: Stack(children: [
      Center(
          child: FullScreenPage(
              imageUrl: imageUrl, imageInfo: imageInfo, showInfo: showInfo)),
      Align(
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            RaisedButton(
                onPressed: () => _changeImageQuality(),
                child: btnQuality == 'HD'
                    ? Icon(Icons.hdr_on)
                    : Icon(Icons.hdr_off)),
            RaisedButton(
                onPressed: () => _refresh(), child: Icon(Icons.flight)),
            RaisedButton(
                onPressed: () => _showHideInfo(),
                child: btnShowInfo == 'Info ON'
                    ? Icon(Icons.speaker_notes)
                    : Icon(Icons.speaker_notes_off)),
            RaisedButton(
                onPressed: () => _downloadImage(),
                child: Icon(Icons.file_download)),
          ],
        ),
      ),
    ])

        // This trailing comma makes auto-formatting nicer for build methods.
        );
  }

  _changeImageQuality() {
    imageQuality = imageQuality == 'url' ? 'hdurl' : 'url';
    setState(() {
      btnQuality = btnQuality == 'HD' ? 'SD' : 'HD';
    });
    _refresh();
  }

  _showHideInfo() {
    showInfo = !showInfo;
    setState(() {
      btnShowInfo = btnShowInfo == 'Info OFF' ? 'Info ON' : 'Info OFF';
    });
  }

  _downloadImage() async {
    List<PermissionGroup> permissionList = new List<PermissionGroup>();
    permissionList.add(PermissionGroup.storage);
    final Map<PermissionGroup, PermissionStatus> status =
        await PermissionHandler().requestPermissions(permissionList);
    if (status.values.first == PermissionStatus.granted) {
      Toast.show("Download started !", context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);

// await ImageDownloader.downloadImage(imageUrl,
      //                             destination: AndroidDestinationType.directoryDownloads,
      // );

      Dio dio = Dio();
      try {
        var dir = '/storage/emulated/0';//await getExternalStorageDirectories(type: StorageDirectory.downloads);
        String progressString = '0%';


        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Dialog(
                child: new Container(
                    color: Colors.black,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                          child: new CircularProgressIndicator(),
                        ),
                        new Text("$progressString Downloaded...",
                            style: TextStyle(color: Colors.white)),
                      ],
                    )));
          },
        );

        await dio.download(imageUrl, "${dir}/SpaceWander${DateTime.now().toString()}.jpeg",
            onReceiveProgress: (rec, total) {
          setState(() {
            progressString = ((rec / total) * 100).toStringAsFixed(0) + "%";
          });
          if (progressString == "100%") {
            Navigator.pop(context);
            Toast.show("Download completed !", context,
                duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
          }
        });
      } catch (e) {
        Toast.show(e.toString(), context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      }
    } else {
      Toast.show("Allow permission to continue", context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
    }
  }
}

