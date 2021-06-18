import React from 'react';
import ReactDOM from 'react-dom';
import './index.css';
import { BrowserRouter as Router } from 'react-router-dom';
import CssBaseline from '@material-ui/core/CssBaseline';
import reportWebVitals from './reportWebVitals';
import App from './components/app/App';

ReactDOM.render(
  <React.StrictMode>
    <Router>
      <CssBaseline />
      <App />
    </Router>
  </React.StrictMode>,
  document.getElementById('root'),
);

// Set minimum screen width
document.getElementById('root').style.minWidth = '1280px';
document.getElementById('root').style.width = '100vw';
document.getElementById('root').style.height = '100vh';
document.getElementById('root').style.overflow = 'auto';
document.getElementById('root').style.backgroundColor = '#fff';

// If you want to start measuring performance in your app, pass a function
// to log results (for example: reportWebVitals(console.log))
// or send to an analytics endpoint. Learn more: https://bit.ly/CRA-vitals
reportWebVitals();
