import 'package:bloc/bloc.dart';
import 'package:finc/Notification/service_notifica.dart';
import 'package:finc/app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:finc/simple_bloc_observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await LocalNotificationService.init();
  Bloc.observer = SimpleBlocObserver();
  runApp(const MyApp());
}
