mutter is sort of a personal twitter. with a corny name. 

In playing around with various note-taking applications, I felt like the ones I tried were buggy and prone to feature bloat. I was tweeting to someone about it and it occurred to me that it'd be nice to have something like twitter for capturing my notes. 

I wanted something that:

* works basically like twitter, because I use twitter a lot
* is private
* runs on my own server
* has a Mac Dashboard widget for conveniently adding notes
* has hashtags (with auto-suggest) and search
* has todos (tag a note #todo and it magically has a checkbox)

This all pretty much works already, although the dashboard widget does not yet have auto-suggest. The code is there but it needs to be styled in a way that works in the widget. 

My wishlist:

* some smarts in the tagging. For example, if I have a tag called #foo and all the notes tagged #foo are also tagged #todo, and those #todos are all complete, it could cross out the tag. 
* ability to delete notes
* mobile UI

It uses Camping, JQuery, and Dashcode (optional). It's my first Ruby/Camping project so feel free to offer feedback. For now, it uses ActiveRecord. 

Sorry, but you're not limited to 140 characters.