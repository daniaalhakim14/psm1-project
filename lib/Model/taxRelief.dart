class TaxRelief {
  final int? taxreliefid;
  final String? reliefcategory;
  final String? relieftype;
  final String? description;
  final double? reliefamount;
  final String? restrictions;
  final int? userid;
  final String? status;
  final DateTime? datecreated;

  TaxRelief({
    this.taxreliefid,
    this.reliefcategory,
    this.relieftype,
    this.description,
    this.reliefamount,
    this.restrictions,
    this.userid,
    this.status,
    this.datecreated,
  });

  factory TaxRelief.fromJson(Map<String, dynamic> json) => TaxRelief(
    taxreliefid: int.tryParse(json['taxreliefid'].toString()),
    reliefcategory: json['reliefcategory'],
    relieftype: json['relieftype'],
    description: json['description'],
    reliefamount: double.tryParse(json['reliefamount'].toString()),
    restrictions: json['restrictions'],
    userid: int.tryParse(json['userid'].toString()),
    status: json['status'],
    datecreated: json['datecreated'] != null ? DateTime.tryParse(json['datecreated']) : null,
  );

  Map<String, dynamic> toMap() {
    return {
      'taxreliefid': taxreliefid,
      'reliefcategory': reliefcategory,
      'relieftype': relieftype,
      'description': description,
      'reliefamount': reliefamount,
      'restrictions': restrictions,
      'userid': userid,
      'status': status,
      'datecreated': datecreated?.toIso8601String(),
    };
  }
}
