<?php

print "Value";

if(isset($_POST)){
    $host = '127.0.0.1';
    $db = "cyberproject";
    $user = "root";
    $password="";
    $charset="utf8mb4";

    $db_connection = new PDO("mysql:host=$host;dbname=$db;charset=$charset");

    //Alexandra, please this format to conform to the format present in the other pages I'm setting up.
    //I'll replace the db script in this project.
    $sql = "INSERT INTO posts VALUES(null, :user_id, :blog_title, :blog_content, date('Y/m/d'))";

    //This will throw an error saying that your connection is null.
    // PDO is incompatible with mysqli. Found out the hard way.
    $user_id = mysqli_real_escape_string($db_connection, $_POST["user_id"]);
    $blog_title = mysqli_real_escape_string($db_connection, $_POST["blog_title"]);
    $blog_content = mysqli_real_escape_string($db_connection, $_POST["blog_content"]);


    $insert = $db_connection->query($sql);
    $insert->bindParam(':user_id', $user_id);
    $insert->bindParam(':blog_title', $blog_title);
    $insert->bindParam(':blog_content', $blog_content);

    $insert->execute();

    header('location:newBlogForm.php');
}
else{
    header('location:newBlogForm.php');
    exit;
}

?>
