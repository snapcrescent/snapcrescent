import React, { useState } from 'react'
import Typography from '@material-ui/core/Typography';
import Button from '@material-ui/core/Button';
import CssBaseline from '@material-ui/core/CssBaseline';
import TextField from '@material-ui/core/TextField';
import Container from '@material-ui/core/Container';
import Grid from '@material-ui/core/Grid';
import { Link, useHistory } from 'react-router-dom';
import { signup } from '../../services/AuthService';
import './Signup.scss';

const signupModel = {
    firstName: '',
    lastName: '',
    username: '',
    password: '',
    confirmPassword: '',
    formErrors: {
        firstName: '',
        lastName: '',
        username: '',
        password: '',
        confirmPassword: ''
    }
}

export const Signup = () => {

    const [formData, setFormData] = useState(signupModel);
    const history = useHistory();

    const handleSubmit = (event) => {
        event.preventDefault();

        if (validate()) {
            const requestObject = {
                firstName: formData.firstName,
                lastName: formData.lastName,
                username: formData.username,
                password: formData.password
            };
            signup(requestObject)
                .then(res => {
                    if (res) {
                        history.push('/signin');
                    }
                })
                .catch(error => {
                    console.log(error)
                });
        }
    }

    const handleChange = (event) => {
        event.preventDefault();
        const { name, value } = event.target;
        const formErrors = setErrors(name, value);

        setFormData({ ...formData, formErrors, [name]: value });
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
            case 'firstName':
                formErrors.firstName = value.length === 0
                    ? 'First name is required field.' : '';
                break;
            case 'username':
                formErrors.username = value.length === 0
                    ? 'User name is required field.' : '';
                break;
            case 'password':
                formErrors.password = value.length === 0
                    ? 'Password is required field.' : ''
                break;
            case 'confirmPassword':
                formErrors.confirmPassword = formData.password !== value
                    ? 'Password do not match.' : '';
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
                <div className="card">
                    <img className="logo" src={'/logo.png'} alt="logo" />
                    <Typography component="h1" variant="h5">
                        Sign Up
                        </Typography>
                    <form className="form" noValidate>
                        <Grid container spacing={2}>
                            <Grid item xs>
                                <TextField
                                    margin="normal"
                                    required
                                    fullWidth
                                    id="firstName"
                                    label="First Name"
                                    name="firstName"
                                    autoFocus
                                    onChange={handleChange}
                                    error={!!formData.formErrors.firstName}
                                    helperText={formData.formErrors.firstName}
                                />
                            </Grid>
                            <Grid item xs>
                                <TextField
                                    margin="normal"
                                    fullWidth
                                    id="lastName"
                                    label="Last Name"
                                    name="lastName"
                                    onChange={handleChange}
                                    error={!!formData.formErrors.lastName}
                                    helperText={formData.formErrors.lastName}
                                />
                            </Grid>
                        </Grid>
                        <TextField
                            margin="normal"
                            required
                            fullWidth
                            id="username"
                            label="User Name"
                            name="username"
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
                        <TextField
                            margin="normal"
                            required
                            fullWidth
                            name="confirmPassword"
                            label="Confirm Password"
                            type="password"
                            id="confirmPassword"
                            onChange={handleChange}
                            error={!!formData.formErrors.confirmPassword}
                            helperText={formData.formErrors.confirmPassword}
                        />
                        <Button
                            type="submit"
                            fullWidth
                            variant="contained"
                            color="primary"
                            className="submit"
                            onClick={handleSubmit}
                        >
                            Sign Up
                            </Button>

                        <Link to="signin">
                            <small>Already have an account?</small>
                        </Link>
                    </form>
                </div>
            </Container>
        </div>
    )
}