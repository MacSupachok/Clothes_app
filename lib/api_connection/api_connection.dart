class API {
  static const apiToken =
      "fXuauEclTQWZdqmSU3l9ys0jqIWeVb5fVG8pbvd8FUFTiD0WDB1euNkO1rn4INL0";

  static const hostConnect = "http://192.168.1.150/api_clothes_store";
  static const hostConnectUser = "$hostConnect/user/user_services.php";
  static const hostConnectAdmin = "$hostConnect/admin/admin_services.php";
  static const hostConnectItem = "$hostConnect/item/item_services.php";
  static const hostCart = "$hostConnect/cart/cart_services.php";
  static const hostFavorite = "$hostConnect/favorite/favorite_services.php";

  //check auth "http://192.168.1.150/api_clothes_store/user/user_services.php?function=check_auth&api_token=fXuauEclTQWZdqmSU3l9ys0jqIWeVb5fVG8pbvd8FUFTiD0WDB1euNkO1rn4INL0"

  //user srevices
  static const validateEmail =
      "$hostConnectUser?function=validate_email&api_token=$apiToken";
  static const signUp =
      "$hostConnectUser?function=signup_user&api_token=$apiToken";
  static const logIn =
      "$hostConnectUser?function=login_user&api_token=$apiToken";

  //admin srevices
  static const adminLogIn =
      "$hostConnectAdmin?function=login_admin&api_token=$apiToken";

  //item services
  static const uploadNewItem =
      "$hostConnectItem?function=upload_item&api_token=$apiToken";
  static const getTrendingItems =
      "$hostConnectItem?function=get_trending&api_token=$apiToken";
  static const getAllItems =
      "$hostConnectItem?function=get_all_items&api_token=$apiToken";
  static const searchItems =
      "$hostConnectItem?function=search_item&api_token=$apiToken";

  //cart service
  static const addToCart = "$hostCart?function=add_to_cart&api_token=$apiToken";
  static const getCartList = "$hostCart?function=read_cart&api_token=$apiToken";
  static const deleteCart =
      "$hostCart?function=delete_cart&api_token=$apiToken";
  static const updateCart =
      "$hostCart?function=update_cart&api_token=$apiToken";

  //favorite services
  static const addFavorite =
      "$hostFavorite?function=add_favorite&api_token=$apiToken";
  static const deleteFavorite =
      "$hostFavorite?function=delete_favorite&api_token=$apiToken";
  static const checkFavorite =
      "$hostFavorite?function=check_favorite&api_token=$apiToken";
  static const readFavorite =
      "$hostFavorite?function=read_favorite&api_token=$apiToken";
}
