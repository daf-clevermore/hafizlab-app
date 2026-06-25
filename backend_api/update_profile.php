<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include 'koneksi.php';

$conn = new mysqli($host, $user, $pass, $db);

if ($conn->connect_error) {
    die(json_encode(["status" => "error", "message" => "Koneksi Gagal"]));
}

$id_user = $_POST['id_user'] ?? '';
$nama = $_POST['nama'] ?? '';
$avatar = $_POST['avatar'] ?? '';

if (!empty($id_user)) {
    $nama = $conn->real_escape_string($nama);
    $avatar = $conn->real_escape_string($avatar);
    
    $sql = "UPDATE user SET nama='$nama', avatar='$avatar' WHERE id_user='$id_user'";
    if ($conn->query($sql) === TRUE) {
        echo json_encode(["status" => "success"]);
    } else {
        echo json_encode(["status" => "error", "message" => $conn->error]);
    }
}
$conn->close();
?>