<?php
use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

error_reporting(0); 
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

try {
    include 'koneksi.php';
    require 'vendor/autoload.php';

    $email = isset($_POST['email']) ? trim($_POST['email']) : '';

    if (empty($email)) {
        echo json_encode(["status" => "error", "message" => "Email wajib diisi!"]);
        exit;
    }

    $cek_sql = "SELECT id_user, nama FROM user WHERE email = ?";
    $cek_stmt = $conn->prepare($cek_sql);
    
    if (!$cek_stmt) throw new \Exception("DB Error (Cek Email): " . $conn->error);
    
    $cek_stmt->bind_param("s", $email);
    $cek_stmt->execute();
    $result = $cek_stmt->get_result();

    if ($result->num_rows == 0) {
        echo json_encode(["status" => "error", "message" => "Email nggak terdaftar bro!"]);
        exit;
    }
    $user = $result->fetch_assoc();
    $nama = $user['nama'];

    $otp = rand(100000, 999999);

    $update_sql = "UPDATE user SET otp_code = ? WHERE email = ?";
    $update_stmt = $conn->prepare($update_sql);
    
    if (!$update_stmt) throw new \Exception("DB Error (Update OTP): Pastikan kolom otp_code ada! -> " . $conn->error);
    
    $update_stmt->bind_param("ss", $otp, $email);
    $update_stmt->execute();

    $mail = new PHPMailer(true);
    $mail->isSMTP();
    $mail->Host       = 'smtp.gmail.com';
    $mail->SMTPAuth   = true;
    $mail->Username   = 'haidarkadafi78@gmail.com'; 
    $mail->Password   = 'xxtz krvc tznb mcze'; 
    $mail->SMTPSecure = PHPMailer::ENCRYPTION_SMTPS;
    $mail->Port       = 465;

    $mail->setFrom('haidarkadafi78@gmail.com', 'Admin HafizLab');
    $mail->addAddress($email, $nama);

    $mail->isHTML(true);
    $mail->Subject = 'Kode OTP Reset Password - HafizLab';
    $mail->Body    = "Halo <b>$nama</b>,<br><br>Ini adalah kode OTP kamu untuk mereset password: <h2>$otp</h2><br>Jangan kasih tau kode ini ke siapa-siapa ya!";

    $mail->send();
    echo json_encode(["status" => "success", "message" => "OTP berhasil dikirim ke email kamu!"]);

} catch (\Throwable $th) {
    echo json_encode(["status" => "error", "message" => "System Error: " . $th->getMessage()]);
}
?>