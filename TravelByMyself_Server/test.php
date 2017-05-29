<?php

include 'db_config.php';

$getTrips = $db->query("
		select * from `tripList` where 
		`owneruser`='123'
		")->fetchAll();

echo count($getTrips);




?>

