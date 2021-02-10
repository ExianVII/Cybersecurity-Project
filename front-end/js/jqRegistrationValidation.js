$().ready(function()
{
    $("#registration").validate({

        rules: {
            username: {
                required: true,
                minlength:3
            },
            email: {
                required: true,
                email: true
            },
            password: {
                required: true,
                minlength: 10
            },
            password_confirm: {
                required: true,
                minlength: 10,
                equalTo: "#password"
            }
        },
        messages: {
            username: {
                required: "Please enter a username",
                minlength: "Your username must consist of at least 3 characters"
            },
            email: {
                required: "Please enter an email",
                email: "Invalid email format"
            },
            password: {
              required: "Please enter a password",
              minlength: "Your password must consist of at least 10 characters"
            },
            password_confirm: {
                required: "Please fill this field",
                minlength: "Your password must consist of at least 10 characters",
                equalTo: "Passwords do not match"
            }
        }
    });

})
