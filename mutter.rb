Camping.goes :Mutter

module Mutter::Models
  class Note < Base
    has_one :todo
  end
  class Tag < Base
  end
  class Todo < Base
    belongs_to :note
  end
  class Create < V 1.0
    def self.up
      create_table Note.table_name do |t|
        t.string :content
        t.timestamps
      end
      create_table Tag.table_name do |t|
        t.string :name
      end
      create_table Todo.table_name do |t|
        t.column :done, :boolean
        t.integer :note_id
      end      
    end
    def self.down
      drop_table Note.table_name
      drop_table Tag.table_name
      drop_table Todo.table_name
    end
  end
end

module Mutter::Controllers
  # Crud methods
  class Add
    def post
      @note = Note.new;
      @note.content = @input.content
      @note.save
      @input.content.scan(/\#\w+/).each do |tag|
        Tag.new(:name=>tag).save unless Tag.find_by_name(tag)
        Todo.new(:done=>false,:note_id=>@note.id).save if tag == "#todo"
      end
      mab{ send(:one_note,@note) }
    end
  end
  class DeleteN
    def post(id)
      @note = Note.find_by_id(id)
      @note.content.scan(/\#\w+/).each do |tag|
        @notes = Note.find(:all, :conditions => ['content LIKE ?','%' + tag + '%'])
        if @notes.count == 1 then  
          tag = Tag.find_by_name(tag)
          tag.delete if tag
        end 
      end
      @note.delete
      @status = "200"
    end
  end
  # Various ways of retrieval 
  class Index
    def get
      @notes = Note.all.reverse
      @tags = Tag.find(:all,:order=>:name)
      @todos = Todo.all
      render :index
    end
  end
  class Search # called when you click the "search" button
    def get
      @notes = Note.find(:all, :conditions => ['content LIKE ?','%' + @input.search + '%']).reverse  
      @tags = Tag.find(:all,:order=>:name)
      render :index
    end
  end
  class SearchAjaxX # "live" search from the search textbox
    def get(term)
      if (term.length < 3) then
        @notes = Note.all.reverse
      else
        @notes = Note.find(:all, :conditions => ['content LIKE ?','%' + term + '%']).reverse  
      end    
      mab{ send(:list_notes) }
    end
  end
  class TodoNX
    def post(id, done)
      @todo = Todo.find_by_id(id)
      @todo.done = done
      @status = "200" if @todo.save
    end
  end
  class TagX
    def get(tag)
      @notes = Note.find(:all, :conditions => ['content LIKE ?','%' + tag + '%']).reverse      
      @this_tag = tag
      @tags = Tag.find(:all,:order=>:name)
      render :index
    end
  end
  class TagList
    def get
      @tags = Tag.find(:all,:order=>:name)
      mab{ send(:tag_list) }
    end
  end
  class Suggest
    def get
      @headers['Content-Type'] = "application/json"
      @tags = Tag.find(:all, :conditions => ['name LIKE ?', @input.term + '%'], :order => :name)
      tag_names = []
      @tags.each do |tag|
        tag_names.push '"' + tag.name + '"'
      end 
      mab {  "[ " + tag_names.join(',') + "]" }
    end
  end
  class Static < R '/static/(.+)'
    MIME_TYPES = {
      '.html' => 'text/html',
      '.css'  => 'text/css',
      '.js'   => 'text/javascript',
      '.jpg'  => 'image/jpeg',
      '.gif'  => 'image/gif'
    }
    PATH = File.expand_path(File.dirname(__FILE__))
    def get(path)
      @headers['Content-Type'] = MIME_TYPES[path[/\.\w+$/, 0]] || "text/plain" 
      unless path.include? ".." # prevent directory traversal attacks
        @headers['X-Sendfile'] = "#{PATH}/static/#{path}" 
      else
        @status = "403" 
        "403 - Invalid path" 
      end
    end
  end
end

module Mutter::Views
  def layout
    html do
      head do
        title { "Mutter" }
        link :href=>"/static/mutter.css", :type=>"text/css", :rel=>"stylesheet"
        link :href=>"/static/jquery.ui.autocomplete.css", :type=>"text/css", :rel=>"stylesheet"
        script "var serverUrl = '';"
        script nil,:src=>"/static/jquery-1.6.3.min.js"
        script nil,:src=>"/static/jquery-ui-1.8.16.custom.min.js"
        script nil,:src=>"/static/mutter.js"        
      end
      body do
        div.wrapper {self << yield}
      end
    end
  end
  
  def index
    div.wrapper do
      div.main do
        h2.notes do 
          span @this_tag if @this_tag
          "Notes" 
        end
        ul.notes do
          li.newnote do
            span.filter do 
              a.todo_filter "todo", :href => "javascript:return"
              a.done_filter "done", :href => "javascript:return"
              a.no_filter "all", :href => "javascript:return"
            end
            form.newnote :action => R(Add), :method => :post do
              textarea "", :id => :content, :name => :content
              label :for => :content
              input :type => :submit, :value => 'Save'
            end 
          end
          @todos.to_json
          list_notes
        end
      end
      div.sidebar do
        h2.search {"Search"}
        ul.search do
          li do
            form :action => R(Search), :method=>:get do
              input :type => :text, :id => :search, :value => @input.search
              input :type => :submit, :value => 'Search'
            end
          end
        end
        h2.tags { "Tags" }
        ul.tags { tag_list }
      end
    end
  end
  def one_note(note)
    li.note do 
      span note.created_at
      a.delete "X", :href => R(DeleteN, note.id)
      input.todo :type => :checkbox, :value => note.todo.id, :checked => note.todo.done if note.todo
      p { note.content.gsub(/\#\w+/) { |tag| a tag, :href => R(TagX, tag) } }
    end
  end
  def list_notes
    if @notes.count == 0 then
      li.nonotes { p "No notes were found. "}
    else
      @notes.each do |note|
        one_note(note)
      end
    end
  end
  def tag_list
    li {a "None", :href => R(Index)}
    @tags.each do |tag|
      li do
        text " "
        a tag.name, :href => R(TagX, tag.name)
      end
    end
  end
end

def Mutter.create 
  Mutter::Models.create_schema()
end


