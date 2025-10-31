const express = require('express');
const cors = require('cors');
const nodemailer = require('nodemailer');
const dotenv = require('dotenv');

// Load environment variables from .env
dotenv.config({ path: '.env' });

// Resolve SMTP configuration from env (supports both plain and REACT_APP_ prefixes)
const SMTP_USER = process.env.GMAIL_SMTP_USERNAME || process.env.REACT_APP_GMAIL_SMTP_USERNAME;
const SMTP_PASS = process.env.GMAIL_SMTP_PASSWORD || process.env.REACT_APP_GMAIL_SMTP_PASSWORD;
const FROM_EMAIL = process.env.GMAIL_FROM_EMAIL || process.env.REACT_APP_GMAIL_FROM_EMAIL || SMTP_USER;
const FROM_NAME = process.env.GMAIL_FROM_NAME || process.env.REACT_APP_GMAIL_FROM_NAME || 'UmmaHub';
const SMTP_HOST = process.env.GMAIL_SMTP_HOST || process.env.REACT_APP_GMAIL_SMTP_HOST || 'REMOVED_SECRET';
const SMTP_PORT = Number(process.env.GMAIL_SMTP_PORT || process.env.REACT_APP_GMAIL_SMTP_PORT || 587);

if (!SMTP_USER || !SMTP_PASS) {
  console.warn('[Email Server] Missing SMTP credentials. Please set GMAIL_SMTP_USERNAME and GMAIL_SMTP_PASSWORD in .env');
}

// Create Nodemailer transporter for Gmail SMTP
const transporter = nodemailer.createTransport({
  host: SMTP_HOST,
  port: SMTP_PORT,
  secure: SMTP_PORT === 465, // true for 465, false for 587
  auth: {
    user: SMTP_USER,
    pass: SMTP_PASS
  }
});

// Verify transporter on startup
transporter.verify((error, success) => {
  if (error) {
    console.error('[Email Server] SMTP verification failed:', error.message);
  } else {
    console.log('[Email Server] SMTP server is ready to take messages');
  }
});

const app = express();
app.use(cors({ origin: ['http://localhost:3000'], methods: ['GET', 'POST'] }));
app.use(express.json({ limit: '1mb' }));

app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', smtpHost: SMTP_HOST, from: `${FROM_NAME} <${FROM_EMAIL}>` });
});

app.post('/api/send-email', async (req, res) => {
  try {
    const { to, subject, html, text } = req.body || {};

    if (!to || !subject || (!html && !text)) {
      return res.status(400).json({ success: false, error: 'Missing required fields: to, subject, html/text' });
    }

    const mailOptions = {
      from: `${FROM_NAME} <${FROM_EMAIL}>`,
      to,
      subject,
      html,
      text,
      replyTo: FROM_EMAIL
    };

    const info = await transporter.sendMail(mailOptions);
    console.log('[Email Server] Email sent:', info.messageId, 'to:', to);
    res.json({ success: true, messageId: info.messageId, accepted: info.accepted, response: info.response });
  } catch (err) {
    console.error('[Email Server] Send error:', err.message);
    res.status(500).json({ success: false, error: err.message });
  }
});

const PORT = process.env.PORT || 4000;
app.listen(PORT, () => {
  console.log(`[Email Server] Listening on http://localhost:${PORT}`);
});