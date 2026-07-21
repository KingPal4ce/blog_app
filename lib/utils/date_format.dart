const List<String> _monthAbbreviations = <String>[
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String formatDisplayDate(DateTime date) {
  final DateTime local = date.toLocal();
  return '${_monthAbbreviations[local.month - 1]} ${local.day}, ${local.year}';
}
