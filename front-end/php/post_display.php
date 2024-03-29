<?php
//Get the full text contents here. Again, no "display block". See how the contact.html handles its php.
//That's how normal people code. AKA: everyone but our PHP prof.

//:'v
include('php/db_connect.php');

function getSinglePost($post_id){
    $conn = ConnectToDB();

    $singlePost = $conn->prepare("SELECT * FROM posts WHERE post_id = ?");
    $singlePost->bind_param('i', $post_id);
    $singlePost->execute();

    $singlePost->bind_result($post_id, $post_author, $post_title, $post_content, $date_posted);

    $result_values = array();
    while($singlePost->fetch()){
        $result_values = array($post_id, $post_author, $post_title, $post_content, $date_posted);
    }
    return $result_values;
}

function returnHeader($title, $post_date,$post_author){

    return "<h1>".$title."</h1>
            <span class='meta'>Posted by ".$post_author."
               on ".$post_date."</span>";
}

function returnBody($post_content){
    $content_arr = array(explode(".", $post_content));
    $body = "";

    for($i=0; $i< count($content_arr); $i++){
         $body .= "<p>".$content_arr[$i][0]."</p>";
    }
    return $body;
}
?>


