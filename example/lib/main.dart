import 'dart:convert';

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
  Map<String, dynamic> _apiGetRequest = {};
  Map<String, dynamic> _apiPostRequest = {};
  Map<String, dynamic> _apiPutRequest = {};
  Map<String, dynamic> _apiPatchRequest = {};
  Map<String, dynamic> _apiDeleteRequest = {};

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    Map<String, dynamic>? apiGetRequest;
    Map<String, dynamic>? apiPostRequest;
    Map<String, dynamic>? apiPutRequest;
    Map<String, dynamic>? apiPatchRequest;
    Map<String, dynamic>? apiDeleteRequest;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.

    try {
      apiGetRequest = await _dohApiClientPlugin.get(
          url: "https://jsonplaceholder.typicode.com/posts/1",
          headers: {
            "User-Agent":
                "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36"
          },
          dohProvider: DohProvider.CloudFlare);
      setState(() {
        _apiGetRequest = apiGetRequest ?? {};
      });
    } catch (e) {
      apiGetRequest = {
        "ERROR": "Method Channel Failed to call for GET Request"
      };
      setState(() {
        _apiGetRequest = apiGetRequest ?? {};
      });
    }

    try {
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
        _apiPostRequest = apiPostRequest ?? {};
      });
    } catch (e) {
      apiPostRequest = "Method Channel Failed to call for POST Request";
      setState(() {
        _apiPostRequest = apiPostRequest ?? {};
      });
    }

    try {
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
        _apiPutRequest = apiPutRequest ?? {};
      });
    } catch (e) {
      apiPutRequest = "Method Channel Failed to call for PUT Request";
      setState(() {
        _apiPutRequest = apiPutRequest ?? {};
      });
    }

    try {
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
        _apiPatchRequest = apiPatchRequest ?? {};
      });
    } catch (e) {
      apiPatchRequest = "Method Channel Failed to call for PATCH Request";
      setState(() {
        _apiPatchRequest = apiPatchRequest ?? {};
      });
    }

    try {
      apiDeleteRequest = await _dohApiClientPlugin.delete(
          url: "https://jsonplaceholder.typicode.com/posts/1",
          headers: {
            "User-Agent":
                "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36"
          },
          dohProvider: DohProvider.CloudFlare);
      setState(() {
        _apiDeleteRequest = apiDeleteRequest ?? {};
      });
    } catch (e) {
      apiDeleteRequest = "Method Channel Failed to call for DELETE Request";
      setState(() {
        _apiDeleteRequest = apiDeleteRequest ?? {};
      });
    }
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
                    _apiGetRequest.isEmpty
                        ? const CircularProgressIndicator()
                        : Expanded(child: Text(_apiGetRequest)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("POST Request: "),
                    _apiPostRequest.isEmpty
                        ? const CircularProgressIndicator()
                        : Expanded(child: Text(_apiPostRequest)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("PUT Request: "),
                    _apiPutRequest.isEmpty
                        ? const CircularProgressIndicator()
                        : Expanded(child: Text(_apiPutRequest)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("PATCH Request: "),
                    _apiPatchRequest.isEmpty
                        ? const CircularProgressIndicator()
                        : Expanded(child: Text(_apiPatchRequest)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("DELETE Request: "),
                    _apiDeleteRequest.isEmpty
                        ? const CircularProgressIndicator()
                        : Expanded(child: Text(_apiDeleteRequest)),
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
