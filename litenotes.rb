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
        t.string :tag
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
  class AddX
    def post(content)
      @note = Note.new(:content=>content);
      @note.save
      content.scan(/\#\w+/).each do |tag|
        Tag.new(:tag=>tag).save unless Tag.find_by_tag(tag)
      end
      redirect Index
    end
  end
  class TagX
    def get(tag)
      @notes = Note.find(:all, :conditions => ['content LIKE ?','%' + tag + '%']).reverse
      
      @tags = Tag.all
      render:index
    end
  end
end

module Litenotes::Views
  def layout
    html do
      head do
        title { "Litenotes" }
      end
      body { self << yield }
    end
  end
  
  def index
    h2 {"Notes"}
    dl do
      @notes.each do |note|
        dt note.created_at
        dd note.content
      end
    end
    h2 {"Tags"}
    ul do
      @tags.each do |tag|
        li do
          a tag.tag, :href => R(TagX, tag.tag)
        end
      end
    end
  end
end

def Litenotes.create
  Litenotes::Models.create_schema
end