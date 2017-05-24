<?php
	
	// 連結資料庫
	$db=new pdo("mysql:host=localhost","root","");
	$db->query("set names 'utf8'");
	$db->query("use `TravelByMyself`");
?>