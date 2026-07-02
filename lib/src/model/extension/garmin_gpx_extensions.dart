import 'package:collection/collection.dart';

/// Common namespace declarations for GPX documents.
class GpxNamespaces {
  static const garminGpxExtension =
      'http://www.garmin.com/xmlschemas/GpxExtensions/v3';
  static const garminTrackPointExtension =
      'http://www.garmin.com/xmlschemas/TrackPointExtension/v1';
  static const garminWaypointExtension =
      'http://www.garmin.com/xmlschemas/WaypointExtension/v1';

  static const garmin = {
    'gpxx': garminGpxExtension,
    'gpxtpx': garminTrackPointExtension,
    'wptx1': garminWaypointExtension,
  };
}

enum GarminDisplayMode {
  symbolOnly('SymbolOnly'),
  symbolAndName('SymbolAndName'),
  symbolAndDescription('SymbolAndDescription');

  const GarminDisplayMode(this.value);

  final String value;

  static GarminDisplayMode? fromString(String? value) =>
      GarminDisplayMode.values.firstWhereOrNull((mode) => mode.value == value);
}

enum GarminDisplayColor {
  black('Black'),
  darkRed('DarkRed'),
  darkGreen('DarkGreen'),
  darkYellow('DarkYellow'),
  darkBlue('DarkBlue'),
  darkMagenta('DarkMagenta'),
  darkCyan('DarkCyan'),
  lightGray('LightGray'),
  darkGray('DarkGray'),
  red('Red'),
  green('Green'),
  yellow('Yellow'),
  blue('Blue'),
  magenta('Magenta'),
  cyan('Cyan'),
  white('White'),
  transparent('Transparent');

  const GarminDisplayColor(this.value);

  final String value;

  static GarminDisplayColor? fromString(String? value) => GarminDisplayColor
      .values
      .firstWhereOrNull((color) => color.value == value);
}

class GarminAddress {
  List<String> streetAddresses;
  String? city;
  String? state;
  String? country;
  String? postalCode;
  Map<String, Object> extensions;

  GarminAddress({
    List<String>? streetAddresses,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    Map<String, Object>? extensions,
  }) : streetAddresses = streetAddresses ?? [],
       extensions = extensions ?? <String, Object>{};

  @override
  // ignore: type_annotate_public_apis
  bool operator ==(other) {
    if (other is GarminAddress) {
      return const ListEquality().equals(
            other.streetAddresses,
            streetAddresses,
          ) &&
          other.city == city &&
          other.state == state &&
          other.country == country &&
          other.postalCode == postalCode &&
          const DeepCollectionEquality().equals(other.extensions, extensions);
    }

    return false;
  }

  @override
  int get hashCode => Object.hashAll([
    ...streetAddresses,
    city,
    state,
    country,
    postalCode,
    ...extensions.keys,
    ...extensions.values,
  ]);
}

class GarminPhoneNumber {
  String? number;
  String? category;

  GarminPhoneNumber({this.number, this.category});

  @override
  // ignore: type_annotate_public_apis
  bool operator ==(other) {
    if (other is GarminPhoneNumber) {
      return other.number == number && other.category == category;
    }

    return false;
  }

  @override
  int get hashCode => Object.hash(number, category);
}

class GarminAutoroutePoint {
  double? lat;
  double? lon;
  String? subclass;

  GarminAutoroutePoint({this.lat, this.lon, this.subclass});

  @override
  // ignore: type_annotate_public_apis
  bool operator ==(other) {
    if (other is GarminAutoroutePoint) {
      return other.lat == lat && other.lon == lon && other.subclass == subclass;
    }

    return false;
  }

  @override
  int get hashCode => Object.hash(lat, lon, subclass);
}

class GarminWaypointExtension {
  double? proximity;
  double? temperature;
  double? depth;
  GarminDisplayMode? displayMode;
  List<String> categories;
  GarminAddress? address;
  List<GarminPhoneNumber> phoneNumbers;
  Map<String, Object> extensions;

  GarminWaypointExtension({
    this.proximity,
    this.temperature,
    this.depth,
    this.displayMode,
    List<String>? categories,
    this.address,
    List<GarminPhoneNumber>? phoneNumbers,
    Map<String, Object>? extensions,
  }) : categories = categories ?? [],
       phoneNumbers = phoneNumbers ?? [],
       extensions = extensions ?? <String, Object>{};

  @override
  // ignore: type_annotate_public_apis
  bool operator ==(other) {
    if (other is GarminWaypointExtension) {
      return other.proximity == proximity &&
          other.temperature == temperature &&
          other.depth == depth &&
          other.displayMode == displayMode &&
          const ListEquality().equals(other.categories, categories) &&
          other.address == address &&
          const ListEquality().equals(other.phoneNumbers, phoneNumbers) &&
          const DeepCollectionEquality().equals(other.extensions, extensions);
    }

    return false;
  }

  @override
  int get hashCode => Object.hashAll([
    proximity,
    temperature,
    depth,
    displayMode,
    ...categories,
    address,
    ...phoneNumbers,
    ...extensions.keys,
    ...extensions.values,
  ]);
}

class GarminWaypointExtensionV1 {
  double? proximity;
  double? temperature;
  double? depth;
  GarminDisplayMode? displayMode;
  List<String> categories;
  GarminAddress? address;
  List<GarminPhoneNumber> phoneNumbers;
  int? samples;
  DateTime? expiration;
  Map<String, Object> extensions;

  GarminWaypointExtensionV1({
    this.proximity,
    this.temperature,
    this.depth,
    this.displayMode,
    List<String>? categories,
    this.address,
    List<GarminPhoneNumber>? phoneNumbers,
    this.samples,
    this.expiration,
    Map<String, Object>? extensions,
  }) : categories = categories ?? [],
       phoneNumbers = phoneNumbers ?? [],
       extensions = extensions ?? <String, Object>{};

  @override
  // ignore: type_annotate_public_apis
  bool operator ==(other) {
    if (other is GarminWaypointExtensionV1) {
      return other.proximity == proximity &&
          other.temperature == temperature &&
          other.depth == depth &&
          other.displayMode == displayMode &&
          const ListEquality().equals(other.categories, categories) &&
          other.address == address &&
          const ListEquality().equals(other.phoneNumbers, phoneNumbers) &&
          other.samples == samples &&
          other.expiration == expiration &&
          const DeepCollectionEquality().equals(other.extensions, extensions);
    }

    return false;
  }

  @override
  int get hashCode => Object.hashAll([
    proximity,
    temperature,
    depth,
    displayMode,
    ...categories,
    address,
    ...phoneNumbers,
    samples,
    expiration,
    ...extensions.keys,
    ...extensions.values,
  ]);
}

class GarminRouteExtension {
  bool isAutoNamed;
  GarminDisplayColor? displayColor;
  Map<String, Object> extensions;

  GarminRouteExtension({
    this.isAutoNamed = false,
    this.displayColor,
    Map<String, Object>? extensions,
  }) : extensions = extensions ?? <String, Object>{};

  @override
  // ignore: type_annotate_public_apis
  bool operator ==(other) {
    if (other is GarminRouteExtension) {
      return other.isAutoNamed == isAutoNamed &&
          other.displayColor == displayColor &&
          const DeepCollectionEquality().equals(other.extensions, extensions);
    }

    return false;
  }

  @override
  int get hashCode => Object.hashAll([
    isAutoNamed,
    displayColor,
    ...extensions.keys,
    ...extensions.values,
  ]);
}

class GarminRoutePointExtension {
  String? subclass;
  List<GarminAutoroutePoint> routePoints;
  Map<String, Object> extensions;

  GarminRoutePointExtension({
    this.subclass,
    List<GarminAutoroutePoint>? routePoints,
    Map<String, Object>? extensions,
  }) : routePoints = routePoints ?? [],
       extensions = extensions ?? <String, Object>{};

  @override
  // ignore: type_annotate_public_apis
  bool operator ==(other) {
    if (other is GarminRoutePointExtension) {
      return other.subclass == subclass &&
          const ListEquality().equals(other.routePoints, routePoints) &&
          const DeepCollectionEquality().equals(other.extensions, extensions);
    }

    return false;
  }

  @override
  int get hashCode => Object.hashAll([
    subclass,
    ...routePoints,
    ...extensions.keys,
    ...extensions.values,
  ]);
}

class GarminTrackExtension {
  GarminDisplayColor? displayColor;
  Map<String, Object> extensions;

  GarminTrackExtension({this.displayColor, Map<String, Object>? extensions})
    : extensions = extensions ?? <String, Object>{};

  @override
  // ignore: type_annotate_public_apis
  bool operator ==(other) {
    if (other is GarminTrackExtension) {
      return other.displayColor == displayColor &&
          const DeepCollectionEquality().equals(other.extensions, extensions);
    }

    return false;
  }

  @override
  int get hashCode =>
      Object.hashAll([displayColor, ...extensions.keys, ...extensions.values]);
}

class GarminTrackPointExtension {
  double? temperature;
  double? depth;
  Map<String, Object> extensions;

  GarminTrackPointExtension({
    this.temperature,
    this.depth,
    Map<String, Object>? extensions,
  }) : extensions = extensions ?? <String, Object>{};

  @override
  // ignore: type_annotate_public_apis
  bool operator ==(other) {
    if (other is GarminTrackPointExtension) {
      return other.temperature == temperature &&
          other.depth == depth &&
          const DeepCollectionEquality().equals(other.extensions, extensions);
    }

    return false;
  }

  @override
  int get hashCode => Object.hashAll([
    temperature,
    depth,
    ...extensions.keys,
    ...extensions.values,
  ]);
}

class GarminTrackPointExtensionV1 {
  double? airTemperature;
  double? waterTemperature;
  double? depth;
  int? heartRate;
  int? cadence;
  Map<String, Object> extensions;

  GarminTrackPointExtensionV1({
    this.airTemperature,
    this.waterTemperature,
    this.depth,
    this.heartRate,
    this.cadence,
    Map<String, Object>? extensions,
  }) : extensions = extensions ?? <String, Object>{};

  @override
  // ignore: type_annotate_public_apis
  bool operator ==(other) {
    if (other is GarminTrackPointExtensionV1) {
      return other.airTemperature == airTemperature &&
          other.waterTemperature == waterTemperature &&
          other.depth == depth &&
          other.heartRate == heartRate &&
          other.cadence == cadence &&
          const DeepCollectionEquality().equals(other.extensions, extensions);
    }

    return false;
  }

  @override
  int get hashCode => Object.hashAll([
    airTemperature,
    waterTemperature,
    depth,
    heartRate,
    cadence,
    ...extensions.keys,
    ...extensions.values,
  ]);
}
