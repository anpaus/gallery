// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:flutter_gen/gen_l10n/gallery_localizations.dart';
import 'package:gallery/layout/adaptive.dart';

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

const appBarDesktopHeight = 128.0;
Future<Album> futureAlbum;
int selectedItem = 1;

Future<Album> fetchAlbum(String i) async {
  final String s = 'jsonplaceholder.typicode.com';
  final String a = 'albums/' + i;
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
    notifyListeners();
  }
}


class Album {
  final int userId;
  final int id;
  final String title;

  Album({@required this.userId, @required this.id, @required this.title});

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      userId: json['userId'],
      id: json['id'],
      title: json['title'],
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
              child: Scaffold(
                appBar: const AdaptiveAppBar(
                  isDesktop: true,
                ),
                body: Consumer<AlbumModel>(
                  builder: (context, cart, child) {
                    return BodyDynamic();
                  }),
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
        IconButton(
          icon: const Icon(Icons.share),
          tooltip: GalleryLocalizations.of(context).starterAppTooltipShare,
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.favorite),
          tooltip: GalleryLocalizations.of(context).starterAppTooltipFavorite,
          onPressed: () {},
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
                  future: fetchAlbum(i.toString()),
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
                    futureAlbum = fetchAlbum(selectedItem.toString());
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
    futureAlbum = fetchAlbum(selectedItem.toString());
  }



  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final isDesktop = isDisplayDesktop(context);
    return SafeArea(
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

          ],
        ),
      ),
    );
  }
}
