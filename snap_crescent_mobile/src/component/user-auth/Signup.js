import React from 'react';
import { TextInput, View, Button, Text } from 'react-native';
import { signup } from '../../utils/AuthUtil';
import { isNotNull } from '../../utils/CoreUtil';
import AuthStyle from './Auth-Styles';

class Signup extends React.Component {

    constructor(props) {
        super(props);

        this.state = {
            firstName: '',
            lastName: '',
            username: '',
            password: '',
            confirmPassword: '',
            formError: {
                firstName: '',
                username: '',
                password: '',
                confirmPassword: ''
            }
        }
    }

    submit() {
        if (this.validate()) {
            const payload = this.state;
            delete payload.confirmPassword;
            delete payload.formError;
            signup(payload).then(resp => {
                console.warn(resp);
            });
        } else {
            console.warn('Please fill all the valid values.');
        }
    }

    validate() {
        let valid = true;

        Object.keys(this.state).forEach(key => {
            if (!['lastName', 'formError'].includes(key)) {
                this.setErrors(key, this.state[key]);
            }
        });

        Object.keys(this.state.formError).forEach(formErrorKey => {
            if (isNotNull(this.state.formError[formErrorKey])) {
                valid = false;
            }
        });

        if (this.state.password != this.state.confirmPassword) {
            this.state.formError.confirmPassword = 'Password does not match.';
            valid = false;
        }

        return valid;
    }

    setErrors(name, value) {
        const formErrors = this.state.formError;
        if (!isNotNull(value)) {
            formErrors[name] = 'Please enter a valid ' + name.toUpperCase();
        } else {
            formErrors[name] = '';
        }

        this.setState({ ...this.state, formError: formErrors });
    }

    render() {
        return (
            <View style={AuthStyle.container}>
                <TextInput
                    style={[AuthStyle.textInput, AuthStyle.marginY10]}
                    placeholder="Firstname *"
                    onBlur={() => this.setErrors('firstName', this.state.firstName)}
                    onChangeText={(text) => this.setState({ firstName: text })} />
                {
                    this.state.formError.firstName != ''
                        ? <Text style={AuthStyle.error}>{this.state.formError.firstName}</Text>
                        : null
                }

                <TextInput
                    style={[AuthStyle.textInput, AuthStyle.marginY10]}
                    placeholder="Lastname"
                    onChangeText={(text) => this.setState({ lastName: text })} />

                <TextInput
                    style={[AuthStyle.textInput, AuthStyle.marginY10]}
                    placeholder="Username *"
                    onBlur={() => this.setErrors('username', this.state.username)}
                    onChangeText={(text) => this.setState({ username: text })} />
                {
                    this.state.formError.username != ''
                        ? <Text style={AuthStyle.error}>{this.state.formError.username}</Text>
                        : null
                }

                <TextInput
                    style={[AuthStyle.textInput, AuthStyle.marginY10]}
                    secureTextEntry={true}
                    placeholder="Password *"
                    onBlur={() => this.setErrors('password', this.state.password)}
                    onChangeText={(text) => this.setState({ password: text })} />
                {
                    this.state.formError.password != ''
                        ? <Text style={AuthStyle.error}>{this.state.formError.password}</Text>
                        : null
                }

                <TextInput
                    style={[AuthStyle.textInput, AuthStyle.marginY10]}
                    secureTextEntry={true}
                    placeholder="Confirm Password *"
                    onBlur={() => this.setErrors('confirmPassword', this.state.confirmPassword)}
                    onChangeText={(text) => this.setState({ confirmPassword: text })} />
                {
                    this.state.formError.confirmPassword != ''
                        ? <Text style={AuthStyle.error}>{this.state.formError.confirmPassword}</Text>
                        : null
                }

                <View style={{ marginTop: 10, width: '80%' }}>
                    <Button title="Signup" onPress={() => { this.submit() }} />
                </View>
                <View style={{ marginTop: 10, width: '80%' }}>
                    <Button title="Go to Login" onPress={() => this.props.navigation.navigate('Login')}></Button>
                </View>
            </View>
        );
    }
}

export default Signup;