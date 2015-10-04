
<?php
/**
 * Created by PhpStorm.
 * User: ashish
 * Date: 10/3/15
 * Time: 10:04 PM
 */



include('login.php'); // Includes Login Script

if(isset($_SESSION['login_user'])){
    header("location: profile.php?user=" . $_SESSION['login_user']);
}



?>
<!DOCTYPE html>
<html>
<head>
    <title>Login Form in PHP with Session</title>
    <link href="styles/style.css" rel="stylesheet" type="text/css">
</head>
<body>
<div id="main">
    <h1>PHP Login Session Example</h1>
    <div id="login">
        <h2>Login Form</h2>
        <form action="" method="post">
            <label>UserName :</label>
            <input id="name" name="username" placeholder="username" type="text">
            <label>Password :</label>
            <input id="password" name="password" placeholder="**********" type="password">
            <input name="submit" type="submit" value=" Login ">
            <span><?php echo $error; ?></span>
        </form>
    </div>
</div>
</body>
</html>
