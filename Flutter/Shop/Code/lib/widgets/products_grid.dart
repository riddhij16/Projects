import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './product_item.dart';
import '../providers/productsp.dart';

class ProductsGrid extends StatelessWidget {

  final bool showFavs;
  ProductsGrid(this.showFavs);
  @override

  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context); //listening
    //it gives us access to the nearest provider of products type in the widget tree
    //we want to make direct communictaion channel btw the providers package and products class

    final products = showFavs ? productsData.favoriteItems: productsData.items; //show favs logic

    return GridView.builder(
      padding: const EdgeInsets.all(10.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, //how many grids in each row prob
        childAspectRatio: 3 / 2, //each grid size..taller
        crossAxisSpacing: 10, //spacing btw grid
        mainAxisSpacing: 10,//how grid should be structured.. how many cols it should have etc
      ), 

      itemBuilder: (ctx, i) => ChangeNotifierProvider.value( //when we dont have to consider c //provider for each product indl
        //in case of edit existing item use .value
        
        //create: (c) => products[i], 
        value:products[i],//this works good with grid/list when f recycles the widget*
        child: ProductItem(
          //products[i].id,
          //products[i].title,
          //products[i].imageUrl,
        ),
      ),
      itemCount: products.length,
    );
  }
}

//finding providers for single product- which registers changes in single product eg marking it as fav
//we need this only in product item..so put provider above it
// providers for products as whole- which registers whether new product is added to list


