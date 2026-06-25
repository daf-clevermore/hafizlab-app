<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include 'koneksi.php';

$email = isset($_POST['email']) ? $_POST['email'] : '';
$otp = isset($_POST['otp']) ? $_POST['otp'] : '';
$new_password = isset($_POST['new_password']) ? $_POST['new_password'] : '';

if (empty($email) || empty($otp) || empty($new_password)) {
    echo json_encode(["status" => "error", "message" => "Data nggak lengkap!"]);
    exit;
}

$cek_sql = "SELECT id_user FROM user WHERE email = ? AND otp_code = ?";
$cek_stmt = $conn->prepare($cek_sql);
$cek_stmt->bind_param("ss", $email, $otp);
$cek_stmt->execute();

if ($cek_stmt->get_result()->num_rows > 0) {
    $hashed_password = password_hash($new_password, PASSWORD_DEFAULT);
    
    $update_sql = "UPDATE user SET password = ?, otp_code = NULL WHERE email = ?";
    $update_stmt = $conn->prepare($update_sql);
    $update_stmt->bind_param("ss", $hashed_password, $email);
    $update_stmt->execute();
    
    echo json_encode(["status" => "success", "message" => "Sandi berhasil diganti! Silakan login."]);
} else {
    echo json_encode(["status" => "error", "message" => "Kode OTP salah atau udah hangus!"]);
}
?>