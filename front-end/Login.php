<?php session_start();
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <meta name="description" content="">
    <meta name="author" content="">

    <title>Login</title>

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
                    <a class="nav-link" href="post.html">Sample Post</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="contact.html">Contact</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="Sign%20up.php">Sign up</a>
                </li>
            </ul>
        </div>
    </div>
</nav>
<header class="masthead" style="background-color: black">
    <div class="overlay"></div>
    <div class="container">
        <div class="row">
            <div class="col-lg-8 col-md-10 mx-auto">
                <div class="site-header" style="padding: 50px">
                </div>
            </div>
        </div>
    </div>
</header>
<div class="container row align-items-center">
    <div class=" jumbotron col-sm-12 align-self-center" style="margin-top:5%; margin-left: 15%;">
        <h1 class="text-center">Login</h1>
        <form action="php/existing_user_handler.php" id="registration" class="cmxform" name="signin" method="post" autocomplete="off">
            <div class = "form-group">
                <p>
                    <label for="email" >Email</label>
                    <input type="email" class="form-control" id="email" name="email"
                           placeholder="Email"  required data-validation-required-message="Please enter your email"
                           data-/>
                </p>
            </div>
            <div class="form-group">
                <p>
                    <label for="password">Password</label>
                    <input type="password" class="form-control" id="password" name="password" placeholder="Password" required data-validation-required-message="Please enter your password">
                </p>
            </div>
            <div class="form-group">
                <p>New to this blog? No problem. <a href="Sign%20up.php">Sign up</a></p>
                <p id="backendError" style="color: red">
                    <?php
                    if(isset($_SESSION['error'])) {
                        echo $_SESSION['error'];
                        unset($_SESSION['error']);
                    }
                    ?>
                </p>
                <p id="registrationSuccess" style="color: #1c7430">
                    <?php
                    if(isset($_SESSION['creationSuccess'])) {
                        echo $_SESSION['creationSuccess'];
                        unset($_SESSION['creationSuccess']);
                    }
                    ?>
                </p>
            </div>
            <div class="form-group">
                <button type="submit" class="btn btn-primary" id="signinButton" name="registerButton">Submit</button>
            </div>
        </form>
    </div>
</div>
<!-- Bootstrap core JavaScript -->
<script src="vendor/jquery/jquery.min.js"></script>
<script src="vendor/bootstrap/js/bootstrap.bundle.min.js"></script>

<!-- Sign up form JavaScript -->
<script src="js/jqBootstrapValidation.js"></script>

<!-- Custom scripts for this template -->
<script src="js/clean-blog.min.js"></script>
<script src="js/jsFormValidation.js"></script>
<script src="js/jqLoginValidation.js"></script>
</body>
</html>
