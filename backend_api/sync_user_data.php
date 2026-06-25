<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
include 'koneksi.php';

$id_user = $_POST['id_user'] ?? '';
if (empty($id_user)) {
    echo json_encode(["status" => "error", "message" => "ID User kosong"]);
    exit;
}

$sql_user = "SELECT avatar, highscore_tebak_surah, highscore_tebak_ayat FROM user WHERE id_user = '$id_user'";
$res_user = $conn->query($sql_user)->fetch_assoc();

$sql_progress = "SELECT nama_level, skor FROM progress_level WHERE id_user = '$id_user'";
$res_progress = $conn->query($sql_progress);

$progress = [];
if ($res_progress && $res_progress->num_rows > 0) {
    while ($row = $res_progress->fetch_assoc()) {
        $progress[] = [
            "nama_level" => $row['nama_level'],
            "skor" => (int)$row['skor']
        ];
    }
}

echo json_encode([
    "status" => "success",
    "user_data" => $res_user,
    "progress" => $progress
]);

$conn->close();
?>
