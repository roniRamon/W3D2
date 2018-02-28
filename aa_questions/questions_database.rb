require 'sqlite3'
require 'singleton'
require 'byebug'


class QuestionDatabase < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end

end

class Users

  attr_accessor :fname, :lname

  def self.find_by_id(id)
    user = QuestionDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        users
      WHERE
        id = ?
    SQL
    raise "NO user found" if user.length == 0
    Users.new(user.first)
  end

  def self.find_by_name(fname, lname)
    user = QuestionDatabase.instance.execute(<<-SQL, fname, lname)
      SELECT
        *
      FROM
        users
      WHERE
        fname = ? AND lname = ?
    SQL
    raise "NO user found" if user.length == 0
    Users.new(user.first)
  end

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def authored_questions
    user = Question.find_by_author(@id)
  end

  def authored_replies
    user = Replies.find_by_user_id(@id)
  end

  def followed_questions
    QuestionFollows.followed_questions_for_user_id(@id)
  end

  def liked_questions
    QuestionLikes.liked_questions_for_user_id(@id)
  end

end

class Question

  attr_accessor :title, :body, :user_id

  def self.find_by_id(id)
    qa = QuestionDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        questions
      WHERE
        id = ?
    SQL
    raise "NO question found" if qa.length == 0
    Question.new(qa.first)
  end

  def self.find_by_author(author_id)
    qa = QuestionDatabase.instance.execute(<<-SQL, author_id)
      SELECT
        *
      FROM
        questions
      WHERE
        user_id = ?
      SQL
      raise "Author not found" if qa.length == 0
      qa.map {|elem| Question.new(elem)}
  end

  def self.most_followed(n)
    QuestionFollow.most_followed_questions(n)
  end

  def self.most_liked(n)
    QuestionLikes.most_liked_question(n)
  end


  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @user_id = options['user_id']
  end

  def author
    user = Users.find_by_id(@user_id)
    user.fname + " " + user.lname
  end

  def question_replies
    Replies.find_by_user_id(@user_id)
  end

  def followers
    QuestionFollows.followers_for_question_id(@id)
  end

  def likers
    QuestionLike.likers_for_question_id(@id)
  end

  def num_likes
    QuestionLikes.num_likes_for_question_id(@id)
  end
end

class QuestionFollows

  attr_accessor :user_id, :question_id

  def self.find_by_id(id)
    qafollow = QuestionDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        question_follows
      WHERE
        id = ?
    SQL
    raise "NO followers found" if qafollow.length == 0
    QuestionFollows.new(qafollow.first)
  end

  def self.followers_for_question_id(question_id)
    qafollow = QuestionDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        users
      JOIN question_follows qf
      ON qf.user_id = users.id
      WHERE  question_id  = ?
    SQL
    raise "NO followers found" if qafollow.length == 0
    qafollow.map { |user| Users.new(user) }
  end

  def self.followed_questions_for_user_id(user_id)
    qafollow = QuestionDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        questions
      JOIN question_follows qf
      ON qf.question_id = questions.id
      WHERE  qf.user_id  = ?
    SQL
    raise "NO Question found" if qafollow.length == 0
    qafollow.map { |qa| Question.new(qa) }
  end

  def self.most_followed_questions(n)
    qa = QuestionDatabase.instance.execute(<<-SQL, n)
    SELECT
      *
    FROM
      questions
    JOIN question_follows ON question_follows.question_id = questions.id
    GROUP BY
      question_follows.question_id
    ORDER BY
      count(question_follows.user_id) desc
    LIMIT
    n
      SQL

      raise "NO Question found" if qafollow.length == 0
      qa.map { |el| Question.new(el) }

  end


  def initialize(options)
    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end



end

class Replies

  attr_accessor :title, :body, :question_id, :user_id, :parent_id
  attr_reader :id

  def self.find_by_id(id)
    replie = QuestionDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies
      WHERE
        id = ?
    SQL
    raise "NO replie found" if replie.length == 0
    Replies.new(replie.first)
  end

  def self.find_by_user_id(user_id)
    replie = QuestionDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        replies
      WHERE
        user_id = ?
    SQL
    raise "NO replie found for this user" if replie.length == 0
    replie.map { |el| Replies.new(el) }
  end

  def self.find_by_question_id(question_id)
    replie = QuestionDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        replies
      WHERE
        question_id = ?
    SQL
    raise "NO replie found for this question" if replie.length == 0
    replie.map { |el| Replies.new(el) }
  end

  def author
    user = Users.find_by_id(@user_id)
    user.fname + " " + user.lname
  end

  def question
    Question.find_by_id(@question_id)
  end

  def parent_reply
    # self.find_by_id(@parent_id)
    replie = QuestionDatabase.instance.execute(<<-SQL, @parent_id)
      SELECT
        *
      FROM
        replies
      WHERE
        id = ?
    SQL
    raise "NO parent replies found" if replie.length == 0
    Replies.new(replie.first)

  end

  def child_replies
    replie = QuestionDatabase.instance.execute(<<-SQL, @id)
      SELECT
        *
      FROM
        replies
      WHERE
        parent_id = ?
    SQL
    raise "NO child replies found" if replie.length == 0
    replie.map { |el| Replies.new(el) }
  end


  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @question_id = options['question_id']
    @user_id = options['user_id']
    @parent_id = options['parent_id']
  end
end

class QuestionLikes

  attr_accessor :user_id, :question_id

  def self.find_by_id(id)
    like = QuestionDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        question_likes
      WHERE
        id = ?
    SQL
    raise "NO likes found" if like.length == 0
    QuestionLikes.new(like.first)
  end

  def self.likers_for_question_id(question_id)
    like = QuestionDatabase.instance.execute(<<-SQL, question_id)
      SELECT DISTINCT users.id, fname, lname
       FROM
       users
       JOIN question_likes
        ON question_likes.user_id = users.id
        WHERE question_likes.question_id = ?
    SQL

    raise "NO likes found" if like.length == 0
    like.map {|user| QuestionLikes.new(user) }
  end

  def self.num_likes_for_question_id(question_id)
    l = QuestionDatabase.instance.execute(<<-SQL, question_id)
    SELECT
      count(user_id)
    FROM
      question_likes
    WHERE
      question_id = ?
    GROUP BY
      question_id

    SQL

    l.first['q']
  end

  def self.liked_questions_for_user_id(user_id)
    l = QuestionDatabase.instance.execute(<<-SQL, user_id)
    SELECT questions.id, questions.title, questions.body, questions.user_id FROM
      questions
    JOIN question_likes ql
    ON questions.id =  ql.question_id
    WHERE ql.user_id = ?
    SQL

    raise "NO liked questions found" if l.length == 0
    l.map {|qa| Question.new(qa) }
  end

  def self.most_liked_questions(n)
    qa = QuestionDatabase.instance.execute(<<-SQL, n)
    SELECT
      *
    FROM
      questions
    JOIN question_likes ON question_likes.question_id = questions.id
    GROUP BY
      question_likes.question_id
    ORDER BY
      count(question_likes.user_id) desc
    LIMIT
    n
      SQL

      raise "NO Question found" if qafollow.length == 0
      qa.map { |el| Question.new(el) }

  end


  def initialize(options)

    @id = options['id']
    @user_id = options['user_id']
    @question_id = options['question_id']
  end

end
