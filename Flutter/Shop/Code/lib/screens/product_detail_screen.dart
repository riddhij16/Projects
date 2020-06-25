import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/productsp.dart';

class ProductDetailScreen extends StatelessWidget {
  static const routeName = 'ProductDetail';

  @override
  Widget build(BuildContext context) {
    final productId =
        ModalRoute.of(context).settings.arguments as String; // is the id

    //since it is the child of myapp which is the changenotifierprovider
    final loadedProduct = Provider.of<Products>(
      context,
      listen:
          false, //donot listen to changes //it will not rerun again and again
    ).findById(productId);
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(loadedProduct.title),
      // ),
      body: CustomScrollView(
        //slivers are scrollable area on screen
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 300,
            pinned: true, //it wiil not scroll out of view instead
            flexibleSpace: FlexibleSpaceBar(
              title: Text(loadedProduct.title),
              background:Hero(//that should be visible when the appbar is expanded
                tag: loadedProduct.id,
                child: Image.network(
                  loadedProduct.imageUrl,
                  fit: BoxFit.cover,
                ),
              ) ,
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              SizedBox(
                height: 10,
              ),
              Text(
                '\$${loadedProduct.price}',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                width: double.infinity,
                child: Text(
                  loadedProduct.description,
                  textAlign: TextAlign.center,
                  softWrap: true,
                ),
              ),
              SizedBox(height:800,),
            ]),
          ),
        ],
        
      ),
    );
  }
}
