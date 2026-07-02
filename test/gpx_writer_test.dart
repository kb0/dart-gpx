import 'dart:io';

import 'package:gpx/gpx.dart';
import 'package:test/test.dart';

import 'utils.dart';

void main() {
  test('write empty gpx', () async {
    final gpx = createMinimalGPX();
    final xml = await File('test/assets/minimal.gpx').readAsString();

    expectXml(GpxWriter().asString(gpx, pretty: true), xml);
  });

  test('write empty gpx with metadata', () async {
    final gpx = createMinimalMetadataGPX();
    final xml = await File(
      'test/assets/minimal_with_metadata.gpx',
    ).readAsString();

    expectXml(GpxWriter().asString(gpx, pretty: true), xml);
  });

  test('write gpx with multiply points', () async {
    final gpx = createGPXWithWpt();
    final xml = await File('test/assets/wpt_nocdata.gpx').readAsString();

    expectXml(GpxWriter().asString(gpx, pretty: true), xml);
  });

  test('write gpx with multiply points', () async {
    final gpx = createGPXWithWpt();
    final xml = await File('test/assets/wpt_nocdata.gpx').readAsString();

    expectXml(GpxWriter().asString(gpx, pretty: true), xml);
  });

  test('write gpx with multiply routes', () async {
    final gpx = createGPXWithRte();
    final xml = await File('test/assets/rte.gpx').readAsString();

    expectXml(GpxWriter().asString(gpx, pretty: true), xml);
  });

  test('write gpx with multiply tracks', () async {
    final gpx = createGPXWithTrk();
    final xml = await File('test/assets/trk.gpx').readAsString();

    expectXml(GpxWriter().asString(gpx, pretty: true), xml);
  });

  test('write complex gpx', () async {
    final gpx = createComplexGPX();
    final xml = await File('test/assets/complex.gpx').readAsString();

    expectXml(GpxWriter().asString(gpx, pretty: true), xml);
  });

  test('write metadata gpx', () async {
    final gpx = createMetadataGPX();
    final xml = await File('test/assets/metadata.gpx').readAsString();

    expectXml(GpxWriter().asString(gpx, pretty: true), xml);
  });

  test('write FixType', () async {
    final gpx = createMinimalGPX();
    gpx.wpts = [
      Wpt(lat: 1, lon: 1, fix: FixType.fix_2d),
      Wpt(lat: 1, lon: 1, fix: FixType.fix_3d),
      Wpt(lat: 1, lon: 1, fix: FixType.none),
    ];
    final xml = await File('test/assets/fix.gpx').readAsString();

    expectXml(GpxWriter().asString(gpx, pretty: true), xml);
  });

  test('write custom namespaces', () async {
    final gpx = createMinimalGPX();
    gpx.wpts = [Wpt(lat: 1, lon: 1, fix: FixType.none)];
    final xml = await File('test/assets/namespace_attrs.gpx').readAsString();

    final gpxXml = GpxWriter().asXml(gpx);
    gpxXml.children[1].setAttribute(
      'xmlns:trp',
      'http://www.garmin.com/xmlschemas/TripExtensions/v1',
    );
    gpxXml.children[1].setAttribute(
      'xsi:schemaLocation',
      'http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd',
    );
    expectXml(gpxXml.toXmlString(), xml);
  });

  test('write custom namespaces as params', () async {
    final gpx = createMinimalGPX();
    gpx.wpts = [Wpt(lat: 1, lon: 1, fix: FixType.none)];
    final xml = await File('test/assets/namespace.gpx').readAsString();

    final str = GpxWriter().asString(
      gpx,
      namespaces: {'trp': 'http://www.garmin.com/xmlschemas/TripExtensions/v1'},
      attributes: {
        'xsi:schemaLocation':
            'http://www.topografix.com/GPX/1/1 '
            'http://www.topografix.com/GPX/1/1/gpx.xsd',
      },
    );
    expectXml(str, xml);
  });

  test('write gpx11 compatibility mode', () {
    final gpx = createMinimalGPX();

    final str = GpxWriter().asString(
      gpx,
      compatibility: GpxCompatibilityMode.gpx11,
    );

    expect(str, contains('xmlns="http://www.topografix.com/GPX/1/1"'));
    expect(
      str,
      contains('xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"'),
    );
    expect(
      str,
      contains(
        'xsi:schemaLocation="http://www.topografix.com/GPX/1/1 '
        'http://www.topografix.com/GPX/1/1/gpx.xsd"',
      ),
    );
  });

  test('write custom namespaces and attributes over gpx11 defaults', () {
    final gpx = createMinimalGPX();

    final str = GpxWriter().asString(
      gpx,
      compatibility: GpxCompatibilityMode.gpx11,
      namespaces: {
        null: 'urn:custom-gpx',
        'xsi': 'urn:custom-xsi',
        'trp': 'http://www.garmin.com/xmlschemas/TripExtensions/v1',
      },
      attributes: {'xsi:schemaLocation': 'urn:custom-schema'},
    );

    expect(str, contains('xmlns="urn:custom-gpx"'));
    expect(str, contains('xmlns:xsi="urn:custom-xsi"'));
    expect(
      str,
      contains(
        'xmlns:trp="http://www.garmin.com/xmlschemas/TripExtensions/v1"',
      ),
    );
    expect(str, contains('xsi:schemaLocation="urn:custom-schema"'));
    expect(str, isNot(contains('xmlns="http://www.topografix.com/GPX/1/1"')));
  });
}
