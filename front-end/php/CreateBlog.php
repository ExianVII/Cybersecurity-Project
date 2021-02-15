<?php

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
        $user_id = 1; // holder for now

        $sql_query = "INSERT INTO posts VALUES(null, ?, ?, ?, ?);";
        $insert = $conn->prepare($sql_query);
        $insert->bind_param('isss', $user_id, $post_title, $post_content, $today);
        $insert->execute();

        header("Location: ../index.php?success=true");
            exit;
    }
    else{
    $_SESSION['error'] = "Access denied. Sign in or sign up to access this page";
        header('location:../newBlogForm.php');
    }
}
?>
