class AddBranchModel{
  String title = '';
  double latitude = 0.0;
  double longitude = 0.0;
  double selectedRange = 100.0; // Default range
Map<String, dynamic> toJson()
{
  return {
    'title': title,
    'lat': latitude,
    'lon': longitude,
    'range': selectedRange
  };
}
}