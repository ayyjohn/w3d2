require_relative 'user'
require_relative 'reply'

class Question

  attr_accessor :title, :body, :asker_id

  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM questions")
    data.map { |datum| Question.new(datum) }
  end

  def self.find_by_id(id)
    question = QuestionsDatabase.instance.execute(<<-SQL, id)

      SELECT *
      FROM questions
      WHERE id = ?
    SQL

    return nil unless question.length > 0
    Question.new(question.first)
  end

  def self.find_by_asker_id(asker_id)
    question = QuestionsDatabase.instance.execute(<<-SQL, asker_id)

      SELECT *
      FROM questions
      WHERE asker_id = ?

    SQL

    return nil unless question.length > 0
    Question.new(question.first)
  end

  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @asker_id = options['asker_id']
  end

  def followers
    QuestionFollow.followers_for_question_id(@id)
  end

  def author
    User.find_by_id(@asker_id)
  end

  def replies
    Reply.find_by_subject_question_id(@id)
  end

  def create
    raise "#{self} is in db" if @id
    QuestionsDatabase.instance.execute(<<-SQL, @title, @body, @asker_id)
      INSERT INTO questions (title, body, asker_id)
      VALUES (?, ?, ?)
    SQL

    @id = QuestionsDatabase.instance.last_insert_row_id
  end

  def update
    raise "#{self} not in database" unless @id
    QuestionsDatabase.instance.execute(<<-SQL, @title, @body, @asker_id, @id)
      UPDATE questions
      SET title = ?, body = ?, asker_id = ?
      WHERE id = ?
    SQL
  end
end
