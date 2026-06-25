<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
include 'koneksi.php';

if ($conn->connect_error) {
    die(json_encode(["status" => "error", "message" => "Koneksi Gagal"]));
}

$kategori = isset($_GET['kategori']) ? $_GET['kategori'] : 'campaign';
$data = [];

if ($kategori == 'campaign') {
    $query = "SELECT u.nama, u.avatar, COALESCE(SUM(p.skor), 0) as skor_akhir 
              FROM user u 
              LEFT JOIN progress_level p ON u.id_user = p.id_user 
              WHERE u.role != 'admin' 
              GROUP BY u.id_user 
              ORDER BY skor_akhir DESC LIMIT 50";
} else if ($kategori == 'tebak_surah') {
    $query = "SELECT nama, avatar, highscore_tebak_surah as skor_akhir FROM user WHERE role != 'admin' ORDER BY highscore_tebak_surah DESC LIMIT 50";
} else {
    $query = "SELECT nama, avatar, highscore_tebak_ayat as skor_akhir FROM user WHERE role != 'admin' ORDER BY highscore_tebak_ayat DESC LIMIT 50";
}

$result = $conn->query($query);

if ($result && $result->num_rows > 0) {
    while($row = $result->fetch_assoc()) {
        $data[] = [
            "nama" => $row['nama'],
            "avatar" => !empty($row['avatar']) ? $row['avatar'] : 'assets/avatar/user.png',
            "skor" => (int)$row['skor_akhir']
        ];
    }
    echo json_encode(["status" => "success", "data" => $data]);
} else {
    echo json_encode(["status" => "success", "data" => []]);
}

$conn->close();
?>