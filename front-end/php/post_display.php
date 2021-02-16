<?php
function displayPost($postId)
{
    require('db_mysqli.php');
    $sqlPost = "SELECT * FROM posts WHERE post_id=?";

    if (!isset($postId)) {

        return "There's no content to display!";
    }
    else {
        if (isset($db)) {

            return mysqli_fetch_array(prepared_query($db, $sqlPost, [$postId])->get_result());

        }
        else
        {

            return "Could not connect to the Database";
        }
    }
}
?>
