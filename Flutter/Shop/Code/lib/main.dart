import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/screens/cart_screen.dart';
import 'package:shop/screens/edit_product_screen.dart';
import 'package:shop/widgets/user_product_item.dart';
import './providers/auth.dart';
import './screens/auth_screen.dart';
import './screens/products_overview_screen.dart';
import './screens/product_detail_screen.dart';
import './providers/productsp.dart';
import './providers/cart.dart';
import './screens/cart_screen.dart';
import './providers/orders.dart';
import './screens/orders_screen.dart';
import './screens/user_products_screen.dart';
import './screens/splash_screen.dart';
import './helpers/custom_route.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        //to have multi providers
        providers: [
          ChangeNotifierProvider(
            create: (ctx) => Auth(),
          ),
          //auth mst be above products to be used in proxy
          //1)data u want 2) data u provide
          ChangeNotifierProxyProvider<Auth, Products>(
            //allows to create a provider which itself depends on another providr
            create: (_) => Products(null, null, []),
            update: (ctx, auth, previousProducts) => Products(
              auth.token,
              auth.userId,
              previousProducts == null ? [] : previousProducts.items,
            ),
          ),
          ChangeNotifierProvider(
            //better than .value   //auto cleans up old data
            create: (ctx) =>
                Cart(), //as instantiating a new obj.. we dont use .value
          ),
          ChangeNotifierProxyProvider<Auth, Orders>(
            //allows to create a provider which itself depends on another providr
            create: (_) => Orders(null, null, []),
            update: (ctx, auth, previousOrders) => Orders(
              auth.token,
              auth.userId,
              previousOrders == null ? [] : previousOrders.orders,
            ),
          ),
          // ChangeNotifierProvider(
          //   create: (ctx) => Orders(),
          // )
        ],
        child: Consumer<Auth>(
          builder: (ctx, auth, _) => MaterialApp(
            //will receive all providers
            //this will only built widgets which are listening and not the whole
            title: 'Shop!',
            theme: ThemeData(
              primarySwatch: Colors.purple,
              accentColor: Colors.deepOrange,
              fontFamily: 'Lato',
              pageTransitionsTheme: PageTransitionsTheme(builders:{
                TargetPlatform.android:CustomPageTransitionBuilder(),
                TargetPlatform.iOS:CustomPageTransitionBuilder(),
              },) ,//diff builder func for diff operating systems
            ),
            // home: ProductsOverviewScreen(),
            home: auth.isAuth
                ? ProductsOverviewScreen()
                : FutureBuilder( //if not authenticated check the autologin..by thw time show spinner
                    future: auth.tryAutoLogin(),
                    builder: (ctx, authResultSnapshot) =>
                        authResultSnapshot.connectionState ==
                                ConnectionState.waiting
                            ? SplashScreen()
                            : AuthScreen(),
                  ),
            routes: {
              ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
              CartScreen.routeName: (ctx) => CartScreen(),
              OrdersScreen.routeName: (ctx) => OrdersScreen(),
              UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
              EditProductScreen.routeName: (ctx) => EditProductScreen(),
            },
          ),
        ));
  }
}
