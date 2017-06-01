-- phpMyAdmin SQL Dump
-- version 4.6.5.2
-- https://www.phpmyadmin.net/
--
-- 主機: localhost
-- 產生時間： 2017 年 05 月 30 日 01:05
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
(7, 'create', 'ddd', 'ddd.gmail.com'),
(9, 'test', 'kkk', 'ppp.gmail.com');

-- --------------------------------------------------------

--
-- 資料表結構 `pocketspot`
--

CREATE TABLE `pocketspot` (
  `id` int(11) NOT NULL,
  `spotName` varchar(200) NOT NULL,
  `ownerUser` varchar(200) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;

--
-- 資料表的匯出資料 `pocketspot`
--

INSERT INTO `pocketspot` (`id`, `spotName`, `ownerUser`) VALUES
(5, '羅浮宮', 'create'),
(6, '羅浮宮', '123'),
(7, '羅浮宮', '123'),
(8, '羅浮宮', '123'),
(9, '巴黎鐵塔', 'create'),
(10, '巴黎鐵塔', '234'),
(11, '巴黎鐵塔', '234'),
(12, 'Tokyo', 'create');

-- --------------------------------------------------------

--
-- 資料表結構 `pockettrip`
--

CREATE TABLE `pockettrip` (
  `id` int(11) NOT NULL,
  `tripName` varchar(200) NOT NULL,
  `tripDays` int(11) NOT NULL,
  `ownerUser` varchar(200) NOT NULL,
  `tripCountry` varchar(200) NOT NULL,
  `coverImg` varchar(300) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;

--
-- 資料表的匯出資料 `pockettrip`
--

INSERT INTO `pockettrip` (`id`, `tripName`, `tripDays`, `ownerUser`, `tripCountry`, `coverImg`) VALUES
(7, '日本五日遊', 5, 'create', '日本', 'create_日本五日遊_1496043112_pocketTripCover.jpeg');

-- --------------------------------------------------------

--
-- 資料表結構 `pockettripspot`
--

CREATE TABLE `pockettripspot` (
  `id` int(11) NOT NULL,
  `tripName` varchar(300) NOT NULL,
  `spotName` varchar(300) NOT NULL,
  `nDay` int(11) NOT NULL,
  `nth` int(11) NOT NULL,
  `trafficToNext` varchar(300) NOT NULL,
  `ownerUser` varchar(300) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;

--
-- 資料表的匯出資料 `pockettripspot`
--

INSERT INTO `pockettripspot` (`id`, `tripName`, `spotName`, `nDay`, `nth`, `trafficToNext`, `ownerUser`) VALUES
(9, '日本五日遊', '天龍寺', 4, 4, '', 'create'),
(10, '日本五日遊', '金閣寺', 3, 3, '十號公車轉三號公車，下車向西二十公尺後左轉，五十公尺後右轉，換地鐵三號線至天龍人站，向東行五十公尺後右轉，直行二十公尺', 'create'),
(11, '日本五日遊', '平等院', 2, 2, '十號公車轉三號公車，下車向西二十公尺後左轉，五十公尺後右轉，換五號公車乘坐到金閣寺站，下車向東行三十公尺', 'create'),
(12, '日本五日遊', '清水寺', 1, 1, '十號公車轉三號公車，下車向西二十公尺後左轉，五十公尺後右轉', 'create');

-- --------------------------------------------------------

--
-- 資料表結構 `sharedtrip`
--

CREATE TABLE `sharedtrip` (
  `id` int(11) NOT NULL,
  `tripName` varchar(200) NOT NULL,
  `tripDays` int(11) NOT NULL,
  `tripCountry` varchar(200) NOT NULL,
  `ownerUser` varchar(200) NOT NULL,
  `coverImg` varchar(300) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;

--
-- 資料表的匯出資料 `sharedtrip`
--

INSERT INTO `sharedtrip` (`id`, `tripName`, `tripDays`, `tripCountry`, `ownerUser`, `coverImg`) VALUES
(10, '日本五日遊', 5, '日本', 'create', '日本遊.jpeg'),
(11, '香港三日遊', 3, '香港', 'test', '香港.jpeg');

-- --------------------------------------------------------

--
-- 資料表結構 `sharedtripspot`
--

CREATE TABLE `sharedtripspot` (
  `id` int(11) NOT NULL,
  `tripName` varchar(300) NOT NULL,
  `spotName` varchar(300) NOT NULL,
  `nDay` int(11) NOT NULL,
  `nth` int(11) NOT NULL,
  `trafficToNext` varchar(300) NOT NULL,
  `ownerUser` varchar(300) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- 資料表的匯出資料 `sharedtripspot`
--

INSERT INTO `sharedtripspot` (`id`, `tripName`, `spotName`, `nDay`, `nth`, `trafficToNext`, `ownerUser`) VALUES
(5, '日本五日遊', '天龍寺', 4, 4, '', 'create'),
(6, '日本五日遊', '金閣寺', 3, 3, '十號公車轉三號公車，下車向西二十公尺後左轉，五十公尺後右轉，換地鐵三號線至天龍人站，向東行五十公尺後右轉，直行二十公尺', 'create'),
(7, '日本五日遊', '平等院', 2, 2, '十號公車轉三號公車，下車向西二十公尺後左轉，五十公尺後右轉，換五號公車乘坐到金閣寺站，下車向東行三十公尺', 'create'),
(8, '日本五日遊', '清水寺', 1, 1, '十號公車轉三號公車，下車向西二十公尺後左轉，五十公尺後右轉', 'create');

--
-- 已匯出資料表的索引
--

--
-- 資料表索引 `member`
--
ALTER TABLE `member`
  ADD PRIMARY KEY (`id`);

--
-- 資料表索引 `pocketspot`
--
ALTER TABLE `pocketspot`
  ADD PRIMARY KEY (`id`);

--
-- 資料表索引 `pockettrip`
--
ALTER TABLE `pockettrip`
  ADD PRIMARY KEY (`id`);

--
-- 資料表索引 `pockettripspot`
--
ALTER TABLE `pockettripspot`
  ADD PRIMARY KEY (`id`);

--
-- 資料表索引 `sharedtrip`
--
ALTER TABLE `sharedtrip`
  ADD PRIMARY KEY (`id`);

--
-- 資料表索引 `sharedtripspot`
--
ALTER TABLE `sharedtripspot`
  ADD PRIMARY KEY (`id`);

--
-- 在匯出的資料表使用 AUTO_INCREMENT
--

--
-- 使用資料表 AUTO_INCREMENT `member`
--
ALTER TABLE `member`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;
--
-- 使用資料表 AUTO_INCREMENT `pocketspot`
--
ALTER TABLE `pocketspot`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;
--
-- 使用資料表 AUTO_INCREMENT `pockettrip`
--
ALTER TABLE `pockettrip`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;
--
-- 使用資料表 AUTO_INCREMENT `pockettripspot`
--
ALTER TABLE `pockettripspot`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;
--
-- 使用資料表 AUTO_INCREMENT `sharedtrip`
--
ALTER TABLE `sharedtrip`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;
--
-- 使用資料表 AUTO_INCREMENT `sharedtripspot`
--
ALTER TABLE `sharedtripspot`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
