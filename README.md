# flutter_api_services

A new Flutter package project.

## Getting Started

```
import 'package:flutter/material.dart';
import 'package:flutter_api_services/flutter_api_services.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ApiServices(
        child: MaterialApp(
          title: 'Api Services',
          home: ...,
        ),
    );
  }
}

```

```
  final Map<String, FieldModel> _map = Map<String, FieldModel>();
  UserService _userService;
  FirestorageService _firestorageService;

  @override
  void initState() {
    super.initState();

    _userService = Provider.of<UserService>(context, listen: false);
    _firestorageService =
        Provider.of<FirestorageService>(context, listen: false);
  }
```
