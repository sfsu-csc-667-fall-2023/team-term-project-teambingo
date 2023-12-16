const express = require("express");
const http = require("http");
const websocket = require("socket.io");
const session = require("express-session");
const cookieParser = require("cookie-parser");
const app = express();
const bodyParser = require("body-parser");
const path = require("path");
const PORT = process.env.PORT || 3000;
const requireLogin = require("../backend/middleware/reqLogin.js")
require("dotenv").config();

app.use(bodyParser.urlencoded({extended:true}));

// Set up to use cookies
app.use(cookieParser());

app.use(
    session({
        secret: "key",
        resave: false,
        saveUninitialized: true,
    })
);

app.use(express.static(path.join(__dirname, "../frontend/")));

// Establishing routes
const logoutRoutes = require("./routes/logout.js");
const gameRoutes = require("./routes/game.js");
const activeGamesRoutes = require("./routes/active_games.js");
const globalLobbyRoutes = require("./routes/global_lobby.js");
const createGameRoutes = require("./routes/create_game.js");
const landingRoutes = require("./routes/landing");
const signUpRoutes = require("./routes/sign_up");
const loginRoutes = require("./routes/login");
const configureDatabase = require("../db/db.js");
const { config } = require("dotenv");

// Mounting routers
app.use("/", landingRoutes);
app.use("/game", gameRoutes);
app.use("/activegames", activeGamesRoutes);
app.use("/lobby",globalLobbyRoutes);
app.use("/creategame",createGameRoutes);
app.use("/logout", logoutRoutes);
app.use("/signup",signUpRoutes);
app.use("/login", loginRoutes);

// Setup for views. Views is in "views" dir and the engine is ejs
app.set("views", path.join(__dirname, "views"));
app.set("view engine", "ejs");

// Setup the server and sockets
const server = http.createServer(app); 
const io = new websocket.Server(server, {
    cors: {
        origin: process.env.NODE_ENV === "production" ? false:
        ["http://localhost:3000"]
    }
});

// Setup our database so we can use it here
const db = configureDatabase();
db.connect();

// Listens for any new messages in a game's chatroom
db.query('LISTEN gamechat_channel');
db.on('notification', async (notification) => {    
    const gameCode = notification.payload;
    console.log('Received new message notification for game:', gameCode);

    const queryResult = await db.query(
        'SELECT * FROM gamechat WHERE game_id = $1 ORDER BY time_sent DESC LIMIT 1',
        [gameCode]
    );

    if (queryResult.rows.length > 0) {
        const latestMessage = queryResult.rows[0];
        const formattedMessage = {
            content: latestMessage.message,
            sender: latestMessage.user_id,
            timestamp: latestMessage.time_sent,
            gamecode: latestMessage.game_id,
        };
        setTimeout(() => {
        }, 500);
        io.emit('message', formattedMessage);
    }
});

// Listens for any new messages in the lobby's chatroom
db.query('LISTEN lobby_channel');
db.on('notification', async (notification) => {
  if (notification.channel === 'lobby_channel') {
    console.log('Received new message notification for lobby');
    
    const queryResult = await db.query(
      'SELECT * FROM messages ORDER BY message_time DESC LIMIT 1',
      []
    );

    if (queryResult.rows.length > 0) {
      const latestMessage = queryResult.rows[0];
      const formattedMessage = {
        content: latestMessage.message_content,
        sender: latestMessage.player_name,
        timestamp: latestMessage.message_time,
      };
      // Emit the message to the client
      io.emit('lobbymessage', formattedMessage);
    }
  }
});

// The server and the individual sockets
io.on("connection", (socket) => {   

    // Socket to show a player's games
    socket.on("active_games", (username) => {
        db.query('SELECT game.game_code, game.game_name FROM game JOIN player_card ON game.game_code = player_card.game_id  JOIN player ON player.username = player_card.player_id WHERE player.username = $1;',
            [username], (error, result) => {
                if (error) {
                    console.error("Error getting your games :(", error);
                } else {
                    const active_games = result.rows;
                    socket.emit("active_games_return", active_games);
                }
            });
    });

    // Socket to show all games (global_lobby.js)
    socket.on("global_games_call", () => {
        db.query('SELECT game_code, game_name FROM game;', 
            (error, result) => {
                if (error) {
                    console.error("Error getting all games :(", error);
                } else {
                    const all_games = result.rows;
                    io.emit("global_games_return", all_games);
                }
        });
    });

    // Socket for when a player exits pages: game, lobby, activegames
    socket.on("disconnect", () => {
        console.log("User has left this page");
    });
    
    // Socket for chats - (A Game) When a player sends a message, store it into the database 
    socket.on("messageToDB", (messageData) => {
        const content = messageData.content;
        const sender = messageData.sender;
        const timestamp = messageData.timestamp;
        const gamecode = messageData.gamecode;

        db.query("INSERT INTO gamechat (user_id, game_id, message, time_sent) VALUES ($1, $2, $3 , $4)", 
        [sender, gamecode, content, timestamp], (error, result) => {
            if (error) {
                console.error("Error saving message to the db:", error);
            } else {
                console.log('Message inserted successfully');
                // Check if the message is not from the local user, then emit to clients
                if (sender !== '<%= user.username.username %>') {
                    const formattedMessage = {
                        content: content,
                        sender: sender,
                        timestamp: timestamp,
                        gamecode: gamecode,
                    };
                }
            }
        });
    });
    
    // Socket for chats - (Lobby) When a player sends a message, store it into the database 
    socket.on("messageToLobbyDB", (messageData) => {
        const content = messageData.content;
        const sender = messageData.sender;
        const timestamp = messageData.timestamp;

        db.query("INSERT INTO messages (player_name, message_content, message_time) VALUES ($1, $2, $3)", [sender, content, timestamp], (error, result) => {
            if (error) {
                console.error("Error saving message to the db:", error);
            } else {
                console.log('Message inserted successfully');
                // Check if the message is not from the local user, then emit to clients
                if (sender !== '<%= user.username.username %>') {
                    const formattedMessage = {
                        content: content,
                        sender: sender,
                        timestamp: timestamp,
                    };
                }
            }
        });
    });


    // Socket for chats - (A Game) Loads messages from a game
    socket.on("joinGame", (gamecode)=>{
        socket.join(gamecode);
        db.query("SELECT * FROM gamechat WHERE game_id = $1", [gamecode], (error, result) => {
            if (error) {
                console.error("Error getting gamechat messages", error);
            } else {
                const formattedMessages = result.rows.map((row) => ({
                    content: row.message,
                    sender: row.user_id,
                    timestamp: row.time_sent,
                    gamecode: row.game_id,
                }));

                io.to(gamecode).emit("previousMessages", formattedMessages);
            }
        })
    })

    // Socket for chats - (Lobby) Loads messages in the lobby 
    socket.on("joinLobby", ()=>{
        db.query("SELECT * FROM messages ", [], (error, result) => {
            if (error) {
                console.error("Error getting gamechat messages", error);
            } else {
                const formattedMessages = result.rows.map((row) => ({
                    content: row.message_content,
                    sender: row.player_name,
                    timestamp: row.message_time,
                }));
                io.emit("previousLobbyMessages", formattedMessages);
            }
        })
    })

    // Socket for a game - Update the Start Time of a game
    socket.on("gamestartDB", (gamestartPayload) => {
        const { timestamp, gamecode } = gamestartPayload;
        db.query(
            "UPDATE game SET started_at = $1 WHERE game_code = $2",
            [timestamp, gamecode],
            (error, result) => {
                if (error) {
                    console.error("Error updating game start time:", error);
                } else {
                    console.log("Game start time updated successfully");
                }
            }
        );
        io.to(gamecode).emit("gamestarted", gamecode);
    });

    // Socket for a game - Creates a player's game card
    socket.on("getPlayerCard", (playercardPayload) => {
        const { game_id, player_id, is_winner} = playercardPayload;
        db.query(
            "INSERT INTO player_card (game_id, player_id, is_winner) VALUES ($1, $2, $3)",
            [game_id, player_id, is_winner],
            (error, result) => {
                if (error) {
                    socket.emit("game_card_exists", { message: "Game Card Already exists" });
                } else {
                    console.log("Got the players card");
                }
            }
        );

    });

    // Socket for a game - Fills in all the card spots on a player's bingo card
    socket.on("cardspotting", (playercardPayload) => {
        let isStamp = false;
        db.query(
            "SELECT pc.id FROM player_card pc JOIN game g ON pc.game_id = g.game_code WHERE g.game_code = $1 AND pc.player_id = $2;",
            [playercardPayload.game_id, playercardPayload.player_id],
            (error, result) => {
              if (error) {
                console.error("Error looking up player_card_id:", error);
              } else if (result.rows.length > 0) {
                const playerCardId = result.rows[0].id;
                if(playercardPayload.spot_id == 13){
                    isStamp = true;
                }
                db.query(
                  `INSERT INTO card_spot (player_card_id, bingo_ball_id, is_stamp, spot_id)
                  SELECT $1, $2, $3, $4
                  WHERE NOT EXISTS (
                      SELECT 1
                      FROM card_spot
                      WHERE player_card_id = $1
                        AND spot_id = $4
                  );`,
                  [playerCardId, playercardPayload.randomNum, isStamp, playercardPayload.spot_id],
                  (insertError, insertResult) => {
                    if (insertError) {
                      console.error("Error inserting into card_spot:", insertError);
                      socket.emit("card_spot_insert_failed", { message: "Failed to insert into card_spot" });
                    } else {
                      console.log("Successfully inserted into card_spot");
                    }
                  }
                );
              } else {
                console.log("Player card not found for the given game_code and player_id");
              }
            }
          );
    });

    // Socket for a game - Pulls a random bingo ball
    socket.on("pullball", (gamecode) => {
        db.query(
            "SELECT * FROM bingo_ball WHERE id NOT IN (SELECT bingo_ball_id FROM pulled_balls where game_id = $1) ORDER BY RANDOM()LIMIT 1;",
            [gamecode],(error, result) =>{
                if (error) {
                    console.log('error from pullball');
                } else {
                    console.log("RESULT from pullball: "+  result.rows[0].id + ' '+ result.rows[0].letter);
                    const ballInfo = {
                        ballNum: result.rows[0].id,
                        ballLetter: result.rows[0].letter
                    }
                    db.query(
                        "INSERT INTO pulled_balls (game_id, bingo_ball_id, time_pulled) VALUES ($1, $2, $3)",
                        [gamecode, ballInfo.ballNum, new Date().toISOString().slice(0, 19).replace("T", " ")],
                        (error, result) => {
                            if(error){
                                console.log("problems putting it into pulled_balls" + error);
                            }else{
                                console.log("Succesfully put into pulled_balls");
                            }
                        }
                    )
                    io.to(gamecode).emit("ballNumber",ballInfo );
                }
            }
        )
    });
    
    // Socket for a game - Checks to see if a player has Bingo (runs every time a ball is pulled)
    socket.on("checkPlayerBoard", (data)=> {
        db.query(
            "SELECT pc.id FROM player_card pc JOIN game g ON pc.game_id = g.game_code WHERE g.game_code = $1 AND pc.player_id = $2;",
            [data.gamecode, data.player_id],
            (error, result) =>{
                if(error){
                    console.error("problem checking player_card to get id"+ error);
                }else{
                    data.id = result.rows[0].id;
                    db.query(
                        `UPDATE card_spot
                        SET is_stamp = true
                        WHERE bingo_ball_id = $1
                          AND player_card_id = (SELECT id FROM player_card WHERE player_id = $2 AND game_id = $3);
                        `,
                        [data.pulledBallNum, data.player_id, data.gamecode],
                        (error,result)=> {
                            if(error){
                                console.error("error updating is_stamp" + error);
                            }else{
                                // check if winner here from db
                                const winningCombinations = [
                                    [1, 2, 3, 4, 5],
                                    [6, 7, 8, 9, 10],
                                    [11, 12, 13, 14, 15],
                                    [16, 17, 18, 19, 20],
                                    [21, 22, 23, 24, 25],
                                    [1, 6, 11, 16, 21],
                                    [2, 7, 12, 17, 22],
                                    [3, 8, 13, 18, 23],
                                    [4, 9, 14, 19, 24],
                                    [5, 10, 15, 20, 25],
                                    [1, 7, 13, 19, 25],
                                    [5, 9, 13, 17, 21]
                                ];
                                winningCombinations.forEach(combination => {
                                    const query = {
                                        text: "SELECT COUNT(DISTINCT spot_id) AS count FROM card_spot WHERE spot_id IN ($1, $2, $3, $4, $5) AND is_stamp = true AND player_card_id = $6;",
                                        values: [combination[0], combination[1], combination[2], combination[3] ,combination[4], data.id]
                                    };
                                
                                    db.query(query, (error, result) => {
                                        if (error) {
                                            console.error("Error executing query:", error);
                                        } else {
                                            const count = result.rows[0].count;
                                            if (count == 5) {
                                                console.log("Winning combination found:", combination);
                                                db.query(
                                                    "UPDATE player_card SET is_winner=true WHERE game_id = $1 AND player_id = $2",
                                                    [data.gamecode, data.player_id],
                                                    (error, result) => {
                                                        if(error){
                                                            console.error("Failed to update Winner" + error);
                                                        }else{
                                                            const winner_id = data.player_id;
                                                            io.to(data.gamecode).emit("WinnerWinner",winner_id);
                                                        }
                                                    }
                                                )
                                            }
                                        }
                                    });
                                });
                            }
                        }
                    )
                }
            }
        )
    });
});

// Starts up the Server
server.listen(PORT, () => {
    console.log(`Server started on port ${PORT}`);
});