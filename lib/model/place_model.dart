
class PlaceModel {
  final String name, rating, number, delivery, openNow, openDetail;
  
  PlaceModel.detailfromJson(Map<String, dynamic> json) 
  : name = json['result']['name'],
  rating = json['result']['rating'].toString(),
  number = json['result']['formatted_phone_number'] ?? '정보 없음',
  delivery = _confDelivery(json),
  openNow = _confOpenNow(json),
  openDetail = _confOpenDetail(json) ;

  static String _confDelivery(Map<String, dynamic> json) {
    /* log(json['result']['opening_hours']['delivery'].toString()); */
    if (json['result']['delivery'] == null) {
      return '정보 없음';
    } else {
      return json['result']['delivery'] == true ? '가능' : '불가능';
    } 
  }

  static String _confOpenNow(Map<String, dynamic> json) {
    if (json['result']['opening_hours'] == null) {
      return '영업 정보 없음';
    } else {
      return json['result']['opening_hours']['open_now'] == true ? '영업중' : '영업 시간이 아님';
    }
  }

  static String _confOpenDetail(Map<String, dynamic> json) {
    if(json['result']['opening_hours'] == null) {
      return 'null';
    }
    var valList = json['result']['opening_hours']['weekday_text'];
    String result = "";
    for (var elem in valList) {
      result += elem + "\n";
    }
    return result;
  }

}