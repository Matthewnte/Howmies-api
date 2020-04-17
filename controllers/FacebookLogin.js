const passport = require('passport');
const dotenv = require('dotenv');
const bcrypt = require('bcryptjs');
const strategy = require('passport-facebook');
const pool = require('../middleware/configs/elephantsql');
const facebookLogin = require('../middleware/configs/facebookConfig');
const LoginProcessor = require('../middleware/LoginHandler');

const FacebookStrategy = strategy.Strategy;

dotenv.config();

// Sign Facebook user up
const salt = bcrypt.genSaltSync(10);

const cryptedFacebookID = (facebookID) => bcrypt.hashSync(facebookID, salt);

const loginProcessor = new LoginProcessor();

const registerFacebookUser = async (firstName, lastName, email, facebookID, done) => {
  await pool.query(
    `INSERT INTO users(first_name, last_name, email, phone, password, register_date)
    VALUES($1, $2, $3, $4, $5, $6)
    RETURNING *`,
    [
      firstName,
      lastName,
      email,
      cryptedFacebookID(facebookID),
      Date.now(),
    ],
    async (err, result) => {
      if (err || (result.rows && result.rows.length === 0)) {
        return done(err);
      }

      loginProcessor.done = done;
      loginProcessor.uid = result.rows[0].id;
      loginProcessor.confirmedLogin = await loginProcessor.loggedUser;
      loginProcessor.username = `${result.rows[0].first_name} ${result.rows[0].last_name}`;
      loginProcessor.telephone = '';
      loginProcessor.email = result.rows[0].email;

      const user = { loginProcessor };

      module.exports.newUser = user;
      return done(null, user);
    },
  );

  return null;
};

// Check if Facebook user is an in-app registered user
const checkRegisteredUser = async (email, done, firstName, lastName, facebookID) => {
  await pool.query(
    'SELECT * FROM users WHERE email=$1',
    [email],
    async (err, result) => {
      if (err) {
        return done(err);
      }

      if (result.rows && result.rows.length === 0) {
        return registerFacebookUser(firstName, lastName, email, facebookID, done);
      }

      if (result.rows && result.rows.length === 1) {
        loginProcessor.done = done;
        loginProcessor.uid = result.rows[0].id;
        loginProcessor.confirmedLogin = await loginProcessor.loggedUser;
        loginProcessor.username = `${result.rows[0].first_name} ${result.rows[0].last_name}`;
        loginProcessor.telephone = '';
        loginProcessor.email = result.rows[0].email;

        const user = { loginProcessor };

        module.exports.loggedUser = user;
        return done(null, user);
      }
    },
  );

  return null;
};

passport.use(
  new FacebookStrategy(
    facebookLogin,
    ((accessTokenHowmies, refreshTokenHowmies, profile, done) => {
      const {
        email, id, first_name, last_name,
      } = profile._json;

      const user = {
        email,
        uid: id,
        firstName: first_name,
        lastName: last_name,
      };

      return checkRegisteredUser(user.email, done, user.firstName, user.lastName, id);
    }),
  ),
);