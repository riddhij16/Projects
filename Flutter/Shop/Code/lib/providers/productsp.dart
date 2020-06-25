import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './product.dart';
import '../models/http_exception.dart';



//change notifier basically allows us to establish behind the scenes communication tunnels
class Products with ChangeNotifier {//mix-ins  :with
  List<Product> _items=[
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),

  ]; 

  //var _showFavoritesOnly=false;
  final String authToken;
  final String userId;

  Products(this.authToken,this.userId,this._items);

  List<Product> get items {  //so that whenevr any value gets added.. it on purpose calls a method so that all the listeners get to know that something has changed

    //if(_showFavoritesOnly){
      //return _items.where((prodItem)=> prodItem.isFavorite).toList();
    //}
    
    return [..._items]; //copy
  }

  List<Product> get favoriteItems{
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }
  
  Product findById(String id){
    return _items.firstWhere((prod) => prod.id==id);
  }


//refer this to get clear for await async
//give queries after ? using & for multiple
//filtering done on server side before the database is hit.. bcoz if not then the app becomes slow
//[] used for optional positional argument

  Future<void> fetchAndSetProducts([bool filterByUser=false]) async{
    final filterString=filterByUser? 'orderBy="creatorId"&equalTo="$userId"' : '' ;
    final url='https://shop-25acc.firebaseio.com/products.json?auth=$authToken&$filterString';
    try{
      final response = await http.get(url);
      final extractedData=json.decode(response.body) as Map<String, dynamic >;
      if(extractedData==null){
      return;
     }
     final url1='https://shop-25acc.firebaseio.com/userFavorites/$userId.json?auth=$authToken';
      final favoriteResponse=await http.get(url1);
      final favoriteData=json.decode(favoriteResponse.body) ;

      final List<Product> loadedProducts=[];
      
      extractedData.forEach((prodId,prodData){
        loadedProducts.add(Product(
          id:prodId,
          title:prodData['title'],
          description:prodData['description'],
          price:prodData['price'],
          imageUrl:prodData['imageUrl'],
          isFavorite: favoriteData==null ? false:favoriteData[prodId] ?? false,//?? means if before one is null then execute nextwala
        ));
      });
      _items=loadedProducts;
      notifyListeners();

    }catch (error){
      throw(error);
    }
    

  }
  //changing the rules in firebase to selatc the fields we want to filter and also by/on what fiels


  Future<void> addProduct(Product product) async {
    final url='https://shop-25acc.firebaseio.com/products.json?auth=$authToken'; //gets translated as database query which creates such a collection and stores the data. in profucts.. 
    //must added .json in firebase .json
    //only FIREBASE allows to specify something after /..eg products.json
    // it creates thata as a folder in server

    try{
    final response=await http.post(url,body: json.encode({//http is like future
      
    //to append.. body takes entry in form of json
    //in dart json format is similar to maps
      'title':product.title,
      'description':product.description,
      'imageUrl':product.imageUrl,//async code
      'price':product.price,
      'creatorId':userId,
      //'isFavourite':product.isFavorite,
    }),
    );
    //.then((response) {//response var has the unique crytic ID firebase creates 
      //> invisible then
      final newProduct= Product( //executes when task is done i.e when response comes so takes some time to appear
     
                    title: product.title,
                    price: product.price,
                    description: product.description,
                    imageUrl: product.imageUrl,
                    id: json.decode(response.body)['name'],//on server...backend ID
                  );

    _items.add(newProduct);
    notifyListeners();
  } catch(error){
    throw error; //run if code btw try catxhes error
  }
    


  }
  Future<void> updateProduct(String id,Product newProduct ) async {//overwriting for pencil icon
    final prodIndex=_items.indexWhere((prod)=>prod.id==id);
    if(prodIndex>=0){
      final url='https://shop-25acc.firebaseio.com/products/$id.json?auth=$authToken';
      await http.patch(url,body:json.encode({
        'title':newProduct.title,
        'description':newProduct.description,
        'price':newProduct.price,
        'imageUrl':newProduct.imageUrl,
        //'isFavourite':newProduct.isFavorite, will not send this.. so doesnot overwrite
        //for data which it wll has it will overwrite

      }));//will merge the data which is incoming with existing
      _items[prodIndex]=newProduct;
      notifyListeners();
    }else{
      print('..');
    }
  }

  Future<void> deleteProduct(String id) async{
    final url='https://shop-25acc.firebaseio.com/products/$id.json?auth=$authToken';
    final existingProductIndex=_items.indexWhere((prod)=> prod.id==id);
    var existingProduct=_items[existingProductIndex];
    _items.removeAt(existingProductIndex);//will not remove from memory but from list
    notifyListeners();
    final response = await http.delete(url);

      if(response.statusCode>=400){//CREATING OWN CUSTOM ERROR HANDLING
        _items.insert(existingProductIndex,existingProduct); //rollback if error
      notifyListeners();
        throw HttpException('Could not delete product!');
      }

      existingProduct=null;//now remove from memory
      //OPTIMISTIC UPDATING
       
  }

} 