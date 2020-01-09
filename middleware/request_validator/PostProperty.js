const { body, header } = require('express-validator');

exports.postPropertyValidator = [
  header('Authorization')
    .trim(' ')
    .notEmpty()
    .withMessage('Invalid accessibility')
    .isJWT()
    .withMessage('Invalid accessibles')
    .escape(),
  body('type')
    .trim(' ')
    .notEmpty()
    .withMessage('Choose the type of property you are posting')
    .isLength({ max: 16 })
    .withMessage('Too long')
    .escape(),
  body('state')
    .trim(' ')
    .notEmpty()
    .withMessage('Input the state where the property is located')
    .isLength({ max: 16 })
    .withMessage('Too long')
    .escape(),
  body('lga')
    .trim(' ')
    .notEmpty()
    .withMessage('Input the LGA where the property is located')
    .isLength({ max: 16 })
    .withMessage('Too long')
    .escape(),
  body('address')
    .trim(' ')
    .notEmpty()
    .withMessage('Input the address where the property is located')
    .isLength({ max: 32 })
    .withMessage('Too long')
    .escape(),
  body('price')
    .trim(' ')
    .notEmpty()
    .withMessage('Input the price for patronage of the property')
    .isInt({ min: 0 })
    .withMessage('Price must range from 0 and above')
    .isLength({ max: 8 })
    .withMessage('Too long')
    .escape(),
  body('period')
    .trim(' ')
    .notEmpty()
    .withMessage('Input the period for which payment renewal is due')
    .isLength({ max: 12 })
    .withMessage('Too long')
    .escape(),
  body('description')
    .optional()
    .trim(' ')
    .isLength({ max: 128 })
    .withMessage('Too long')
    .escape(),
  body('features.*')
    .optional()
    .trim(' ')
    .notEmpty()
    .withMessage('Don\'t submit an empty description')
    .isLength({ max: 16 })
    .withMessage('Too long')
    .escape(),
];
