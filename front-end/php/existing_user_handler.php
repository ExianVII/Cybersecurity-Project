<?php
session_start();
require('db_mysqli.php');

//In case the JQuery validations for empty fields fail
if(empty($_POST['email']) || empty($_POST['password']))
{
    $_SESSION['error'] = "You did not fill all the fields. Please check and try again";
    header('Sign up.php');
}

else {

    $email = strip_tags(htmlspecialchars($_POST['email']));
    $password = strip_tags(htmlspecialchars($_POST['password']));

    //In case the JQuery validations for data non-conformance fail.
    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        $_SESSION['error'] = "Invalid email format";
        header('location:Login.php');
    }

    else if(strlen($password) < 10) {
        $_SESSION['error'] = "Passwords must be at least 10 characters long";
        header('location:Login.php');
    }

    else {

        //verify email exists
        $sqlVerification = "SELECT email FROM users WHERE email=?";
        if(isset($db)) {
            $verificationStmt = prepared_query($db, $sqlVerification, [$email]);
            $existingRecords = $verificationStmt->get_result()->fetch_all();

            if(count($existingRecords) > 0)
            {
                //retrieve the password hash.
                $sqlSelectPassword = "SELECT password FROM users WHERE email=?";
                $password_hash = mysqli_fetch_array(prepared_query($db, $sqlSelectPassword, [$email])->get_result());

                //var_dump($hashStatement);
                if(password_verify($password, $password_hash[0]))
                {
                    $sqlSelectUsername = "SELECT username FROM users WHERE email=?";
                    $username = mysqli_fetch_array(prepared_query($db, $sqlSelectUsername, [$email])->get_result());
                    //echo $username[0];
                    $_SESSION['user'] = $username[0];
                    //echo $_SESSION['user'];
                    header('location:../index.php');
                }
                else {
                    $_SESSION['error'] = "Passwords do not match";
                    header('location../Login.php');
                }

            }
        }

        else
        {
            echo "Could not resolve database connection";
        }
    }
}

?>
