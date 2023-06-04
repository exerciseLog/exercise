class NutApiModel {
  final String name, maker, size, kcal, carb, protien, fat, sugar, sodium, col;

  NutApiModel.fromJson(Map<String, dynamic> json)
  : name = json['DESC_KOR'],
    maker = json['MAKER_NAME'],
    size = json['SERVING_SIZE'],
    kcal = json['NUTR_CONT1'],
    carb = json['NUTR_CONT2'],
    protien = json['NUTR_CONT3'],
    fat = json['NUTR_CONT4'],
    sugar = json['NUTR_CONT5'],
    sodium = json['NUTR_CONT6'],
    col = json['NUTR_CONT7'];
}
