<?php
include 'db_config.php';

$getRequest = $_POST['request'];
$getAccount = $_POST['username'];

if($getRequest == "uploadPocketSpot"){

	if($getAccount != ""){

		uploadPocketSpot($db);	

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

		uploadPocketTrip($db);

	} else{

		echo '{"result":false, "errorCode":"Download pocket spot fail, user name error"}';

	}

} else if($getRequest == "uploadPocketTripSpot" || $getRequest == "uploadSharedTripSpot"){

	if($getAccount != ""){

		uploadSpot($db, $getRequest);

	} else{

		echo '{"result":false, "errorCode":"Upload trip spot fail, user name error"}';

	}

} else if($getRequest == "deletePocketSpot"){

	if($getAccount != ""){

		deletePocketSpot($db);

	} else{

		echo '{"result":false, "errorCode":"Delete pocket spot fail, user name error"}';

	}
} else if($getRequest == "deletePocketTrip"){

	if($getAccount != ""){

		deletePocketTrip($db);

	} else{

		echo '{"result":false, "errorCode":"Delete pocket spot fail, user name error"}';

	}
}


function uploadPocketSpot($db){

	$spotName = $_POST['spotName'];
	$ownerUser = $_POST['username'];

	$db->prepare("
			insert into `pocketspot`
			(`spotName`,`ownerUser`)
			values
			('$spotName','$ownerUser')
			")->execute();

	echo '{"result":true, "errorCode":"none"}';
}

function uploadSharedTrip($db){

	$tripName = $_POST['tripName'];
	$ownerUser = $_POST['username'];
	$tripDays = $_POST['tripDays'];
	$tripCountry = $_POST['tripCountry'];

	$isExist = $db->query("
		select * from `sharedtrip` where 
		`tripName`='$tripName' AND
		`ownerUser`='$ownerUser' 
		")->fetch();

	if($isExist != ""){
		echo '{"result":false, "errorCode":"upload pocket trip fail, trip is already exist!"}';
	} else{
		$db->prepare("
			insert into `sharedtrip`
			(`tripName`,`tripDays`,`ownerUser`,`tripCountry`)
			values
			('$tripName','$tripDays','$ownerUser','$tripCountry')
			")->execute();

		echo '{"result":true, "errorCode":"none"}';
	}
}

function uploadPocketTrip($db){

	$tripName = $_POST['tripName'];
	$ownerUser = $_POST['username'];
	$tripDays = $_POST['tripDays'];
	$tripCountry = $_POST['tripCountry'];

	$isExist = $db->query("
		select * from `pockettrip` where 
		`tripName`='$tripName' AND
		`ownerUser`='$ownerUser' 
		")->fetch();

	if($isExist != ""){
		echo '{"result":false, "errorCode":"upload pocket trip fail, trip is already exist!"}';
	} else{
		$db->prepare("
			insert into `pockettrip`
			(`tripName`,`tripDays`,`ownerUser`,`tripCountry`)
			values
			('$tripName','$tripDays','$ownerUser','$tripCountry')
			")->execute();

		echo '{"result":true, "errorCode":"none"}';
	}
}

function uploadSpot($db, $request){

	$tripName = $_POST['tripName'];
	$spotName = $_POST['spotName'];
	$ownerUser = $_POST['username'];
	$nDay = $_POST['nDay'];
	$nth = $_POST['nth'];
	$traffic = $_POST['traffic'];

	if($request == "uploadPocketTripSpot"){

		$db->prepare("
			insert into `pockettripspot`
			(`spotName`,`tripName`,`nDay`,`nth`, `trafficToNext`,`ownerUser`)
			values
			('$spotName','$tripName','$nDay','$nth','$traffic','$ownerUser')
			")->execute();

		echo '{"result":true, "errorCode":"none"}';

	} else if($request = "uploadsharedtripSpot"){

		$db->prepare("
			insert into `sharedtripSpot`
			(`spotName`,`tripName`,`nDay`,`nth`, `trafficToNext`,`ownerUser`)
			values
			('$spotName','$tripName','$nDay','$nth','$traffic','$ownerUser')
			")->execute();

		echo '{"result":true, "errorCode":"none"}';
	}

}



function deletePocketSpot($db){

	$spotName = $_POST['spotName'];
	$ownerUser = $_POST['username'];

	$db->prepare("
			DELETE FROM `pocketspot` WHERE 
			`pocketspot`.`spotName` = '$spotName' AND
			`pocketspot`.`ownerUser` = '$ownerUser' 
			")->execute();

	echo '{"result":true, "errorCode":"none"}';
}

function deletePocketTrip($db){

	$tripName = $_POST['tripName'];
	$ownerUser = $_POST['username'];
	$filePath = "pocketTripCoverImg/";

	$imgName = $db->query("
		select `coverImg` from `pockettrip` where 
		`tripName`='$tripName' AND
		`ownerUser`='$ownerUser' 
		")->fetch();

	$fileFullPath = $filePath.$imgName["coverImg"];

	$db->prepare("
			DELETE FROM `pockettrip` WHERE 
			`pockettrip`.`tripName` = '$tripName' AND
			`pockettrip`.`ownerUser` = '$ownerUser' 
			")->execute();

	$db->prepare("
			DELETE FROM `pockettripspot` WHERE 
			`pockettripspot`.`tripName` = '$tripName' AND
			`pockettripspot`.`ownerUser` = '$ownerUser' 
			")->execute();

	if(file_exists($fileFullPath)){
		unlink($fileFullPath);		
	}

	echo '{"result":true, "errorCode":"none"}';
}

?>