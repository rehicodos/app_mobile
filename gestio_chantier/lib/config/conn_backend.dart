class ConnBackend {
  // L'URL de base de l'API
  static const String _baseUrl =
      // "http://serveur:8080/chantier_gestion_api/backend/traitement_api.php";
      "http://192.168.1.8:8080/chantier_gestion_api/backend/traitement_api.php";

  /// Retourne juste l'URL simple (utile pour POST)
  static Uri get connUrl => Uri.parse(_baseUrl);

  /// Retourne une URL avec des paramètres GET ajoutés (ex: ?action=liste_ouvr)
  static Uri withParams(Map<String, String> params) {
    return Uri.parse(_baseUrl).replace(queryParameters: params);
  }
}
