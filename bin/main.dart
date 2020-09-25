import 'package:uuid/uuid.dart';
import 'package:wallet_connect/src/WCInteractor.dart';
import 'package:wallet_connect/src/WCSession.dart';
import 'package:wallet_connect/src/models/WCPeerMeta.dart';
import 'package:web3dart/web3dart.dart';

main(List<String> args) async {
  var str = 'wc:f8545fcd-a3d2-4721-9d33-602e887f87eb@1?bridge=https%3A%2F%2Fbridge.walletconnect.org&key=49d7aca072fe6ce90b4c8366c3b83a13203344483b6545a4773786986e19cf10';
  var privateKey = EthPrivateKey.fromHex('ba005cd605d8a02e3d5dfd04234cef3a3ee4f76bfbad2722d1fb5af8e12e6764');
  var addr = privateKey.extractAddress();

  var session = WCSession.fromString(str);
  var interactor = WCInteractor(session: session, clientMeta: WCPeerMeta()..name = 'test', clientId: Uuid().v4());
  await interactor.connect();

  await Future.delayed(Duration(seconds: 20));
  return;
}
