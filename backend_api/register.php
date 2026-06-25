<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include 'koneksi.php';

$nama = isset($_POST['nama']) ? $_POST['nama'] : '';
$email = isset($_POST['email']) ? $_POST['email'] : '';
$password = isset($_POST['password']) ? $_POST['password'] : '';

if (empty($nama) || empty($email) || empty($password)) {
    echo json_encode(["status" => "error", "message" => "Semua kolom wajib diisi!"]);
    exit;
}

$cek_sql = "SELECT id_user FROM user WHERE email = ?";
$cek_stmt = $conn->prepare($cek_sql);
$cek_stmt->bind_param("s", $email);
$cek_stmt->execute();
if ($cek_stmt->get_result()->num_rows > 0) {
    echo json_encode(["status" => "error", "message" => "Email ini udah dipakai, ganti yang lain!"]);
    exit;
}
$cek_stmt->close();

$hashed_password = password_hash($password, PASSWORD_DEFAULT);

$sql = "INSERT INTO user (nama, email, password, role) VALUES (?, ?, ?, 'user')";
$stmt = $conn->prepare($sql);
$stmt->bind_param("sss", $nama, $email, $hashed_password);

if ($stmt->execute()) {
    echo json_encode(["status" => "success", "message" => "Alhamdulillah, akun berhasil dibuat!"]);
} else {
    echo json_encode(["status" => "error", "message" => "Gagal bikin akun: " . $conn->error]);
}

$stmt->close();
$conn->close();
?>