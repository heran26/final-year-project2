const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const nodemailer = require('nodemailer');
const { createClient } = require('@supabase/supabase-js');
const User = require('./models/user');
require('dotenv').config();

const app = express();

app.use(cors());
app.use(express.json());

const uri = process.env.MONGODB_URI;
if (!uri) {
  console.error('MONGODB_URI is not defined in environment variables');
  process.exit(1);
}

mongoose.connect(uri, { useNewUrlParser: true, useUnifiedTopology: true })
  .then(() => console.log('Connected to MongoDB'))
  .catch(err => {
    console.error('MongoDB connection error:', err);
    process.exit(1);
  });

const JWT_SECRET = process.env.JWT_SECRET;
const EMAIL_USER = process.env.EMAIL_USER;
const EMAIL_PASS = process.env.EMAIL_PASS;
const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!JWT_SECRET || !EMAIL_USER || !EMAIL_PASS || !SUPABASE_URL || !SUPABASE_SERVICE_ROLE_KEY) {
  console.error('Missing required environment variables');
  process.exit(1);
}

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: EMAIL_USER,
    pass: EMAIL_PASS,
  },
});

// Middleware to verify JWT
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  if (!token) {
    return res.status(401).json({ error: 'Access token required' });
  }
  jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) {
      return res.status(403).json({ error: 'Invalid or expired token' });
    }
    req.user = user;
    next();
  });
};

// Middleware to check admin role
const requireAdmin = (req, res, next) => {
  if (req.user.role !== 'admin') {
    return res.status(403).json({ error: 'Admin access required' });
  }
  next();
};

app.get('/', (req, res) => {
  res.send('Welcome to the Flutter Backend API!');
});

app.get('/health', (req, res) => {
  res.json({ message: 'Server is running' });
});

app.post('/register', async (req, res) => {
  const { name, gender, school, dateOfBirth, grade, email, password } = req.body;
  try {
    if (!name || !gender || !school || !dateOfBirth || !grade || !email || !password) {
      return res.status(400).json({ error: 'All fields are required' });
    }
    const existingUser = await User.findOne({ email: email.trim().toLowerCase() });
    if (existingUser) {
      if (!existingUser.isVerified) {
        const verificationCode = Math.floor(100000 + Math.random() * 900000).toString();
        existingUser.verificationCode = verificationCode;
        await existingUser.save();
        await transporter.sendMail({
          from: EMAIL_USER,
          to: email.trim().toLowerCase(),
          subject: 'Verify Your Email',
          text: `Your new verification code is: ${verificationCode}`,
        });
        console.log('New verification code sent to:', email, 'Code:', verificationCode);
        return res.status(200).json({ message: 'New verification code sent to your email' });
      }
      return res.status(400).json({ error: 'Email already exists and verified' });
    }
    const verificationCode = Math.floor(100000 + Math.random() * 900000).toString();
    const hashedPassword = await bcrypt.hash(password, 10);
    const user = new User({
      name,
      gender,
      school,
      dateOfBirth,
      grade,
      email: email.trim().toLowerCase(),
      password: hashedPassword,
      verificationCode,
      isVerified: false,
      role: 'user',
      avatar: '',
    });
    await user.save();
    console.log('User saved:', { email, verificationCode });
    await transporter.sendMail({
      from: EMAIL_USER,
      to: email.trim().toLowerCase(),
      subject: 'Verify Your Email',
      text: `Your verification code is: ${verificationCode}`,
    });
    console.log('Email sent to:', email, 'Code:', verificationCode);
    res.status(200).json({ message: 'Verification code sent to your email' });
  } catch (error) {
    console.error('Register error:', error);
    res.status(500).json({ error: 'Server error', details: error.message });
  }
});

app.post('/admin/register', async (req, res) => {
  const { name, email, password, gender, school, dateOfBirth, grade } = req.body;
  try {
    if (!name || !email || !password || !gender || !school || !dateOfBirth || !grade) {
      return res.status(400).json({ error: 'All fields are required' });
    }
    const existingUser = await User.findOne({ email: email.trim().toLowerCase() });
    if (existingUser) {
      return res.status(400).json({ error: 'Email already exists' });
    }
    const adminCount = await User.countDocuments({ role: 'admin' });
    if (adminCount > 0) {
      const authHeader = req.headers['authorization'];
      const token = authHeader && authHeader.split(' ')[1];
      if (!token) {
        return res.status(401).json({ error: 'Access token required' });
      }
      let decodedUser;
      try {
        decodedUser = jwt.verify(token, JWT_SECRET);
      } catch (err) {
        return res.status(403).json({ error: 'Invalid or expired token' });
      }
      if (decodedUser.role !== 'admin') {
        return res.status(403).json({ error: 'Admin access required' });
      }
    }
    const verificationCode = Math.floor(100000 + Math.random() * 900000).toString();
    const hashedPassword = await bcrypt.hash(password, 10);
    const user = new User({
      name,
      email: email.trim().toLowerCase(),
      password: hashedPassword,
      gender,
      school,
      dateOfBirth,
      grade,
      verificationCode,
      isVerified: false,
      role: 'admin',
      avatar: '',
    });
    await user.save();
    console.log('Admin saved:', { email, verificationCode });
    await transporter.sendMail({
      from: EMAIL_USER,
      to: email.trim().toLowerCase(),
      subject: 'Verify Your Admin Email',
      text: `Your verification code is: ${verificationCode}`,
    });
    console.log('Email sent to:', email, 'Code:', verificationCode);
    res.status(200).json({ message: 'Verification code sent to your email' });
  } catch (error) {
    console.error('Admin register error:', error);
    res.status(500).json({ error: 'Server error', details: error.message });
  }
});

app.post('/admin/create-book', authenticateToken, requireAdmin, async (req, res) => {
  const {
    bookId,
    title,
    description,
    coverImage,
    pageImageUrls,
    audioUrls,
    pageTexts,
    backgroundImageUrl,
    hashtags // Added support for hashtags
  } = req.body;

  try {
    if (
      !bookId ||
      !title ||
      !description ||
      !coverImage ||
      !pageImageUrls ||
      !audioUrls ||
      !pageTexts ||
      !backgroundImageUrl ||
      !Array.isArray(pageImageUrls) ||
      !Array.isArray(audioUrls) ||
      typeof pageTexts !== 'object'
    ) {
      return res.status(400).json({ error: 'All fields are required and must be valid' });
    }

    // Validate URLs
    const urlPattern = /^https:\/\/nqyegstlgecsutcsmtdx\.supabase\.co\/storage\/v1\/object\/public\//;
    if (
      !urlPattern.test(coverImage) ||
      !urlPattern.test(backgroundImageUrl) ||
      !pageImageUrls.every(url => urlPattern.test(url)) ||
      !audioUrls.every(url => urlPattern.test(url))
    ) {
      return res.status(400).json({ error: 'Invalid Supabase URLs' });
    }

    // Process hashtags (optional field, default to empty array if not provided)
    const processedHashtags = hashtags && Array.isArray(hashtags) ? hashtags.map(tag => tag.toLowerCase().trim().startsWith('#') ? tag : `#${tag}`).filter(tag => tag) : [];

    // Check if bookId already exists
    const { data: existingBook, error: fetchError } = await supabase
      .from('books')
      .select('book_id')
      .eq('book_id', bookId)
      .single();

    if (existingBook) {
      return res.status(400).json({ error: 'Book ID already exists' });
    }
    if (fetchError && fetchError.code !== 'PGRST116') {
      console.error('Fetch book error:', fetchError);
      return res.status(500).json({ error: 'Failed to check book ID', details: fetchError.message });
    }

    // Insert book metadata into Supabase
    const { error: insertError } = await supabase
      .from('books')
      .insert({
        book_id: bookId,
        title,
        description,
        cover_image: coverImage,
        page_image_urls: pageImageUrls,
        audio_urls: audioUrls,
        page_texts: pageTexts,
        background_image_url: backgroundImageUrl, // Correct field name matching the table schema
        hashtags: processedHashtags, // Add hashtags to the insert
      });

    if (insertError) {
      console.error('Insert book error:', insertError);
      return res.status(500).json({ error: 'Failed to create book', details: insertError.message });
    }

    res.status(201).json({ message: 'Book created successfully' });
  } catch (error) {
    console.error('Create book error:', error);
    res.status(500).json({ error: 'Server error', details: error.message });
  }
});

app.get('/books', async (req, res) => {
  try {
    const { data, error } = await supabase
      .from('books')
      .select('book_id, title, description, cover_image, page_image_urls, audio_urls, page_texts, background_image_url, hashtags'); // Added hashtags

    if (error) {
      console.error('Fetch books error:', error);
      return res.status(500).json({ error: 'Failed to fetch books', details: error.message });
    }

    res.status(200).json(data);
  } catch (error) {
    console.error('Fetch books error:', error);
    res.status(500).json({ error: 'Server error', details: error.message });
  }
});

app.post('/verify', async (req, res) => {
  const { email, code } = req.body;
  try {
    if (!email || !code) {
      return res.status(400).json({ error: 'Email and code are required' });
    }
    const user = await User.findOne({ email: email.trim().toLowerCase() });
    if (!user) {
      return res.status(400).json({ error: 'User not found' });
    }
    if (user.isVerified) {
      return res.status(400).json({ error: 'Email already verified' });
    }
    console.log('Verifying:', { email, receivedCode: code, storedCode: user.verificationCode });
    if (user.verificationCode !== code.trim()) {
      return res.status(400).json({ error: 'Invalid verification code' });
    }
    user.isVerified = true;
    user.verificationCode = undefined;
    await user.save();
    const token = jwt.sign(
      { userId: user._id, role: user.role },
      JWT_SECRET,
      { expiresIn: '1h' }
    );
    res.status(201).json({
      message: 'Email verified successfully',
      token,
      user: {
        name: user.name,
        email: user.email,
        gender: user.gender,
        avatar: user.avatar,
        role: user.role,
      },
    });
  } catch (error) {
    console.error('Verification error:', error);
    res.status(500).json({ error: 'Server error', details: error.message });
  }
});

app.post('/check-verification', async (req, res) => {
  const { email } = req.body;
  try {
    if (!email) {
      return res.status(400).json({ error: 'Email is required' });
    }
    const user = await User.findOne({ email: email.trim().toLowerCase() });
    if (!user) {
      return res.status(400).json({ error: 'User not found' });
    }
    res.status(200).json({ isVerified: user.isVerified || false });
  } catch (error) {
    console.error('Check verification error:', error);
    res.status(500).json({ error: 'Server error', details: error.message });
  }
});

app.post('/login', async (req, res) => {
  const { email, password } = req.body;
  try {
    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required' });
    }
    const user = await User.findOne({ email: email.trim().toLowerCase() });
    if (!user) {
      return res.status(400).json({ error: 'Invalid email or password' });
    }
    if (!user.isVerified) {
      return res.status(400).json({ error: 'Email not verified' });
    }
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({ error: 'Invalid email or password' });
    }
    const token = jwt.sign(
      { userId: user._id, role: user.role },
      JWT_SECRET,
      { expiresIn: '1h' }
    );
    res.status(200).json({
      message: 'Login successful!',
      token,
      user: {
        name: user.name,
        email: user.email,
        gender: user.gender,
        avatar: user.avatar,
        role: user.role,
      },
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ error: 'Server error', details: error.message });
  }
});

app.post('/forgot-password', async (req, res) => {
  const { email } = req.body;
  try {
    if (!email) {
      return res.status(400).json({ error: 'Email is required' });
    }
    const user = await User.findOne({ email: email.trim().toLowerCase() });
    if (!user) {
      return res.status(400).json({ error: 'User not found' });
    }
    const resetCode = Math.floor(100000 + Math.random() * 900000).toString();
    user.verificationCode = resetCode;
    await user.save();
    await transporter.sendMail({
      from: EMAIL_USER,
      to: email.trim().toLowerCase(),
      subject: 'Password Reset Code',
      text: `Your password reset code is: ${resetCode}`,
    });
    console.log('Password reset code sent to:', email, 'Code:', resetCode);
    res.status(200).json({ message: 'Password reset code sent to your email' });
  } catch (error) {
    console.error('Forgot password error:', error);
    res.status(500).json({ error: 'Server error', details: error.message });
  }
});

app.post('/reset-password', async (req, res) => {
  const { email, code, newPassword } = req.body;
  try {
    if (!email || !code || !newPassword) {
      return res.status(400).json({ error: 'Email, code, and new password are required' });
    }
    const user = await User.findOne({ email: email.trim().toLowerCase() });
    if (!user) {
      return res.status(400).json({ error: 'User not found' });
    }
    if (user.verificationCode !== code.trim()) {
      return res.status(400).json({ error: 'Invalid reset code' });
    }
    const hashedPassword = await bcrypt.hash(newPassword, 10);
    user.password = hashedPassword;
    user.verificationCode = undefined;
    await user.save();
    res.status(200).json({ message: 'Password reset successfully' });
  } catch (error) {
    console.error('Reset password error:', error);
    res.status(500).json({ error: 'Server error', details: error.message });
  }
});

app.post('/update-avatar', authenticateToken, async (req, res) => {
  const { avatar } = req.body;
  try {
    if (!avatar) {
      return res.status(400).json({ error: 'Avatar is required' });
    }
    const user = await User.findById(req.user.userId);
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }
    user.avatar = avatar;
    await user.save();
    res.status(200).json({ message: 'Avatar updated successfully', avatar: user.avatar });
  } catch (error) {
    console.error('Update avatar error:', error);
    res.status(500).json({ error: 'Server error', details: error.message });
  }
});

app.get('/user', authenticateToken, async (req, res) => {
  try {
    const user = await User.findById(req.user.userId).select('name email gender avatar role');
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }
    res.status(200).json({
      name: user.name,
      email: user.email,
      gender: user.gender,
      avatar: user.avatar,
      role: user.role,
    });
  } catch (error) {
    console.error('Fetch user error:', error);
    res.status(500).json({ error: 'Server error', details: error.message });
  }
});

app.delete('/delete-account', authenticateToken, async (req, res) => {
  try {
    const user = await User.findByIdAndDelete(req.user.userId);
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }
    console.log('Account deleted:', { email: user.email });
    res.status(200).json({ message: 'Account deleted successfully' });
  } catch (error) {
    console.error('Delete account error:', error);
    res.status(500).json({ error: 'Server error', details: error.message });
  }
});

app.get('/admin/users', authenticateToken, requireAdmin, async (req, res) => {
  try {
    const users = await User.find().select('name email gender avatar role school dateOfBirth grade');
    res.status(200).json(users);
  } catch (error) {
    console.error('Fetch users error:', error);
    res.status(500).json({ error: 'Server error', details: error.message });
  }
});

app.delete('/admin/delete-user/:userId', authenticateToken, requireAdmin, async (req, res) => {
  const { userId } = req.params;
  try {
    const user = await User.findByIdAndDelete(userId);
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }
    res.status(200).json({ message: 'User deleted successfully' });
  } catch (error) {
    console.error('Admin delete user error:', error);
    res.status(500).json({ error: 'Server error', details: error.message });
  }
});

app.use((req, res) => {
  res.status(404).json({ error: 'Route not found' });
});

module.exports = app;