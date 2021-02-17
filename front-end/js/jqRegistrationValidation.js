$().ready(function() {
    $("#registerButton").hide();
    $('input').change(function (e) {
        if ($("#username").valid() && $("#email").valid() &&
            $("#password").valid() && $("#password_confirm").valid()) {
            $("#registerButton").show();
        }
    });

        $("#registration").validate({

            rules: {
                username: {
                    required: true,
                    minlength: 7
                },
                email: {
                    required: true,
                    email: true
                },
                password: {
                    required: true,
                    minlength: 10,
                    passwordStrong: true
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
                    minlength: "Your username must consist of at least 7 characters"
                },
                email: {
                    required: "Please enter an email",
                    email: "Invalid email format"
                },
                password: {
                    required: "Please enter a password",
                    minlength: "Your password must consist of at least 10 characters",
                    passwordStrong: "Your password must consist of at least one number, one low-case character, one upper case " +
                        "character and one special character."
                },
                password_confirm: {
                    required: "Please fill this field",
                    minlength: "Your password must consist of at least 10 characters",
                    equalTo: "Passwords do not match"
                }
            }
        })
})
