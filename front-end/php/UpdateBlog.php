<?php

if($_POST){
    $host = '127.0.0.1';
    $db = "cyberproject";
    $user = "root";
    $password="";
    $charset="utf8mb4";

    $db_connection = "mysql:host=$host;dbname=$db;charset=$charset";

    $sql = "UPDATE blog
    SET blog_title = :blog_title, blog_content = :blog_content,
    WHERE id = :id";

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
    header("location:updateCreateForm.php");
}

?>
