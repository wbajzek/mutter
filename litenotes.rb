Camping.goes :Litenotes

module Litenotes::Models
  class Note < Base
  end
  class Tag < Base
  end

  class CreateNotes < V 1.0
    def self.up
      create_table Note.table_name do |t|
        t.string :content
        t.timestamps
      end
    end
    def self.down
      drop_table Note.table_name
    end
  end

  class CreateTags < V 1.1
    def self.up
      create_table Tag.table_name do |t|
        t.string :name
      end
    end
    def self.down
      drop_table Tag.table_name
    end
  end
end

module Litenotes::Controllers
  class Index < R '/'
    def get
      @notes = Note.all.reverse
      @tags = Tag.all
      render :index
    end
  end
  class NoteX < R '/note/add'
    def post
      @note = Note.new;
      @note.content = @input.content
      @note.save
      @input.content.scan(/\#\w+/).each do |tag|
        Tag.new(:name=>tag).save unless Tag.find_by_name(tag)
      end
      redirect Index
    end
  end
  class TagX
    def get(tag)
      @notes = Note.find(:all, :conditions => ['content LIKE ?','%' + tag + '%']).reverse      
      @tags = Tag.all
      render :index
    end
  end
  class Tags
    def get
      @headers['Content-Type'] = "application/json"
      @tags = Tag.find(:all, :conditions => ['name LIKE ?', @input.term + '%'])
      tag_names = []
      @tags.each do |tag|
        tag_names.push '"' + tag.name + '"'
      end 
      mab {  "[ " + tag_names.join(',') + "];" }
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

module Litenotes::Views
  def layout
    html do
      head do
        title { "Litenotes" }
        link :href=>"/static/litenotes.css", :type=>"text/css", :rel=>"stylesheet"
        script nil,:src=>"/static/jquery-1.6.3.min.js"
        script nil,:src=>"/static/jquery-ui-1.8.16.custom.min.js"
        script nil,:src=>"/static/litenotes.js"        
      end
      body { self << yield }
    end
  end
  
  def index
    h2 { "Notes" }
    ul.notes do
      li.newnote do
        form :action => R(NoteX), :method => :post do
          textarea "", :id => :content, :name => :content
          label :for => :content
          input :type => :submit, :value => 'Save'
        end 
      end
      @notes.each do |note|
        li do
          span note.created_at
          p note.content
        end
      end
    end
    h2.tags {"Tags"}
    ul.tags do
      li {a "None", :href => "/"}
      @tags.each do |tag|
        li do
          a tag.name, :href => R(TagX, tag.name)
        end
      end
    end
  end
end

def Litenotes.create 
  Litenotes::Models.create_schema
end


