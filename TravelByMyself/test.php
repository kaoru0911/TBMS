<?php

include 'db_config.php';

// $filePath = "pocketTripCoverImg/";

// $imgName = $db->query("
// 		select `coverImg` from `pockettrip` where 
// 		`tripName`='香港三日遊' AND
// 		`ownerUser`='create' 
// 		")->fetch();

// 	// print_r($imgName);
// 	echo $fileFullPath = $filePath.$imgName["coverImg"];

// if(file_exists($fileFullPath)){

// 	unlink($fileFullPath);	

// 	echo "file has been delete.";	
// }

// $getMemberData = $db->query("
// 		select * from `member` where 
// 		`username`='create' 
// 		")->fetch();

// $resultArray = array(
// 				 "result"=>"true",
// 				 "errorCode"=>"none, login success",
// 				 "memberData"=>$getMemberData['email']
// 			 );

// $rtnResult = json_encode($resultArray, JSON_NUMERIC_CHECK);

// echo $rtnResult

$getTrips = $db->query("
		select * from `sharedtripspot` where 
		`ownerUser`='create' and 
		`tripName`='老外玩台北'
		")->fetchAll();

print_r($getTrips[0]["trafficTitle"]);

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
						 );

			array_push($rtnTrips, $item);

			// print_r($item["trafficTitle"]);
		}

		$rtnResult = json_encode($rtnTrips, JSON_NUMERIC_CHECK);

		print_r($rtnTrips);
	}

?>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<title>Test HTML To APP Action</title>
</head>

<form action="coverImgUpload_pocketTrip.php" method="post" enctype="multipart/form-data">
    Select image to upload:
    <input type="file" name="test" id="fileToUpload">
    <input type="submit" value="Upload Image" name="submit">
</form>

</body>
</html>