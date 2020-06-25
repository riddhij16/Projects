import 'package:flutter/foundation.dart';

class CartItem {
  final String id;
  final String title;
  final int quantity;
  final double price;
  CartItem({
    @required this.id,
    @required this.price,
    @required this.title,
    @required this.quantity,
  });
}

class Cart with ChangeNotifier {
  Map<String, CartItem> _items={};

  Map<String, CartItem> get items {
    return {..._items}; //copy
  }

  int get itemCount{//qty as TotalSum of qty(considering qty of product added)...or simply no. of products
    return _items==null ? 0:_items.length;
  }

  double get totalAmount{
    var total=0.0;
    _items.forEach((key,cartItem){
      total+= cartItem.price * cartItem.quantity;
    });
    return total;
  }

  void addItem(String productId, double price, String title) {
    if (_items.containsKey(productId)) {
      //checking whether we already have an entry by checkin the prodID
      //change qty
      _items.update(
        productId,
        (existingCartItem) => CartItem(
          id: existingCartItem.id,
          title: existingCartItem.title,
          price: existingCartItem.price,
          quantity: existingCartItem.quantity + 1,
        ),
      );
    } else {
      _items.putIfAbsent(
        productId,
        () => CartItem(
          id: DateTime.now().toString(),
          price: price,
          title: title,
          quantity: 1,
        ),
      );
    }
    notifyListeners();
  }
  void removeItem(String productId){
    _items.remove(productId);
    notifyListeners();

  }

  void removeSingleItem(String productId){ //remving single item only on clicking undo
    if (!_items.containsKey(productId)){
      return;
    }
    if(_items[productId].quantity>1){

      _items.update(
        productId,
        (existingCartItem) => CartItem(
          id: existingCartItem.id,
          title: existingCartItem.title,
          price: existingCartItem.price,
          quantity: existingCartItem.quantity - 1,
        ));
    } else{//=1
      _items.remove(productId);
    }
    notifyListeners();

  }


  void clear(){
    _items={};
    notifyListeners();
  }
}
