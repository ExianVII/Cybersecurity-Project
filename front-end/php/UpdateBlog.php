<?php
session_start();

require('db_mysqli.php');
require('db_connect.php');

if(!isset($_SESSION['user'])) {
    $_SESSION['error'] = "Access denied. Sign in or sign up to access this page";
    header('location:../Login.php');
}
else if(!isset($_POST) || !isset($_POST["postToUpdate"])){
    header('Location: ../index.php?op_error=true');
    exit;
}
else{
    $conn = ConnectToDB();
    $sql_query = "UPDATE posts SET
    post_title = ?, post_content = ?, date_posted = ? WHERE post_id = ?;";

    $post_title = trim($_POST["uPostName"]);
    $post_content = trim($_POST["uPostContent"]);
    $date_posted = Date("Y-m-d");
    $post_id = $_POST["postToUpdate"];

    $updatePost = $conn->prepare($sql_query);
    $updatePost->bind_param('sssi', $post_title, $post_content, $date_posted, $post_id);
    $updatePost->execute();

    header("Location: ../index.php?updateSuccess=true");
    exit;
}
?>
