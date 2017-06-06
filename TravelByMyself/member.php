<?php

include 'db_config.php';


$getAccount = $_POST['username'];

$getRequest = $_POST['request'];


if($getRequest == "login"){

	$getPassword = $_POST['password'];

	if($getAccount != ""){

	// echo '{"result":true, "errorCode":"get"}';

	// error_log(json_encode($_POST));

	login($db, $getAccount, $getPassword);

	} else{

		echo '{"result":"false", "errorCode":"Login fail"}';

	}
} else if($getRequest == "create"){

	$getEmail = $_POST['email'];

	$getPassword = $_POST['password'];

	if($getAccount != ""){

	create($db, $getAccount, $getPassword, $getEmail);

	} else{

		echo '{"result":false, "errorCode":"Create acocunt fail"}';

	}
} else if($getRequest == "updateUserInfo"){

	$getEmail = $_POST['email'];
	$getPassword = $_POST['password'];

	if($getAccount != ""){

	update($db, $getAccount, $getPassword, $getEmail);

		// echo '{"result":true, "errorCode":"Update success"}';

	} else{

		echo '{"result":false, "errorCode":"Update user info fail"}';

	}
}



function login($db, $account, $password){
	$adminData = $db->query("
		select * from `member` where 
		`username`='$account' and 
		`password`='$password'")->fetch();

	if($adminData!=""){

		$getMemberData = $db->query("
		select * from `member` where 
		`username`='$account' 
		")->fetch();

		// result = 1 = true
		$resultArray = array(
				 "result"=>1,
				 "errorCode"=>"none, login success",
				 "email"=>$getMemberData['email']
			 );

		$rtnResult = json_encode($resultArray, JSON_NUMERIC_CHECK);

		echo $rtnResult;

	}else{
		echo '{"result":false, "errorCode":"login fail"}';
	}
}

function create($db, $account, $password, $email){

	$isExist = $db->query("
		select * from `member` where 
		`username`='$account' 
		")->fetch();

	if($isExist!=""){
		echo '{"result":false, "errorCode":"account is already exist"}';
	}else{
		$db->prepare("
			insert into `member`
			(`username`,`password`,`email`)
			values
			('$account','$password','$email')
			")->execute();

		echo '{"result":true, "errorCode":"none, create account success"}';
	}	
}

function update($db, $account, $password, $email){

	$db->prepare("
			update `member` set			
			`email`='$email',
			`password`='$password'
			where `username`='$account'			
			")->execute();

	echo '{"result":true, "errorCode":"none, update user file success"}';

}



?>