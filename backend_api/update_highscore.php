<?php
header("Content-Type: application/json");
include 'koneksi.php'; 

$id_user = isset($_POST['id_user']) ? $_POST['id_user'] : '';
$tipe_kuis = isset($_POST['tipe_kuis']) ? $_POST['tipe_kuis'] : '';
$score = isset($_POST['score']) ? (int)$_POST['score'] : 0;

if (empty($id_user) || empty($tipe_kuis)) {
    echo json_encode(['status' => 'error', 'message' => 'Data tidak lengkap!']);
    exit;
}

$id_user = mysqli_real_escape_string($conn, $id_user);
$tipe_kuis = mysqli_real_escape_string($conn, $tipe_kuis);

$kolom = ($tipe_kuis == 'tebak_surah') ? 'highscore_tebak_surah' : 'highscore_tebak_ayat';

$query = "UPDATE user SET $kolom = GREATEST($kolom, $score) WHERE id_user = '$id_user'";

if (mysqli_query($conn, $query)) {
    echo json_encode(['status' => 'success', 'message' => 'Highscore berhasil diupdate!']);
} else {
    echo json_encode(['status' => 'error', 'message' => 'Gagal update database!']);
}
?>