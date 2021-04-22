// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:flutter_gen/gen_l10n/gallery_localizations.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:gallery/routes.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gallery/constants.dart';
import 'package:gallery/data/gallery_options.dart';
import 'package:gallery/pages/backdrop.dart';
import 'package:gallery/pages/splash.dart';
import 'package:gallery/themes/gallery_theme_data.dart';
export 'package:gallery/data/demos.dart' show pumpDeferredLibraries;

// Import the firebase_core plugin
import 'package:firebase_core/firebase_core.dart';

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;
  runApp(GalleryApp());
}

class GalleryApp extends StatelessWidget {
   GalleryApp({
    Key key,
    this.initialRoute,
    this.isTestMode = false,
  }) : super(key: key);

  // Create the initialization Future outside of `build`:
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  final bool isTestMode;
  final String initialRoute;

  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
      // Initialize FlutterFire:
      future: _initialization,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          print('Firebase not reachable....');
          return Container();
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          print('Firebase - connection established');
          return ModelBinding(
            initialModel: GalleryOptions(
              themeMode: ThemeMode.system,
              textScaleFactor: systemTextScaleFactorOption,
              customTextDirection: CustomTextDirection.localeBased,
              locale: null,
              timeDilation: timeDilation,
              platform: defaultTargetPlatform,
              isTestMode: isTestMode,
            ),
            child: Builder(
              builder: (context) {
                return MaterialApp(
                  restorationScopeId: 'rootGallery',
                  title: 'Flutter Gallery',
                  debugShowCheckedModeBanner: false,
                  themeMode: GalleryOptions.of(context).themeMode,
                  theme: GalleryThemeData.lightThemeData.copyWith(
                    platform: GalleryOptions.of(context).platform,
                  ),
                  darkTheme: GalleryThemeData.darkThemeData.copyWith(
                    platform: GalleryOptions.of(context).platform,
                  ),
                  localizationsDelegates: const [
                    ...GalleryLocalizations.localizationsDelegates,
                    LocaleNamesLocalizationsDelegate()
                  ],
                  initialRoute: initialRoute,
                  supportedLocales: GalleryLocalizations.supportedLocales,
                  locale: GalleryOptions.of(context).locale,
                  localeResolutionCallback: (locale, supportedLocales) {
                    deviceLocale = locale;
                    return locale;
                  },
                  onGenerateRoute: RouteConfiguration.onGenerateRoute,
                );
              },
            ),
          );
        }

        // Otherwise, show something whilst waiting for initialization to complete
        print('Loading....');
        return Container();
      },
    );


      }
}

class RootPage extends StatelessWidget {
  const RootPage({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const ApplyTextOptions(
      child: SplashPage(
        child: Backdrop(),
      ),
    );
  }
}
