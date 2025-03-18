# DoH API Client Flutter Package

A Flutter package that provides an API client using the DNS over HTTPS (DoH) protocol, implemented with Native code for optimal performance.

## Features

- Perform HTTP requests (GET, POST, PUT, PATCH, DELETE) using DoH protocol
- Support for 12 different DoH providers
- Easy integration with Flutter projects
- Native implementation for improved performance (Also because it is only possible through native code) [OKHTTP on Android and URLSession on IOS]

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  doh_api_client: ^1.0.4
```
s
Then run:

```
flutter pub get
```

## Usage

First, import the package in your Dart file:

```dart
import 'package:doh_api_client/doh_api_client.dart';
```

### Making API Requests

Here's an example of how to make a POST request using the DoH API client:

```dart
final _dohApiClientPlugin = DohApiClient();

try {
  Map<String, dynamic>? apiPostRequest = await _dohApiClientPlugin.post(
    url: "https://jsonplaceholder.typicode.com/posts",
    headers: {
      "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36",
      'Content-type': 'application/json; charset=UTF-8'
    },
    body: jsonEncode({
      "title": 'foo',
      "body": 'bar',
      "userId": 1,
    }),
    dohProvider: DohProvider.CloudFlare
  );
  print(apiPostRequest);
} catch (e) {
  print("Error occurred: $e");
}
```

### Available DoH Providers

The package supports the following DoH providers:

- CloudFlare
- Google
- AdGuard
- Quad9
- AliDNS
- DNSPod
- threeSixty
- Quad101
- Mullvad
- ControlD
- Najalla
- SheCan

You can specify the DoH provider using the `DohProvider` enum when making requests.

## API Reference

### DohApiClient

The main class for making API requests.

Methods:

- `Future<Map<String, dynamic>?> get({required String url, Map<String, String>? headers, DohProvider dohProvider})`
- `Future<Map<String, dynamic>?> post({required String url, Map<String, String>? headers, required String body, DohProvider dohProvider})`
- `Future<Map<String, dynamic>?> put({required String url, Map<String, String>? headers, required String body, DohProvider dohProvider})`
- `Future<Map<String, dynamic>?> patch({required String url, Map<String, String>? headers, required String body, DohProvider dohProvider})`
- `Future<Map<String, dynamic>?> delete({required String url, Map<String, String>? headers, DohProvider dohProvider})`

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](https://github.com/ShalmonAnandas/doh_api_client/blob/main/LICENSE) file for details.