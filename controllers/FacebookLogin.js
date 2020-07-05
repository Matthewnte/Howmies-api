const passport = require('passport');
const strategy = require('passport-facebook');
const facebookLogin = require('../configs/facebookConfig');
const UserModel = require('../models/users-model');
const HashHandler = require('../utils/hash-handler');
const LoginProcessor = require('../utils/login-handler');

const FacebookStrategy = strategy.Strategy;

// Sign Facebook user up

const registerFacebookUser = async (firstName, lastName, email, facebookID, done) => {
  const passwordHash = HashHandler.generateHash(facebookID);
  try {
    const newUser = await UserModel.create(
      email, null, passwordHash, firstName, lastName,
    );

    const uid = newUser.id;
    const username = `${newUser.first_name} ${newUser.last_name}`;
    const telephone = '';
    const userEmail = newUser.email;

    const loginProcessor = new LoginProcessor(uid, username, telephone, userEmail);
    const user = { loginProcessor };
    module.exports.newUser = user;

    return done(null, user);
  } catch (error) {
    return done(JSON.stringify({
      remark: 'Error',
      message: 'Internal server error',
    }));
  }
};

// Check if Facebook user is an in-app registered user
const checkRegisteredUser = async (email, done, firstName, lastName, facebookID) => {
  try {
    const existingUser = await UserModel.getByEmail(email);
    if (!existingUser) {
      return registerFacebookUser(firstName, lastName, email, facebookID, done);
    }

    const uid = existingUser.id;
    const username = `${existingUser.first_name} ${existingUser.last_name}`;
    const telephone = '';
    const userEmail = existingUser.email;

    const loginProcessor = new LoginProcessor(uid, username, telephone, userEmail);
    const user = { loginProcessor };
    module.exports.loggedUser = user;

    return done(null, user);
  } catch (error) {
    return done(JSON.stringify({
      remark: 'Error',
      message: 'Internal server error',
    }));
  }
};

passport.use(
  new FacebookStrategy(
    facebookLogin,
    ((accessTokenHowmies, refreshTokenHowmies, profile, done) => {
      const {
        // eslint-disable-next-line camelcase
        email, id, first_name, last_name,
        // eslint-disable-next-line no-underscore-dangle
      } = profile._json;

      return checkRegisteredUser(email, done, first_name, last_name, id);
    }),
  ),
);
