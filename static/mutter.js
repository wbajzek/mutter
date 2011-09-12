$(function() {

    // Autocomplete
    $('textarea').autocomplete({
        source: function(request, response) {
            var baseUrl = "";
            if (serverUrl)
                baseUrl = serverUrl.value;
                
            var parsed = request.term.split("#");
            if (parsed.length > 1 && parsed[parsed.length - 1].length > 0) {
                $.ajax({
                    url: baseUrl + "/tags?term=%23" + parsed[parsed.length - 1],
                    complete: function(data) { response(eval(data.responseText));},
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
    
    // todo behavior
    $('ul.notes li input[type="checkbox"]').each(function() {
       if ($(this).attr("checked")=="checked")
        $(this).closest("li").addClass("done");
    });
    $('ul.notes li input[type="checkbox"]').click(function() {
        var checked = $(this).attr("checked")=="checked"?true:false;
        var ajaxUrl = "/todo/" + $(this).val() + "/" + checked;
        var checkbox = $(this);
        
        $.ajax({
            type:"post",
            url: ajaxUrl,
            success: function() {
                checkbox.closest("li").toggleClass("done");
            },
        });
    })
    
})
