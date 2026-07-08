gpx
======

[![Pub Package](https://img.shields.io/pub/v/gpx.svg)](https://pub.dartlang.org/packages/gpx)
[![Dart Package](https://github.com/kb0/dart-gpx/actions/workflows/dart.yml/badge.svg)](https://github.com/kb0/dart-gpx/actions/workflows/dart.yml)
[![GitHub Issues](https://img.shields.io/github/issues/kb0/dart-gpx.svg?branch=master)](https://github.com/kb0/dart-gpx/issues)
[![GitHub Forks](https://img.shields.io/github/forks/kb0/dart-gpx.svg?branch=master)](https://github.com/kb0/dart-gpx/network)
[![GitHub Stars](https://img.shields.io/github/stars/kb0/dart-gpx.svg?branch=master)](https://github.com/kb0/dart-gpx/stargazers)
[![GitHub License](https://img.shields.io/badge/license-Apache%202-blue.svg)](https://raw.githubusercontent.com/kb0/dart-gpx/master/LICENSE)


A Dart library for loading, manipulating, and saving GPS data in GPX format
(https://www.topografix.com/gpx.asp), a light-weight XML data format for the
interchange of GPS data, including waypoints, routes, and tracks.
View the official GPX 1.1 Schema at https://www.topografix.com/GPX/1/1/gpx.xsd.

It also supports exporting `Gpx` data into:
- KML (a file format used to display geographic data in an Earth browser such as Google Earth, https://developers.google.com/kml/)
- CSV (*not implemented yet*)

## Getting Started

In your dart/flutter project add the dependency:

```
 dependencies:
   ...
   gpx: ^2.5.0
```

### Reading XML

To read XML input use the GpxReader object and function `Gpx fromString(String input)`:

```dart
import 'package:gpx/gpx.dart';

void main() {
  // create gpx from xml string
  final xmlGpx = GpxReader().fromString('<?xml version="1.0" encoding="UTF-8"?>'
      '<gpx version="1.1" creator="dart-gpx library">'
      '<wpt lat="-25.7996" lon="-62.8666"><ele>10.0</ele><name>Monte Quemado</name><desc>Argentina</desc></wpt>'
      '</gpx>');

  print(xmlGpx);
  print(xmlGpx.wpts);
}
```

### Writing XML

To write object to XML use the GpxWriter object and function `String asString(Gpx gpx, {bool pretty = false})`:

```dart
import 'package:gpx/gpx.dart';

void main() {
  // create gpx object
  final gpx = Gpx();
  gpx.creator = "dart-gpx library";
  gpx.wpts = [
    Wpt(lat: 36.62, lon: 101.77, ele: 10.0, name: 'Xining', desc: 'China'),
  ];

  // generate xml string
  final gpxString1 = GpxWriter().asString(gpx, pretty: true);
  print(gpxString1);

  // generate xml string with namespaces
  final gpxString2 = GpxWriter().asString(
    gpx,
    namespaces: {
      'trp': 'http://www.garmin.com/xmlschemas/TripExtensions/v1',
    },
    attributes: {
      'xsi:schemaLocation': 'http://www.topografix.com/GPX/1/1 '
          'http://www.topografix.com/GPX/1/1/gpx.xsd',
    },
  );
  print(gpxString2);

  // generate GPX 1.1-compatible xml string with standard namespaces
  final gpxString3 = GpxWriter().asString(
    gpx,
    pretty: true,
    compatibility: GpxCompatibilityMode.gpx11,
  );
  print(gpxString3);
}
```

### Compatibility with strict GPX parsers

Some GPX applications expect the standard GPX 1.1 namespace and schema declarations on the root `<gpx>` element. Use
`GpxCompatibilityMode.gpx11` when writing files for applications such as EasyGPS, JPX, Garmin BaseCamp, and other strict
GPX parsers:

```dart
final xml = GpxWriter().asString(
  gpx,
  pretty: true,
  compatibility: GpxCompatibilityMode.gpx11,
);
```

This writes a root element with the standard GPX 1.1 declarations:

```xml
<gpx xmlns="http://www.topografix.com/GPX/1/1"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd"
    version="1.1"
    creator="dart-gpx library">
```

For Garmin BaseCamp files that also need the Garmin `GpxExtensions/v3`
namespace, combine the GPX 1.1 compatibility mode with `GpxNamespaces.garmin`:

```dart
final xml = GpxWriter().asString(
  gpx,
  pretty: true,
  compatibility: GpxCompatibilityMode.gpx11,
  namespaces: GpxNamespaces.garmin,
);
```

Custom `namespaces` and `attributes` are applied after the compatibility mode,
so they can extend or override the default GPX 1.1 declarations when needed.

### Garmin GpxExtensions v3

The package includes typed models for the Garmin `GpxExtensions/v3`, `TrackPointExtension/v1`, and 
`WaypointExtension/v1` schemas:

- `GarminWaypointExtension`
- `GarminWaypointExtensionV1`
- `GarminRouteExtension`
- `GarminRoutePointExtension`
- `GarminTrackExtension`
- `GarminTrackPointExtension`
- `GarminTrackPointExtensionV1`

```dart
final gpx = Gpx()
  ..creator = 'dart-gpx library'
  ..trks = [
    Trk(
      name: 'Morning track',
      typedExtensions: TrkTypedExtensions(
        garmin: GarminTrkExtensions(
          track: GarminTrackExtension(
            displayColor: GarminDisplayColor.darkRed,
          ),
        ),
      ),
      trksegs: [
        Trkseg(
          trkpts: [
            Wpt(
              lat: 51.5,
              lon: -0.1,
              typedExtensions: WptTypedExtensions(
                garmin: GarminWptExtensions(
                  waypointV1: GarminWaypointExtensionV1(
                    samples: 3,
                    expiration: DateTime.utc(2026, 1, 2, 3, 4, 5),
                  ),
                  trackPoint: GarminTrackPointExtension(
                    temperature: 18.5,
                    depth: 4.2,
                  ),
                  trackPointV1: GarminTrackPointExtensionV1(
                    airTemperature: 18.5,
                    heartRate: 142,
                    cadence: 81,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  ];

final xml = GpxWriter().asString(
  gpx,
  pretty: true,
  compatibility: GpxCompatibilityMode.gpx11,
  namespaces: GpxNamespaces.garmin,
);
```

### Export to KML

To export object to KML use the KmlWriter object and function `String asString(Gpx gpx, {bool pretty = false})`:

```dart
import 'package:gpx/gpx.dart';

void main() {
  // create gpx object
  final gpx = Gpx();
  gpx.creator = "dart-gpx library";
  gpx.wpts = [
    Wpt(lat: 36.62, lon: 101.77, ele: 10.0, name: 'Xining', desc: 'China'),
  ];

  // generate xml string
  final kmlString = KmlWriter().asString(gpx, pretty: true);
  print(kmlString);

  // generate xml string with altitude mode - clampToGround
  final kmlStringWithAltitudeMode =
      KmlWriter(altitudeMode: AltitudeMode.clampToGround)
      .asString(gpx, pretty: true);
  print(kmlStringWithAltitudeMode);
}
```


## Limitations

This is just an initial version of the package. There are still some limitations:

- No support for GPX 1.0.
- Read/write only from strings.
- Doesn't validate schema declarations.

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/kb0/dart-gpx/issues

### License

The Apache 2.0 License, see [LICENSE](https://github.com/kb0/dart-gpx/raw/master/LICENSE).
