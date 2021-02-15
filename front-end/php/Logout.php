<?php
session_start();
require 'db_mysqli.php';

if(isset($_SESSION['user']))
{
    unset($_SESSION['user']);
    header('location:../index.php');
}

else
    $_SESSION['error'] = "Access denied. Sign in or sign up to access this page";
    header('location:../Login.php');
?>