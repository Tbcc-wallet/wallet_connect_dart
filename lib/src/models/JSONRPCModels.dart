class JSONRPCRequest {
  int? id;
  String? jsonrpc = '2.0';
  String? method;
  List<dynamic>? params;

  JSONRPCRequest({this.id, this.method, this.params});

  JSONRPCRequest.fromJson(Map<String, dynamic> json, List<dynamic>? paramsList) {
    id = json['id'];
    jsonrpc = json['jsonrpc'];
    method = json['method'];
    params = paramsList;
  }
}

class JSONRPCResponse {
  String jsonrpc = '2.0';
  int? id;
  dynamic result;

  JSONRPCResponse({this.id, this.result});

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'jsonrpc': jsonrpc,
        'result': result,
      };
}
