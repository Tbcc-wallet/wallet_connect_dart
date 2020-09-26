import '../constants.dart';
import 'WCPeerMeta.dart';

class WCSessionRequestParam {
  String peerId;
  WCPeerMeta peerMeta;
  int chainId;
  WCSessionRequestParam.fromJson(Map<String, dynamic> json) {
    peerId = json['peerId'];
    chainId = json['chainId'];
    peerMeta = json['peerMeta'] != null ? WCPeerMeta.fromJson(json['peerMeta']) : null;
  }
}

class WCSessionUpdateParam {
  bool approved;
  int chainId;
  List<String> accounts;
  WCSessionUpdateParam.fromJson(Map<String, dynamic> json) {
    approved = json['approved'];
    chainId = json['chainId'];
    accounts = json['accounts'].cast<String>();
  }
}

class WCApproveSessionResponse extends Jsonable {
  bool approved;
  int chainId;
  List<String> accounts;
  String peerId;
  WCPeerMeta peerMeta;

  WCApproveSessionResponse({
    this.approved,
    this.chainId,
    this.accounts,
    this.peerId,
    this.peerMeta,
  });

  @override
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};

    data['approved'] = approved;
    data['chainId'] = chainId;
    data['accounts'] = accounts;
    data['peerId'] = peerId;
    data['peerMeta'] = peerMeta.toJson();
    return data;
  }
}
