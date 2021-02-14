<?php
require 'db_connect.php';
if(isset($_POST)){
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


    $query = $db_connection-> prepare($sql);
    $query->bindParam(':user_id', $user_id);
    $query->bindParam(':blog_title', $blog_title);
    $query->bindParam(':blog_content', $blog_content);

    $query->execute();

}
else{
    header('location:newBlogForm.html');
    exit;
}

?>
