import 'package:xml/xml_events.dart';

import 'model/bounds.dart';
import 'model/copyright.dart';
import 'model/email.dart';
import 'model/extension/garmin_gpx_extensions.dart';
import 'model/extension/typed_extensions.dart';
import 'model/gpx.dart';
import 'model/gpx_tag.dart';
import 'model/link.dart';
import 'model/metadata.dart';
import 'model/person.dart';
import 'model/rte.dart';
import 'model/trk.dart';
import 'model/trkseg.dart';
import 'model/wpt.dart';

/// Read Gpx from string
class GpxReader {
  //  // @TODO
  //  Gpx fromStream(Stream<int> stream) {
  //
  //  }

  /// Parse xml string and create Gpx object
  Gpx fromString(String xml) {
    final iterator = parseEvents(xml).iterator;

    while (iterator.moveNext()) {
      final val = iterator.current;

      if (val is XmlStartElementEvent && val.name == GpxTagV11.gpx) {
        break;
      }
    }

    // ignore: avoid_as
    final gpxTag = iterator.current as XmlStartElementEvent;
    final gpx = Gpx();

    gpx.version = gpxTag.attributes
        .firstWhere(
          (attr) => attr.name == GpxTagV11.version,
          orElse: () => XmlEventAttribute(
            GpxTagV11.version,
            '1.1',
            XmlAttributeType.DOUBLE_QUOTE,
          ),
        )
        .value;
    gpx.creator = gpxTag.attributes
        .firstWhere(
          (attr) => attr.name == GpxTagV11.creator,
          orElse: () => XmlEventAttribute(
            GpxTagV11.creator,
            'unknown',
            XmlAttributeType.DOUBLE_QUOTE,
          ),
        )
        .value;

    while (iterator.moveNext()) {
      final val = iterator.current;
      if (val is XmlEndElementEvent && val.name == GpxTagV11.gpx) {
        break;
      }

      if (val is XmlStartElementEvent) {
        switch (val.name) {
          case GpxTagV11.metadata:
            gpx.metadata = _parseMetadata(iterator);
            break;
          case GpxTagV11.wayPoint:
            gpx.wpts.add(_readPoint(iterator, val.name));
            break;
          case GpxTagV11.route:
            gpx.rtes.add(_parseRoute(iterator));
            break;
          case GpxTagV11.track:
            gpx.trks.add(_parseTrack(iterator));
            break;

          case GpxTagV11.extensions:
            gpx.extensions = _readExtensions(iterator);
            break;
        }
      }
    }

    return gpx;
  }

  Metadata _parseMetadata(Iterator<XmlEvent> iterator) {
    final metadata = Metadata();
    final elm = iterator.current;

    if ((elm is XmlStartElementEvent) && !elm.isSelfClosing) {
      while (iterator.moveNext()) {
        final val = iterator.current;

        if (val is XmlStartElementEvent) {
          switch (val.name) {
            case GpxTagV11.name:
              metadata.name = _readString(iterator, val.name);
              break;
            case GpxTagV11.desc:
              metadata.desc = _readString(iterator, val.name);
              break;
            case GpxTagV11.author:
              metadata.author = _readPerson(iterator);
              break;
            case GpxTagV11.copyright:
              metadata.copyright = _readCopyright(iterator);
              break;
            case GpxTagV11.link:
              metadata.links.add(_readLink(iterator));
              break;
            case GpxTagV11.time:
              metadata.time = _readDateTime(iterator, val.name);
              break;
            case GpxTagV11.keywords:
              metadata.keywords = _readString(iterator, val.name);
              break;
            case GpxTagV11.bounds:
              metadata.bounds = _readBounds(iterator);
              break;
            case GpxTagV11.extensions:
              metadata.extensions = _readExtensions(iterator);
              break;
          }
        }

        if (val is XmlEndElementEvent && val.name == GpxTagV11.metadata) {
          break;
        }
      }
    }

    return metadata;
  }

  Rte _parseRoute(Iterator<XmlEvent> iterator) {
    final rte = Rte();
    final elm = iterator.current;

    if ((elm is XmlStartElementEvent) && !elm.isSelfClosing) {
      while (iterator.moveNext()) {
        final val = iterator.current;

        if (val is XmlStartElementEvent) {
          switch (val.name) {
            case GpxTagV11.routePoint:
              rte.rtepts.add(_readPoint(iterator, val.name));
              break;

            case GpxTagV11.name:
              rte.name = _readString(iterator, val.name);
              break;
            case GpxTagV11.desc:
              rte.desc = _readString(iterator, val.name);
              break;
            case GpxTagV11.comment:
              rte.cmt = _readString(iterator, val.name);
              break;
            case GpxTagV11.src:
              rte.src = _readString(iterator, val.name);
              break;

            case GpxTagV11.link:
              rte.links.add(_readLink(iterator));
              break;

            case GpxTagV11.number:
              rte.number = _readInt(iterator, val.name);
              break;
            case GpxTagV11.type:
              rte.type = _readString(iterator, val.name);
              break;

            case GpxTagV11.extensions:
              rte.extensions = _readExtensions(iterator);
              rte.typedExtensions = _readRteTypedExtensions(rte.extensions);
              break;
          }
        }

        if (val is XmlEndElementEvent && val.name == GpxTagV11.route) {
          break;
        }
      }
    }

    return rte;
  }

  Trk _parseTrack(Iterator<XmlEvent> iterator) {
    final trk = Trk();
    final elm = iterator.current;

    if ((elm is XmlStartElementEvent) && !elm.isSelfClosing) {
      while (iterator.moveNext()) {
        final val = iterator.current;

        if (val is XmlStartElementEvent) {
          switch (val.name) {
            case GpxTagV11.trackSegment:
              trk.trksegs.add(_readSegment(iterator));
              break;

            case GpxTagV11.name:
              trk.name = _readString(iterator, val.name);
              break;
            case GpxTagV11.desc:
              trk.desc = _readString(iterator, val.name);
              break;
            case GpxTagV11.comment:
              trk.cmt = _readString(iterator, val.name);
              break;
            case GpxTagV11.src:
              trk.src = _readString(iterator, val.name);
              break;

            case GpxTagV11.link:
              trk.links.add(_readLink(iterator));
              break;

            case GpxTagV11.number:
              trk.number = _readInt(iterator, val.name);
              break;
            case GpxTagV11.type:
              trk.type = _readString(iterator, val.name);
              break;

            case GpxTagV11.extensions:
              trk.extensions = _readExtensions(iterator);
              trk.typedExtensions = _readTrkTypedExtensions(trk.extensions);
              break;
          }
        }

        if (val is XmlEndElementEvent && val.name == GpxTagV11.track) {
          break;
        }
      }
    }

    return trk;
  }

  Wpt _readPoint(Iterator<XmlEvent> iterator, String tagName) {
    final wpt = Wpt();
    final elm = iterator.current;

    if (elm is XmlStartElementEvent) {
      wpt.lat = double.parse(
        elm.attributes
            .firstWhere((attr) => attr.name == GpxTagV11.latitude)
            .value,
      );
      wpt.lon = double.parse(
        elm.attributes
            .firstWhere((attr) => attr.name == GpxTagV11.longitude)
            .value,
      );
    }

    if ((elm is XmlStartElementEvent) && !elm.isSelfClosing) {
      while (iterator.moveNext()) {
        final val = iterator.current;

        if (val is XmlStartElementEvent) {
          switch (val.name) {
            case GpxTagV11.sym:
              wpt.sym = _readString(iterator, val.name);
              break;

            case GpxTagV11.fix:
              final fixAsString = _readString(iterator, val.name);
              wpt.fix = FixType.values.firstWhere(
                (e) =>
                    e.toString().replaceFirst('.fix_', '.') ==
                    'FixType.$fixAsString',
                orElse: () => FixType.unknown,
              );

              if (wpt.fix == FixType.unknown) {
                wpt.fix = null;
              }
              break;

            case GpxTagV11.dGPSId:
              wpt.dgpsid = _readInt(iterator, val.name);
              break;

            case GpxTagV11.name:
              wpt.name = _readString(iterator, val.name);
              break;
            case GpxTagV11.desc:
              wpt.desc = _readString(iterator, val.name);
              break;
            case GpxTagV11.comment:
              wpt.cmt = _readString(iterator, val.name);
              break;
            case GpxTagV11.src:
              wpt.src = _readString(iterator, val.name);
              break;
            case GpxTagV11.link:
              wpt.links.add(_readLink(iterator));
              break;
            case GpxTagV11.hDOP:
              wpt.hdop = _readDouble(iterator, val.name);
              break;
            case GpxTagV11.vDOP:
              wpt.vdop = _readDouble(iterator, val.name);
              break;
            case GpxTagV11.pDOP:
              wpt.pdop = _readDouble(iterator, val.name);
              break;
            case GpxTagV11.ageOfData:
              wpt.ageofdgpsdata = _readDouble(iterator, val.name);
              break;

            case GpxTagV11.magVar:
              wpt.magvar = _readDouble(iterator, val.name);
              break;
            case GpxTagV11.geoidHeight:
              wpt.geoidheight = _readDouble(iterator, val.name);
              break;

            case GpxTagV11.sat:
              wpt.sat = _readInt(iterator, val.name);
              break;

            case GpxTagV11.elevation:
              wpt.ele = _readDouble(iterator, val.name);
              break;
            case GpxTagV11.time:
              wpt.time = _readDateTime(iterator, val.name);
              break;
            case GpxTagV11.type:
              wpt.type = _readString(iterator, val.name);
              break;
            case GpxTagV11.extensions:
              wpt.extensions = _readExtensions(iterator);
              wpt.typedExtensions = _readWptTypedExtensions(wpt.extensions);
              break;
          }
        }

        if (val is XmlEndElementEvent && val.name == tagName) {
          break;
        }
      }
    }

    return wpt;
  }

  double? _readDouble(Iterator<XmlEvent> iterator, String tagName) {
    final doubleString = _readString(iterator, tagName);
    return doubleString != null ? double.parse(doubleString) : null;
  }

  int? _readInt(Iterator<XmlEvent> iterator, String tagName) {
    final intString = _readString(iterator, tagName);
    return intString != null ? int.parse(intString) : null;
  }

  DateTime? _readDateTime(Iterator<XmlEvent> iterator, String tagName) {
    final dateTimeString = _readString(iterator, tagName);
    return dateTimeString != null ? DateTime.parse(dateTimeString) : null;
  }

  String? _readString(Iterator<XmlEvent> iterator, String tagName) {
    final elm = iterator.current;
    if (!(elm is XmlStartElementEvent &&
        elm.name == tagName &&
        !elm.isSelfClosing)) {
      return null;
    }

    var string = '';
    while (iterator.moveNext()) {
      final val = iterator.current;

      if (val is XmlTextEvent) {
        string += val.value;
      }

      if (val is XmlCDATAEvent) {
        string += val.value;
      }

      if (val is XmlEndElementEvent && val.name == tagName) {
        break;
      }
    }

    return string;
  }

  Object? _readMap(Iterator<XmlEvent> iterator, String tagName) {
    final elm = iterator.current;
    if (!(elm is XmlStartElementEvent &&
        elm.name == tagName &&
        !elm.isSelfClosing)) {
      return null;
    }

    final valueMap = <String, Object>{};
    if (elm.attributes.isNotEmpty) {
      valueMap['@attributes'] = <String, Object>{
        for (final attribute in elm.attributes) attribute.name: attribute.value,
      };
    }
    String? valueText;
    while (iterator.moveNext()) {
      final val = iterator.current;

      if (val is XmlStartElementEvent) {
        final value = _readMap(iterator, val.name) ?? {};
        final existingValue = valueMap[val.name];
        if (existingValue == null) {
          valueMap[val.name] = value;
        } else if (existingValue is List<Object>) {
          existingValue.add(value);
        } else {
          valueMap[val.name] = [existingValue, value];
        }
      }

      if (val is XmlTextEvent) {
        valueText = val.value;
      }

      if (val is XmlCDATAEvent) {
        valueText = val.value;
      }

      if (val is XmlEndElementEvent && val.name == tagName) {
        break;
      }
    }

    if (valueMap.isNotEmpty) {
      if (valueText != null && valueText.trim().isNotEmpty) {
        valueMap['#text'] = valueText;
      }
      return valueMap;
    }

    return valueText;
  }

  Trkseg _readSegment(Iterator<XmlEvent> iterator) {
    final trkseg = Trkseg();
    final elm = iterator.current;

    if ((elm is XmlStartElementEvent) && !elm.isSelfClosing) {
      while (iterator.moveNext()) {
        final val = iterator.current;

        if (val is XmlStartElementEvent) {
          switch (val.name) {
            case GpxTagV11.trackPoint:
              trkseg.trkpts.add(_readPoint(iterator, val.name));
              break;
            case GpxTagV11.extensions:
              trkseg.extensions = _readExtensions(iterator);
              break;
          }
        }

        if (val is XmlEndElementEvent && val.name == GpxTagV11.trackSegment) {
          break;
        }
      }
    }

    return trkseg;
  }

  Map<String, Object> _readExtensions(Iterator<XmlEvent> iterator) {
    final exts = _readMap(iterator, GpxTagV11.extensions) ?? {};
    return (exts is Map<String, Object>) ? exts : {};
  }

  WptTypedExtensions? _readWptTypedExtensions(Map<String, Object> extensions) {
    final garmin = GarminWptExtensions(
      waypoint: _readGarminWaypointExtension(extensions),
      waypointV1: _readGarminWaypointExtensionV1(extensions),
      routePoint: _readGarminRoutePointExtension(extensions),
      trackPoint: _readGarminTrackPointExtension(extensions),
      trackPointV1: _readGarminTrackPointExtensionV1(extensions),
    );

    return garmin.isEmpty ? null : WptTypedExtensions(garmin: garmin);
  }

  RteTypedExtensions? _readRteTypedExtensions(Map<String, Object> extensions) {
    final garmin = GarminRteExtensions(
      route: _readGarminRouteExtension(extensions),
    );

    return garmin.isEmpty ? null : RteTypedExtensions(garmin: garmin);
  }

  TrkTypedExtensions? _readTrkTypedExtensions(Map<String, Object> extensions) {
    final garmin = GarminTrkExtensions(
      track: _readGarminTrackExtension(extensions),
    );

    return garmin.isEmpty ? null : TrkTypedExtensions(garmin: garmin);
  }

  GarminWaypointExtension? _readGarminWaypointExtension(
    Map<String, Object> extensions,
  ) {
    final value = _readGarminExtensionMap(
      extensions,
      'WaypointExtension',
      qualifiedName: 'gpxx:WaypointExtension',
    );
    if (value == null) {
      return null;
    }

    return GarminWaypointExtension(
      proximity: _doubleValue(value, 'Proximity'),
      temperature: _doubleValue(value, 'Temperature'),
      depth: _doubleValue(value, 'Depth'),
      displayMode: GarminDisplayMode.fromString(
        _stringValue(value, 'DisplayMode'),
      ),
      categories: _stringValues(
        _readGarminExtensionMap(value, 'Categories') ?? const {},
        'Category',
      ),
      address: _readGarminAddress(value),
      phoneNumbers: _readGarminPhoneNumbers(value),
      extensions: _readGarminNestedExtensions(value),
    );
  }

  GarminAddress? _readGarminAddress(Map<String, Object> extension) {
    final value = _readGarminExtensionMap(extension, 'Address');
    if (value == null) {
      return null;
    }

    return GarminAddress(
      streetAddresses: _stringValues(value, 'StreetAddress'),
      city: _stringValue(value, 'City'),
      state: _stringValue(value, 'State'),
      country: _stringValue(value, 'Country'),
      postalCode: _stringValue(value, 'PostalCode'),
      extensions: _readGarminNestedExtensions(value),
    );
  }

  GarminWaypointExtensionV1? _readGarminWaypointExtensionV1(
    Map<String, Object> extensions,
  ) {
    final value = _readGarminExtensionMap(
      extensions,
      'WaypointExtension',
      qualifiedName: 'wptx1:WaypointExtension',
    );
    if (value == null) {
      return null;
    }

    return GarminWaypointExtensionV1(
      proximity: _doubleValue(value, 'Proximity'),
      temperature: _doubleValue(value, 'Temperature'),
      depth: _doubleValue(value, 'Depth'),
      displayMode: GarminDisplayMode.fromString(
        _stringValue(value, 'DisplayMode'),
      ),
      categories: _stringValues(
        _readGarminExtensionMap(value, 'Categories') ?? const {},
        'Category',
      ),
      address: _readGarminAddress(value),
      phoneNumbers: _readGarminPhoneNumbers(value),
      samples: _intValue(value, 'Samples'),
      expiration: _dateTimeValue(value, 'Expiration'),
      extensions: _readGarminNestedExtensions(value),
    );
  }

  List<GarminPhoneNumber> _readGarminPhoneNumbers(
    Map<String, Object> extension,
  ) {
    final value = _valueByLocalName(extension, 'PhoneNumber');
    if (value == null) {
      return [];
    }

    final values = value is List<Object> ? value : [value];
    return values.map((phoneNumber) {
      if (phoneNumber is Map<String, Object>) {
        return GarminPhoneNumber(
          number: _textValue(phoneNumber),
          category: _attributeValue(phoneNumber, 'Category'),
        );
      }

      return GarminPhoneNumber(number: phoneNumber.toString());
    }).toList();
  }

  GarminRouteExtension? _readGarminRouteExtension(
    Map<String, Object> extensions,
  ) {
    final value = _readGarminExtensionMap(
      extensions,
      'RouteExtension',
      qualifiedName: 'gpxx:RouteExtension',
    );
    if (value == null) {
      return null;
    }

    return GarminRouteExtension(
      isAutoNamed: _boolValue(value, 'IsAutoNamed') ?? false,
      displayColor: GarminDisplayColor.fromString(
        _stringValue(value, 'DisplayColor'),
      ),
      extensions: _readGarminNestedExtensions(value),
    );
  }

  GarminRoutePointExtension? _readGarminRoutePointExtension(
    Map<String, Object> extensions,
  ) {
    final value = _readGarminExtensionMap(
      extensions,
      'RoutePointExtension',
      qualifiedName: 'gpxx:RoutePointExtension',
    );
    if (value == null) {
      return null;
    }

    return GarminRoutePointExtension(
      subclass: _stringValue(value, 'Subclass'),
      routePoints: _readGarminAutoroutePoints(value),
      extensions: _readGarminNestedExtensions(value),
    );
  }

  List<GarminAutoroutePoint> _readGarminAutoroutePoints(
    Map<String, Object> extension,
  ) {
    final value = _valueByLocalName(extension, 'rpt');
    if (value == null) {
      return [];
    }

    final values = value is List<Object> ? value : [value];
    return values
        .whereType<Map<String, Object>>()
        .map(
          (routePoint) => GarminAutoroutePoint(
            lat: _doubleAttributeValue(routePoint, GpxTagV11.latitude),
            lon: _doubleAttributeValue(routePoint, GpxTagV11.longitude),
            subclass: _stringValue(routePoint, 'Subclass'),
          ),
        )
        .toList();
  }

  GarminTrackExtension? _readGarminTrackExtension(
    Map<String, Object> extensions,
  ) {
    final value = _readGarminExtensionMap(
      extensions,
      'TrackExtension',
      qualifiedName: 'gpxx:TrackExtension',
    );
    if (value == null) {
      return null;
    }

    return GarminTrackExtension(
      displayColor: GarminDisplayColor.fromString(
        _stringValue(value, 'DisplayColor'),
      ),
      extensions: _readGarminNestedExtensions(value),
    );
  }

  GarminTrackPointExtension? _readGarminTrackPointExtension(
    Map<String, Object> extensions,
  ) {
    final value = _readGarminExtensionMap(
      extensions,
      'TrackPointExtension',
      qualifiedName: 'gpxx:TrackPointExtension',
    );
    if (value == null) {
      return null;
    }

    return GarminTrackPointExtension(
      temperature: _doubleValue(value, 'Temperature'),
      depth: _doubleValue(value, 'Depth'),
      extensions: _readGarminNestedExtensions(value),
    );
  }

  GarminTrackPointExtensionV1? _readGarminTrackPointExtensionV1(
    Map<String, Object> extensions,
  ) {
    final value = _readGarminExtensionMap(
      extensions,
      'TrackPointExtension',
      qualifiedName: 'gpxtpx:TrackPointExtension',
    );
    if (value == null) {
      return null;
    }

    return GarminTrackPointExtensionV1(
      airTemperature: _doubleValue(value, 'atemp'),
      waterTemperature: _doubleValue(value, 'wtemp'),
      depth: _doubleValue(value, 'depth'),
      heartRate: _intValue(value, 'hr'),
      cadence: _intValue(value, 'cad'),
      extensions: _readGarminNestedExtensions(value),
    );
  }

  Map<String, Object> _readGarminNestedExtensions(
    Map<String, Object> extension,
  ) => _readGarminExtensionMap(extension, 'Extensions') ?? <String, Object>{};

  Map<String, Object>? _readGarminExtensionMap(
    Map<String, Object> extensions,
    String localName, {
    String? qualifiedName,
  }) {
    final value = qualifiedName != null
        ? _valueByQualifiedOrLocalName(extensions, qualifiedName, localName)
        : _valueByLocalName(extensions, localName);
    return value is Map<String, Object> ? value : null;
  }

  Object? _valueByQualifiedOrLocalName(
    Map<String, Object> map,
    String qualifiedName,
    String localName,
  ) {
    final value = map[qualifiedName];
    if (value != null) {
      return value;
    }

    return map[localName];
  }

  Object? _valueByLocalName(Map<String, Object> map, String localName) {
    for (final entry in map.entries) {
      if (_localName(entry.key) == localName) {
        return entry.value;
      }
    }

    return null;
  }

  double? _doubleValue(Map<String, Object> map, String localName) {
    final value = _stringValue(map, localName);
    return value != null ? double.parse(value) : null;
  }

  int? _intValue(Map<String, Object> map, String localName) {
    final value = _stringValue(map, localName);
    return value != null ? int.parse(value) : null;
  }

  bool? _boolValue(Map<String, Object> map, String localName) {
    final value = _stringValue(map, localName);
    return value != null ? value.toLowerCase() == 'true' : null;
  }

  DateTime? _dateTimeValue(Map<String, Object> map, String localName) {
    final value = _stringValue(map, localName);
    return value != null ? DateTime.parse(value) : null;
  }

  String? _stringValue(Map<String, Object> map, String localName) {
    final value = _valueByLocalName(map, localName);
    if (value is String) {
      return value;
    }
    if (value is Map<String, Object>) {
      return _textValue(value);
    }

    return null;
  }

  List<String> _stringValues(Map<String, Object> map, String localName) {
    final value = _valueByLocalName(map, localName);
    if (value is String) {
      return [value];
    }
    if (value is Map<String, Object>) {
      final text = _textValue(value);
      return text != null ? [text] : [];
    }
    if (value is List<Object>) {
      return value
          .map((item) {
            if (item is String) {
              return item;
            }
            if (item is Map<String, Object>) {
              return _textValue(item);
            }
            return null;
          })
          .whereType<String>()
          .toList();
    }

    return [];
  }

  String? _textValue(Map<String, Object> map) {
    final value = map['#text'];
    return value is String ? value : null;
  }

  double? _doubleAttributeValue(Map<String, Object> map, String attributeName) {
    final value = _attributeValue(map, attributeName);
    return value != null ? double.parse(value) : null;
  }

  String? _attributeValue(Map<String, Object> map, String attributeName) {
    final attributes = map['@attributes'];
    if (attributes is Map<String, Object>) {
      final value = attributes[attributeName];
      return value is String ? value : null;
    }

    return null;
  }

  String _localName(String name) {
    final separatorIndex = name.indexOf(':');
    return separatorIndex == -1 ? name : name.substring(separatorIndex + 1);
  }

  Link _readLink(Iterator<XmlEvent> iterator) {
    final link = Link();
    final elm = iterator.current;

    if (elm is XmlStartElementEvent) {
      final hrefs = elm.attributes.where((attr) => attr.name == GpxTagV11.href);

      if (hrefs.isNotEmpty) {
        link.href = hrefs.first.value;
      }
    }

    if ((elm is XmlStartElementEvent) && !elm.isSelfClosing) {
      while (iterator.moveNext()) {
        final val = iterator.current;

        if (val is XmlStartElementEvent) {
          switch (val.name) {
            case GpxTagV11.text:
              link.text = _readString(iterator, val.name);
              break;
            case GpxTagV11.type:
              link.type = _readString(iterator, val.name);
              break;
          }
        }

        if (val is XmlEndElementEvent && val.name == GpxTagV11.link) {
          break;
        }
      }
    }

    return link;
  }

  Person _readPerson(Iterator<XmlEvent> iterator) {
    final person = Person();
    final elm = iterator.current;

    if ((elm is XmlStartElementEvent) && !elm.isSelfClosing) {
      while (iterator.moveNext()) {
        final val = iterator.current;

        if (val is XmlStartElementEvent) {
          switch (val.name) {
            case GpxTagV11.name:
              person.name = _readString(iterator, val.name);
              break;
            case GpxTagV11.email:
              person.email = _readEmail(iterator);
              break;
            case GpxTagV11.link:
              person.link = _readLink(iterator);
              break;
          }
        }

        if (val is XmlEndElementEvent && val.name == GpxTagV11.author) {
          break;
        }
      }
    }

    return person;
  }

  Copyright _readCopyright(Iterator<XmlEvent> iterator) {
    final copyright = Copyright();
    final elm = iterator.current;

    if (elm is XmlStartElementEvent) {
      copyright.author = elm.attributes
          .firstWhere((attr) => attr.name == GpxTagV11.author)
          .value;

      if (!elm.isSelfClosing) {
        while (iterator.moveNext()) {
          final val = iterator.current;

          if (val is XmlStartElementEvent) {
            switch (val.name) {
              case GpxTagV11.year:
                copyright.year = _readInt(iterator, val.name);
                break;
              case GpxTagV11.license:
                copyright.license = _readString(iterator, val.name);
                break;
            }
          }

          if (val is XmlEndElementEvent && val.name == GpxTagV11.copyright) {
            break;
          }
        }
      }
    }

    return copyright;
  }

  Bounds _readBounds(Iterator<XmlEvent> iterator) {
    final bounds = Bounds();
    final elm = iterator.current;

    if (elm is XmlStartElementEvent) {
      bounds.minlat = double.parse(
        elm.attributes
            .firstWhere((attr) => attr.name == GpxTagV11.minLatitude)
            .value,
      );
      bounds.minlon = double.parse(
        elm.attributes
            .firstWhere((attr) => attr.name == GpxTagV11.minLongitude)
            .value,
      );
      bounds.maxlat = double.parse(
        elm.attributes
            .firstWhere((attr) => attr.name == GpxTagV11.maxLatitude)
            .value,
      );
      bounds.maxlon = double.parse(
        elm.attributes
            .firstWhere((attr) => attr.name == GpxTagV11.maxLongitude)
            .value,
      );

      if (!elm.isSelfClosing) {
        while (iterator.moveNext()) {
          final val = iterator.current;

          if (val is XmlEndElementEvent && val.name == GpxTagV11.bounds) {
            break;
          }
        }
      }
    }

    return bounds;
  }

  Email _readEmail(Iterator<XmlEvent> iterator) {
    final email = Email();
    final elm = iterator.current;

    if (elm is XmlStartElementEvent) {
      email.id = elm.attributes
          .firstWhere((attr) => attr.name == GpxTagV11.id)
          .value;
      email.domain = elm.attributes
          .firstWhere((attr) => attr.name == GpxTagV11.domain)
          .value;

      if (!elm.isSelfClosing) {
        while (iterator.moveNext()) {
          final val = iterator.current;

          if (val is XmlEndElementEvent && val.name == GpxTagV11.email) {
            break;
          }
        }
      }
    }

    return email;
  }
}
