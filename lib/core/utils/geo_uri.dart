/// Builds the `geo:` URI that opens an installed maps app for a task location.
///
/// The task form stores a human label ("Kantin Fakultas", "Ruang 3.2"), never
/// coordinates — Tazk asks for no location permission — so the query form
/// `geo:0,0?q=<label>` is the right shape: `0,0` is the placeholder centre that
/// the `geo` spec requires, and the maps app resolves the label itself.
///
/// Returns `null` when [location] is empty or whitespace only, so the caller can
/// disable the action instead of launching a map of nowhere. Surrounding
/// whitespace is trimmed, internal spaces and reserved characters (`#`, `&`,
/// `?`, `=`) are percent-encoded with [Uri.encodeComponent] so they cannot break
/// out of the query.
Uri? buildGeoUri(String location) {
  final trimmed = location.trim();
  if (trimmed.isEmpty) return null;
  return Uri.parse('geo:0,0?q=${Uri.encodeComponent(trimmed)}');
}