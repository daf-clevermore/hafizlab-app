<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include 'koneksi.php';

$id_surah = isset($_POST['id_surah']) ? (int)$_POST['id_surah'] : 35;

$sql = "SELECT s.id_soal, a.teks_ayat, s.pilihan_a, s.pilihan_b, s.pilihan_c, s.jawaban_benar 
        FROM soal s 
        JOIN ayat a ON s.id_ayat = a.id_ayat 
        WHERE a.id_surah = ?";

$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $id_surah);
$stmt->execute();
$result = $stmt->get_result();

$soal_list = [];
while ($row = $result->fetch_assoc()) {
    $soal_list[] = $row;
}

if (count($soal_list) > 0) {
    echo json_encode(["status" => "success", "data" => $soal_list]);
} else {
    echo json_encode(["status" => "error", "message" => "Soal untuk level ini belum ada di database!"]);
}

$stmt->close();
$conn->close();
?>