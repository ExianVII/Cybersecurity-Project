<?php
session_start();
include('post_display.php');

if(!isset($_SESSION['user'])) {
    $_SESSION['error'] = "Access denied. Sign in or sign up to access this page";
    header('location:../front-end/Login.php');
}
if(isset($_GET['post'])){
    $post_info = getSinglePost($post_id);
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <meta name="description" content="">
    <meta name="author" content="">

    <title>Update an old blog</title>

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
                ?>
            </ul>
        </div>
    </div>
</nav>

<!-- Page Header -->
<header class="masthead" style="background-image: url('img/laptop-bg.jpg')">
    <div class="overlay"></div>
    <div class="container">
        <div class="row">
            <div class="col-lg-8 col-md-10 mx-auto">
                <div class="page-heading">
                    <h1>Update your old blog post</h1>
                    <span class="subheading">Had a typo? You suddenly changed your mind? Repair your mistakes here</span>
                </div>
            </div>
        </div>
    </div>
</header>

<!-- Main Content -->
<div class="container">
    <div class="row">
        <div class="col-lg-8 col-md-10 mx-auto">
            <p>Update the values on this form and submit it to save the changes.</p>

            <form name="sentMessage" id="blogUpdateForm" method="POST" action="php/UpdateBlog.php">
                <div class="control-group">
                    <div class="form-group floating-label-form-group controls">
                        <label>Post Name</label>
                        <input type="text" class="form-control" placeholder="Name" id="uPostName" name="uPostName"
                               required data-validation-required-message="Please enter a name."
                               value="<?php echo strlen($post_info[2]) > 0 ? $post_info[2] : '' ?>">
                        <p class="help-block text-danger"></p>
                    </div>
                </div>
                <div class="control-group">
                    <div class="form-group floating-label-form-group controls">
                        <label>Message</label>
                        <textarea rows="5" class="form-control" placeholder="Message" id="uPostContent" name="uPostContent"
                                  required data-validation-required-message="Please enter a message.">
                                  <?php echo strlen($post_info[3]) > 0 ? $post_info[3] : '' ?>
                                  </textarea>
                        <p class="help-block text-danger"></p>
                    </div>
                </div>
                <br>
                <input type="hidden" name="postToUpdate" value="<?php echo $_GET['post'] ?>"/>
                <div class="form-group">
                    <button type="submit" class="btn btn-primary" id="updatePostBtn">Send</button>
                </div>
            </form>
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
                <p class="copyright text-muted">Copyright &copy; Your Website 2019</p>
            </div>
        </div>
    </div>
</footer>

<!-- Bootstrap core JavaScript -->
<script src="vendor/jquery/jquery.min.js"></script>
<script src="vendor/bootstrap/js/bootstrap.bundle.min.js"></script>

<!-- Contact Form JavaScript -->
<script src="js/jqBootstrapValidation.js"></script>
<script src="js/contact_me.js"></script>

<!-- Custom scripts for this template -->
<script src="js/clean-blog.min.js"></script>

</body>
</html>
