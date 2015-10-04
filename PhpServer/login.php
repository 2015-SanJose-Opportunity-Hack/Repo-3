<?php

require 'vendor/autoload.php';

use Parse\ParseObject;
use Parse\ParseQuery;
use Parse\ParseACL;
use Parse\ParsePush;
use Parse\ParseUser;
use Parse\ParseInstallation;
use Parse\ParseException;
use Parse\ParseAnalytics;
use Parse\ParseFile;
use Parse\ParseCloud;
use Parse\ParseClient;

$app_id = "YiutbXLU5r5ofy1JdpRzCWq3w4ypjmNLajS5fwpl";
$rest_key = "k4Y8vkkSxjbSm5ShOfqCdkIWgjnLYMIOfEnT7SR6";
$master_key = "2nHXLv737mlU2mJJ7qsNFlAnd8WPfUs3YBPV0ROL";

session_start(); // Starting Session
$error=''; // Variable To Store Error Message
if (isset($_POST['submit'])) {
    if (empty($_POST['username']) || empty($_POST['password'])) {
        $error = "Username or Password is invalid";
    }
    else
    {
// Define $username and $password
        $username=$_POST['username'];
        $password=$_POST['password'];

        ParseClient::initialize( $app_id, $rest_key, $master_key );
        $query1 = new ParseQuery("user");
        $query1->equalTo("user_name", $username);
        $query2 = new ParseQuery("user");
        $query2->equalTo("user_id", $password);

        $mainQuery = ParseQuery::orQueries([$query1, $query2]);
        $results = $mainQuery->find();

        if(count($results)>0) {
            $_SESSION['login_user']=$username; // Initializing Session
            header("location: profile.php?user=" . $username); // Redirecting To Other Page
        } else {
            $error = "Username or Password is invalid";
        }
    }
}
?>