mutter is sort of a personal twitter. with a corny name. for tweets that you want to keep to yourself.

Basically, I tried various note-taking applications and felt like a lot were buggy and/or prone to feature bloat. I was tweeting to someone about it and it occurred to me that it'd be nice to have something like twitter for capturing my notes. 

I wanted something that:

* works basically like twitter, because I use twitter a lot
* is private/runs on my own server
* has a Mac Dashboard widget for conveniently adding notes
* has hashtags (with auto-suggest) and search
* has todos (tag a note #todo and it magically has a checkbox)

This all pretty much works already, although the dashboard widget is crude. 

My wishlist:

* some smarts in the tagging. For example, if I have a tag called #foo and all the notes tagged #foo are also tagged #todo, and those #todos are all complete, it could cross out the tag.
* sorting options
* autosuggest in the dashboard widget
* ability to edit notes
* mobile UI

It uses Camping, JQuery, and Dashcode (optional). If you don't have them yet, install the camping and markaby ruby gems and then run "camping mutter.rb" from the application's folder. To use the dashboard widget, build it from within Dashcode then run File > Deploy and click "Deploy to Dashboard." Note that I am still running Snow Leopard for now and haven't tested the dashboard widget with a later OS or DashCode yet. It's simple enough that I don't see any reason why it wouldn't work, though.

It's my first Ruby/Camping project so feel free to offer feedback. For now, it uses ActiveRecord. 

Sorry, but you're not limited to 140 characters.
