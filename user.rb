require_relative 'questionsdatabase'
require_relative 'question'
require_relative 'question_follow'
require_relative 'reply'
class User

  attr_accessor :fname, :lname

  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM users")
    data.map { |datum| User.new(datum) }
  end

  def self.find_by_id(id)
    user = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT *
      FROM users
      WHERE id = ?
    SQL
    return nil unless user.length > 0
    User.new(user.first)
  end

  def self.find_by_name(fname, lname)
    user = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)

      SELECT *
      FROM users
      WHERE fname = ? AND lname = ?

    SQL

    return nil unless user.length > 0
    User.new(user.first)
  end

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def followed_questions
    Question.find_by_id(QuestionFollow.find_by_id(@id).question_id)
  end

  def create
    raise "#{self} is in database" if @id
    QuestionsDatabase.instance.execute(<<-SQL, @fname, @lname)
      INSERT INTO users (fname, lname)
      VALUES (?, ?)
    SQL

    @id = QuestionsDatabase.instance.last_insert_row_id
  end

  def update
    raise "#{self} not in database" unless @id
    QuestionsDatabase.instance.execute(<<-SQL, @fname, @lname, @id)
      UPDATE users
      SET fname = ?, lname = ?
      WHERE id = ?
    SQL
  end

  def authored_questions
    Question.find_by_asker_id(@id)
  end

  def authored_replies
    Reply.find_by_author_id(@id)
  end

end
