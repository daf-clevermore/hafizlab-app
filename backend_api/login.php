<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include 'koneksi.php';

$email = isset($_POST['email']) ? $_POST['email'] : '';
$password = isset($_POST['password']) ? $_POST['password'] : '';

if (empty($email) || empty($password)) {
    echo json_encode(["status" => "error", "message" => "Email dan Password wajib diisi!"]);
    exit;
}

$sql = "SELECT * FROM user WHERE email = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("s", $email);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $data = $result->fetch_assoc();
    
    if (password_verify($password, $data['password'])) {
        echo json_encode([
            "status" => "success",
            "message" => "Login Berhasil!",
            "data" => [
                "id_user" => $data['id_user'],
                "nama" => $data['nama'],
                "role" => $data['role'],
                "avatar" => $data['avatar'] ?? null
            ]
        ]);
    } else {
        echo json_encode(["status" => "error", "message" => "Email atau Password salah!"]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "Email tidak ditemukan!"]);
}

$stmt->close();
$conn->close();
?>