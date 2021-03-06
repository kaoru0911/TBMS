<?php

include 'db_config.php';


$getAccount = $_POST['username'];
$getRequest = $_POST['request'];

if($getRequest == "downloadPocketTrip"){

	if($getAccount != ""){

		downloadPocketTrip($db, $getAccount);

	} else{

		echo '{"result":false, "errorCode":"Download pocketTrip fail, user name error"}';

	}
} else if($getRequest == "downloadSharedTrip"){

	if($getAccount != ""){

		downloadSharedTrip($db, $getAccount);

	} else{

		echo '{"result":false, "errorCode":"Download sharedTrip fail, user name error"}';

	}

} else if($getRequest == "downloadPocketSpot"){

	if($getAccount != ""){

		downloadPocketSpot($db, $getAccount);

	} else{

		echo '{"result":false, "errorCode":"Download pocket spot fail, user name error"}';

	}
} else if($getRequest == "downloadSharedTripSpot"){

	if($getAccount != ""){

		downloadSharedTripSpot($db, $getAccount);

	} else{

		echo '{"result":false, "errorCode":"Download shared trip spot fail, user name error"}';

	}
} else if($getRequest == "downloadPocketTripSpot"){

	if($getAccount != ""){

		downloadPocketTripSpot($db, $getAccount);

	} else{

		echo '{"result":false, "errorCode":"Download shared trip spot fail, user name error"}';

	}
}



function downloadPocketTrip($db, $account){

	$getTrips = $db->query("
		select * from `pockettrip` where 
		`owneruser`='$account'
		")->fetchAll();

	// echo $getTrips;

	if(count($getTrips) > 0){

		$rtnTrips = array();

		foreach ($getTrips as $k => $v){

			$item = array(
						 "id"=>$v['id'],
						 "tripName"=>$v['tripName'],
						 "tripDays"=>$v['tripDays'],
						 "tripCountry"=>$v['tripCountry'],						 					 						 							 					 
						 "ownerUser"=>$v['ownerUser'],
						 "coverImg"=>$v['coverImg'],
						 );

			array_push($rtnTrips, $item);
		}

		$rtnResult = json_encode($rtnTrips, JSON_NUMERIC_CHECK);

		echo $rtnResult;

	} else{
		echo '{"result":false, "errorCode":"There are no pocket trip"}';
	}
}


function downloadSharedTrip($db){

	$getTrips = $db->query("
		select * from `sharedtrip`
		")->fetchAll();

	if(count($getTrips) > 0){

		$rtnTrips = array();

		foreach ($getTrips as $k => $v){

			$item = array(
						 "id"=>$v['id'],
						 "tripName"=>$v['tripName'],
						 "tripDays"=>$v['tripDays'],
						 "tripCountry"=>$v['tripCountry'],						 					 						 							 					 
						 "ownerUser"=>$v['ownerUser'],
						 "coverImg"=>$v['coverImg'],
						 );

			array_push($rtnTrips, $item);
		}

		$rtnResult = json_encode($rtnTrips, JSON_NUMERIC_CHECK);

		echo $rtnResult;

	} else{
		echo '{"result":false, "errorCode":"There are no shared trip"}';
	}
}

function downloadPocketSpot($db, $account){

	$getTrips = $db->query("
		select * from `pocketspot` where 
		`ownerUser`='$account'
		")->fetchAll();

	if(count($getTrips) > 0){

		$rtnTrips = array();

		foreach ($getTrips as $k => $v){

			$item = array(
						 "id"=>$v['id'],
						 "spotName"=>$v['spotName'],							 							 					 
						 "ownerUser"=>$v['ownerUser'],
						 "spotCountry"=>$v['spotCountry'],
						 "placeID"=>$v['placeID'],	
						 "latitude"=>$v['latitude'],
						 "longitude"=>$v['longitude']
						 );

			array_push($rtnTrips, $item);
		}

		$rtnResult = json_encode($rtnTrips, JSON_NUMERIC_CHECK);

		echo $rtnResult;

	} else{
		echo '{"result":false, "errorCode":"There are no pocket spot"}';
	}
}

function downloadSharedTripSpot($db, $account){

	$tripName = $_POST['tripName'];

	$getTrips = $db->query("
		select * from `sharedtripspot` where 
		`ownerUser`='$account' and 
		`tripName`='$tripName'
		")->fetchAll();

	if(count($getTrips) > 0){

		$rtnTrips = array();

		foreach ($getTrips as $k => $v){

			$item = array(
						 "id"=>$v['id'],
						 "tripName"=>$v['tripName'],
						 "spotName"=>$v['spotName'],	
						 "nDay"=>$v['nDay'],
						 "nth"=>$v['nth'],	
						 "trafficTitle"=>$v['trafficTitle'],
						 "trafficToNext"=>$v['trafficToNext'],
						 "placeID"=>$v['placeID'],	
						 "latitude"=>$v['latitude'],
						 "longitude"=>$v['longitude']				 
						 );

			array_push($rtnTrips, $item);
		}

		$rtnResult = json_encode($rtnTrips, JSON_NUMERIC_CHECK);

		echo $rtnResult;

	} else{
		echo '{"result":false, "errorCode":"There are no shared trip spot"}';
	}
}

function downloadPocketTripSpot($db, $account){

	$tripName = $_POST['tripName'];

	$getTrips = $db->query("
		select * from `pockettripspot` where 
		`ownerUser`='$account' and 
		`tripName`='$tripName'
		")->fetchAll();

	if(count($getTrips) > 0){

		$rtnTrips = array();

		foreach ($getTrips as $k => $v){

			$item = array(
						 "id"=>$v['id'],
						 "tripName"=>$v['tripName'],
						 "spotName"=>$v['spotName'],	
						 "nDay"=>$v['nDay'],
						 "nth"=>$v['nth'],	
						 "trafficTitle"=>$v['trafficTitle'],
						 "trafficToNext"=>$v['trafficToNext'],
						 "placeID"=>$v['placeID'],	
						 "latitude"=>$v['latitude'],
						 "longitude"=>$v['longitude']				 
						 );

			array_push($rtnTrips, $item);
		}

		$rtnResult = json_encode($rtnTrips, JSON_NUMERIC_CHECK);

		echo $rtnResult;

	} else{
		echo '{"result":false, "errorCode":"There are no pocket trip spot"}';
	}
}



?>