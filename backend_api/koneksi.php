<?php
$host = "localhost";
$user = "hafj5975_atmin";
$pass = "kliryahk6";
$db   = "hafj5975_hafizlab";

$conn = new mysqli($host, $user, $pass, $db);
mysqli_set_charset($conn, "utf8mb4");

if ($conn->connect_error) {
    die("Koneksi gagal: " . $conn->connect_error);
}
?>