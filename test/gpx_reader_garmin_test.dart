import 'dart:io';

import 'package:gpx/gpx.dart';
import 'package:test/test.dart';

void main() {
  test('read Garmin extensions', () async {
    final xml = await File('test/assets/ext_garmin_trk.gpx').readAsString();
    final gpx = GpxReader().fromString(xml);

    expect(
      gpx
          .trks
          .first
          .trksegs
          .first
          .trkpts
          .first
          .typedExtensions!
          .garmin!
          .trackPointV1!
          .heartRate!,
      130,
    );
  });

  test('read Garmin extensions', () async {
    final xml = await File('test/assets/ext_garmin_full.gpx').readAsString();

    final gpx = GpxReader().fromString(xml);
    final waypointExtension = gpx.wpts.first.typedExtensions!.garmin!.waypoint!;
    expect(waypointExtension.proximity, 100);
    expect(waypointExtension.temperature, 18.5);
    expect(waypointExtension.depth, 4.2);
    expect(waypointExtension.displayMode, GarminDisplayMode.symbolAndName);
    expect(waypointExtension.categories, ['Food', 'Favorites']);
    expect(waypointExtension.address!.streetAddresses, [
      '1 Main St',
      'Suite 2',
    ]);
    expect(waypointExtension.address!.city, 'London');
    expect(waypointExtension.phoneNumbers.first.number, '+440000000');
    expect(waypointExtension.phoneNumbers.first.category, 'Work');

    final waypointExtensionV1 =
        gpx.wpts.first.typedExtensions!.garmin!.waypointV1!;
    expect(waypointExtensionV1.proximity, 101);
    expect(waypointExtensionV1.temperature, 19.5);
    expect(waypointExtensionV1.depth, 5.2);
    expect(
      waypointExtensionV1.displayMode,
      GarminDisplayMode.symbolAndDescription,
    );
    expect(waypointExtensionV1.categories, ['Trailhead']);
    expect(waypointExtensionV1.address!.streetAddresses, ['2 Main St']);
    expect(waypointExtensionV1.address!.city, 'Paris');
    expect(waypointExtensionV1.phoneNumbers.first.number, '+330000000');
    expect(waypointExtensionV1.phoneNumbers.first.category, 'Mobile');
    expect(waypointExtensionV1.samples, 3);
    expect(waypointExtensionV1.expiration, DateTime.utc(2026, 1, 2, 3, 4, 5));

    expect(gpx.rtes.first.typedExtensions!.garmin!.route!.isAutoNamed, false);
    expect(
      gpx.rtes.first.typedExtensions!.garmin!.route!.displayColor,
      GarminDisplayColor.blue,
    );
    expect(
      gpx.rtes.first.rtepts.first.typedExtensions!.garmin!.routePoint!.subclass,
      '000000000000000000',
    );
    expect(
      gpx
          .rtes
          .first
          .rtepts
          .first
          .typedExtensions!
          .garmin!
          .routePoint!
          .routePoints
          .first
          .lat,
      3.1,
    );
    expect(
      gpx
          .rtes
          .first
          .rtepts
          .first
          .typedExtensions!
          .garmin!
          .routePoint!
          .routePoints
          .first
          .lon,
      4.1,
    );
    expect(
      gpx
          .rtes
          .first
          .rtepts
          .first
          .typedExtensions!
          .garmin!
          .routePoint!
          .routePoints
          .first
          .subclass,
      '111111111111111111',
    );
    expect(
      gpx.trks.first.typedExtensions!.garmin!.track!.displayColor,
      GarminDisplayColor.darkRed,
    );
    expect(
      gpx
          .trks
          .first
          .trksegs
          .first
          .trkpts
          .first
          .typedExtensions!
          .garmin!
          .trackPoint!
          .temperature,
      10.5,
    );
    expect(
      gpx
          .trks
          .first
          .trksegs
          .first
          .trkpts
          .first
          .typedExtensions!
          .garmin!
          .trackPoint!
          .depth,
      2.5,
    );

    final trackPointExtensionV1 = gpx
        .trks
        .first
        .trksegs
        .first
        .trkpts
        .first
        .typedExtensions!
        .garmin!
        .trackPointV1!;
    expect(trackPointExtensionV1.airTemperature, 11.5);
    expect(trackPointExtensionV1.waterTemperature, 7.5);
    expect(trackPointExtensionV1.depth, 3.5);
    expect(trackPointExtensionV1.heartRate, 142);
    expect(trackPointExtensionV1.cadence, 81);
  });
}
