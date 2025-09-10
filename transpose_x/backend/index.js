const express = require('express');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const { exec } = require('child_process');
const glob = require('glob');
require('dotenv').config();
const mysql = require('mysql2');
const xml2js = require('xml2js');
const axios = require('axios');

process.env.TESSDATA_PREFIX = '/opt/homebrew/share'; // Set for Tesseract

const musescorePath = process.env.MUSESCORE_PATH;
const audiverisPath = process.env.AUDIVERIS_PATH || "/Applications/Audiveris.app/Contents/app";

const app = express();
const PORT = process.env.PORT || 3000;

const uploadsDir = path.join('/tmp', 'uploads');

if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir, { recursive: true });
  console.log("📂 Created 'uploads/' directory manually at runtime");
} else {
  console.log("✅ 'uploads/' directory exists");
}

// MySQL connection setup
const connection = mysql.createConnection({
  host: 'hopper.proxy.rlwy.net',
  user: 'root',
  password: 'ZuVBzBqHGqPqDQFMIdgapcuGVOupDJan',
  database: 'railway',
  port: 45563,
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

app.use(express.json({ limit: '20mb' })); 
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

const musicXmlPath = path.join('/tmp', 'uploads/MusicXml');
app.use('/MusicXml', express.static(musicXmlPath));
app.use(express.json());

// Multer setup
const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, 'uploads/'),
  filename: (req, file, cb) => {
    const sanitized = file.originalname.replace(/[^a-zA-Z0-9.]/g, '_');
    const unique = Date.now() + '-' + sanitized;
    cb(null, unique);
  },
});
const upload = multer({ storage });

// Upload Endpoint
app.post('/upload', upload.single('musicImage'), (req, res) => {
  const sheetName = req.body.sheetName;
  console.log('🛬 Incoming /upload request');
    console.log('📦 Uploaded file:', req.file);
    console.log('📝 Sheet name:', sheetName);

  if (!req.file || !sheetName) {
    return res.status(400).json({ error: 'Both file and sheetName are required' });
  }

  const inputPath = path.resolve(req.file.path);
  const baseOutputDir = path.resolve('/tmp/uploads/MusicXml');
  const outputDir = path.join(baseOutputDir, `${Date.now()}_${path.parse(inputPath).name}`);
  fs.mkdirSync(outputDir, { recursive: true });

  console.log(`📌 File received: ${inputPath}`);
  const command = `java -cp "${audiverisPath}/*" org.audiveris.omr.Main -batch -export -output "${outputDir}" -- "${inputPath}"`;
  console.log("📌 Running Audiveris Command:", command);

  exec(command, (error, stdout, stderr) => {
    if (error) {
      console.error('❌ Audiveris execution failed:', error.message);
      return res.status(500).json({ error: 'Audiveris processing error' });
    }

    console.log("🛠 Audiveris stdout:", stdout);
    console.error("🛠 Audiveris stderr:", stderr);

    glob(`${outputDir}/**/*.+(xml|mxl)`, (err, files) => {
      if (err || files.length === 0) {
        console.error("❌ Raw XML file not found in expected folder.");
        return res.status(500).json({ error: 'XML file not found after Audiveris' });
      }

      const xmlFilePath = files[0];
      const publicXmlPath = `/MusicXml/${path.relative(baseOutputDir, xmlFilePath)}`;
      console.log(`✅ Found XML path: ${xmlFilePath}`);

      const sql = 'INSERT INTO sheets (sheetName, imageUrl, musicXMLUrl) VALUES (?, ?, ?)';
      connection.query(sql, [sheetName, inputPath, publicXmlPath], (err, result) => {
        if (err) {
          console.error("❌ DB insert failed:", err);
          return res.status(500).json({ error: 'Database insert failed', details: err });
        }

        res.json({
          message: '✅ File uploaded and saved to database',
          sheetId: result.insertId,
          sheetName,
          filePath: inputPath,
          xmlPath: publicXmlPath,
        });
      });
    });
  });
});

// Save Transposed Song
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

// Get all saved songs
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

// Delete a song
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

// Transpose Endpoint
app.post('/api/transpose', async (req, res) => {
  const { xml, interval } = req.body;

  if (!xml || isNaN(interval)) {
    return res.status(400).json({ code: 'BAD_REQUEST', message: 'Missing or invalid parameters.' });
  }

  try {
    const tmpDir = path.join('/tmp', 'uploads/tmp');
    const inputPath = path.join(tmpDir, 'original.xml');
    const outputPath = path.join(tmpDir, 'transposed.xml');

    if (!fs.existsSync(tmpDir)) fs.mkdirSync(tmpDir, { recursive: true });
    fs.writeFileSync(inputPath, xml, 'utf-8');

    const response = await axios.post('https://transposex.onrender.com/transpose', { xml, interval });
    const transposedXml = response.data.transposedXml;

    res.status(200).json({
      message: 'Transposition successful',
      transposedXml,
    });
  } catch (err) {
    console.error('❌ Transposition error:', err.message);
    res.status(500).json({
      code: 'SYSTEM_ERROR',
      message: 'Internal server error during transposition.',
    });
  }
});

// Start server
app.listen(PORT, () => {
  console.log(`🚀 Server is running on ${PORT}`);
});

// Rename Sheet Endpoint
app.post('/rename-sheet', (req, res) => {
  const { oldName, newName } = req.body;

  if (!oldName || !newName) {
    return res.status(400).json({ error: 'Missing oldName or newName' });
  }

  const sql = `
    UPDATE saved_songs
    SET name = ?
    WHERE name = ?
  `;

  connection.query(sql, [newName, oldName], (err, result) => {
    if (err) {
      console.error('❌ Failed to rename sheet:', err);
      return res.status(500).json({ error: 'Failed to rename sheet' });
    }

    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Sheet not found' });
    }

    res.json({ message: '✅ Sheet renamed successfully' });
  });
});