$().ready(function() {
    $("#signinButton").hide();

    $('input').change(function(e) {
        if($("#email").valid() && $("#password").valid())
        {
            $("#signinButton").show();
        }
    });

    $("#signin").validate ({

        rules: {
            email: {
                required: true,
                email: true
            },
            password: {
                required: true,
                minlength: 10
            }
        },
        messages: {
            email: {
                required: "Please enter your email",
                email: "Invalid email format"
            },
            password: {
                required: "Please enter a password",
                minlength: "Your password must consist of at least 10 characters"
            }

        }
    })
});