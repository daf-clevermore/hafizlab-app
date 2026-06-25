<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

try {
    include 'koneksi.php';

    $sql = "SELECT l.id_level, l.id_surah, l.kkm_skor, s.nama_surah 
            FROM level_campaign l 
            JOIN surah s ON l.id_surah = s.id_surah 
            ORDER BY l.id_level ASC";

    $result = $conn->query($sql);
    $levels = [];

    if ($result) {
        if ($result->num_rows > 0) {
            while($row = $result->fetch_assoc()) {
                $levels[] = $row;
            }
        }
    } else {
        throw new Exception("Error DB: " . $conn->error);
    }
} catch (\Throwable $th) {
    echo json_encode(["status" => "error", "message" => "System Error: " . $th->getMessage()]);
}
?>