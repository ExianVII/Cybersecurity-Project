<?php
session_start();
require 'db_mysqli.php';

if(empty($_POST['username'])      ||
    empty($_POST['email'])     ||
    empty($_POST['password'])     ||
    empty($_POST['password_confirm']) )
    {
        $_SESSION['error'] = "You did not fill all the fields. Please check and try again";
        header('Sign up.php');
    }
else {
    $username = strip_tags(htmlspecialchars($_POST['username']));
    $email_address = strip_tags(htmlspecialchars($_POST['email']));
    $password = strip_tags(htmlspecialchars($_POST['password']));
    $confirmedPassword = strip_tags(htmlspecialchars($_POST['password_confirm']));

    if (strlen($username) < 3) {
        $_SESSION['error'] = "The username is too short.";
        header('Sign up.php');
    } else if (!filter_var($email_address, FILTER_VALIDATE_EMAIL)) {
        $_SESSION['error'] = "Invalid email format";
        header('Sign up.php');
    } else if (strlen($password) < 10 || strlen($confirmedPassword) < 10) {
        $_SESSION['error'] = "Passwords must be at least 10 characters long";
        header('Sign up.php');
    } else if (strcmp($password, $confirmedPassword) != 0) {
        $_SESSION['error'] = "Passwords don't match";
        header('Sign up.php');
    }
    else {
        //verify user and email are unique
             $sqlVerification = "SELECT email FROM users WHERE email=?";
        if (isset($db)) {
            //echo $Email_address;
            $verificationStmt = prepared_query($db, $sqlVerification, [$email_address]);

            $existingRecords = $verificationStmt->get_result()->fetch_all();

            if(count($existingRecords) > 0)
            {
                $_SESSION['email'] = $email_address;
                $_SESSION['error'] = "A user with the same email already exists";
                header('location:../Sign up.php');
            }

            else
            {
                $sqlInsert = "INSERT INTO users (email, username, password) VALUES (?, ? ,?)";
                prepared_query($db, $sqlInsert, [$email_address, $username, $password]);
                $_SESSION['creationSuccess'] = "Congratulations! You've been successfully registered!";
                header('location:../Login.php');
            }

        }
        else {
            echo "db is null";
        }
    }
}
?>
