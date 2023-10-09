const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
const http = require("http");
const authRouter = require("./routes/auth");
const documentRouter = require("./routes/document");
const Document = require("./models/document");

const PORT = process.env.PORT | 3001;

const app = express();
var server = http.createServer(app);
var io = require('socket.io')(server);

app.use(express.json());
app.use(cors());
app.use(authRouter);
app.use(documentRouter);

const DB = "<Connect your mongoDB>";

mongoose.connect(DB).then(() => {console.log("Connection Successfull!");}).catch((err) => {console.log(err);});

io.on("connection", (socket) => {
    socket.on("join", (documentId) => {
        socket.join(documentId);
    });

    socket.on("save", async ({data, id}) => {
        console.log(id);

        let document = await Document.findById(id);
        document.content = data;
        document = await document.save();
    });

    socket.on("fetchContent", async(id) => {
        let document = await Document.findById(id);
        let content = document.content;
        console.log(content[0]);
        socket.emit("receiveFetchedData", content[0]);
    });
    console.log('connected '+ socket.id);
});

const saveData = async ({data, id}) => {

}

server.listen(PORT, "0.0.0.0", () => {
    console.log(`connected ${PORT}`);
});