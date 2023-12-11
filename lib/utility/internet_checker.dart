import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';


class InternetConnectionWidget extends StatefulWidget {
  const InternetConnectionWidget({super.key});

  @override
  InternetConnectionWidgetState createState() =>
      InternetConnectionWidgetState();
}

class InternetConnectionWidgetState extends State<InternetConnectionWidget> {
  late Connectivity _connectivity;
  late bool _isConnected;

  @override
  void initState() {
    super.initState();
    _connectivity = Connectivity();
    _checkInternetConnection();
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      _checkInternetConnection();
    });
  }

  Future<void> _checkInternetConnection() async {
    var connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        _isConnected = false;
      });
    } else {
      setState(() {
        _isConnected = true;
      });
    }
  }

  Future<void> _showNoInternetDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('No Internet Connection'),
          content: const Text('Please check your internet connection and try again.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isConnected) {
      _showNoInternetDialog(context);
    }

    return Center(
      child: Text(
        _isConnected ? 'Connected to the internet' : 'No internet connection',
      ),
    );
  }
}
