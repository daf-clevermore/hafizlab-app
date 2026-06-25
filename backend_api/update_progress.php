<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
include 'koneksi.php';

$id_user = $_POST['id_user'] ?? '';
$nama_level = $conn->real_escape_string($_POST['level_selesai'] ?? '');
$skor = $_POST['score'] ?? 0;

if (empty($id_user) || empty($nama_level)) {
    echo "Error: Data tidak lengkap";
    exit;
}

$check = $conn->query("SELECT id FROM progress_level WHERE id_user = '$id_user' AND nama_level = '$nama_level'");

if ($check->num_rows > 0) {
    $conn->query("UPDATE progress_level SET skor = '$skor' WHERE id_user = '$id_user' AND nama_level = '$nama_level'");
} else {
    $conn->query("INSERT INTO progress_level (id_user, nama_level, skor) VALUES ('$id_user', '$nama_level', '$skor')");
}

echo "Success: Progress tersimpan";
$conn->close();
?>