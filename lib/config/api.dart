class Api {
  static const _BaseUrl = 'http://127.0.0.1/dompetku';

  // USERS
  static const _user = '$_BaseUrl/users';
  static const getUser = '$_user/getUser.php';
  static const delUser = '$_user/delUser.php';
  static const insertUser = '$_user/insertUser.php'; // register
  static const updateUser = '$_user/updateUser.php';
  static const login = '$_user/loginUser.php';

  // TRANSAKSI
  static const _transaksi = '$_BaseUrl/transaksi';
  static const getTransaksi = '$_transaksi/getTransaksi.php';
  static const insertTransaksi = '$_transaksi/insertTransaksi.php';
  static const updateTransaksi = '$_transaksi/updateTransaksi.php';
  static const delTransaksi = '$_transaksi/delTransaksi.php';
  static const String getRekap = "$_BaseUrl/transaksi/getRekap.php";

  // KATEGORI
  static const _kategori = '$_BaseUrl/kategori';
  static const getKategori = '$_kategori/getKategori.php';
  static const insertKategori = '$_kategori/insertKategori.php';
  static const updateKategori = '$_kategori/updateKategori.php';
  static const delKategori = '$_kategori/delKategori.php';

  // CATATAN
  static const _catatan = '$_BaseUrl/catatan';
  static const getCatatan = '$_catatan/getCatatan.php';
  static const insertCatatan = '$_catatan/insertCatatan.php';
  static const updateCatatan = '$_catatan/updateCatatan.php';
  static const delCatatan = '$_catatan/delCatatan.php';
}
