const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');

const app = express();
const port = process.env.PORT || 3000; // Use assigned port or 3000 locally

app.use(cors());
app.use(express.json());

const uri = 'mongodb+srv://heran61:%23deNech1994@cluster0.kuu330z.mongodb.net/final?retryWrites=true&w=majority';
mongoose.connect(uri)
  .then(() => console.log('Connected to MongoDB'))
  .catch(err => {
    console.error('MongoDB connection error:', err);
    process.exit(1);
  });

const userSchema = new mongoose.Schema({
  name: { type: String, required: true },
  gender: { type: String, required: true },
  school: { type: String, required: true },
  dateOfBirth: { type: String, required: true },
  grade: { type: String, required: true },
  username: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  createdAt: { type: Date, default: Date.now }
});

const User = mongoose.model('User', userSchema);

app.post('/register', async (req, res) => {
  console.log('Received registration:', req.body);
  try {
    const { name, gender, school, dateOfBirth, grade, username, password } = req.body;

    const existingUser = await User.findOne({ username });
    if (existingUser) {
      return res.status(400).json({ error: 'Username already registered' });
    }

    const user = new User({
      name,
      gender,
      school,
      dateOfBirth,
      grade,
      username,
      password,
      createdAt: new Date()
    });

    await user.save();
    res.status(201).json({ message: 'Registration successful', id: user._id });
  } catch (error) {
    console.error('Registration error:', error);
    res.status(500).json({ error: 'Server error' });
  }
});

mongoose.connection.once('open', () => {
  app.listen(port, () => {
    console.log(`Server running on port ${port}`);
  });
});