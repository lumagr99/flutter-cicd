class TimetableEntry {
  final String title;
  final DateTime start;
  final DateTime end;
  final String location;

  TimetableEntry({
    required this.title,
    required this.start,
    required this.end,
    required this.location,
  });
}

extension TimetableEntryValidation on TimetableEntry {
  bool isValid() {
    return title.trim().isNotEmpty &&
        location.trim().isNotEmpty &&
        start.isBefore(end) || start.isAtSameMomentAs(end);
  }
}
