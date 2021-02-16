<?php
$session_start();

require('db_mysqli.php');

if(!isset($_SESSION['user'])) {
    $_SESSION['error'] = "Access denied. Sign in or sign up to access this page";
    header('location:../index.php');
}
else if(!isset($_POST) || !isEmpty($_POST["postToUpdate"]){
    header("Location: ../index.php?op_error=true");
    exit;
}
else{
    $conn = ConnectToDB();
    $sql_query = "UPDATE posts SET post_title = ?, post_content = ?, post_date = ? WHERE id = ?;";

    $post_title = trim($_POST["uPostName"]);
    $post_content = trim($_POST["uPostContent"]);
    $post_date = Date("Y-m-d");
    $post_id = $_POST["postToUpdate"];

    $updatePost = $conn->prepare($sql);
    $updatePost->bind_param('sssi', $post_title, $post_content, $post_date, $post_id);
    $updatePost->execute();

    header("Location: ../index.php?updateSuccess=true");
    exit;
}
?>
