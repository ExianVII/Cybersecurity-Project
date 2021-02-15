<?php session_start(); ?>
<!DOCTYPE html>
<html lang="en">
<?php include 'php/db_connect.php';
 include 'php/post-preview-indexpage.php';

 $conn = ConnectToDB();
 $notFound = "<br/>";
 $connection_state = false;

 if($conn->connect_error){
  $connection_state = true;
    $notFound = "<div class='text-center' style='width:100%;background-color:darkRed;
                    color:white'>
                    <p>No posts were found at the moment!</p>
                    </div>";
 }
?>

<head>

  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
  <meta name="description" content="">
  <meta name="author" content="">

  <title>Clean Blog - Start Bootstrap Theme</title>

  <!-- Bootstrap core CSS -->
  <link href="vendor/bootstrap/css/bootstrap.min.css" rel="stylesheet">

  <!-- Custom fonts for this template -->
  <link href="vendor/fontawesome-free/css/all.min.css" rel="stylesheet" type="text/css">
  <link href='https://fonts.googleapis.com/css?family=Lora:400,700,400italic,700italic' rel='stylesheet' type='text/css'>
  <link href='https://fonts.googleapis.com/css?family=Open+Sans:300italic,400italic,600italic,700italic,800italic,400,300,600,700,800' rel='stylesheet' type='text/css'>

  <!-- Custom styles for this template -->
  <link href="css/clean-blog.min.css" rel="stylesheet">

</head>

<body>

<!-- Navigation -->
<nav class="navbar navbar-expand-lg navbar-light fixed-top" id="mainNav">
  <div class="container">
    <a class="navbar-brand" href="index.php">Start Bootstrap</a>
    <button class="navbar-toggler navbar-toggler-right" type="button" data-toggle="collapse" data-target="#navbarResponsive" aria-controls="navbarResponsive" aria-expanded="false" aria-label="Toggle navigation">
      Menu
      <i class="fas fa-bars"></i>
    </button>
    <div class="collapse navbar-collapse" id="navbarResponsive">
      <ul class="navbar-nav ml-auto">
        <li class="nav-item">
          <a class="nav-link" href="index.php">Home</a>
        </li>
        <li class="nav-item">
          <a class="nav-link" href="about.html">About</a>
        </li>
        <li class="nav-item">
          <a class="nav-link" href="contact.html">Contact</a>
        </li>
          <!-- If user is logged in, show this.-!-->
          <?php
          if(isset($_SESSION['user']))
          {
              echo '
                <li class="nav-item dropdown" >
                  <a class="nav-link dropdown-toggle" href = "#" role="button"
                  data-toggle="dropdown" aria-haspopup="true" aria-expanded="false" >
                  Welcome back, '.$_SESSION['user'].' </a >
                 <div class="dropdown-menu" aria-labelledby="navbarDropdown">
                    <a class="nav-link" href = "newBlogForm.php" > new Blog Entry </a >
                    <a class="nav-link" href = "updateBlogForm.php" > Update an old entry </a >
                    <a class="nav-link" href = "php/Logout.php" > Logout </a >
                </div>
                </li>';
          }
          else {

              echo '<!--user is not logged in-->
                    <li class="nav-item">
                    <a class="nav-link" href="contact.html">Contact</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="Sign%20up.php">Sign up</a>
                </li>';
          }
          ?>
      </ul>
    </div>
  </div>
</nav>

  <!-- Page Header -->
  <header class="masthead" style="background-image: url('img/home-bg.jpg')">
    <div class="overlay"></div>
    <div class="container">
      <div class="row">
        <div class="col-lg-8 col-md-10 mx-auto">
          <div class="site-heading">
            <h1>Clean Blog</h1>
            <span class="subheading">A Blog Theme by Start Bootstrap</span>
          </div>
        </div>
      </div>
    </div>
  </header>

    <?php

    echo $notFound;

        //Submission message for the blog
        if(isset($_GET["success"])){
            if($_GET["success"] == "true")
            {
                echo "<div class='text-center' style='width:100%;background-color:green;
                color:white'>
                <p>Cool! Your last blog was successfully submitted!</p>
                </div>";
            }
        }
    ?>

  <!-- Main Content -->
  <div class="container">
    <div class="row">
      <div class="col-lg-8 col-md-10 mx-auto">

      <?php
           if(!$connection_state){
                $sql_query = "SELECT * from posts ORDER BY post_date";
                $posts = $conn->prepare($sql_query);
                $posts->execute();

                $posts->bind_result($id, $user_id, $post_title, $post_content, $post_date);

                while($posts->fetch()){
                    $post_content_preview = substr($post_content, 0, 20);
                    echo displayPostPreview($id, $post_title, $post_content_preview, $user_id, $post_date);
                }
           }
      ?>
        <!-- Pager -->
        <div class="clearfix">
          <a class="btn btn-primary float-right" href="#">Older Posts &rarr;</a>
        </div>
      </div>
    </div>
  </div>

  <hr>

  <!-- Footer -->
  <footer>
    <div class="container">
      <div class="row">
        <div class="col-lg-8 col-md-10 mx-auto">
          <ul class="list-inline text-center">
            <li class="list-inline-item">
              <a href="#">
                <span class="fa-stack fa-lg">
                  <i class="fas fa-circle fa-stack-2x"></i>
                  <i class="fab fa-twitter fa-stack-1x fa-inverse"></i>
                </span>
              </a>
            </li>
            <li class="list-inline-item">
              <a href="#">
                <span class="fa-stack fa-lg">
                  <i class="fas fa-circle fa-stack-2x"></i>
                  <i class="fab fa-facebook-f fa-stack-1x fa-inverse"></i>
                </span>
              </a>
            </li>
            <li class="list-inline-item">
              <a href="#">
                <span class="fa-stack fa-lg">
                  <i class="fas fa-circle fa-stack-2x"></i>
                  <i class="fab fa-github fa-stack-1x fa-inverse"></i>
                </span>
              </a>
            </li>
          </ul>
          <p class="copyright text-muted">Copyright &copy; Maria Carolina, Alexandra Adelaida 2021</p>
        </div>
      </div>
    </div>
  </footer>

  <!-- Bootstrap core JavaScript -->
  <script src="vendor/jquery/jquery.min.js"></script>
  <script src="vendor/bootstrap/js/bootstrap.bundle.min.js"></script>

  <!-- Custom scripts for this template -->
  <script src="js/clean-blog.min.js"></script>

</body>

</html>
