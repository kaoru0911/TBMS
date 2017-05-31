<?php
include 'db_config.php';

$tripName = $_POST['tripName'];
$ownerUser = $_POST['username'];
$getRequest = $_POST['request'];

$imgName = $ownerUser."_".$tripName."_".time();

if($getRequest == "uploadPocketTripCover"){

	$target_dir = "pocketTripCoverImg/";

	$table = "pockettrip";

} else if($getRequest == "uploadSharedTripCover"){

	$target_dir = "sharedTripCoverImg/";

	$table = "sharedtrip";
}

$target_filename = $imgName."_".basename($_FILES["coverImg"]["name"]);
$target_filepath = $target_dir.$target_filename;

if (move_uploaded_file($_FILES["coverImg"]["tmp_name"], $target_filepath)){

	$db->prepare("
			update `$table` set			
			`coverImg`='$target_filename' where 
			`ownerUser`='$ownerUser' and
			`tripName`='$tripName'
			")->execute();
	
	echo '{"result":true, "errorCode":"none"}';
} else{

	echo '{"result":false, "errorCode":"upload cover img fail"}';
}

?>