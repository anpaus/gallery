// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import 'package:flutter_gen/gen_l10n/gallery_localizations.dart';
import 'package:gallery/layout/adaptive.dart';

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'package:mime_type/mime_type.dart';
import 'package:image_picker_web_redux/image_picker_web_redux.dart';
import 'package:path/path.dart' as Path;

import 'package:gallery/ml.dart';
import 'package:js/js_util.dart' as jsutil;
import 'dart:html' as html;

const appBarDesktopHeight = 128.0;
Future<Album> futureAlbum;
int selectedItem = 1;
Image fromPicker;
MediaInfo mediaData;
final _listOfMap = <ImageResults>[];
String p = '';

Future selectImage() async {
  //fromPicker = await ImagePickerWeb.getImage(outputType: ImageType.widget);
  mediaData = await ImagePickerWeb.getImageInfo;
  print(mediaData.fileName);
  fromPicker = Image.memory(mediaData.data);

  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  String mimeType = mime(Path.basename(mediaData.fileName));
  //html.File mediaFile = new html.File(mediaData.data, mediaData.fileName, {'type': mimeType});
  try {
    firebase_storage.SettableMetadata metadata =
    firebase_storage.SettableMetadata(
      contentType: 'image/jpeg'
    );
    await firebase_storage.FirebaseStorage.instance
        .ref(mediaData.fileName)
        .putData(mediaData.data, metadata);
    String downloadURL = await firebase_storage.FirebaseStorage.instance
        .ref(mediaData.fileName)
        .getDownloadURL();
    print(downloadURL);

    myFunction();

    html.document.getElementById("img").setAttribute('src', downloadURL);
    Image image = Image.memory(mediaData.data);
    image.image
        .resolve(ImageConfiguration())
        .addListener(ImageStreamListener((ImageInfo info, bool isSync) {
      html.document.getElementById("img").setAttribute('width', info.image.width.toString());
      html.document.getElementById("img").setAttribute('height', info.image.height.toString());
      print(info.image.width);
      print(info.image.height);
    }));

  } on firebase_core.FirebaseException catch (e) {
    print(e);
  }

}

Future<Album> fetchAlbum(String i) async {
  final String s = 'reqres.in';
  final String a = 'api/users/' + i;
  final response = await http.get(Uri.https(s,a));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.

    return Album.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album ' + s + a);
  }
}

class AlbumModel extends ChangeNotifier {
  void refresh() {
    print("Listeners Notified");
    notifyListeners();
  }
}


class Album {
  final int userId;
  final String id;
  final String title;

  Album({@required this.userId, @required this.id, @required this.title});

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      userId: json['data']['id'],
      id: json['data']['email'],
      title: json['data']['first_name'],
    );
  }

  String getTitle() => title;
}



class HomePage extends StatelessWidget {
  const HomePage();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final isDesktop = isDisplayDesktop(context);

    final body = SafeArea(
      child: Padding(
        padding: isDesktop
            ? const EdgeInsets.symmetric(horizontal: 72, vertical: 48)
            : const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              /*GalleryLocalizations.of(context).starterAppGenericHeadline*/ selectedItem.toString(),
              style: textTheme.headline3.copyWith(
                color: colorScheme.onSecondary,
              ),

            ),
            const SizedBox(height: 10),
            Text(
              GalleryLocalizations.of(context).starterAppGenericSubtitle,
              style: textTheme.subtitle1,
            ),
            const SizedBox(height: 48),
            Text(
              GalleryLocalizations.of(context).starterAppGenericBody,
              style: textTheme.bodyText1,
            ),

          ],
        ),
      ),
    );

    if (isDesktop) {
      /*return Row(
        children: [
          ListDrawer(),
          const VerticalDivider(width: 1),
          Expanded(
            child: Scaffold(
              appBar: const AdaptiveAppBar(
                isDesktop: true,
              ),
              body: BodyDynamic(),
              floatingActionButton: FloatingActionButton.extended(
                heroTag: 'Extended Add',
                onPressed: () {},
                label: Text(
                  GalleryLocalizations.of(context).starterAppGenericButton,
                  style: TextStyle(color: colorScheme.onSecondary),
                ),
                icon: Icon(Icons.add, color: colorScheme.onSecondary),
                tooltip: GalleryLocalizations.of(context).starterAppTooltipAdd,
              ),
            ),
          ),
        ],
      );*/
      return ChangeNotifierProvider(
        create: (context) => AlbumModel(),
        child: Row(
          children: [
            Consumer<AlbumModel>(
                builder: (context, cart, child) {
                  return ListDrawer();
                }),
            const VerticalDivider(width: 1),
            Expanded(
              child:
              Consumer<AlbumModel>(
              builder: (context, cart, child) {
                return Scaffold(
                appBar:
                  const AdaptiveAppBar(
                  isDesktop: true,
                  ),

                   body: Consumer<AlbumModel>(
                    builder: (context, cart, child) {
                    print('Rebuilding Body Dynamic');
                    return BodyDynamic();
                    }),
                floatingActionButton:
                  Consumer<AlbumModel>(
                  builder: (context, cart, child) {
                    return FloatingActionButton.extended(
                    heroTag: 'Extended Add',
                    onPressed: () async {
                    await selectImage();
                    var cart = context.read<AlbumModel>();
                    cart.refresh();
                    },
                      label: Text(
                        GalleryLocalizations.of(context).starterAppGenericButton,
                        style: TextStyle(color: colorScheme.onSecondary),
                        ),
                      icon: Icon(Icons.add, color: colorScheme.onSecondary),
                      tooltip: GalleryLocalizations.of(context).starterAppTooltipAdd,
                      );
                }),
                );
                })
            ),
          ],
        ),
      );
    } else {
      /*return Scaffold(
        appBar: const AdaptiveAppBar(),
        body: BodyDynamic(),
        drawer: ListDrawer(),
        floatingActionButton: FloatingActionButton(
          heroTag: 'Add',
          onPressed: () {},
          tooltip: GalleryLocalizations.of(context).starterAppTooltipAdd,
          child: Icon(
            Icons.add,
            color: Theme.of(context).colorScheme.onSecondary,
          ),
        ),
      );*/
      return ChangeNotifierProvider(
        create: (context) => AlbumModel(),
        child: Scaffold(
          appBar: const AdaptiveAppBar(),
          body: Consumer<AlbumModel>(
              builder: (context, cart, child) {
                return BodyDynamic();
              }),
          drawer: Consumer<AlbumModel>(
              builder: (context, cart, child) {
                return ListDrawer();
              }),
          floatingActionButton: FloatingActionButton(
          heroTag: 'Add',
          onPressed: () {},
          tooltip: GalleryLocalizations.of(context).starterAppTooltipAdd,
          child: Icon(
          Icons.add,
          color: Theme.of(context).colorScheme.onSecondary,
          ),
          ),
          ),
      );
    }
  }
}

class AdaptiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AdaptiveAppBar({
    Key key,
    this.isDesktop = false,
  }) : super(key: key);

  final bool isDesktop;

  @override
  Size get preferredSize => isDesktop
      ? const Size.fromHeight(appBarDesktopHeight)
      : const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    return AppBar(
      automaticallyImplyLeading: !isDesktop,
      title: isDesktop
          ? null
          : Text(GalleryLocalizations.of(context).starterAppGenericTitle),
      bottom: isDesktop
          ? PreferredSize(
              preferredSize: const Size.fromHeight(26),
              child: Container(
                alignment: AlignmentDirectional.centerStart,
                margin: const EdgeInsetsDirectional.fromSTEB(72, 0, 0, 22),
                child: Text(
                  GalleryLocalizations.of(context).starterAppGenericTitle,
                  style: themeData.textTheme.headline6.copyWith(
                    color: themeData.colorScheme.onPrimary,
                  ),
                ),
              ),
            )
          : null,
      actions: [
        Consumer<AlbumModel>(
            builder: (context, cart, child) {
          return IconButton(
          icon: const Icon(Icons.share),
          tooltip: GalleryLocalizations.of(context).starterAppTooltipShare,
          onPressed: () async {
            //var a = 'https://i.imgur.com/jbWVY0v.png';
            //var a = 'https://firebasestorage.googleapis.com/v0/b/anpaus-dart.appspot.com/o/Malbork.JPG?alt=media&token=f9b960d4-98f5-4a9e-a99b-9777d347a26d';
            print(html.document.getElementById("img").getAttribute('src'));
            print(html.document.getElementById("img").getAttribute('width'));
            print(html.document.getElementById("img").getAttribute('height'));
            List<Object> _val = await jsutil.promiseToFuture<List<Object>>(imageClassifier());
            //final _listOfMap = <ImageResults>[];

            _listOfMap.clear();
            p = '';

            for (final item in _val) {
              final _jsString = stringify(item);
              _listOfMap.add(jsonObject(_jsString));
            }

            for (final ImageResults _item in _listOfMap) {
              print('ClassName : ${_item.className}');
              print('Probability : ${_item.probability}\n');
              p += 'ClassName : ${_item.className} ';
              p += 'Probability : ${_item.probability} ';
            }

            print(p);

            var cart = context.read<AlbumModel>();
            cart.refresh();
          },
        );
        }),

        IconButton(
          icon: const Icon(Icons.favorite),
          tooltip: GalleryLocalizations.of(context).starterAppTooltipFavorite,
          onPressed: () async {
            log('Hello world!'); // invokes console.log() in JavaScript land
            myFunction();
            num x = await jsutil.promiseToFuture<num>(runPrediction());
            print('Prediction: ' + x.toString());
          },
        ),
        IconButton(
          icon: const Icon(Icons.search),
          tooltip: GalleryLocalizations.of(context).starterAppTooltipSearch,
          onPressed: () {},
        ),
      ],
    );
  }
}

class ListDrawer extends StatefulWidget {
  @override
  _ListDrawerState createState() => _ListDrawerState();
}

class _ListDrawerState extends State<ListDrawer> {

  static final numItems = 9;


  @override
  void initState() {
    super.initState();
    futureAlbum = fetchAlbum(selectedItem.toString());
  }



  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Drawer(
      child: SafeArea(
        child: ListView(
          children: [
            ListTile(
              title: Text(
                GalleryLocalizations.of(context).starterAppTitle,
                style: textTheme.headline6,
              ),
              subtitle: Text(
                GalleryLocalizations.of(context).starterAppGenericSubtitle,
                style: textTheme.bodyText2,
              ),
            ),
            const Divider(),

            ...Iterable<int>.generate(numItems).toList().map((i) {
              return ListTile(
                enabled: true,
                selected: i == selectedItem,
                leading: const Icon(Icons.favorite),
                title: FutureBuilder<Album>(
                  future: fetchAlbum((i+1).toString()),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Text(snapshot.data.title);
                    } else if (snapshot.hasError) {
                      return Text("${snapshot.error}");
                    }

                    // By default, show a loading spinner.
                    return Text("Loading...");
                  },
                ),
                onTap: () {
                  setState(() {
                    selectedItem = i;
                    futureAlbum = fetchAlbum((selectedItem+1).toString());
                    var cart = context.read<AlbumModel>();
                    cart.refresh();
                  });
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
class BodyDynamic extends StatefulWidget {
  @override
  _BodyDynamicState createState() => _BodyDynamicState();
}

class _BodyDynamicState extends State<BodyDynamic> {

  static final numItems = 9;


  @override
  void initState() {
    super.initState();
    futureAlbum = fetchAlbum((selectedItem+1).toString());
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final isDesktop = isDisplayDesktop(context);
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
        padding: isDesktop
            ? const EdgeInsets.symmetric(horizontal: 72, vertical: 48)
            : const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<Album>(
              future: futureAlbum,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(snapshot.data.id.toString());
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                }

                // By default, show a loading spinner.
                return Text("Loading...");
              },
            ),
            const SizedBox(height: 10),
            FutureBuilder<Album>(
              future: futureAlbum,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(snapshot.data.userId.toString());
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                }

                // By default, show a loading spinner.
                return Text("Loading...");
              },
            ),
            const SizedBox(height: 48),
            FutureBuilder<Album>(
              future: futureAlbum,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(snapshot.data.title);
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                }

                // By default, show a loading spinner.
                return Text("Loading...");
              },
            ),
            Container(
                margin: EdgeInsets.all(15),
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(
                    Radius.circular(15),
                  ),
                  border: Border.all(color: Colors.white),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      offset: Offset(2, 2),
                      spreadRadius: 2,
                      blurRadius: 1,
                    ),
                  ],
                ),
                child: (fromPicker != null)?
                fromPicker :
                Image.network('https://i.imgur.com/sUFH1Aq.png')
            ),
            const SizedBox(),
            Container(
                margin: EdgeInsets.all(15),
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(
                    Radius.circular(15),
                  ),
                  border: Border.all(color: Colors.white),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      offset: Offset(2, 2),
                      spreadRadius: 2,
                      blurRadius: 1,
                    ),
                  ],
                ),
                child: Text(p)
            ),

          ],
        ),
      ),
      )
    );
  }
}
