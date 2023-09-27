class PlaceModel {
  final String rating, number;

  PlaceModel.detailfromJson(Map<String, dynamic> json) 
  : rating = json['result']['rating'].toString(),
  number = json['result']['formatted_phone_number'] ?? '';

}