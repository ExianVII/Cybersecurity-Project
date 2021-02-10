<?php

if(empty($_POST['exampleUsername'])      ||
    empty($_POST['exampleInputEmail1'])     ||
    empty($_POST['exampleInputPassword1'])     ||
    empty($_POST['exampleInputPassword2'])   ||
    !filter_var($_POST['exampleInputEmail1'],FILTER_VALIDATE_EMAIL))
    {
    echo "No arguments Provided!";
    return false;
    }
else
{
    $username = strip_tags(htmlspecialchars($_POST['exampleUsername']));
    $email_address = strip_tags(htmlspecialchars($_POST['exampleInputEmail1']));
    $password = strip_tags(htmlspecialchars($_POST['exampleInputPassword1']));
    $confirmedPassword = strip_tags(htmlspecialchars($_POST['exampleInputEmail1']));

    if (strcmp($password, $confirmedPassword) == 0)
    {
        echo "The data sent is: $username, $email_address, $password $confirmedPassword";
        return true;
    }
    else
     {
        echo "Passwords don't match";
        return false;
     }
}
?>
