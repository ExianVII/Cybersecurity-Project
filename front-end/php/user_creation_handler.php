<?php
require 'db_mysqli.php';

if(empty($_POST['username'])      ||
    empty($_POST['email'])     ||
    empty($_POST['password'])     ||
    empty($_POST['password_confirm']) )
    {
        $_SESSION['error'] = "You did not fill all the fields. Please check and try again";
        header('Sign up.html');
    }
else {
    $Username = strip_tags(htmlspecialchars($_POST['username']));
    $Email_address = strip_tags(htmlspecialchars($_POST['email']));
    $Password = strip_tags(htmlspecialchars($_POST['password']));
    $confirmedPassword = strip_tags(htmlspecialchars($_POST['password_confirm']));

    if (strlen($Username) < 3) {
        $_SESSION['error'] = "The username is too short.";
        header('Sign up.html');
    } else if (!filter_var($_POST['email'], FILTER_VALIDATE_EMAIL)) {
        $_SESSION['error'] = "Invalid email format";
        header('Sign up.html');
    } else if (strlen($Password) < 10 || strlen($confirmedPassword) < 10) {
        $_SESSION['error'] = "Passwords must be at least 10 characters long";
        header('Sign up.html');
    } else if (strcmp($Password, $confirmedPassword) != 0) {
        $_SESSION['error'] = "Passwords don't match";
        header('Sign up.html');
    }
    else {
        //verify user and email are unique
             $sqlVerification = "SELECT * FROM users WHERE email=?";
        if (isset($db)) {

            $verificationStmt = prepared_query($db, $sqlVerification, [$Email_address]);
            echo $Email_address;
            //var_dump($verificationStmt);

            var_dump($verificationStmt->get_result());

        }
        else{
            echo "db is null";
        }


           /*  if($verificationSql->num_rows() > 0)
             {
                 echo "gets here";
                 $_SESSION['error'] = "A user with the same email already exists";
                 header('Sign up.html');
             }*/

             /*else
             {
                 //echo "doesn't detect the error";
                $insertData = "INSERT INTO users(id, email, username, password)
                    values(null, '$email_address', '$username', '$password')";
                //$result =
             }*/

         }
}
?>
