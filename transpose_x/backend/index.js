const express = require('express');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const { exec } = require('child_process');
const glob = require('glob');
require('dotenv').config();
const mysql = require('mysql2');

const connection = mysql.createConnection({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASS,
  database: process.env.DB_NAME
});

connection.connect((err) => {
  if (err) throw err;
  console.log('✅ Connected to MySQL');

  const createTableQuery = `
    CREATE TABLE IF NOT EXISTS sheets (
      id INT AUTO_INCREMENT PRIMARY KEY,
      sheetName VARCHAR(255) NOT NULL,
      imageUrl VARCHAR(500) NOT NULL,
      musicXMLUrl VARCHAR(500),
      createdTime TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
  `;

  connection.query(createTableQuery, (err) => {
    if (err) throw err;
    console.log('📄 Table "sheets" is ready');
  });
});

console.log("📌 Checking if .env is loaded:", process.env.AUDIVERIS_PATH);

const audiverisPath = process.env.AUDIVERIS_PATH || "/Applications/Audiveris.app/Contents/app";
const app = express();
const PORT = 3000;

app.use('/MusicXml', express.static(path.join(__dirname, 'uploads/MusicXml')));

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/');
  },
  filename: (req, file, cb) => {
    const sanitizedOriginal = file.originalname.replace(/[^a-zA-Z0-9.]/g, '_');
    const uniqueName = Date.now() + '-' + sanitizedOriginal;
    cb(null, uniqueName);
  }
});

const upload = multer({ storage });
app.use(express.json());

app.get('/', (req, res) => {
  res.send('🎶 Welcome to TransposeX Backend!');
});

app.post('/upload', upload.single('musicImage'), (req, res) => {
  const sheetName = req.body.sheetName;
  if (!req.file || !sheetName) {
    return res.status(400).json({ error: 'Both file and sheetName are required' });
  }

  const inputPath = path.resolve(req.file.path);
  const outputDir = path.resolve('uploads/MusicXml');

  console.log(`📌 File received: ${inputPath}`);

  const command = `java -cp "${audiverisPath}/*" org.audiveris.omr.Main -batch -export -output "${outputDir}" -- "${inputPath}"`;
  console.log("📌 Running Audiveris Command:", command);

  exec(command, (error, stdout, stderr) => {
    if (error) {
      console.error('❌ Audiveris execution failed:', error.message);
      return res.status(500).json({ error: 'Audiveris processing error' });
    }

    // Search for any .xml file generated under MusicXml recursively
    glob(`${outputDir}/**/*.xml`, (err, files) => {
      if (err || files.length === 0) {
        console.error("❌ Raw XML file not found. Something went wrong.");
        return res.status(500).json({ error: 'Raw XML file not found after Audiveris execution' });
      }

      const xmlFilePath = files[0];
      const publicXmlPath = `/MusicXml/${path.relative(path.join(__dirname, 'uploads/MusicXml'), xmlFilePath)}`;
      console.log(`✅ Found XML path: ${xmlFilePath}`);

      const sql = 'INSERT INTO sheets (sheetName, imageUrl, musicXMLUrl) VALUES (?, ?, ?)';
      connection.query(sql, [sheetName, inputPath, publicXmlPath], (err, result) => {
        if (err) {
          console.error("❌ Database insert failed:", err);
          return res.status(500).json({ error: 'Database insert failed', details: err });
        }

        res.json({
          message: '✅ File uploaded and saved to database',
          sheetId: result.insertId,
          sheetName: sheetName,
          filePath: inputPath,
          xmlPath: publicXmlPath // used in Flutter client to fetch the XML
        });
      });
    });
  });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Server is running on http://0.0.0.0:${PORT}`);
});