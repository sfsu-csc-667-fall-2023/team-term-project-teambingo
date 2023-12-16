CREATE TABLE "player" (
  "username" varchar(255) PRIMARY KEY,
  "email" varchar(255) NOT NULL,
  "password" varchar(255) NOT NULL
);

CREATE TABLE "game" (
  "game_code" VARCHAR(255) PRIMARY KEY,
  "game_name" varchar(255),
  "created_at" timestamp without time zone NOT NULL,
  "started_at" timestamp without time zone,
  "connected_players" int DEFAULT 0,
  "is_finished" boolean DEFAULT false
);

CREATE TABLE "gamechat" (
  "id" SERIAL PRIMARY KEY,
  "user_id" VARCHAR(255) NOT NULL,
  "game_id" VARCHAR(255) NOT NULL,
  "message" VARCHAR(255) NOT NULL,
  "time_sent" timestamp without time zone NOT NULL
);

CREATE TABLE "player_card" (
  "id" SERIAL PRIMARY KEY,
  "game_id" VARCHAR(255) NOT NULL,
  "player_id" VARCHAR(255) NOT NULL,
  "is_checked_in" boolean,
  "is_winner" boolean
);

CREATE TABLE "pulled_balls" (
  "game_id" int NOT NULL,
  "bingo_ball_id" int NOT NULL,
  "time_pulled" timestamp without time zone NOT NULL
);

CREATE TABLE "card_spot" (
  "spot_id" SMALLINT,
  "bingo_ball_id" int NOT NULL,
  "player_card_id" int NOT NULL,
  "is_stamp" boolean,
  PRIMARY KEY ("spot_id", "bingo_ball_id", "player_card_id"), 
  CONSTRAINT card_spot_spot_id_check CHECK (((spot_id >= 1) AND (spot_id <= 25)))
);

CREATE TABLE "bingo_ball" (
  "id" int NOT NULL,
  "letter" varchar(1) NOT NULL
);

CREATE UNIQUE INDEX ON "player_card" ("game_id", "player_id");

CREATE UNIQUE INDEX ON "pulled_balls" ("game_id", "bingo_ball_id");

CREATE TABLE "player_gamechat" (
  "player_id" int,
  "gamechat_id" int,
  PRIMARY KEY ("player_id", "gamechat_id"),
  FOREIGN KEY ("player_id") REFERENCES "player" ("id"),
  FOREIGN KEY ("gamechat_id") REFERENCES "gamechat" ("id")
);

ALTER TABLE "gamechat" ADD FOREIGN KEY ("game_id") REFERENCES "game" ("id") ON DELETE CASCADE;

ALTER TABLE "player_card" ADD FOREIGN KEY ("game_id") REFERENCES "game" ("id") ON DELETE CASCADE;

ALTER TABLE "player_card" ADD FOREIGN KEY ("player_id") REFERENCES "player" ("id") ON DELETE CASCADE;

ALTER TABLE "pulled_balls" ADD FOREIGN KEY ("game_id") REFERENCES "game" ("id") ON DELETE CASCADE;

ALTER TABLE "pulled_balls" ADD FOREIGN KEY ("bingo_ball_id") REFERENCES "bingo_ball" ("id") ON DELETE CASCADE;

ALTER TABLE "card_spot" ADD FOREIGN KEY ("bingo_ball_id") REFERENCES "bingo_ball" ("id") ON DELETE CASCADE;

ALTER TABLE "card_spot" ADD FOREIGN KEY ("player_card_id") REFERENCES "player_card" ("id") ON DELETE CASCADE;
