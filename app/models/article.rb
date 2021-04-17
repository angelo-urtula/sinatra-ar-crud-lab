#Placeholder for a model

class Article < ActiveRecord::Base
    attr_accessor :title, :content
    attr_reader :id
    def initialize(title, content, id=nil)
        @id = id
        @title = title
        @content = content
    end

    def save
        if self.id
          self.update
        else
          sql = <<-SQL
            INSERT INTO articles (title, content)
            VALUES (?, ?)
          SQL
    
          DB[:conn].execute(sql, self.title, self.content)
          @id = DB[:conn].execute("SELECT last_insert_rowid() FROM articles")[0][0]
        end
      end
    
      def self.create(title:, content:)
        article = Article.new(title, content)
        article.save
        article
      end
    
      def self.find_by_id(id)
        sql = "SELECT * FROM articles WHERE id = ?"
        result = DB[:conn].execute(sql, id)[0]
        Article.new(result[0], result[1], result[2])
      end
    
      def update
        sql = "UPDATE articles SET title = ?, content = ? WHERE id = ?"
        DB[:conn].execute(sql, self.title, self.content, self.id)
      end

    def self.find_or_create_by(title:, content:)
        article = DB[:conn].execute("SELECT * FROM articles WHERE title = ? AND content = ?", title, content)
        if !article.empty?
          article_data = article[0]
          article = Article.new(article_data[0], article_data[1], article_data[2])
        else
          article = self.create(title: title, content: content)
        end
        article
      end 
end