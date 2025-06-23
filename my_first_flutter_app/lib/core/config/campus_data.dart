
import 'package:my_first_flutter_app/core/models/campus.dart';

class CampusData {
  static const List<Campus> campuses = [
    Campus(
      name: 'Hagen',
      latitude: 51.365142,
      longitude: 7.492510,
      menuUrl: 'https://www.stwdo.de/mensa-cafes-und-catering/fh-suedwestfalen/hagen/',
    ),
    Campus(
      name: 'Iserlohn',
      latitude: 51.36947,
      longitude: 7.68508,
      menuUrl: 'https://www.stwdo.de/mensa-cafes-und-catering/fh-suedwestfalen/iserlohn/',
    ),
    Campus(
      name: 'Meschede',
      latitude: 51.360725,
      longitude: 8.292891,
      menuUrl: 'https://www.stwdo.de/mensa-cafes-und-catering/fh-suedwestfalen/meschede/',
    ),
    Campus(
      name: 'Soest',
      latitude: 51.562942,
      longitude: 8.114576,
      menuUrl: 'https://www.stwdo.de/mensa-cafes-und-catering/fh-suedwestfalen/soest/',
    ),
  ];
}
