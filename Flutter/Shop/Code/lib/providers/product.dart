import 'dart:convert';
import 'package:flutter/foundation.dart';
import'package:http/http.dart' as http;

class Product with ChangeNotifier{//it would be notified when the products changes in the child widgets
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  //final String userId;
  bool isFavorite;

  Product(
      { @required this.description,
      @required this.id,
      @required this.imageUrl,
      @required this.price,
      @required this.title,
      //@required this.userId,
      this.isFavorite = false,});

      void _setFavValue(bool newValue){
        isFavorite=newValue;
        notifyListeners();
      }

      Future <void> toggleFavoriteStatus(String token,String userId) async {
        final oldStatus=isFavorite;
        isFavorite=!isFavorite;
        notifyListeners();
        final url='https://shop-25acc.firebaseio.com/userFavorites/$userId/$id.json?auth=$token';
        try{
          final response=await http.put(url,body:json.encode(//override
          //'isFavourite':isFavorite,
          isFavorite,
        ),);
        if(response.statusCode>=400){
          _setFavValue(oldStatus);
        }
        }catch(error){
          _setFavValue(oldStatus);
        }
        
        //equivalent setstate // this will let all widgets know that something has changed
      }
}
