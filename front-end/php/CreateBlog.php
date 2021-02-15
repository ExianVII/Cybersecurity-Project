<?php
require 'db_connect.php';
if(isset($_SESSION['user'])){
    $host = '127.0.0.1';
    $db = "cyberproject";
    $user = "root";
    $password="";
    $charset="utf8mb4";

    $db_connection = "mysql:host=$host;dbname=$db;charset=$charset";

    $sql = "INSERT INTO posts VALUES(null, :user_id, :blog_title, :blog_content, date('Y/m/d'))";

    $user_id = mysqli_real_escape_string($db_connection, $_POST["user_id"]);
    $blog_title = mysqli_real_escape_string($db_connection, $_POST["blog_title"]);
    $blog_content = mysqli_real_escape_string($db_connection, $_POST["blog_content"]);

//Check the db_mysqli file to use the method to generate this same code and/or just reference the connection.
    $query = $db_connection-> prepare($sql);
    $query->bindParam(':user_id', $user_id);
    $query->bindParam(':blog_title', $blog_title);
    $query->bindParam(':blog_content', $blog_content);

    $query->execute();

}
else{
    /*header('location:newBlogForm.html');
    exit;*/
    $_SESSION['error'] = "Access denied. Sign in or sign up to access this page";
    header('location:index.php');
}

?>
