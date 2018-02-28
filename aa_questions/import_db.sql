DROP TABLE IF EXISTS users;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname TEXT NOT NULL,
  lname TEXT NOT NULL
);

DROP TABLE IF EXISTS questions;

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  user_id INTEGER NOT NULL,

  FOREIGN KEY (user_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS question_follows;

CREATE TABLE question_follows (
id INTEGER PRIMARY KEY,
user_id INTEGER NOT NULL,
question_id INTEGER NOT NULL,

FOREIGN KEY (user_id) REFERENCES users(id),
FOREIGN KEY (question_id) REFERENCES questions(id)
);

DROP TABLE IF EXISTS replies;

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  question_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,
  parent_id INTEGER,

  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (parent_id) REFERENCES replies(id)
);

DROP TABLE IF EXISTS question_likes;

CREATE TABLE question_likes (
id INTEGER PRIMARY KEY,
user_id INTEGER NOT NULL,
question_id INTEGER NOT NULL,

FOREIGN KEY (user_id) REFERENCES users(id),
FOREIGN KEY (question_id) REFERENCES questions(id)
);

INSERT INTO
  users (fname, lname)
VALUES
 ('Anna', 'Black'),
 ('Michal', 'Less'),
 ('Dan', 'Irwin'),
 ('Cody', 'Jackson');

INSERT INTO
  questions (title, body, user_id)
VALUES
    ('Scared', 'What happens when you get scared half to death twice?', (SELECT id FROM users WHERE fname = 'Anna') ),
    ('electrical outlet', 'Why is an electrical outlet called an outlet when you plug things into it? Shouldn''t it be called an inlet.', (SELECT id FROM users WHERE fname = 'Cody') ),
    ('Goofy', 'Why does Goofy stand erect while Pluto remains on all fours? They''re both dogs!?', (SELECT id FROM users WHERE fname = 'Michal') ),
    ('cars', 'WWhy do most cars have speedometers that go up to at least 130 when you legally can''t go that fast on any road?', (SELECT id FROM users WHERE fname = 'Dan') );

INSERT INTO
      question_follows (user_id, question_id)
VALUES
     (1,2),
     (2,3),
     (3,4),
     (1,3),
     (4,2);

INSERT INTO
       replies (title, body, user_id, question_id, parent_id)
VALUES
      ('replies1', 'body1', 2, 4, null),
      ('replies2', 'body2', 2, 3, null ),
      ('replies3', 'body3', 1, 2, 1),
      ('replies4', 'body4', 4, 3, 3),
      ('replies5', 'body5', 3, 1, 1),
      ('replies6', 'body6', 2, 1);

      INSERT INTO
      question_likes (user_id, question_id)

      VALUES
      (1, 1),
      (2, 2),
      (3, 3),
      (4, 4),
      (2, 1),
      (3, 2),
      (2, 3),
      (2, 4),
      (3, 1),
      (3, 2),
      (2, 3),
      (3, 4);
