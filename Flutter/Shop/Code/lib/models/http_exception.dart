class HttpException implements Exception{
  //implemts all the func of latter class
  final String message;
  HttpException(this.message);
  @override
  String toString() {
    return message;
    //return super.toString();//instance of exception
  }


}