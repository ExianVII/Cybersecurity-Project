<?php
session_start();
include('db_connect.php');

if(!isset($_SESSION['user'])) {
    $_SESSION['error'] = "Access denied. Sign in or sign up to access this page";
    header('location:../front-end/Login.php');
    exit;
}
else{
    $conn = ConnectToDB();

    if($conn->connect_error){
        header("Location: ../newBlogForm.php");
        exit;
    }
    else{
        //&& isset $_POST["user_id"]
        if(isset($_POST)){
            $post_title = trim($_POST["cPostName"]);
            $post_content = trim($_POST["cPostContent"]);
            $today = date("Y/m/d");
            $author = 1; // holder for now

            $sql_query = "INSERT INTO posts VALUES(null, ?, ?, ?, ?);";
            $insert = $conn->prepare($sql_query);
            $insert->bind_param('isss', $author, $post_title, $post_content, $today);
            $insert->execute();

            header("Location: ../index.php?success=true");
                exit;
        }
        else{
           header("Location: ../index.php?op_error=true");
               exit;
        }
}
}
?>
