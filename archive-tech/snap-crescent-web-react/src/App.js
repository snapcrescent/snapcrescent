import React, { useEffect, useState } from 'react'
import './App.css';
import { Signup } from './components/Signup/Signup';
import { Signin } from './components/Signin/Signin';
import { Home } from './components/Home/Home';
import { HashRouter, Route, Redirect } from 'react-router-dom';
import { ResetPassword } from './components/ResetPassword/ResetPassword';
import { doesUserExists, authenticate } from './services/AuthService';
import { getConfigJWT } from './services/ConfigService';
import { CssBaseline } from '@material-ui/core';
import { updateAuthHeader } from './utils/ApiUtil';

const appModel = {
  dataFetched: false,
  userExists: null,
  isAuthenticated: localStorage.getItem('authenticated')
}

export const App = () => {
  const [formData, setFormData] = useState(appModel);

  useEffect(() => {
    getConfigJWT().then(res => {
      const demoToken = res;
      if (demoToken) {
        localStorage.setItem('env', 'demo');
        updateAuthHeader(demoToken);
        setFormData({ dataFetched: true, userExists: true, isAuthenticated: true });
      } else {
        localStorage.removeItem('env');
        doesUserExists()
          .then(exists => {
            if (localStorage.getItem('token')) {
              authenticate()
                .then(res => {
                  if (res) {
                    setFormData({ dataFetched: true, userExists: exists, isAuthenticated: true });
                  } else {
                    setFormData({ dataFetched: true, userExists: exists, isAuthenticated: false });
                  }
                });
            } else {
              setFormData({ dataFetched: true, userExists: exists, isAuthenticated: false });
            }

          });
      }
    });
  }, []);


  if (!formData.dataFetched) {
    return null;
  }
  return (
    <div className="App">
      <CssBaseline />
      <HashRouter>
        <Route
          exact
          path="/"
          render={() => {
            return (
              formData.isAuthenticated ?
                <Redirect to="/home" /> :
                formData.userExists ?
                  <Redirect to="/signin" /> :
                  <Redirect to="/signup" />
            )
          }}
        />
        <Route path='/home' component={Home} />
        <Route path='/signup' component={Signup} />
        <Route path='/signin' component={Signin} />
        <Route path='/reset-password' component={ResetPassword} />
      </HashRouter>
    </div>
  );
}

export default App;
