DROP TABLE IF EXISTS users;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(50) NOT NULL,
  lname VARCHAR(50) NOT NULL
);


DROP TABLE IF EXISTS questions;

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  body TEXT NOT NULL,
  asker_id INTEGER NOT NULL,

  FOREIGN KEY (asker_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS question_follows;

CREATE TABLE question_follows (
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  follower_id INTEGER,

  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (follower_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS replies;

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  body TEXT NOT NULL,
  parent_reply_id INTEGER,
  subject_question_id INTEGER NOT NULL,
  author_id INTEGER NOT NULL,

  FOREIGN KEY (parent_reply_id) REFERENCES replies(id),
  FOREIGN KEY (subject_question_id) REFERENCES questions(id),
  FOREIGN KEY (author_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS question_likes;

CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY,
  liker_id INTEGER,
  liked_question_id INTEGER,

  FOREIGN KEY (liker_id) REFERENCES users(id),
  FOREIGN KEY (liked_question_id) REFERENCES questions(id)
);

INSERT INTO users (fname, lname)
VALUES ("Ned", "Ruggeri"), ("Kush", "Patel"), ("Earl", "Cat");

--questions
INSERT INTO questions (title, body, asker_id)
SELECT "Ned Question", "NED NED NED", users.id
FROM users
WHERE users.fname = "Ned" AND users.lname = "Ruggeri";

INSERT INTO questions (title, body, asker_id)
SELECT "Kush Question", "KUSH KUSH KUSH", users.id
FROM users
WHERE users.fname = "Kush" AND users.lname = "Patel";

INSERT INTO questions (title, body, asker_id)
SELECT "Earl Question", "MEOW MEOW MEOW", users.id
FROM users
WHERE users.fname = "Earl" AND users.lname = "Cat";

--replies
INSERT INTO replies (body, parent_reply_id, subject_question_id, author_id)
VALUES
  ((SELECT id FROM questions WHERE title = "Earl Question"),
  NULL,
  (SELECT id FROM users WHERE fname = "Ned" AND lname = "Ruggeri"),
  "Did you say NOW NOW NOW?"
);

INSERT INTO
  replies (body, parent_reply_id, subject_question_id, author_id)
VALUES
  ((SELECT id FROM questions WHERE title = "Earl Question"),
  (SELECT id FROM replies WHERE body = "Did you say NOW NOW NOW?"),
  (SELECT id FROM users WHERE fname = "Kush" AND lname = "Patel"),
  "I think he said MEOW MEOW MEOW."
);

--question_likes
INSERT INTO question_likes (liker_id, liked_question_id)
VALUES
  ((SELECT id FROM users WHERE fname = "Kush" AND lname = "Patel"),
  (SELECT id FROM questions WHERE title = "Earl Question")
);
INSERT INTO question_likes (liker_id, liked_question_id) VALUES (1, 1);
INSERT INTO question_likes (liker_id, liked_question_id) VALUES (1, 2);


-- question follows
INSERT INTO question_follows (question_id, follower_id)
VALUES
  ((SELECT id FROM users WHERE fname = "Ned" AND lname = "Ruggeri"),
  (SELECT id FROM questions WHERE title = "Earl Question")),

  ((SELECT id FROM users WHERE fname = "Kush" AND lname = "Patel"),
  (SELECT id FROM questions WHERE title = "Earl Question")
);
