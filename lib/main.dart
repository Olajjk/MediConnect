import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mediconnect/provider/local_provider.dart';
import 'package:mediconnect/provider/theme_provider.dart';
import 'package:mediconnect/theme/theme.dart';
import 'package:mediconnect/welcome.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => LocaleProvider()..setLocale(Locale("fr")),
        ),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        //ChangeNotifierProvider(create: (context) => Auth()),
      ],
      child: MainPage(),
    ),
  );
}

class MainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MainPageState();
  }
}

class MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return AdaptiveTheme(
      light: lightMode,
      dark: darkMode,
      initial: themeProvider.themeMode,
      builder: (theme, darkTheme) {
        WidgetsBinding.instance.addPostFrameCallback((_) {});
        return Consumer<LocaleProvider>(
          builder: (context, localeProvider, child) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: theme,
              darkTheme: darkTheme,
              locale: localeProvider.locale,
              localizationsDelegates: [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: [
                Locale('fr'),
                Locale('en'),
                Locale('es'),
                //Locale('yo'),
                //Locale('ha'),
              ],
              home: WelcomPage(),
            );
          },
        );
      },
    );
  }
}
