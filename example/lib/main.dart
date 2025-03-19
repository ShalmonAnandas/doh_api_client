import 'dart:convert';

import 'package:doh_api_client/doh_response_model.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:doh_api_client/doh_api_client.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _dohApiClientPlugin = DohApiClient();
  DohResponse _apiGetRequest = DohResponse.empty();
  DohResponse _apiPostRequest = DohResponse.empty();
  DohResponse _apiPutRequest = DohResponse.empty();
  DohResponse _apiPatchRequest = DohResponse.empty();
  DohResponse _apiDeleteRequest = DohResponse.empty();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    DohResponse apiGetRequest;
    DohResponse apiPostRequest;
    DohResponse apiPutRequest;
    DohResponse apiPatchRequest;
    DohResponse apiDeleteRequest;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.

    apiGetRequest = await _dohApiClientPlugin.get(
        url: "https://jsonplaceholder.typicode.com/posts/1",
        headers: {
          "User-Agent":
              "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36"
        },
        dohProvider: DohProvider.CloudFlare);
    setState(() {
      _apiGetRequest = apiGetRequest;
    });

    apiPostRequest = await _dohApiClientPlugin.post(
        url: "https://jsonplaceholder.typicode.com/posts",
        headers: {
          "User-Agent":
              "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36",
          'Content-type': 'application/json; charset=UTF-8'
        },
        body: jsonEncode({
          "title": 'foo',
          "body": 'bar',
          "userId": 1,
        }),
        dohProvider: DohProvider.CloudFlare);
    setState(() {
      _apiPostRequest = apiPostRequest;
    });

    apiPutRequest = await _dohApiClientPlugin.put(
        url: "https://jsonplaceholder.typicode.com/posts/1",
        headers: {
          "User-Agent":
              "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36",
          'Content-type': 'application/json; charset=UTF-8'
        },
        body: jsonEncode({
          "id": 1,
          "title": 'foo',
          "body": 'bar',
          "userId": 1,
        }),
        dohProvider: DohProvider.CloudFlare);
    setState(() {
      _apiPutRequest = apiPutRequest;
    });

    apiPatchRequest = await _dohApiClientPlugin.patch(
        url: "https://jsonplaceholder.typicode.com/posts/1",
        headers: {
          "User-Agent":
              "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36",
          'Content-type': 'application/json; charset=UTF-8'
        },
        body: jsonEncode({
          "title": 'foo',
        }),
        dohProvider: DohProvider.CloudFlare);
    setState(() {
      _apiPatchRequest = apiPatchRequest;
    });

    apiDeleteRequest = await _dohApiClientPlugin.delete(
        url: "https://jsonplaceholder.typicode.com/posts/1",
        headers: {
          "User-Agent":
              "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36"
        },
        dohProvider: DohProvider.CloudFlare);
    setState(() {
      // custom map in case of delete request because delete returns {}
      _apiDeleteRequest = apiDeleteRequest;
    });

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('DoH API Client Example'),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("GET Request: "),
                    _apiGetRequest.statusCode != 200
                        ? const CircularProgressIndicator()
                        : Expanded(
                            child: Text(jsonEncode(_apiGetRequest.data))),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("POST Request: "),
                    _apiPostRequest.statusCode == 200
                        ? const CircularProgressIndicator()
                        : Expanded(
                            child: Text(jsonEncode(_apiPostRequest.data))),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("PUT Request: "),
                    _apiPutRequest.statusCode != 200
                        ? const CircularProgressIndicator()
                        : Expanded(
                            child: Text(jsonEncode(_apiPutRequest.data))),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("PATCH Request: "),
                    _apiPatchRequest.statusCode != 200
                        ? const CircularProgressIndicator()
                        : Expanded(
                            child: Text(jsonEncode(_apiPatchRequest.data))),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("DELETE Request: "),
                    _apiDeleteRequest.statusCode != 200
                        ? const CircularProgressIndicator()
                        : Expanded(
                            child: Text(jsonEncode(_apiDeleteRequest.data))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
