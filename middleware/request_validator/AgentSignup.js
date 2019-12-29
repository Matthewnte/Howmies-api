const { body } = require('express-validator');

exports.agentSignupValidator = [
  body('agentName')
    .trim(' ')
    .notEmpty()
    .withMessage('Input agency name')
    .escape(),
  body('address')
    .trim(' ')
    .notEmpty()
    .withMessage('Input office address')
    .escape(),
  body('lga')
    .trim(' ')
    .notEmpty()
    .withMessage('Input office local government area')
    .escape(),
  body('state')
    .trim(' ')
    .notEmpty()
    .withMessage('Input the state your office is located')
    .escape(),
  body('email')
    .trim(' ')
    .notEmpty()
    .withMessage('Input a user email')
    .isEmail()
    .withMessage('Input correct email address')
    .normalizeEmail({ all_lowercase: true }),
  body('phoneNumber')
    .trim(' ')
    .notEmpty()
    .withMessage('Input a phone number into the office number field')
    .escape(),
  body('otherPhone')
    .optional({ nullable: true })
    .trim(' ')
    .notEmpty()
    .isMobilePhone(['en-NG'], { strictMode: true })
    .withMessage('Input a standard phone number e.g +234 8012345678')
    .custom((value, { req }) => value !== req.body.phoneNumber)
    .withMessage(
      'mobile number must not be the same as office number',
    )
    .escape(),
  body('password')
    .trim(' ')
    .notEmpty()
    .withMessage('Input a user password')
    .isLength({ max: 24, min: 8 })
    .withMessage('Password must be between 8 - 24 characters')
    .escape(),
  body('confirmPassword')
    .custom((value, { req }) => value === req.body.password)
    .withMessage(
      'confirmation password must be the same as the password you entered',
    )
    .trim(' ')
    .notEmpty()
    .withMessage('Confirm your user password')
    .isLength({ max: 24, min: 8 })
    .withMessage('Password must be between 8 - 24 characters')
    .escape(),
];
