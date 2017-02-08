require_relative 'user'

class QuestionFollow

  attr_accessor :question_id, :follower_id

  def self.all
    data = QuestionsDatabase.instance.execute("SELECT * FROM question_follows")
    data.map { |datum| QuestionFollow.new(datum) }
  end

  def self.find_by_id(id)
    question_follow = QuestionsDatabase.instance.execute(<<-SQL, id)

      SELECT *
      FROM question_follows
      WHERE id = ?
    SQL

    return nil unless question_follow.length > 0

    QuestionFollow.new(question_follow.first)
  end

  def self.followers_for_question_id(question_id)
    #question instance execute
    #join questions and questionfollow on question.id = question_follows.question_id
    #return array of user objects
    user_array = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT users.*
      FROM users
      JOIN question_follows ON users.id = question_follows.follower_id
      WHERE question_follows.question_id = ?
    SQL

    user_array.map { |user_hash| User.new(user_hash) }
  end

  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @follower_id = options['follower_id']
  end

  def create
    raise "#{self} is in db" if @id
    QuestionsDatabase.instance.execute(<<-SQL, @question_id, @follower_id)
      INSERT INTO question_follows (question_id, follower_id)
      VALUES (?, ?)
    SQL

    @id = QuestionsDatabase.instance.last_insert_row_id
  end

  def update
    raise "#{self} not in database" unless @id
    QuestionsDatabase.instance.execute(<<-SQL, @question_id, @follower_id, @id)
      UPDATE question_follows
      SET question_id = ?, follower_id = ?
      WHERE id = ?
    SQL
  end
end
