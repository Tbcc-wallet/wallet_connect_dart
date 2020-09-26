import '../constants.dart';

class JSONRPCRequest<T> {
  int id;
  String jsonrpc = '2.0';
  String method;
  List<T> params;

  JSONRPCRequest({this.id, this.method, this.params});

  JSONRPCRequest.fromJson(Map<String, dynamic> json, List<T> typedParams) {
    id = json['id'];
    jsonrpc = json['jsonrpc'];
    method = json['method'];
    params = typedParams;
  }
}

class JSONRPCResponse<T extends Jsonable> {
  String jsonrpc = '2.0';
  int id;
  T result;

  JSONRPCResponse({this.id, this.result});

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['jsonrpc'] = jsonrpc;
    data['result'] = result.toJson();

    return data;
  }
}
