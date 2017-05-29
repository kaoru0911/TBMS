<?php

include 'db_config.php';


$getAccount = $_POST['username'];
$getPassword = $_POST['password'];
$getRequest = $_POST['request'];
$getEmail = $_POST['email'];

if($getRequest == "login"){

	if($getAccount != ""){

	// echo '{"result":true, "errorCode":"get"}';

	// error_log(json_encode($_POST));

	login($db, $getAccount, $getPassword);

	} else{

		echo '{"result":false, "errorCode":"Login fail"}';

	}
} else if($getRequest == "create"){

	if($getAccount != ""){

	create($db, $getAccount, $getPassword, $getEmail);

	} else{

		echo '{"result":false, "errorCode":"Create acocunt fail"}';

	}
} else if($getRequest == "updateUserInfo"){

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
		echo '{"result":true, "errorCode":"none"}';
	}else{
		echo '{"result":fail, "errorCode":"login fail"}';
	}
}

function create($db, $account, $password, $email){

	$isExist = $db->query("
		select * from `member` where 
		`username`='$account' 
		")->fetch();

	if($isExist!=""){
		echo '{"result":fail, "errorCode":"account is already exist"}';
	}else{
		$db->prepare("
			insert into `member`
			(`username`,`password`,`email`)
			values
			('$account','$password','$email')
			")->execute();
	}	
}

function update($db, $account, $password, $email){

	$db->prepare("
			update `member` set			
			`email`='$email',
			`password`='$password'
			where `username`='$account'			
			")->execute();

}



?>