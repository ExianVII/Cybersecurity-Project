<?php
function ConnectToDB()
{
    $Host = "127.0.0.1";
    $user = "root";
    $pwd = 'nip123!';
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
