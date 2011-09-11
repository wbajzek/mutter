$(function() {
    $('textarea').autocomplete({
        source: function(request, response) {
            var parsed = request.term.split("#");
            if (parsed.length > 1 && parsed[parsed.length - 1].length > 0) {
                $.ajax({
                    url: "/tags?term=%23" + parsed[parsed.length - 1],
                    complete: function(data) {response(eval(data.responseText));},
                });
            }
        },
        select: function (event) {
            event.preventDefault();
            
            var parsed = $(this).val().split("#");
            parsed[parsed.length-1] = event.srcElement.text.substring(1);
            $(this).val(parsed.join("#"));
        }
    });
})
