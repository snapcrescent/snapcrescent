import React from 'react';
import { TextInput, View, Button, Text } from 'react-native';
import { signin } from '../../utils/AuthUtil';
import { isNotNull } from '../../utils/CoreUtil';
import AuthStyle from './Auth-Styles';

class Login extends React.Component {

    constructor(props) {
        super(props);

        this.state = {
            username: '',
            password: '',
            formError: {
                username: '',
                password: ''
            }
        }
    }

    login() {
        if (this.validate()) {
            const payload = this.state;
            delete payload.formError;
            signin(payload).then(resp => {
                console.warn(resp);
            });
        } else {
            console.warn('Please fill valid values.');
        }
    }

    validate() {
        let valid = true;

        Object.keys(this.state).forEach(key => {
            if (!['formError'].includes(key)) {
                this.setErrors(key, this.state[key]);
            }
        });

        Object.keys(this.state.formError).forEach(formErrorKey => {
            if (isNotNull(this.state.formError[formErrorKey])) {
                valid = false;
            }
        });

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

                <View style={{ marginTop: 10, width: '80%' }}>
                    <Button title="Login" onPress={() => { this.login() }} />
                </View>
                <View style={{ marginTop: 10, width: '80%' }}>
                    <Button title="Go to Signup" onPress={() => this.props.navigation.navigate('Signup')}></Button>
                </View>
            </View>
        );
    }
}

export default Login;