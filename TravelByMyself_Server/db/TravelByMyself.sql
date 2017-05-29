-- phpMyAdmin SQL Dump
-- version 4.6.5.2
-- https://www.phpmyadmin.net/
--
-- 主機: localhost
-- 產生時間： 2017 年 05 月 22 日 18:41
-- 伺服器版本: 10.1.21-MariaDB
-- PHP 版本： 5.6.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- 資料庫： `TravelByMyself`
--

-- --------------------------------------------------------

--
-- 資料表結構 `member`
--

CREATE TABLE `member` (
  `id` int(11) NOT NULL,
  `username` varchar(200) NOT NULL,
  `password` varchar(200) NOT NULL,
  `email` varchar(200) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- 資料表的匯出資料 `member`
--

INSERT INTO `member` (`id`, `username`, `password`, `email`) VALUES
(1, '123', '456', '789@gmail.com'),
(7, 'create', 'ddd', 'ddd.gmail.com');

-- --------------------------------------------------------

--
-- 資料表結構 `pocketSpot`
--

CREATE TABLE `pocketSpot` (
  `id` int(11) NOT NULL,
  `spotName` varchar(200) NOT NULL,
  `ownerUser` varchar(200) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- 資料表的匯出資料 `pocketSpot`
--

INSERT INTO `pocketSpot` (`id`, `spotName`, `ownerUser`) VALUES
(2, '大笨鐘', 'create'),
(3, '比薩斜塔', 'create'),
(5, '羅浮宮', '123'),
(6, '羅浮宮', '123'),
(7, '羅浮宮', '123'),
(8, '羅浮宮', '123'),
(9, '巴黎鐵塔', '234'),
(10, '巴黎鐵塔', '234'),
(11, '巴黎鐵塔', '234');

-- --------------------------------------------------------

--
-- 資料表結構 `pocketTrip`
--

CREATE TABLE `pocketTrip` (
  `id` int(11) NOT NULL,
  `tripName` varchar(200) NOT NULL,
  `tripDays` int(11) NOT NULL,
  `ownerUser` varchar(200) NOT NULL,
  `tripCountry` varchar(200) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 資料表結構 `pocketTripSpot`
--

CREATE TABLE `pocketTripSpot` (
  `id` int(11) NOT NULL,
  `tripName` varchar(200) NOT NULL,
  `spotName` varchar(200) NOT NULL,
  `nDay` int(11) NOT NULL,
  `nth` int(11) NOT NULL,
  `trafficToNext` varchar(300) NOT NULL,
  `ownerUser` varchar(200) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 資料表結構 `sharedTrip`
--

CREATE TABLE `sharedTrip` (
  `id` int(11) NOT NULL,
  `tripName` varchar(200) NOT NULL,
  `tripDays` int(11) NOT NULL,
  `tripCountry` varchar(200) NOT NULL,
  `ownerUser` varchar(200) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 資料表結構 `sharedTripSpot`
--

CREATE TABLE `sharedTripSpot` (
  `id` int(11) NOT NULL,
  `tripName` int(11) NOT NULL,
  `spotName` int(11) NOT NULL,
  `nDay` int(11) NOT NULL,
  `nth` int(11) NOT NULL,
  `trafficToNext` int(11) NOT NULL,
  `ownerUser` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- 已匯出資料表的索引
--

--
-- 資料表索引 `member`
--
ALTER TABLE `member`
  ADD PRIMARY KEY (`id`);

--
-- 資料表索引 `pocketSpot`
--
ALTER TABLE `pocketSpot`
  ADD PRIMARY KEY (`id`);

--
-- 資料表索引 `pocketTrip`
--
ALTER TABLE `pocketTrip`
  ADD PRIMARY KEY (`id`);

--
-- 資料表索引 `pocketTripSpot`
--
ALTER TABLE `pocketTripSpot`
  ADD PRIMARY KEY (`id`);

--
-- 資料表索引 `sharedTrip`
--
ALTER TABLE `sharedTrip`
  ADD PRIMARY KEY (`id`);

--
-- 在匯出的資料表使用 AUTO_INCREMENT
--

--
-- 使用資料表 AUTO_INCREMENT `member`
--
ALTER TABLE `member`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;
--
-- 使用資料表 AUTO_INCREMENT `pocketSpot`
--
ALTER TABLE `pocketSpot`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;
--
-- 使用資料表 AUTO_INCREMENT `pocketTrip`
--
ALTER TABLE `pocketTrip`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- 使用資料表 AUTO_INCREMENT `pocketTripSpot`
--
ALTER TABLE `pocketTripSpot`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- 使用資料表 AUTO_INCREMENT `sharedTrip`
--
ALTER TABLE `sharedTrip`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
