<?php
function displayPostPreview($post_id, $post_title, $post_content, $user_id, $post_date){

    $post_preview = "<div class='post-preview'>
                      <a href='post.php?post=".$post_id."'>
                        <h2 class='post-title'>".$post_title."</h2>
                        <h3 class='post-subtitle'>".$post_content."
                        </h3>
                      </a>
                      <p class='post-meta'>Posted by
                        <a href='#'>". $user_id ."</a>
                        on ". $post_date ."</p>";

     //Also gotta validate if the user was the author
             if(isset($_SESSION['user'])){
                $post_preview .= "<div style='width:100%'>
                                      <p class='post-meta'><a href='../front-end/updateBlogForm.php?post=".$post_id."'>
                                      Edit</a></p>
                                  </div>";
             }

    $post_preview .= "</div><hr>";

    return $post_preview;
}
?>
