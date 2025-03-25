## 0.0.1

* Initial Release of DoH API Client

## 1.0.0

* updated release

## 1.0.1    

* Added support for IOS

## 1.0.2

* Updated Changelog to include 1.0.0 release because publishing failed

## 1.0.3

* Updated version in pubspec

## 1.0.4

* Changed error behaviour, now returns Map<String, Dynamic>? instead of String?

## 1.0.5
* Now returns DohResponse instead of plain Map<String, dynamic> to better handle error states

## 1.0.6
* Added support for custom interceptors. As well as 2 built in interceptors, 1 basic and 1 based on [PrettyDioLogger](https://github.com/Milad-Akarie/pretty_dio_logger)


## 1.0.7
* Runs interceptor on isolates so that intercepting and printing large request / responses dont block the api call execution

## 1.0.8
* PrettyDohLogger now prints blocks instead of lines