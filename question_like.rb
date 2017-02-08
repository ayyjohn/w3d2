class QuestionLike

  attr_accessor :liker_id, :liked_question_id

    def self.all
      data = QuestionsDatabase.instance.execute("SELECT * FROM question_likes")
      data.map { |datum| QuestionLike.new(datum) }
    end

    def self.find_by_id(id)
      question_like = QuestionsDatabase.instance.execute(<<-SQL, id)

      SELECT *
      FROM question_likes
      WHERE id = ?
    SQL

      return nil unless question_like.length > 0

      QuestionLike.new(question_like.first)
    end
  def initialize(options)
    @id = options['id']
    @liker_id = options['liker_id']
    @liked_question_id = options['liked_question_id']
  end

  def create
    raise "#{self} is in db" if @id
    QuestionsDatabase.instance.execute(<<-SQL, @liker_id, @liked_question_id)
      INSERT INTO question_likes (liker_id, liked_question_id)
      VALUES (?, ?)
    SQL

    @id = QuestionsDatabase.instance.last_insert_row_id
  end

  def update
    raise "#{self} not in database" unless @id
    QuestionsDatabase.instance.execute(<<-SQL, @liker_id, @liked_question_id, @id)
      UPDATE question_likes
      SET liker_id = ?, liked_question_id = ?
      WHERE id = ?
    SQL
  end
end
