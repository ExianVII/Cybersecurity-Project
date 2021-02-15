<?php

//Take the text from the content and cut it like this, more or less:
//$out = strlen($in) > 50 ? substr($in,0,50)."..." : $in;

//In theory, the command above will make the post contents(which is super long) have only about 50 characters
//for the lead to display on the main page.

function displayPostPreview($post_id, $post_title, $post_content, $user_id, $post_date){

    return "<div class='post-preview'>
                      <a href='post.php?post=".$post_id."'>
                        <h2 class='post-title'>".$post_title."</h2>
                        <h3 class='post-subtitle'>".$post_content."
                        </h3>
                      </a>
                      <p class='post-meta'>Posted by
                        <a href='#'>". $user_id ."</a>
                        on ". $post_date."</p>
                    </div><hr>";
}

?>
