
class AddItemCart{
  final int userid;
  final int itemcode;
  final String? brand;
  final String? unit;
  final int quantity;

  AddItemCart({
    required this.userid,
    required this.itemcode,
    required this.brand,
    required this.unit,
    required this.quantity
  });

  factory AddItemCart.fromJson(Map<String,dynamic> json){
    return AddItemCart(
        userid: int.parse(json['userid'].toString()),
        itemcode: int.parse(json['itemcode'].toString()),
        unit: json['unit'],
        brand: json['brand'],
        quantity: int.parse(json['quantity'].toString())
    );
  }

  Map<String, dynamic> toMap(){
    return{
      'userid': userid,
      'itemcode': itemcode,
      'unit': unit,
      'brand': brand,
      'quantity': quantity
    };
  }
}

class ViewItemCart{
  final int cartId;
  final int itemcode;
  final String? brand;
  final String? unit;
  final int quantity;

  ViewItemCart({
    required this.cartId,
    required this.itemcode,
    required this.brand,
    required this.unit,
    required this.quantity
  });

  factory ViewItemCart.fromJson(Map<String,dynamic> json){
    return ViewItemCart(
        cartId: int.parse(json['cartid'].toString()),
        itemcode: int.parse(json['itemcode'].toString()),
        unit: json['unit'],
        brand: json['brand'],
        quantity: int.parse(json['quantity'].toString())
    );
  }

  Map<String, dynamic> toMap(){
    return{
      'cartid': cartId,
      'itemcode': itemcode,
      'unit': unit,
      'brand': brand,
      'quantity': quantity
    };
  }
}

class DeleteItemCart {
  final int cart_item_id;

  DeleteItemCart({
    required this.cart_item_id,
  });

  // Construct a DeleteExpense instance from JSON
  factory DeleteItemCart.fromJson(Map<String, dynamic> json) {
    return DeleteItemCart(
      cart_item_id: int.parse(json['cart_item_id'].toString()),
    );
  }

  // Convert DeleteItemCart object to a Map for API requests
  Map<String, dynamic> toMap() {
    return {
      'cart_item_id': cart_item_id,
    };
  }
}
