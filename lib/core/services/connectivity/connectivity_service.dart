abstract interface class ConnectivityService {
  Future<bool> checkConnectivity();
  Stream<bool> get onConnectivityChanged;
}