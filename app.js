import createError from 'http-errors'
import express from 'express'
import path from 'path'

import cookieParser from 'cookie-parser'
import logger from 'morgan'

import bodyParser from 'body-parser'
const app = express();

app.use(bodyParser.json())
app.use(bodyParser.urlencoded({
  extended: true
}))

// view engine setup
app.set('views', path.join(__dirname, 'app/views'));
var engine = require('ejs-locals');
app.engine('ejs', engine);
app.set('view engine', 'ejs');

// app.use(logger('dev'));
app.use(express.json());
app.use(express.urlencoded({
  extended: false
}));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));

app.use((req, res, next) =>{
  res.locals.sharee = {
      url   : req.originalUrl
  }
  next();
});
import indexRouter from './routes/index'
app.use('/', indexRouter);

import contractRouter from './routes/contract'
app.use('/contract', contractRouter);

import custommerRouter from './routes/custommer'
app.use('/custommer', custommerRouter);

import productRouter from './routes/product'
app.use('/product', productRouter);


// allow-cors
app.use((req, res, next) => {
  console.log('Time router: ', Date.now())
  res.header("Access-Control-Allow-Origin", "*");
  res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
  next();
})
// catch 404 and forward to error handler
app.use((req, res, next) => {
  next(createError(404));
});

// error handler
app.use((err, req, res, next) => {
  // set locals, only providing error in development
  res.locals.message = err.message;
  res.locals.error = req.app.get('env') === 'development' ? err : {};
  // render the error page
  res.status(err.status || 500);
  res.render('error');
});


module.exports = app;