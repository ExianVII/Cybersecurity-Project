<?php
require 'db_mysqli.php';
//Check if the user is logged in first and foremost.
if(isset($_SESSION['user']))
{
    $host = '127.0.0.1';
    $db = "cyberproject";
    $user = "root";
    $password="";
    $charset="utf8mb4";

    $db_connection = "mysql:host=$host;dbname=$db;charset=$charset";

    $sql = "UPDATE posts
    SET post_title = :blog_title, post_content = :blog_content
    WHERE post_author = :id";

    $blog_title = mysqli_real_escape_string($db_connection, $_POST["blog_title"]);
    $blog_content = mysqli_real_escape_string($db_connection, $_POST["blog_content"]);
    $id = mysqli_real_escape_string($db_connection, $_POST["id"]);

    $query = $db_connection->prepare($sql);
    $query->bindParam(':blog_title', $blog_title);
    $query->bindParam(':blog_content', $blog_content);
    $query->bindParam(':id', $id);

    $query->execute();
}
else{
    $_SESSION['error'] = "Access denied. Sign in or sign up to access this page";
    header('location:index.php');
    //header("location:updateCreateForm.php");
}

?>
