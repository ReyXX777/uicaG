const express = require("express");
const fs = require("fs");
const { exec } = require("child_process");
const cors = require("cors");
const path = require("path");

const app = express();
app.use(cors());
app.use(express.json()); // Allows parsing of JSON request bodies

// Ensure temp folder exists
const tempDir = path.join(__dirname, "temp");
if (!fs.existsSync(tempDir)) {
  fs.mkdirSync(tempDir);
}

app.post("/analyze", (req, res) => {
  try {
    const code = req.body.code;
    if (!code) {
      return res.status(400).json({ error: "Missing 'code' field in request" });
    }

    const asmPath = path.join(tempDir, "input.asm");
    const objPath = path.join(tempDir, "input.o");
    const asmCode = `.intel_syntax noprefix\n${code}`;

    fs.writeFileSync(asmPath, asmCode);

    exec(`as ${asmPath} -o ${objPath}`, (asmErr, asmStdout, asmStderr) => {
      if (asmErr) {
        console.error("Assembly Error:", asmStderr || asmErr.message);
        return res.status(500).json({ error: "Assembly failed", details: asmStderr || asmErr.message });
      }

      exec(`python3 uiCA/uiCA.py ${objPath} -arch SKL`, (uiErr, uiStdout, uiStderr) => {
        if (uiErr) {
          console.error("uiCA Error:", uiStderr || uiErr.message);
          return res.status(500).json({ error: "uiCA failed", details: uiStderr || uiErr.message });
        }

        res.json({ result: uiStdout });
      });
    });
  } catch (e) {
    console.error("Unexpected error:", e);
    res.status(500).json({ error: "Server error", details: e.message });
  }
});

app.listen(3000, () => console.log("Server running on port 3000"));
