class NutApiModel {
  final String name, maker, size, kcal;

  NutApiModel.fromJson(Map<String, dynamic> json)
  : name = json['DESC_KOR'],
    maker = json['MAKER_NAME'],
    size = json['SERVING_SIZE'],
    kcal = json['NUTR_CONT1'];
}
