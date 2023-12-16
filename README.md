### Bingo!
# CSC 667 Fall 2023, Group A: Adithya Gutala, Louis Houston, Aleia Natividad, Nina Young

### CURRENT NODE PACKAGES INSTALLED 
├── bcrypt@5.1.1
├── body-parser@1.20.2
├── cookie-parser@1.4.6
├── dotenv@16.3.1
├── ejs@3.1.9
├── express-session@1.17.3
├── express@4.18.2
├── http-errors@2.0.0
├── nodemon@3.0.1
├── pg@8.11.3
└── socket.io@4.7.2

To start using, first make sure you have access to the team-bingo DB with psql. You will also need to make a .env file with the correct link.
Use ```npm install``` to install all necessary dependencies. You may need to uninstall and reinstall bcrypt before running as different machines seem to cause issues with this program.

## Overview
Our Bingo game is set up to allow you to make an account, log in, and view your active games and global games. Players can create a new room, generate a player card, and watch the bingo game play out automatically. When a player wins, their victory is announced in the global lobby. Players can chat with each other in the global lobby as well as individual game rooms.

# Structure
Our code has a standard backend and frontend, and the actual game logic is mostly stored in the .ejs files in views. All our Javascript files are found in the routes folder. All css is stored in a single static .css folder in frontend.
Our database is hosted on Render, so you'll need a .env file with our Render information (which we will provide to you). 
You could also build the database from scratch via our SQL code bingo_db_psql.sql in our db folder.

## Appplications Needed to run the website - Node.js
1. Make sure you have Node.js
    For Windows Users:
        1) Go to: https://nodejs.org/en/
        2) Download the LTS version (You can download the current experiemental version if you'd like, but it's not neccessary!)

## Run Instructions
1. Open your favorite code editor
2. With your editor, open the entire folder named '<insert our repo name here>'
3. In the code editor terminal, run 'npm install'
4. Open your favorite browser, and type in "http://localhost:3000/"
