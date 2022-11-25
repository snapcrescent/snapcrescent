require("./environment");
const express = require("express");
const app = express();
const fs = require("fs");
const mysql = require('mysql2/promise');
const mysqlConfig = require("./environment").mysqlConfig;
const storageConfig = require("./environment").storageConfig;
const cors = require('cors');

const corsOptions = {
  "origin": "*",
  "methods": "GET,HEAD,PUT,PATCH,POST,DELETE",
  "preflightContinue": false,
  "optionsSuccessStatus": 204
}

app.use(cors(corsOptions));

app.get("/video/:id",async  function (req, res) {
  var asset = (await query(`Select * from asset where id  = ${req.params.id}`))[0];
  var metadata = (await query(`Select * from metadata where id = ${asset.metadata_id}`))[0];
  
  // Ensure there is a range given for the video
  const range = req.headers.range;
  if (!range) {
    res.status(400).send("Requires Range header");
  }

  const videoPath = `${storageConfig.path}/videos/${metadata.path}${metadata.internal_name}`;
  const videoSize = fs.statSync(videoPath).size;

  // Parse Range
  // Example: "bytes=32324-"
  const CHUNK_SIZE = 10 ** 6; // 1MB
  const start = Number(range.replace(/\D/g, ""));
  const end = Math.min(start + CHUNK_SIZE, videoSize - 1);

  // Create headers
  const contentLength = end - start + 1;
  const headers = {
    "Content-Range": `bytes ${start}-${end}/${videoSize}`,
    "Accept-Ranges": "bytes",
    "Content-Length": contentLength,
    "Content-Type": "video/mp4",
  };

  // HTTP Status 206 for Partial Content
  res.writeHead(206, headers);

  // create video read stream for this particular chunk
  const videoStream = fs.createReadStream(videoPath, { start, end });

  // Stream the video chunk to the client
  videoStream.pipe(res);
});

async function query(sql, params) {
  const connection = await mysql.createConnection(mysqlConfig);
  const [results, ] = await connection.execute(sql, params);
  connection.destroy();
  return results;
}

app.listen(8000, function () {
  console.log("Listening on port 8000!");
});