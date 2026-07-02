import 'garmin_gpx_extensions.dart';

class WptTypedExtensions {
  GarminWptExtensions? garmin;

  WptTypedExtensions({this.garmin});

  @override
  // ignore: type_annotate_public_apis
  bool operator ==(other) {
    if (other is WptTypedExtensions) {
      return other.garmin == garmin;
    }

    return false;
  }

  @override
  int get hashCode => garmin.hashCode;
}

class RteTypedExtensions {
  GarminRteExtensions? garmin;

  RteTypedExtensions({this.garmin});

  @override
  // ignore: type_annotate_public_apis
  bool operator ==(other) {
    if (other is RteTypedExtensions) {
      return other.garmin == garmin;
    }

    return false;
  }

  @override
  int get hashCode => garmin.hashCode;
}

class TrkTypedExtensions {
  GarminTrkExtensions? garmin;

  TrkTypedExtensions({this.garmin});

  @override
  // ignore: type_annotate_public_apis
  bool operator ==(other) {
    if (other is TrkTypedExtensions) {
      return other.garmin == garmin;
    }

    return false;
  }

  @override
  int get hashCode => garmin.hashCode;
}

class GarminWptExtensions {
  GarminWaypointExtension? waypoint;
  GarminWaypointExtensionV1? waypointV1;
  GarminRoutePointExtension? routePoint;
  GarminTrackPointExtension? trackPoint;
  GarminTrackPointExtensionV1? trackPointV1;

  GarminWptExtensions({
    this.waypoint,
    this.waypointV1,
    this.routePoint,
    this.trackPoint,
    this.trackPointV1,
  });

  bool get isEmpty =>
      waypoint == null &&
      waypointV1 == null &&
      routePoint == null &&
      trackPoint == null &&
      trackPointV1 == null;

  @override
  // ignore: type_annotate_public_apis
  bool operator ==(other) {
    if (other is GarminWptExtensions) {
      return other.waypoint == waypoint &&
          other.waypointV1 == waypointV1 &&
          other.routePoint == routePoint &&
          other.trackPoint == trackPoint &&
          other.trackPointV1 == trackPointV1;
    }

    return false;
  }

  @override
  int get hashCode =>
      Object.hash(waypoint, waypointV1, routePoint, trackPoint, trackPointV1);
}

class GarminRteExtensions {
  GarminRouteExtension? route;

  GarminRteExtensions({this.route});

  bool get isEmpty => route == null;

  @override
  // ignore: type_annotate_public_apis
  bool operator ==(other) {
    if (other is GarminRteExtensions) {
      return other.route == route;
    }

    return false;
  }

  @override
  int get hashCode => route.hashCode;
}

class GarminTrkExtensions {
  GarminTrackExtension? track;

  GarminTrkExtensions({this.track});

  bool get isEmpty => track == null;

  @override
  // ignore: type_annotate_public_apis
  bool operator ==(other) {
    if (other is GarminTrkExtensions) {
      return other.track == track;
    }

    return false;
  }

  @override
  int get hashCode => track.hashCode;
}
