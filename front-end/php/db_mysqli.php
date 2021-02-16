<?php
    mysqli_report(MYSQLI_REPORT_ERROR | MYSQLI_REPORT_STRICT);
    //$db = null;
    try {
        include ('db_credentials.php');
        if (!empty($host) && !empty($user) && !empty($pwd) && !empty($dbname) && !empty($port)) {
            $db = new mysqli($host, $user, $pwd, $dbname, $port);
        }
        if(!empty($charset))
        $db -> set_charset($charset);
    }

    catch (mysqli_sql_exception $e)
    {
        throw new mysqli_sql_exception($e->getMessage(), $e->getCode());
    }
date_default_timezone_set('America/Toronto');

    function prepared_query($db, $sql, $params, $types="")
    {
        $types = $types ?: str_repeat("s", count($params));
        $stmt = $db->prepare($sql);
        @$stmt->bind_param($types, ...$params);
        $stmt->execute();
        return $stmt;
    }

?>
