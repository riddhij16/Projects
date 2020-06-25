import 'package:flutter/material.dart';

//SINGLES ROUTES ON THE FLY CREATION
class CustomRoute<T> extends MaterialPageRoute<T> {
  CustomRoute({
    WidgetBuilder builder,
    RouteSettings settings,
  }) : super(
          builder: builder,
          settings: settings,
        );

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {

    if(settings.name == '/'){
      return child;//does not animate the very first page that comes in
    }

    return FadeTransition(opacity:animation , child:child,);
    // return super
    //.buildTransitions(context, animation, secondaryAnimation, child);
  }
}

//GENERAL PAGE.. ALL TOGETHER
class CustomPageTransitionBuilder extends PageTransitionsBuilder{
  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {

    if(route.settings.name == '/'){
      return child;//does not animate the very first page that comes in
    }

    return FadeTransition(opacity:animation , child:child,);
   
  }
}

