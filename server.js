const express = require("express");
const multer = require("multer");
const fs = require("fs");
const { exec } = require("child_process");
const cors = require("cors");

const app = express();
app.use(cors());
app.use(express.json());

const upload = multer({ dest: "temp/" });

app.post("/analyze", upload.none(), (req, res) => {
  const code = req.body.code;
  const asmPath = "temp/input.asm";
  const objPath = "temp/input.o";
  const asmCode = `.intel_syntax noprefix\n${code}`;

  fs.writeFileSync(asmPath, asmCode);

  exec(`as ${asmPath} -o ${objPath}`, (err) => {
    if (err) return res.status(500).send("Assembly failed");

    exec(`python3 uiCA/uiCA.py ${objPath} -arch SKL`, (err, stdout, stderr) => {
      if (err) return res.status(500).send("uiCA failed");
      res.send(stdout);
    });
  });
});

app.listen(3000, () => console.log("Server running on port 3000"));
