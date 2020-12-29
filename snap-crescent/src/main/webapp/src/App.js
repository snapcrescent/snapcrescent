import React, { Component } from 'react'
import './App.css';
import { Signup } from './components/Signup/Signup';
import { Signin } from './components/Signin/Signin';
import { Home } from './components/Home/Home';
import { HashRouter, Route, Redirect } from 'react-router-dom';
import { ResetPassword } from './components/ResetPassword/ResetPassword';
import { doesUserExists, authenticate } from './services/AuthService';
import { CssBaseline } from '@material-ui/core';

export class App extends Component {

  constructor(props) {
    super(props);

    this.state = {
      dataFetched: false,
      userExists: false,
      isAuthenticated: false
    }
  }

  componentDidMount() {
    doesUserExists()
      .then(exists => {
        if(localStorage.getItem('token')) {
          authenticate() 
          .then( res => {
            if(res) {
              this.setState({ dataFetched: true, userExists: exists, isAuthenticated: true});
            } else {
              this.setState({ dataFetched: true, userExists: exists, isAuthenticated: false});
            }
          });
        } else {
          this.setState({ dataFetched: true, userExists: exists, isAuthenticated: false});
        }     
        
      });
  }
  render() {
    if (!this.state.dataFetched) {
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
                this.state.isAuthenticated ?
                  <Redirect to="/home" /> :
                  this.state.userExists ?
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
}

export default App;
