<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include 'koneksi.php';

$id_user = isset($_POST['id_user']) ? $_POST['id_user'] : '';

if (empty($id_user)) {
    echo json_encode(["status" => "error", "message" => "ID User kosong!"]);
    exit;
}

$sql_skor = "SELECT SUM(nilai) as total_koin FROM skor WHERE id_user = ?";
$stmt_skor = $conn->prepare($sql_skor);
$stmt_skor->bind_param("i", $id_user);
$stmt_skor->execute();
$res_skor = $stmt_skor->get_result()->fetch_assoc();
$total_koin = $res_skor['total_koin'] ? $res_skor['total_koin'] : 0;
$stmt_skor->close();

$sql_prog = "SELECT COUNT(*) as ayat_hafal FROM riwayat WHERE id_user = ? AND hasil = 'benar'";
$stmt_prog = $conn->prepare($sql_prog);
$stmt_prog->bind_param("i", $id_user);
$stmt_prog->execute();
$res_prog = $stmt_prog->get_result()->fetch_assoc();
$ayat_hafal = $res_prog['ayat_hafal'] ? $res_prog['ayat_hafal'] : 0;
$stmt_prog->close();

$persentase = ($ayat_hafal > 0) ? round(($ayat_hafal / 114) * 100) : 0;

echo json_encode([
    "status" => "success",
    "total_koin" => $total_koin,
    "ayat_hafal" => $ayat_hafal,
    "persentase" => $persentase
]);

$conn->close();
?>