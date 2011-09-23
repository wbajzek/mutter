$(function() {
    
    // refresh the tags list (when adding, deleting, etc)
    function refreshTags() { $('ul.tags').load("/tag/list"); }
    
    // Autocomplete
    $('textarea').autocomplete({
        source: function(request, response) {
            var baseUrl = "";
            if (serverUrl)
                baseUrl = serverUrl;
                
            var parsed = request.term.split("#");
            if (parsed.length > 1 && parsed[parsed.length - 1].length > 0) {
                $.ajax({
                    url: baseUrl + "/suggest?term=%23" + parsed[parsed.length - 1],
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
    $('ul.notes li input[type="checkbox"]').live('click',function() {
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

    $('form.newnote').submit(function(event) {
        event.preventDefault();
        var $form = $(this),
            note = $form.find( 'textarea' ).val(),
            url = $form.attr( 'action' );
        $.post(url, { 'content':note },
            function(data) {                 
                $('li.newnote').after(data); 
                $('li.newnote').next().find('a.delete').bind('click',deleteHandler);
                $('li.newnote textarea').val("");
                refreshTags();
            }
        );        
    });
    
    deleteHandler = function(event) {
        event.preventDefault();
        if (confirm("Delete this note?")) {
            var note = $(this).closest("li");
            $.ajax({
                type:"post",
                url: $(this).attr("href"),
                success: function() { note.fadeOut(); refreshTags(); },
            });
        }
    };
    
    $('a.delete').bind('click',deleteHandler);
    
    
    // filtering
    $('ul.notes input.todo').closest('li').addClass('todo');
    $('a.todo_filter').click(function() {
        $('ul.notes > :not(".todo,.newnote")').hide();
        $('ul.notes > .todo, ul.notes > .newnote').show();
    })
    $('a.done_filter').click(function() { $('ul.notes > :not(".done,.newnote")').hide(); })
    $('a.no_filter').click(function() {  $('ul.notes li').show();  })
    
    // searching
    $('input#search').autocomplete({
        source: function(request, response) {
            var baseUrl = "";
            if (serverUrl)
                baseUrl = serverUrl;

        
            $.ajax({
                url: baseUrl + "/search/ajax/" + request.term,
                complete: function(data) {  
                    $('ul.notes li').not('.newnote').remove();
                    $('ul.notes').append(data.responseText);
                },
            });
        },
    })
    
})
