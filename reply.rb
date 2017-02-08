class Reply

  attr_accessor :body, :parent_reply_id, :subject_question_id, :author_id

  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM replies")
    data.map { |datum| Reply.new(datum) }
  end

  def self.find_by_id(id)
    reply = QuestionsDatabase.instance.execute(<<-SQL, id)

    SELECT *
    FROM replies
    WHERE id = ?
  SQL

    return nil unless reply.length > 0

    Reply.new(reply.first)
  end

  def self.find_by_author_id(author_id)
    reply = QuestionsDatabase.instance.execute(<<-SQL, author_id)

    SELECT *
    FROM replies
    WHERE author_id = ?
  SQL

    return nil unless reply.length > 0

    Reply.new(reply.first)
  end

  def self.find_by_subject_question_id(subject_question_id)
    reply = QuestionsDatabase.instance.execute(<<-SQL, subject_question_id)

    SELECT *
    FROM replies
    WHERE subject_question_id = ?
  SQL

    return nil unless reply.length > 0

    Reply.new(reply.first)
  end

  def initialize(options)
    @id = options['id']
    @body = options['body']
    @parent_reply_id = options['parent_reply_id']
    @subject_question_id = options['subject_question_id']
    @author_id = options['author_id']
  end

  def author
    User.find_by_id(@author_id)
  end

  def question
    Question.find_by_id(@subject_question_id)
  end

  def parent_reply
    Reply.find_by_id(@parent_reply_id)
  end

  def child_replies
    Reply.find_by_id(Reply.parent_reply(@id))
  end

  def create
    raise "#{self} is in db" if @id
    QuestionsDatabase.instance.execute(<<-SQL, @body, @parent_reply_id, @subject_question_id, @author_id)
      INSERT INTO replies (body, parent_reply_id, subject_question_id, author_id)
      VALUES (?, ?, ?, ?)
    SQL

    @id = QuestionsDatabase.instance.last_insert_row_id
  end

  def update
    raise "#{self} not in database" unless @id
    QuestionsDatabase.instance.execute(<<-SQL, @body, @parent_reply_id, @subject_question_id, @author_id, @id)
      UPDATE replies
      SET body = ?, parent_reply_id = ?, subject_question_id = ?, author_id = ?
      WHERE id = ?
    SQL
  end
end
