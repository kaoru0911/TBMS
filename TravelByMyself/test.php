<?php

include 'db_config.php';

$filePath = "pocketTripCoverImg/";

$imgName = $db->query("
		select `coverImg` from `pockettrip` where 
		`tripName`='香港三日遊' AND
		`ownerUser`='create' 
		")->fetch();

	// print_r($imgName);
	echo $fileFullPath = $filePath.$imgName["coverImg"];

if(file_exists($fileFullPath)){

	unlink($fileFullPath);	

	echo "file has been delete.";	
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