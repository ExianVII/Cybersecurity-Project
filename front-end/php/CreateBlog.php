<?php

require_once("db_connect.php");

$conn = ConnectToDB();

if($conn->connect_error){
    header("Location: ../newBlogForm.php");
    exit;
}
else{
    //&& isset $_POST["user_id"]
    if(isset($_POST)){

        $blog_title = trim($_POST["cBlogName"]);
        $blog_content = trim($_POST["cBlogMessage"]);
        $today = date("Y/m/d");
        $user_id = 1;

        $sql_query = "INSERT INTO posts VALUES(null, ?, ?, ?, ?);";

        $insert = $conn->prepare($sql_query);
        $insert->bind_param('isss', $user_id, $post_title, $post_content, $today);
        $insert->execute();

        $idInsert = $conn->insert_id;

        echo "The user ". $idInsert. " added this post";

        header("Location: ../index.php?success=true");
        exit;
    }
    else{
        header("Location: ../newBlogForm.php");
        exit;
    }
}
?>
