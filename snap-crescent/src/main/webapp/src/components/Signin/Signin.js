import React, { useState } from 'react';
import Typography from '@material-ui/core/Typography';
import Button from '@material-ui/core/Button';
import CssBaseline from '@material-ui/core/CssBaseline';
import TextField from '@material-ui/core/TextField';
import Container from '@material-ui/core/Container';
import { Link, useHistory } from 'react-router-dom';
import { signin } from '../../services/AuthService';
import { updateAuthHeader } from '../../utils/ApiUtil';

import './Signin.scss';

const signinModel = {
  username: '',
  password: '',
  formErrors: {
    username: '',
    password: ''
  }
}

export const Signin = () => {
  const [formData, setFormData] = useState(signinModel);
  const history = useHistory();

  const handleSubmit = (event) => {
    event.preventDefault();
    if (validate(formData, setFormData)) {
      const requestObject = {
        username: formData.username,
        password: formData.password,
      }
      signin(requestObject)
        .then(res => {
          if (res) {
            localStorage.setItem('user', JSON.stringify(res.user));
            localStorage.setItem('token', res.token);
            updateAuthHeader(res.token);
            history.push({ pathname: '/home' });
          }
        })
    }
  }

  const handleChange = (event) => {
    event.preventDefault();
    const { name, value } = event.target;
    const formErrors = setErrors(name, value);
    setFormData({
      ...formData,
      formErrors,
      [name]: value
    });
  }

  const validate = () => {
    let valid = true;
    let formErrors = formData.formErrors;

    Object.keys(formData).forEach(name => {
      formErrors = setErrors(name, formData[name]);
    });

    Object.values(formErrors).forEach(formError => {
      if (formError.length) {
        valid = false;
      }
    });

    setFormData({ ...formData, formErrors });
    return valid;
  };

  const setErrors = (name, value) => {

    const formErrors = formData.formErrors;
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
  return (
    <div className="signup-signin">
      <Container component="main" maxWidth="xs">
        <CssBaseline />
        <div className="signup-signin-card">
          <img className="logo" src={'/logo.png'} alt="logo" />
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
              onChange={handleChange}
              error={!!formData.formErrors.username}
              helperText={formData.formErrors.username}
            />
            <TextField
              margin="normal"
              required
              fullWidth
              name="password"
              label="Password"
              type="password"
              id="password"
              onChange={handleChange}
              error={!!formData.formErrors.password}
              helperText={formData.formErrors.password}
            />
            <Button
              type="submit"
              fullWidth
              variant="contained"
              color="primary"
              className="submit"
              onClick={handleSubmit}
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