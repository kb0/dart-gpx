import 'package:gpx/gpx.dart';
import 'package:test/test.dart';

import 'utils.dart';

void main() {
  test('write Garmin extensions', () {
    final gpx = createMinimalGPX();
    gpx.wpts = [
      Wpt(
        lat: 1,
        lon: 2,
        typedExtensions: WptTypedExtensions(
          garmin: GarminWptExtensions(
            waypoint: GarminWaypointExtension(
              proximity: 100,
              temperature: 18.5,
              depth: 4.2,
              displayMode: GarminDisplayMode.symbolAndName,
              categories: ['Food', 'Favorites'],
              address: GarminAddress(
                streetAddresses: ['1 Main St', 'Suite 2'],
                city: 'London',
                state: 'London',
                country: 'GB',
                postalCode: 'SW1A',
              ),
              phoneNumbers: [
                GarminPhoneNumber(number: '+440000000', category: 'Work'),
              ],
            ),
            waypointV1: GarminWaypointExtensionV1(
              proximity: 101,
              temperature: 19.5,
              depth: 5.2,
              displayMode: GarminDisplayMode.symbolAndDescription,
              categories: ['Trailhead'],
              address: GarminAddress(
                streetAddresses: ['2 Main St'],
                city: 'Paris',
                country: 'FR',
              ),
              phoneNumbers: [
                GarminPhoneNumber(number: '+330000000', category: 'Mobile'),
              ],
              samples: 3,
              expiration: DateTime.utc(2026, 1, 2, 3, 4, 5),
            ),
          ),
        ),
      ),
    ];
    gpx.rtes = [
      Rte(
        name: 'Route',
        typedExtensions: RteTypedExtensions(
          garmin: GarminRteExtensions(
            route: GarminRouteExtension(
              isAutoNamed: false,
              displayColor: GarminDisplayColor.blue,
            ),
          ),
        ),
        rtepts: [
          Wpt(
            lat: 3,
            lon: 4,
            typedExtensions: WptTypedExtensions(
              garmin: GarminWptExtensions(
                routePoint: GarminRoutePointExtension(
                  subclass: '000000000000000000',
                  routePoints: [
                    GarminAutoroutePoint(
                      lat: 3.1,
                      lon: 4.1,
                      subclass: '111111111111111111',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ];
    gpx.trks = [
      Trk(
        name: 'Track',
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
                lat: 5,
                lon: 6,
                typedExtensions: WptTypedExtensions(
                  garmin: GarminWptExtensions(
                    trackPoint: GarminTrackPointExtension(
                      temperature: 10.5,
                      depth: 2.5,
                    ),
                    trackPointV1: GarminTrackPointExtensionV1(
                      airTemperature: 11.5,
                      waterTemperature: 7.5,
                      depth: 3.5,
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

    final str = GpxWriter().asString(
      gpx,
      compatibility: GpxCompatibilityMode.gpx11,
      namespaces: GpxNamespaces.garmin,
    );

    expect(
      str,
      contains(
        'xmlns:gpxx="http://www.garmin.com/xmlschemas/GpxExtensions/v3"',
      ),
    );
    expect(
      str,
      contains(
        'xmlns:gpxtpx="http://www.garmin.com/xmlschemas/TrackPointExtension/v1"',
      ),
    );
    expect(
      str,
      contains(
        'xmlns:wptx1="http://www.garmin.com/xmlschemas/WaypointExtension/v1"',
      ),
    );
    expect(str, contains('<gpxx:WaypointExtension>'));
    expect(str, contains('<gpxx:Proximity>100.0</gpxx:Proximity>'));
    expect(str, contains('<gpxx:DisplayMode>SymbolAndName</gpxx:DisplayMode>'));
    expect(str, contains('<gpxx:Category>Food</gpxx:Category>'));
    expect(str, contains('<gpxx:PhoneNumber Category="Work">+440000000'));
    expect(str, contains('<wptx1:WaypointExtension>'));
    expect(str, contains('<wptx1:Proximity>101.0</wptx1:Proximity>'));
    expect(
      str,
      contains('<wptx1:DisplayMode>SymbolAndDescription</wptx1:DisplayMode>'),
    );
    expect(str, contains('<wptx1:Category>Trailhead</wptx1:Category>'));
    expect(str, contains('<wptx1:PhoneNumber Category="Mobile">+330000000'));
    expect(str, contains('<wptx1:Samples>3</wptx1:Samples>'));
    expect(
      str,
      contains('<wptx1:Expiration>2026-01-02T03:04:05.000Z</wptx1:Expiration>'),
    );
    expect(str, contains('<gpxx:RouteExtension>'));
    expect(str, contains('<gpxx:IsAutoNamed>false</gpxx:IsAutoNamed>'));
    expect(str, contains('<gpxx:DisplayColor>Blue</gpxx:DisplayColor>'));
    expect(str, contains('<gpxx:RoutePointExtension>'));
    expect(str, contains('<gpxx:rpt lat="3.1" lon="4.1">'));
    expect(str, contains('<gpxx:TrackExtension>'));
    expect(str, contains('<gpxx:DisplayColor>DarkRed</gpxx:DisplayColor>'));
    expect(str, contains('<gpxx:TrackPointExtension>'));
    expect(str, contains('<gpxx:Temperature>10.5</gpxx:Temperature>'));
    expect(str, contains('<gpxx:Depth>2.5</gpxx:Depth>'));
    expect(str, contains('<gpxtpx:TrackPointExtension>'));
    expect(str, contains('<gpxtpx:atemp>11.5</gpxtpx:atemp>'));
    expect(str, contains('<gpxtpx:wtemp>7.5</gpxtpx:wtemp>'));
    expect(str, contains('<gpxtpx:depth>3.5</gpxtpx:depth>'));
    expect(str, contains('<gpxtpx:hr>142</gpxtpx:hr>'));
    expect(str, contains('<gpxtpx:cad>81</gpxtpx:cad>'));
  });

  test('typed Garmin GpxExtensions v3 wins over raw extension block', () {
    final gpx = createMinimalGPX();
    gpx.wpts = [
      Wpt(
        lat: 1,
        lon: 2,
        extensions: {
          'gpxx:TrackPointExtension': {'gpxx:Temperature': '99'},
        },
        typedExtensions: WptTypedExtensions(
          garmin: GarminWptExtensions(
            trackPoint: GarminTrackPointExtension(temperature: 12),
          ),
        ),
      ),
    ];

    final str = GpxWriter().asString(gpx, namespaces: GpxNamespaces.garmin);

    expect(str, contains('<gpxx:Temperature>12.0</gpxx:Temperature>'));
    expect(str, isNot(contains('<gpxx:Temperature>99</gpxx:Temperature>')));
  });

  test('typed Garmin TrackPointExtension v1 wins over raw extension block', () {
    final gpx = createMinimalGPX();
    gpx.wpts = [
      Wpt(
        lat: 1,
        lon: 2,
        extensions: {
          'gpxtpx:TrackPointExtension': {'gpxtpx:hr': '99'},
        },
        typedExtensions: WptTypedExtensions(
          garmin: GarminWptExtensions(
            trackPointV1: GarminTrackPointExtensionV1(heartRate: 142),
          ),
        ),
      ),
    ];

    final str = GpxWriter().asString(gpx, namespaces: GpxNamespaces.garmin);

    expect(str, contains('<gpxtpx:hr>142</gpxtpx:hr>'));
    expect(str, isNot(contains('<gpxtpx:hr>99</gpxtpx:hr>')));
  });

  test('typed Garmin WaypointExtension v1 wins over raw extension block', () {
    final gpx = createMinimalGPX();
    gpx.wpts = [
      Wpt(
        lat: 1,
        lon: 2,
        extensions: {
          'wptx1:WaypointExtension': {'wptx1:Samples': '99'},
        },
        typedExtensions: WptTypedExtensions(
          garmin: GarminWptExtensions(
            waypointV1: GarminWaypointExtensionV1(samples: 3),
          ),
        ),
      ),
    ];

    final str = GpxWriter().asString(gpx, namespaces: GpxNamespaces.garmin);

    expect(str, contains('<wptx1:Samples>3</wptx1:Samples>'));
    expect(str, isNot(contains('<wptx1:Samples>99</wptx1:Samples>')));
  });
}
