import 'package:xml/xml.dart';

import 'model/gpx.dart';
import 'model/gpx_tag.dart';
import 'model/extension/garmin_gpx_extensions.dart';
import 'model/link.dart';
import 'model/metadata.dart';
import 'model/rte.dart';
import 'model/trk.dart';
import 'model/wpt.dart';

/// Built-in GPX writer compatibility presets.
enum GpxCompatibilityMode {
  /// Keep the historical writer output unchanged.
  legacy,

  /// Add standard GPX 1.1 namespace and schema declarations.
  gpx11,
}

/// Convert Gpx into GPX
class GpxWriter {
  static const _gpx11Namespace = 'http://www.topografix.com/GPX/1/1';
  static const _xmlSchemaInstanceNamespace =
      'http://www.w3.org/2001/XMLSchema-instance';
  static const _gpx11SchemaLocation =
      'http://www.topografix.com/GPX/1/1 '
      'http://www.topografix.com/GPX/1/1/gpx.xsd';

  /// Convert Gpx into GPX XML (v1.1) as String
  String asString(
    Gpx gpx, {
    bool pretty = false,
    GpxCompatibilityMode compatibility = GpxCompatibilityMode.legacy,
    Map<String?, String?> namespaces = const {},
    Map<String, String> attributes = const {},
  }) => _build(
    gpx,
    compatibility,
    namespaces,
    attributes,
  ).toXmlString(pretty: pretty);

  /// Convert Gpx into GPX XML (v1.1) as XmlNode
  XmlNode asXml(
    Gpx gpx, {
    GpxCompatibilityMode compatibility = GpxCompatibilityMode.legacy,
    Map<String?, String?> namespaces = const {},
    Map<String, String> attributes = const {},
  }) => _build(gpx, compatibility, namespaces, attributes);

  XmlNode _build(
    Gpx gpx,
    GpxCompatibilityMode compatibility,
    Map<String?, String?> gpxNamespaces,
    Map<String, String> gpxAttributes,
  ) {
    final builder = XmlBuilder();
    final namespaces = {..._namespacesFor(compatibility), ...gpxNamespaces};
    final attributes = {..._attributesFor(compatibility), ...gpxAttributes};

    builder.processing('xml', 'version="1.0" encoding="UTF-8"');
    builder.element(
      GpxTagV11.gpx,
      namespaceUris: namespaces,
      attributes: attributes,
      nest: () {
        builder.attribute(GpxTagV11.version, gpx.version);
        builder.attribute(GpxTagV11.creator, gpx.creator);

        if (gpx.metadata != null) {
          _writeMetadata(builder, gpx.metadata!);
        }

        _writeExtensions(builder, gpx.extensions);

        for (final wpt in gpx.wpts) {
          _writePoint(builder, GpxTagV11.wayPoint, wpt);
        }
        for (final rte in gpx.rtes) {
          _writeRoute(builder, rte);
        }
        for (final trk in gpx.trks) {
          _writeTrack(builder, trk);
        }
      },
    );

    return builder.buildDocument();
  }

  Map<String?, String?> _namespacesFor(GpxCompatibilityMode compatibility) {
    switch (compatibility) {
      case GpxCompatibilityMode.legacy:
        return const {};
      case GpxCompatibilityMode.gpx11:
        return const {
          null: _gpx11Namespace,
          'xsi': _xmlSchemaInstanceNamespace,
        };
    }
  }

  Map<String, String> _attributesFor(GpxCompatibilityMode compatibility) {
    switch (compatibility) {
      case GpxCompatibilityMode.legacy:
        return const {};
      case GpxCompatibilityMode.gpx11:
        return const {'xsi:schemaLocation': _gpx11SchemaLocation};
    }
  }

  void _writeMetadata(XmlBuilder builder, Metadata metadata) {
    builder.element(
      GpxTagV11.metadata,
      nest: () {
        _writeElement(builder, GpxTagV11.name, metadata.name);
        _writeElement(builder, GpxTagV11.desc, metadata.desc);

        _writeElement(builder, GpxTagV11.keywords, metadata.keywords);

        if (metadata.author != null) {
          builder.element(
            GpxTagV11.author,
            nest: () {
              if (metadata.author?.name != null) {
                _writeElement(builder, GpxTagV11.name, metadata.author?.name);
              }

              if (metadata.author?.email != null) {
                builder.element(
                  GpxTagV11.email,
                  nest: () {
                    _writeAttribute(
                      builder,
                      GpxTagV11.id,
                      metadata.author?.email?.id,
                    );
                    _writeAttribute(
                      builder,
                      GpxTagV11.domain,
                      metadata.author?.email?.domain,
                    );
                  },
                );
              }

              _writeLinks(builder, [metadata.author?.link]);
            },
          );
        }

        if (metadata.copyright != null) {
          builder.element(
            GpxTagV11.copyright,
            nest: () {
              _writeAttribute(
                builder,
                GpxTagV11.author,
                metadata.copyright?.author,
              );

              _writeElement(builder, GpxTagV11.year, metadata.copyright?.year);
              _writeElement(
                builder,
                GpxTagV11.license,
                metadata.copyright?.license,
              );
            },
          );
        }

        _writeLinks(builder, metadata.links);

        _writeElementWithTime(builder, GpxTagV11.time, metadata.time);

        if (metadata.bounds != null) {
          builder.element(
            GpxTagV11.bounds,
            nest: () {
              _writeAttribute(
                builder,
                GpxTagV11.minLatitude,
                metadata.bounds?.minlat,
              );
              _writeAttribute(
                builder,
                GpxTagV11.minLongitude,
                metadata.bounds?.minlon,
              );
              _writeAttribute(
                builder,
                GpxTagV11.maxLatitude,
                metadata.bounds?.maxlat,
              );
              _writeAttribute(
                builder,
                GpxTagV11.maxLongitude,
                metadata.bounds?.maxlon,
              );
            },
          );
        }

        _writeExtensions(builder, metadata.extensions);
      },
    );
  }

  void _writeRoute(XmlBuilder builder, Rte rte) {
    builder.element(
      GpxTagV11.route,
      nest: () {
        _writeElement(builder, GpxTagV11.name, rte.name);
        _writeElement(builder, GpxTagV11.desc, rte.desc);
        _writeElement(builder, GpxTagV11.comment, rte.cmt);
        _writeElement(builder, GpxTagV11.type, rte.type);

        _writeElement(builder, GpxTagV11.src, rte.src);
        _writeElement(builder, GpxTagV11.number, rte.number);

        _writeExtensions(
          builder,
          rte.extensions,
          garminRouteExtension: rte.typedExtensions?.garmin?.route,
        );

        for (final wpt in rte.rtepts) {
          _writePoint(builder, GpxTagV11.routePoint, wpt);
        }

        _writeLinks(builder, rte.links);
      },
    );
  }

  void _writeTrack(XmlBuilder builder, Trk trk) {
    builder.element(
      GpxTagV11.track,
      nest: () {
        _writeElement(builder, GpxTagV11.name, trk.name);
        _writeElement(builder, GpxTagV11.desc, trk.desc);
        _writeElement(builder, GpxTagV11.comment, trk.cmt);
        _writeElement(builder, GpxTagV11.type, trk.type);

        _writeElement(builder, GpxTagV11.src, trk.src);
        _writeElement(builder, GpxTagV11.number, trk.number);

        _writeExtensions(
          builder,
          trk.extensions,
          garminTrackExtension: trk.typedExtensions?.garmin?.track,
        );

        for (final trkseg in trk.trksegs) {
          builder.element(
            GpxTagV11.trackSegment,
            nest: () {
              for (final wpt in trkseg.trkpts) {
                _writePoint(builder, GpxTagV11.trackPoint, wpt);
              }

              _writeExtensions(builder, trkseg.extensions);
            },
          );
        }

        _writeLinks(builder, trk.links);
      },
    );
  }

  void _writePoint(XmlBuilder builder, String tagName, Wpt? wpt) {
    if (wpt != null) {
      builder.element(
        tagName,
        nest: () {
          _writeAttribute(builder, GpxTagV11.latitude, wpt.lat);
          _writeAttribute(builder, GpxTagV11.longitude, wpt.lon);

          _writeElement(builder, GpxTagV11.elevation, wpt.ele);

          _writeElementWithTime(builder, GpxTagV11.time, wpt.time);
          _writeElement(
            builder,
            GpxTagV11.fix,
            wpt.fix
                ?.toString()
                .replaceFirst('FixType.', '')
                .replaceFirst('fix_', ''),
          );
          _writeElement(builder, GpxTagV11.magVar, wpt.magvar);

          _writeElement(builder, GpxTagV11.sat, wpt.sat);
          _writeElement(builder, GpxTagV11.src, wpt.src);

          _writeElement(builder, GpxTagV11.hDOP, wpt.hdop);
          _writeElement(builder, GpxTagV11.vDOP, wpt.vdop);
          _writeElement(builder, GpxTagV11.pDOP, wpt.pdop);

          _writeElement(builder, GpxTagV11.geoidHeight, wpt.geoidheight);
          _writeElement(builder, GpxTagV11.ageOfData, wpt.ageofdgpsdata);
          _writeElement(builder, GpxTagV11.dGPSId, wpt.dgpsid);

          _writeElement(builder, GpxTagV11.name, wpt.name);
          _writeElement(builder, GpxTagV11.desc, wpt.desc);
          _writeElement(builder, GpxTagV11.comment, wpt.cmt);
          _writeElement(builder, GpxTagV11.type, wpt.type);
          _writeElement(builder, GpxTagV11.sym, wpt.sym);

          _writeExtensions(
            builder,
            wpt.extensions,
            garminWaypointExtension: wpt.typedExtensions?.garmin?.waypoint,
            garminWaypointExtensionV1: wpt.typedExtensions?.garmin?.waypointV1,
            garminRoutePointExtension: wpt.typedExtensions?.garmin?.routePoint,
            garminTrackPointExtension: wpt.typedExtensions?.garmin?.trackPoint,
            garminTrackPointExtensionV1:
                wpt.typedExtensions?.garmin?.trackPointV1,
          );

          _writeLinks(builder, wpt.links);
        },
      );
    }
  }

  void _writeExtensions(
    XmlBuilder builder,
    Map<String, Object>? value, {
    GarminWaypointExtension? garminWaypointExtension,
    GarminWaypointExtensionV1? garminWaypointExtensionV1,
    GarminRouteExtension? garminRouteExtension,
    GarminRoutePointExtension? garminRoutePointExtension,
    GarminTrackExtension? garminTrackExtension,
    GarminTrackPointExtension? garminTrackPointExtension,
    GarminTrackPointExtensionV1? garminTrackPointExtensionV1,
  }) {
    final raw = _extensionsWithoutTypedGarmin(
      value,
      garminWaypointExtension: garminWaypointExtension,
      garminWaypointExtensionV1: garminWaypointExtensionV1,
      garminRouteExtension: garminRouteExtension,
      garminRoutePointExtension: garminRoutePointExtension,
      garminTrackExtension: garminTrackExtension,
      garminTrackPointExtension: garminTrackPointExtension,
      garminTrackPointExtensionV1: garminTrackPointExtensionV1,
    );
    final hasGarminExtension =
        garminWaypointExtension != null ||
        garminWaypointExtensionV1 != null ||
        garminRouteExtension != null ||
        garminRoutePointExtension != null ||
        garminTrackExtension != null ||
        garminTrackPointExtension != null ||
        garminTrackPointExtensionV1 != null;

    if (raw.isNotEmpty || hasGarminExtension) {
      builder.element(
        GpxTagV11.extensions,
        nest: () {
          _writeGarminWaypointExtension(builder, garminWaypointExtension);
          _writeGarminWaypointExtensionV1(builder, garminWaypointExtensionV1);
          _writeGarminRouteExtension(builder, garminRouteExtension);
          _writeGarminRoutePointExtension(builder, garminRoutePointExtension);
          _writeGarminTrackExtension(builder, garminTrackExtension);
          _writeGarminTrackPointExtension(builder, garminTrackPointExtension);
          _writeGarminTrackPointExtensionV1(
            builder,
            garminTrackPointExtensionV1,
          );

          raw.forEach((k, v) {
            _writeElement(builder, k, v);
          });
        },
      );
    }
  }

  Map<String, Object> _extensionsWithoutTypedGarmin(
    Map<String, Object>? value, {
    GarminWaypointExtension? garminWaypointExtension,
    GarminWaypointExtensionV1? garminWaypointExtensionV1,
    GarminRouteExtension? garminRouteExtension,
    GarminRoutePointExtension? garminRoutePointExtension,
    GarminTrackExtension? garminTrackExtension,
    GarminTrackPointExtension? garminTrackPointExtension,
    GarminTrackPointExtensionV1? garminTrackPointExtensionV1,
  }) {
    if (value == null || value.isEmpty) {
      return const {};
    }

    final skippedNames = <String>{
      if (garminWaypointExtension != null) 'gpxx:WaypointExtension',
      if (garminWaypointExtensionV1 != null) 'wptx1:WaypointExtension',
      if (garminRouteExtension != null) 'gpxx:RouteExtension',
      if (garminRoutePointExtension != null) 'gpxx:RoutePointExtension',
      if (garminTrackExtension != null) 'gpxx:TrackExtension',
      if (garminTrackPointExtension != null) 'gpxx:TrackPointExtension',
      if (garminTrackPointExtensionV1 != null) 'gpxtpx:TrackPointExtension',
    };
    final skippedLocalNames = <String>{
      if (garminWaypointExtension != null) 'WaypointExtension',
      if (garminWaypointExtensionV1 != null) 'WaypointExtension',
      if (garminRouteExtension != null) 'RouteExtension',
      if (garminRoutePointExtension != null) 'RoutePointExtension',
      if (garminTrackExtension != null) 'TrackExtension',
      if (garminTrackPointExtension != null ||
          garminTrackPointExtensionV1 != null)
        'TrackPointExtension',
    };

    return Map.fromEntries(
      value.entries.where((entry) {
        if (entry.key.contains(':')) {
          return !skippedNames.contains(entry.key);
        }

        final localName = _localName(entry.key);
        return !skippedLocalNames.contains(localName);
      }),
    );
  }

  void _writeGarminWaypointExtension(
    XmlBuilder builder,
    GarminWaypointExtension? extension,
  ) {
    if (extension == null) {
      return;
    }

    builder.element(
      'gpxx:WaypointExtension',
      nest: () {
        _writeElement(builder, 'gpxx:Proximity', extension.proximity);
        _writeElement(builder, 'gpxx:Temperature', extension.temperature);
        _writeElement(builder, 'gpxx:Depth', extension.depth);
        _writeElement(
          builder,
          'gpxx:DisplayMode',
          extension.displayMode?.value,
        );
        if (extension.categories.isNotEmpty) {
          builder.element(
            'gpxx:Categories',
            nest: () {
              for (final category in extension.categories) {
                _writeElement(builder, 'gpxx:Category', category);
              }
            },
          );
        }
        _writeGarminAddress(builder, extension.address);
        for (final phoneNumber in extension.phoneNumbers) {
          builder.element(
            'gpxx:PhoneNumber',
            nest: () {
              _writeAttribute(builder, 'Category', phoneNumber.category);
              builder.text(phoneNumber.number ?? '');
            },
          );
        }
        _writeGarminNestedExtensions(builder, 'gpxx', extension.extensions);
      },
    );
  }

  void _writeGarminAddress(XmlBuilder builder, GarminAddress? address) {
    if (address == null) {
      return;
    }

    builder.element(
      'gpxx:Address',
      nest: () {
        for (final streetAddress in address.streetAddresses) {
          _writeElement(builder, 'gpxx:StreetAddress', streetAddress);
        }
        _writeElement(builder, 'gpxx:City', address.city);
        _writeElement(builder, 'gpxx:State', address.state);
        _writeElement(builder, 'gpxx:Country', address.country);
        _writeElement(builder, 'gpxx:PostalCode', address.postalCode);
        _writeGarminNestedExtensions(builder, 'gpxx', address.extensions);
      },
    );
  }

  void _writeGarminWaypointExtensionV1(
    XmlBuilder builder,
    GarminWaypointExtensionV1? extension,
  ) {
    if (extension == null) {
      return;
    }

    builder.element(
      'wptx1:WaypointExtension',
      nest: () {
        _writeElement(builder, 'wptx1:Proximity', extension.proximity);
        _writeElement(builder, 'wptx1:Temperature', extension.temperature);
        _writeElement(builder, 'wptx1:Depth', extension.depth);
        _writeElement(
          builder,
          'wptx1:DisplayMode',
          extension.displayMode?.value,
        );
        if (extension.categories.isNotEmpty) {
          builder.element(
            'wptx1:Categories',
            nest: () {
              for (final category in extension.categories) {
                _writeElement(builder, 'wptx1:Category', category);
              }
            },
          );
        }
        _writeGarminAddressV1(builder, extension.address);
        for (final phoneNumber in extension.phoneNumbers) {
          builder.element(
            'wptx1:PhoneNumber',
            nest: () {
              _writeAttribute(builder, 'Category', phoneNumber.category);
              builder.text(phoneNumber.number ?? '');
            },
          );
        }
        _writeElement(builder, 'wptx1:Samples', extension.samples);
        _writeElementWithTime(
          builder,
          'wptx1:Expiration',
          extension.expiration,
        );
        _writeGarminNestedExtensions(builder, 'wptx1', extension.extensions);
      },
    );
  }

  void _writeGarminAddressV1(XmlBuilder builder, GarminAddress? address) {
    if (address == null) {
      return;
    }

    builder.element(
      'wptx1:Address',
      nest: () {
        for (final streetAddress in address.streetAddresses) {
          _writeElement(builder, 'wptx1:StreetAddress', streetAddress);
        }
        _writeElement(builder, 'wptx1:City', address.city);
        _writeElement(builder, 'wptx1:State', address.state);
        _writeElement(builder, 'wptx1:Country', address.country);
        _writeElement(builder, 'wptx1:PostalCode', address.postalCode);
        _writeGarminNestedExtensions(builder, 'wptx1', address.extensions);
      },
    );
  }

  void _writeGarminRouteExtension(
    XmlBuilder builder,
    GarminRouteExtension? extension,
  ) {
    if (extension == null) {
      return;
    }

    builder.element(
      'gpxx:RouteExtension',
      nest: () {
        _writeElement(builder, 'gpxx:IsAutoNamed', extension.isAutoNamed);
        _writeElement(
          builder,
          'gpxx:DisplayColor',
          extension.displayColor?.value,
        );
        _writeGarminNestedExtensions(builder, 'gpxx', extension.extensions);
      },
    );
  }

  void _writeGarminRoutePointExtension(
    XmlBuilder builder,
    GarminRoutePointExtension? extension,
  ) {
    if (extension == null) {
      return;
    }

    builder.element(
      'gpxx:RoutePointExtension',
      nest: () {
        _writeElement(builder, 'gpxx:Subclass', extension.subclass);
        for (final routePoint in extension.routePoints) {
          builder.element(
            'gpxx:rpt',
            nest: () {
              _writeAttribute(builder, GpxTagV11.latitude, routePoint.lat);
              _writeAttribute(builder, GpxTagV11.longitude, routePoint.lon);
              _writeElement(builder, 'gpxx:Subclass', routePoint.subclass);
            },
          );
        }
        _writeGarminNestedExtensions(builder, 'gpxx', extension.extensions);
      },
    );
  }

  void _writeGarminTrackExtension(
    XmlBuilder builder,
    GarminTrackExtension? extension,
  ) {
    if (extension == null) {
      return;
    }

    builder.element(
      'gpxx:TrackExtension',
      nest: () {
        _writeElement(
          builder,
          'gpxx:DisplayColor',
          extension.displayColor?.value,
        );
        _writeGarminNestedExtensions(builder, 'gpxx', extension.extensions);
      },
    );
  }

  void _writeGarminTrackPointExtension(
    XmlBuilder builder,
    GarminTrackPointExtension? extension,
  ) {
    if (extension == null) {
      return;
    }

    builder.element(
      'gpxx:TrackPointExtension',
      nest: () {
        _writeElement(builder, 'gpxx:Temperature', extension.temperature);
        _writeElement(builder, 'gpxx:Depth', extension.depth);
        _writeGarminNestedExtensions(builder, 'gpxx', extension.extensions);
      },
    );
  }

  void _writeGarminTrackPointExtensionV1(
    XmlBuilder builder,
    GarminTrackPointExtensionV1? extension,
  ) {
    if (extension == null) {
      return;
    }

    builder.element(
      'gpxtpx:TrackPointExtension',
      nest: () {
        _writeElement(builder, 'gpxtpx:atemp', extension.airTemperature);
        _writeElement(builder, 'gpxtpx:wtemp', extension.waterTemperature);
        _writeElement(builder, 'gpxtpx:depth', extension.depth);
        _writeElement(builder, 'gpxtpx:hr', extension.heartRate);
        _writeElement(builder, 'gpxtpx:cad', extension.cadence);
        _writeGarminNestedExtensions(builder, 'gpxtpx', extension.extensions);
      },
    );
  }

  void _writeGarminNestedExtensions(
    XmlBuilder builder,
    String prefix,
    Map<String, Object> extensions,
  ) {
    if (extensions.isNotEmpty) {
      builder.element(
        '$prefix:Extensions',
        nest: () {
          extensions.forEach((k, v) {
            _writeElement(builder, k, v);
          });
        },
      );
    }
  }

  void _writeLinks(XmlBuilder builder, List<Link?>? value) {
    if (value != null) {
      for (final link in value.where((link) => link != null)) {
        builder.element(
          GpxTagV11.link,
          nest: () {
            _writeAttribute(builder, GpxTagV11.href, link?.href);

            _writeElement(builder, GpxTagV11.text, link?.text);
            _writeElement(builder, GpxTagV11.type, link?.type);
          },
        );
      }
    }
  }

  void _writeElement(XmlBuilder builder, String tagName, Object? value) {
    if (value != null) {
      if (value is Map) {
        builder.element(
          tagName,
          nest: () {
            value.forEach((k, v) {
              _writeElement(builder, k, v);
            });
          },
        );
      } else if (value is Iterable) {
        for (final item in value) {
          _writeElement(builder, tagName, item);
        }
      } else {
        builder.element(tagName, nest: value);
      }
    }
  }

  void _writeAttribute(XmlBuilder builder, String tagName, Object? value) {
    if (value != null) {
      builder.attribute(tagName, value);
    }
  }

  void _writeElementWithTime(
    XmlBuilder builder,
    String tagName,
    DateTime? value,
  ) {
    if (value != null) {
      builder.element(tagName, nest: value.toUtc().toIso8601String());
    }
  }

  String _localName(String name) {
    final separatorIndex = name.indexOf(':');
    return separatorIndex == -1 ? name : name.substring(separatorIndex + 1);
  }
}
