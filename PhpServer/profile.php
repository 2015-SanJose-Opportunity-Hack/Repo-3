<!DOCTYPE html>
<html>
<head>
    <title>List of patients</title>
    <link href="styles/style.css" rel="stylesheet" type="text/css">
    <h1> List of Patients</h1>
    <style type="text/css">
        table.query-table { border-collapse: collapse; }
        th {color: #FFF;
            background-color: #555;
            border: 1px solid #555;
            padding: 3px;
            vertical-align: top;
            text-align: left; }

        table.query-table tr:nth-child(2n+1) {
            background-color: #F1F1F1;
        }

        table.query-table tr:nth-child(2n) {
            background-color: #FFF;
        }

        table.query-table td {
            border: 1px solid #D4D4D4;
            padding: 7px 5px;
            vertical-align: top;
        }
    </style>
</head>
<body>
<table class="query-table">
    <tr>
        <th>Number</th><th>Patient</th><th>Blood Pressure (mm Hg)</th><th>Weight (lbs)</th><th>Haemoglobin (g/dL)</th>
    </tr>
<?php
/**
 * Created by PhpStorm.
 * User: ashish
 * Date: 10/4/15
 * Time: 1:37 AM
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
$query->equalTo("doctor_id", $_GET['user']);

$results = $query->find();

for ($i = 0; $i < count($results); $i++) {
?>

    <tr>
        <td> <?php echo $i+1; ?></td><td><a href="/patient.php?id=<?php echo $results[$i]->get("patient_id");?>"><?php echo $results[$i]->get("patient_id");?></a></td>
        <td><?php echo $results[$i]->get("bp");?></td>
        <td><?php echo $results[$i]->get("weight");?></td>
        <td><?php echo $results[$i]->get("hgb");?></td>
    </tr>

<?php
}

?>

</table>
</body>
</html>
