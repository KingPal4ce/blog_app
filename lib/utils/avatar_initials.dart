String avatarInitials(String? email) {
  if (email == null || email.isEmpty) {
    return '?';
  }
  final String namePart = email.split('@').first;
  final List<String> segments = namePart.split(RegExp('[._-]')).where((String s) => s.isNotEmpty).toList();
  if (segments.isEmpty) {
    return namePart.substring(0, 1).toUpperCase();
  }
  final String first = segments.first.substring(0, 1);
  final String second = segments.length > 1 ? segments[1].substring(0, 1) : '';
  return (first + second).toUpperCase();
}
