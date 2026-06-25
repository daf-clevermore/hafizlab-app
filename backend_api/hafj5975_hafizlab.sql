-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Waktu pembuatan: 21 Jun 2026 pada 12.37
-- Versi server: 10.11.17-MariaDB-cll-lve
-- Versi PHP: 8.4.21

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `hafj5975_hafizlab`
--

-- --------------------------------------------------------

--
-- Struktur dari tabel `progress_level`
--

CREATE TABLE `progress_level` (
  `id` int(11) NOT NULL,
  `id_user` int(11) NOT NULL,
  `nama_level` varchar(100) NOT NULL,
  `skor` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data untuk tabel `progress_level`
--

INSERT INTO `progress_level` (`id`, `id_user`, `nama_level`, `skor`) VALUES
(1, 3, '1. An-Nas', 100),
(2, 3, '2. Al-Falaq', 100);

-- --------------------------------------------------------

--
-- Struktur dari tabel `user`
--

CREATE TABLE `user` (
  `id_user` int(11) NOT NULL,
  `nama` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` varchar(20) NOT NULL,
  `level_terbuka` int(11) DEFAULT 1,
  `highscore_tebak_surah` int(11) NOT NULL DEFAULT 0,
  `highscore_tebak_ayat` int(11) NOT NULL DEFAULT 0,
  `otp_code` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `user`
--

INSERT INTO `user` (`id_user`, `nama`, `email`, `password`, `role`, `level_terbuka`, `highscore_tebak_surah`, `highscore_tebak_ayat`, `otp_code`) VALUES
(1, 'Aisyah', 'aisyah@gmail.com', '123456', 'user', 1, 0, 0, NULL),
(2, 'Admin HafizLab', 'admin@hafizlab.com', 'admin123', 'admin', 114, 0, 0, NULL),
(3, 'Rafif', 'haidarkadafi78@gmail.com', 'fida1234', 'user', 1, 130, 0, NULL);

--
-- Indexes for dumped tables
--

--
-- Indeks untuk tabel `progress_level`
--
ALTER TABLE `progress_level`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_progress_user` (`id_user`);

--
-- Indeks untuk tabel `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`id_user`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT untuk tabel yang dibuang
--

--
-- AUTO_INCREMENT untuk tabel `progress_level`
--
ALTER TABLE `progress_level`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT untuk tabel `user`
--
ALTER TABLE `user`
  MODIFY `id_user` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- Ketidakleluasaan untuk tabel pelimpahan (Dumped Tables)
--

--
-- Ketidakleluasaan untuk tabel `progress_level`
--
ALTER TABLE `progress_level`
  ADD CONSTRAINT `fk_progress_user` FOREIGN KEY (`id_user`) REFERENCES `user` (`id_user`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
