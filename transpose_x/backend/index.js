const express = require('express');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const { exec } = require('child_process');
const glob = require('glob');
require('dotenv').config();
const mysql = require('mysql2');

// MySQL connection setup
const connection = mysql.createConnection({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASS,
  database: process.env.DB_NAME
});

connection.connect((err) => {
  if (err) throw err;
  console.log('✅ Connected to MySQL');

  const createSheetsTable = `
    CREATE TABLE IF NOT EXISTS sheets (
      id INT AUTO_INCREMENT PRIMARY KEY,
      sheetName VARCHAR(255) NOT NULL,
      imageUrl VARCHAR(500) NOT NULL,
      musicXMLUrl VARCHAR(500),
      createdTime TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
  `;

  const createSavedSongsTable = `
    CREATE TABLE IF NOT EXISTS saved_songs (
      id INT AUTO_INCREMENT PRIMARY KEY,
      name VARCHAR(255) NOT NULL,
      xml LONGTEXT NOT NULL,
      originalKey VARCHAR(100),
      transposedKey VARCHAR(100),
      createdTime TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
  `;

  connection.query(createSheetsTable, (err) => {
    if (err) throw err;
    console.log('📄 Table "sheets" is ready');
  });

  connection.query(createSavedSongsTable, (err) => {
    if (err) throw err;
    console.log('📄 Table "saved_songs" is ready');
  });
});

const app = express();
const PORT = 3000;

const audiverisPath = process.env.AUDIVERIS_PATH || "/Applications/Audiveris.app/Contents/app";
app.use('/MusicXml', express.static(path.join(__dirname, 'uploads/MusicXml')));

// Middleware
app.use(express.json());

// Multer setup for file upload
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/');
  },
  filename: (req, file, cb) => {
    const sanitized = file.originalname.replace(/[^a-zA-Z0-9.]/g, '_');
    const unique = Date.now() + '-' + sanitized;
    cb(null, unique);
  }
});

const upload = multer({ storage });

app.get('/', (req, res) => {
  res.send('🎶 Welcome to TransposeX Backend!');
});

// Upload Endpoint
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
          xmlPath: publicXmlPath
        });
      });
    });
  });
});

// Save Transposed Song to Library
app.post('/save-song', (req, res) => {
  const { name, xml, originalKey, transposedKey } = req.body;

  if (!name || !xml || !originalKey || !transposedKey) {
    return res.status(400).json({ error: 'Missing required fields' });
  }

  const sql = `
    INSERT INTO saved_songs (name, xml, originalKey, transposedKey)
    VALUES (?, ?, ?, ?)
  `;

  connection.query(sql, [name, xml, originalKey, transposedKey], (err, result) => {
    if (err) {
      console.error("❌ Failed to insert song:", err);
      return res.status(500).json({ error: "Failed to save song" });
    }

    console.log(`✅ Saved transposed song: ${name} (ID: ${result.insertId})`);
    res.json({ message: "✅ Song saved successfully", songId: result.insertId });
  });
});

// GET all saved songs
app.get('/saved-songs', (req, res) => {
  const sql = `
    SELECT id, name, xml, originalKey, transposedKey, createdTime
    FROM saved_songs
    ORDER BY createdTime DESC
  `;

  connection.query(sql, (err, results) => {
    if (err) {
      console.error('❌ Failed to fetch saved songs:', err);
      return res.status(500).json({ error: 'Failed to fetch saved songs' });
    }

    console.log(`✅ Fetched ${results.length} saved songs`);
    res.json(results);
  });
});

// delete a song from library
app.delete('/songs/:id', (req, res) => {
  const songId = req.params.id;

  const query = 'DELETE FROM saved_songs WHERE id = ?';
  connection.query(query, [songId], (err, results) => {
    if (err) {
      console.error("❌ Failed to delete song:", err);
      return res.status(500).json({ error: 'Failed to delete song' });
    }

    res.json({ message: '✅ Song deleted successfully' });
  });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Server is running on http://0.0.0.0:${PORT}`);
});