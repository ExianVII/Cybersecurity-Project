<?php
function ConnectToDB()
{
    $Host = "localhost";
    $user = "root";
    //$pwd = 'u*NIc?"F*}db|A&Y&\Z/C+%>dd<$%F';
    $pwd = '';
    $DB = "cybersec_project";

    $conn = new mysqli($Host, $user, $pwd, $DB);

    //connection failed.
    if($conn->connect_error)
    {
        die("Connection failed: " . $conn->connect_error);
    }

    return $conn;
}
?>
