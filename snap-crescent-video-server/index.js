const mysqlConfig = require("./environment").mysqlConfig;
const storageConfig = require("./environment").storageConfig;

const express = require("express");
const app = express();
const fs = require("fs");
const mysql = require('mysql2/promise');

const cors = require('cors');
const corsOptions = {
  "origin": "*",
  "methods": "GET,HEAD,PUT,PATCH,POST,DELETE",
  "preflightContinue": false,
  "optionsSuccessStatus": 204
}

const AssetType = require("./model/asset-type").AssetType;

app.use(cors(corsOptions));

app.get("/thumbnail/:id",async  function (req, res) {
  var thumbnail = (await query(`Select * from thumbnail where id = ${req.params.id}`))[0];
  
  const headers = {};
  
  var stream;

  const thumbnailPath = `${storageConfig.path}/thumbnails/${thumbnail.path}${thumbnail.name}`;

  headers["Content-Length"] = fs.statSync(thumbnailPath).size;
  headers["Content-Type"] = "image/jpg";

  stream = fs.createReadStream(thumbnailPath);
  
  stream.pipe(res);
  
});

app.get("/asset/:id/stream",async  function (req, res) {
  var asset = (await query(`Select * from asset where id  = ${req.params.id}`))[0];
  var metadata = (await query(`Select * from metadata where id = ${asset.metadata_id}`))[0];
  
  const headers = {};
  headers["Content-Type"] = metadata.mime_type;
  
  var contentLength = 0;
  var stream;

if(asset.asset_type === AssetType.PHOTO.id) {
    const photoPath = `${storageConfig.path}/photos/${metadata.path}${metadata.internal_name}`;
    contentLength = fs.statSync(photoPath).size;
    stream = fs.createReadStream(photoPath);
  } else {
    // Ensure there is a range given for the video
    const range = req.headers.range;
    if (!range) {
      res.status(400).send("Requires Range header");
    }

    const videoPath = `${storageConfig.path}/videos/${metadata.path}${metadata.internal_name}`;
    const videoSize = fs.statSync(videoPath).size;

    const CHUNK_SIZE = 10 ** 6; // 1MB
    const start = Number(range.replace(/\D/g, ""));
    const end = Math.min(start + CHUNK_SIZE, videoSize - 1);

    contentLength = end - start + 1;

    headers["Content-Range"] = `bytes ${start}-${end}/${videoSize}`;
    headers["Accept-Ranges"] = `bytes`;
    
    res.writeHead(206, headers);

    stream = fs.createReadStream(videoPath, { start, end });  
  }

  headers["Content-Length"] = contentLength;

  stream.pipe(res);
  
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