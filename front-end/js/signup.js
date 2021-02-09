$(function() {

    $("#registration input").jqBootstrapValidation({
        preventSubmit: true,
        submitError: function($form, event, errors) {
            // additional error messages or events
        },
        submitSuccess: function($form, event) {
            event.preventDefault(); // prevent default submit behaviour
            // get values from FORM
            var username = $("input#exampleUsername").val();
            var email = $("input#exampleInputEmail1").val();
            var password = $("input#exampleInputPassword1").val();
            var confirmedPassword = $("input#exampleInputPassword2").val();
            var user = username; // For Success/Failure Message
            // Check for white space in name for Success/Fail message
            if (username.indexOf(' ') >= 0) {
                username = name.split(' ').slice(0, -1).join(' ');
            }
            $this = $("#registerButton");
            $this.prop("disabled", true); // Disable submit button until AJAX call is complete to prevent duplicate messages
            $.ajax({
                url: "././php/user_creation_handler.php",
                type: "POST",
                data: {
                    username: username,
                    email: email,
                    password: password,
                    confirmedPassword: confirmedPassword
                },
                cache: false,
                success: function() {
                    // Success message
                    $('#success').html("<div class='alert alert-success'>");
                    $('#success > .alert-success').html("<button type='button' class='close' data-dismiss='alert' aria-hidden='true'>&times;")
                        .append("</button>");
                    $('#success > .alert-success')
                        .append("<strong> You have been successfully registered </strong>");
                    $('#success > .alert-success')
                        .append('</div>');
                    //clear all fields
                    $('#registration').trigger("reset");
                },
                error: function() {
                    // Fail message
                    $('#success').html("<div class='alert alert-danger'>");
                    $('#success > .alert-danger').html("<button type='button' class='close' data-dismiss='alert' aria-hidden='true'>&times;")
                        .append("</button>");
                    $('#success > .alert-danger').append($("<strong>").text("Sorry " + firstName + ", there seems to be an error in the data" +
                        " you entered or the server. Please try again later."));
                    $('#success > .alert-danger').append('</div>');
                    //clear all fields
                    $('#registration').trigger("reset");
                },
                complete: function() {
                    setTimeout(function() {
                        $this.prop("disabled", false); // Re-enable submit button when AJAX call is complete
                    }, 1000);
                }
            });
        },
        filter: function() {
            return $(this).is(":visible");
        },
    });

    $("a[data-toggle=\"tab\"]").click(function(e) {
        e.preventDefault();
        $(this).tab("show");
    });

    /*When clicking on Full hide fail/success boxes */
    $('#exampleUsername').focus(function() {
        $('#success').html('');
    });

});
