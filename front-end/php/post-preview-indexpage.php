<?php
include 'db_mysqli.php';

$sqlRetrievePosts = "SELECT * FROM posts WHERE 1";

if(isset($db))
{
    $result = $db->query($sqlRetrievePosts);
    //$postData = mysqli_fetch_all($result);


       while($row = $result->fetch_assoc())
        {
            if(count($row) == 0)
            {
                $_SESSION['post_preview'] = "There are no posts to display";
                break;
            }
            //var_dump($row);
            $title = $row['post_title'];
            $preview = strlen($row['post_content']) > 50 ? substr($row['post_content'],0,50)."..." :$row['post_content'];
            $author = $row['post_author'];
            $post_date = $row['date_posted'];

            echo nl2br("Title: ".$title."\r\n". "Preview: ".$preview." \r\n"."Author: ".$author."\r\n"."Date posted ".$post_date);

        }

}

else {
    $_SESSION['post_preview'] = "Error! Database Connection failed.";
    //echo "Error! Database Connection failed.";
}


//Take the text from the content and cut it like this, more or less:
//$out = strlen($in) > 50 ? substr($in,0,50)."..." : $in;

//In theory, the command above will make the post contents(which is super long) have only about 50 characters
//for the lead to display on the main page.
?>
