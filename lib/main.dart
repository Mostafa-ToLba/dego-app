
import 'package:dego/AppCubit/appCubit.dart';
import 'package:dego/AppCubit/appCubitStates.dart';
import 'package:dego/Screens/splashScreen/splashScreen.dart';
import 'package:dego/Shared/casheHelper/sharedPreferance.dart';
import 'package:dego/Shared/constans/constans.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sizer/sizer.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {

  Fluttertoast.showToast(msg: 'Hello from dego app');
}
 void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await MobileAds.instance.initialize();
  await CasheHelper.init();
  var dark;
   dark = CasheHelper.getData(key:'isDark');
  await translator.init(
    localeType: LocalizationDefaultType.device,
    languagesList: <String>['ar','en'],
    assetsDirectory: 'assets/lang/',
  );
  FirebaseMessaging.onMessage.listen((event) {
    print(event.data.toString());
  });

   FirebaseMessaging.onMessageOpenedApp.listen((event) {
     print(event.data.toString());
   });

   FirebaseMessaging.onBackgroundMessage((firebaseMessagingBackgroundHandler));
   if(dark==false||dark==null) {
     SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
          systemNavigationBarColor: color1,
          systemNavigationBarDividerColor:
          color1,
          systemNavigationBarIconBrightness:
          Brightness.dark,
          statusBarIconBrightness: Brightness.dark,
          statusBarColor: Colors.transparent,
          systemStatusBarContrastEnforced: true,statusBarBrightness: Brightness.dark
      ));
   }
   else
   {
     SystemChrome.setSystemUIOverlayStyle(
         const SystemUiOverlayStyle(
           systemNavigationBarColor: Colors.black,
           systemNavigationBarDividerColor: Colors.black,
           systemNavigationBarIconBrightness:Brightness.light,
           statusBarColor: Colors.transparent
         ));
   }

  runApp(LocalizedApp(child: MyApp(dark:dark,)));
}

class MyApp extends StatefulWidget {
  var dark;

   MyApp({required this.dark,Key? key }): super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _navigatorKey.currentState!.popUntil((route) => route.isCurrent);
    }
  }
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => AppCubit(InitialAppCubitState())..MakeItDark(shared:   widget.dark)..loadAppOpenAd()..createDatabase(),
      child: BlocConsumer<AppCubit,AppCubitStates>(
        listener: (BuildContext context, state) {  },
        builder: (BuildContext context, Object? state) {
          return Sizer(
            builder: (BuildContext context, Orientation orientation, DeviceType deviceType) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                navigatorKey: _navigatorKey,
                title: translator.activeLanguageCode!='ar'?'Dego':'ديجو',
                theme: ThemeData(
                  textSelectionTheme: const TextSelectionThemeData(
                    cursorColor: Colors.grey,
                  ),
                  fontFamily: translator.activeLanguageCode=='en'?engFont:arbFont,
                  appBarTheme:  AppBarTheme(elevation: 0,
                    iconTheme: IconThemeData(color: color2),
                  ),
                  primarySwatch: createMaterialColor(color1),
                  bottomNavigationBarTheme:  BottomNavigationBarThemeData(
                    unselectedLabelStyle: TextStyle(fontSize: 10.5.sp,fontWeight: FontWeight.w800,),
                    selectedLabelStyle: TextStyle(fontSize: 11.sp,fontWeight: FontWeight.w800,),
                  ),
                  tabBarTheme: TabBarTheme(labelStyle: TextStyle(fontSize: 11.5.sp,fontWeight: FontWeight.w700,fontFamily: translator.activeLanguageCode=='en'?engFont:arbFont
                  ),unselectedLabelStyle:TextStyle(fontSize: 11.5.sp,fontWeight: FontWeight.w600,fontFamily: translator.activeLanguageCode=='en'?engFont:arbFont
                  ), ),
                ),
                darkTheme: ThemeData(
                  textSelectionTheme: const TextSelectionThemeData(
                    cursorColor: Colors.grey,
                  ),
                  fontFamily: translator.activeLanguageCode=='en'?engFont:arbFont,
                  tabBarTheme: TabBarTheme(labelStyle: TextStyle(fontSize: 11.5.sp,fontWeight: FontWeight.w700,fontFamily: translator.activeLanguageCode=='en'?engFont:arbFont
                  ),unselectedLabelStyle:TextStyle(fontSize: 11.5.sp,fontWeight: FontWeight.w600,fontFamily: translator.activeLanguageCode=='en'?engFont:arbFont
                  ), ),
                  progressIndicatorTheme:const ProgressIndicatorThemeData(
                    color: Colors.white,
                  ),
                  textTheme:const TextTheme(
                    bodyText1:TextStyle(
                      color: Colors.white,
                      //   fontSize: 18,
                      //     fontWeight: FontWeight.w600,
                    ),
                    subtitle1: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  primarySwatch: createMaterialColor(color1),
                  scaffoldBackgroundColor: Colors.black,
                  appBarTheme: AppBarTheme(
                    actionsIconTheme: const IconThemeData(
                      color: Colors.white,
                    ),
                    backgroundColor: HexColor('0D0D0D'),systemOverlayStyle:

                  const SystemUiOverlayStyle(
                    systemNavigationBarColor: Colors.black,
                    systemNavigationBarDividerColor:
                    Colors.black,
                    systemNavigationBarIconBrightness:
                    Brightness.dark,
                    statusBarIconBrightness: Brightness.light
                  ) ,
                    elevation: 0.0,iconTheme: const IconThemeData(color: Colors.white,),

                  ),
                  bottomNavigationBarTheme: BottomNavigationBarThemeData(
                    type: BottomNavigationBarType.fixed,
                    selectedItemColor: Colors.white,
                    backgroundColor: HexColor('0D0D0D'),
                    unselectedItemColor: Colors.grey,
                    selectedIconTheme: const IconThemeData(color: Colors.white,),
                      selectedLabelStyle: TextStyle(fontSize: 11.sp,fontWeight: FontWeight.w800,),
                    unselectedLabelStyle: TextStyle(fontSize: 10.5.sp,fontWeight: FontWeight.w800),
                  ),

                  backgroundColor: Colors.black,
                  unselectedWidgetColor: Colors.grey,
                  iconTheme:const IconThemeData(color: Colors.white,),

                ),
                themeMode: AppCubit.get(context).isDark?ThemeMode.dark:ThemeMode.light,
                home:  const SplashScreen(),
                localizationsDelegates: translator.delegates, // Android + iOS Delegates
                locale: translator.activeLocale, // Active locale
                supportedLocales: translator.locals(),
              );
            },
          );
        },
      ),
    );
  }
}