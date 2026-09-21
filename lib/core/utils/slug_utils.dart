class SlugUtils {
  static String from(String value) {
    final lower = value.trim().toLowerCase();
    final slug = lower
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-{2,}'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    return slug.isEmpty ? 'item' : slug;
  }

  static String searchable(String value) => value.trim().toLowerCase();

  static List<String> keywords(String value) {
    final parts = searchable(value)
        .split(RegExp(r'[\s,/|-]+'))
        .where((e) => e.length > 1)
        .toSet()
        .toList();
    return parts;
  }
}
