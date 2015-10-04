
<?php
/**
 * Created by PhpStorm.
 * User: ashish
 * Date: 10/4/15
 * Time: 3:29 AM
 */


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

ParseClient::initialize( $app_id, $rest_key, $master_key );

$query = new ParseQuery("patient");
session_start();

if(!isset($_POST['bp']))
{

    $_SESSION['patient_id']=$_GET['id'];
    $query->equalTo("patient_id", $_GET['id']);
    $results = $query->find();
} else {

    $query->equalTo("patient_id", $_SESSION['patient_id']);
    $results = $query->find();

    if ($_POST['bp'] == "" || $_POST['weight'] == "" || $_POST['hgb'] == "")
        echo "Fields can't be left blank";
    elseif ($_POST['bp'] == $results[0]->get('bp') && $_POST['weight'] == $results[0]->get('weight') && $_POST['hgb'] == $results[0]->get('hgb'))
        echo "Fields are not changed";
    else {
        $q = new ParseQuery("patient");
        $row = $q->get($results[0]->getObjectId());

        $row->set("bp", (int)$_POST['bp']);
        $row->set("weight",(int) $_POST['weight']);
        $row->set("hgb", (int) $_POST['hgb']);
        $row->save();

        header("location: profile.php?user=" . $results[0]->get('doctor_id'));
    }

}

?>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <title>Login & Registration System</title>
    <link rel="stylesheet" href="styles/style2.css" type="text/css" />

</head>
<body>
<center>
    <div id="login-form">
        <form method="post" action="">
            <table align="center" width="30%" border="0">
                <tr>
                    <td>Patient Id : </td><td><?php echo $_GET['id'];?></td>
                </tr>
                <tr>
                    <td>Haemoglobin (g/dL)</td><td><input type="text" name="hgb" id="hgb" value="<?php echo $results[0]->get('hgb'); ?>" required /></td>
                </tr>
                <tr>
                    <td>Weight (lbs)</td><td><input type="text" name="weight" id="weight" value="<?php echo $results[0]->get('weight'); ?>" required /></td>
                </tr>
                <tr>
                    <td>Blood pressure (mm Hg)</td><td><input type="text" name="bp" id="bp" value="<?php echo $results[0]->get('bp'); ?>" required /></td>
                </tr>
                <tr>
                    <td><input type="submit" value="update"/></td><td><input type="button" onclick="location.href='/profile.php?user=<?php echo $results[0]->get('doctor_id'); ?>';" value="back"/></td>
                </tr>
            </table>
        </form>
    </div>
</center>
</body>
</html>
