
import 'package:dego/AppCubit/appCubit.dart';
import 'package:dego/AppCubit/appCubitStates.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../Shared/constans/constans.dart';

class TrendingScreen extends StatefulWidget {
  const TrendingScreen({Key? key}) : super(key: key);

  @override
  State<TrendingScreen> createState() => _TrendingScreenState();
}

class _TrendingScreenState extends State<TrendingScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit,AppCubitStates>(
        listener: (BuildContext context, state) {  },
        builder: (BuildContext context, Object? state) {
          return  Center(child: Text('Trending',));
  });
  }
}