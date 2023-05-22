import 'package:dego/AppCubit/appCubit.dart';
import 'package:dego/AppCubit/appCubitStates.dart';
import 'package:dego/Screens/splashScreen/splashScreen.dart';
import 'package:dego/Shared/constans/constans.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp( MyApp());
}

class MyApp extends StatefulWidget {
   MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => AppCubit(InitialAppCubitState()),
      child: BlocConsumer<AppCubit,AppCubitStates>(
        listener: (BuildContext context, state) {  },
        builder: (BuildContext context, Object? state) {
          return Sizer(
            builder: (BuildContext context, Orientation orientation, DeviceType deviceType) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'Dego',
                theme: ThemeData(
                  primarySwatch: createMaterialColor(color1),
                ),
                home:  SplashScreen(),
              );
            },
          );
        },
      ),
    );
  }
}

