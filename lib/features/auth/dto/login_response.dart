class TokenResponse {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final int refreshExpiresIn;
  final String tokenType;
  final String scope;

  TokenResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.refreshExpiresIn,
    required this.tokenType,
    required this.scope,
  });

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
      expiresIn: json['expires_in'],
      refreshExpiresIn: json['refresh_expires_in'],
      tokenType: json['token_type'],
      scope: json['scope'],
    );
  }
}
