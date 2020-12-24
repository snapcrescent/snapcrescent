import React, { Component } from 'react'
import Typography from '@material-ui/core/Typography';
import Button from '@material-ui/core/Button';
import CssBaseline from '@material-ui/core/CssBaseline';
import TextField from '@material-ui/core/TextField';
import Container from '@material-ui/core/Container';
import { Link } from 'react-router-dom';

import { signin } from '../../actions/AuthAction';

import './Signin.scss';

export class Signin extends Component {

  constructor(props) {
    super(props);

    this.state = {
      username: "",
      password: "",
      formErrors: {
        username: "",
        password: "",
      }
    }
  }

  handleSubmit = (event) => {
    event.preventDefault();

    if (this.validate()) {
      const requestObject = {
        username: this.state.username,
        password: this.state.password
      }
      signin(requestObject)
      .then(res => {
        if(res) {
          localStorage.setItem('user', JSON.stringify(res.user));
          localStorage.setItem('authenticated', true);
          localStorage.setItem('token', res.token);
          this.props.history.push('/home');
        }
      })
      .catch(error => {
        localStorage.setItem('authenticated', false);
      })
    }
  }

  handleChange = (event) => {
    event.preventDefault();
    const { name, value } = event.target;
    const formErrors = this.setErrors(name, value);

    this.setState({ formErrors, [name]: value });
  }

  validate = () => {
    let valid = true;
    let formErrors = this.state.formErrors;

    Object.keys(this.state).forEach(name => {
      formErrors = this.setErrors(name, this.state[name]);
    });

    Object.values(formErrors).forEach(formError => {
      if (formError.length) {
        valid = false;
      }
    });

    this.setState({ formErrors });
    return valid;
  };

  setErrors(name, value) {

    const formErrors = this.state.formErrors;
    switch (name) {
      case 'username':
        formErrors.username = value.length === 0
          ? 'Please enter user name.' : '';
        break;
      case 'password':
        formErrors.password = value.length === 0
          ? 'Please enter password.' : ''
        break;
      default:
        break;
    }

    return formErrors;
  }
  render() {
    return (
      <div className="signup-signin">
        <Container component="main" maxWidth="xs">
          <CssBaseline />
          <div className="card">
            <img className="logo" src={'/logo.png'} />
            <Typography component="h1" variant="h5">
              Sign In
            </Typography>
            <form className="form" noValidate>
              <TextField
                margin="normal"
                required
                fullWidth
                id="username"
                label="User Name"
                name="username"
                autoFocus
                onChange={this.handleChange}
                error={!!this.state.formErrors.username}
                helperText={this.state.formErrors.username}
              />
              <TextField
                margin="normal"
                required
                fullWidth
                name="password"
                label="Password"
                type="password"
                id="password"
                onChange={this.handleChange}
                error={!!this.state.formErrors.password}
                helperText={this.state.formErrors.password}
              />
              <Button
                type="submit"
                fullWidth
                variant="contained"
                color="primary"
                className="submit"
                onClick={this.handleSubmit}
              >
                Sign In
              </Button>
              <Link to="reset-password">
                <small>Reset Password</small>
              </Link>
              <div className="separator" />

              <Link to="signup">
                <Button
                  variant="contained"
                  className="newAccount"
                >
                  Create New Account
                </Button>
              </Link>
            </form>
          </div>
        </Container>
      </div>
    )
  }
}