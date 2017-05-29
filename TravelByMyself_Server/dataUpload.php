<?php
include 'db_config.php';

$getRequest = $_POST['request'];

if($getRequest == "uploadPocketSpot"){

	if($getAccount != ""){

		uploadPocketSpot($db);

		echo '{"result":true}';

	} else{

		echo '{"result":false, "errorCode":"Upload pocketTrip fail, user name error"}';

	}
} else if($getRequest == "uploadSharedTrip"){

	if($getAccount != ""){

		uploadSharedTrip($db);

	} else{

		echo '{"result":false, "errorCode":"Download sharedTrip fail, user name error"}';

	}

} else if($getRequest == "uploadPocketTrip"){

	if($getAccount != ""){

		

	} else{

		echo '{"result":false, "errorCode":"Download pocket spot fail, user name error"}';

	}
}


function uploadPocketSpot($db){

	$spotName = $_POST['spotName'];
	$ownerUser = $_POST['username'];

	$db->prepare("
			insert into `pocketSpot`
			(`spotName`,`ownerUser`)
			values
			('$spotName','$ownerUser')
			")->execute();
}

function uploadSharedTrip($db){

	$tripName = $_POST['tripName'];
	$ownerUser = $_POST['username'];

	$isExist = $db->query("
		select * from `sharedTrip` where 
		`tripname`='$tripName',
		`ownerUser`='$ownerUser' 
		")->fetchAll();

	if($isExist != ""){
		echo '{"result":false, "errorCode":"upload shared trip fail, trip is already exist!"}';
	} else{
		$db->prepare("
			insert into `pocketSpot`
			(`spotName`,`ownerUser`)
			values
			('$spotName','$ownerUser')
			")->execute();

		echo '{"result":true}';
	}
}

function uploadPocketTrip($db){

	$tripName = $_POST['tripName'];
	$ownerUser = $_POST['username'];

	$isExist = $db->query("
		select * from `pocketTrip` where 
		`tripname`='$tripName',
		`ownerUser`='$ownerUser' 
		")->fetchAll();

	if($isExist != ""){
		echo '{"result":false, "errorCode":"upload pocket trip fail, trip is already exist!"}';
	} else{
		$db->prepare("
			insert into `pocketSpot`
			(`spotName`,`ownerUser`)
			values
			('$spotName','$ownerUser')
			")->execute();

		echo '{"result":true}';
	}
}

?>