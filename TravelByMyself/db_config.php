<?php
	
	// 連結資料庫
	$db=new pdo("mysql:host=localhost","chiaonic","luzL83xC36");
	$db->query("set names 'utf8'");
	$db->query("use `chiaonic_travelByMySelf`");
?>