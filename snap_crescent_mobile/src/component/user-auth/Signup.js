import React from 'react';
import { TextInput, View, StyleSheet, Button, Text } from 'react-native';
import { postData } from '../../utils/ApiUtil';
import { signup } from '../../utils/AuthUtil';

class Signup extends React.Component {

    constructor() {
        super();

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

    async submit() {
        if (this.validate()) {
            const payload = this.state;
            delete payload.confirmPassword;
            delete payload.formError;
            const resp = await signup(payload);
            console.warn(resp);
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
            if (this.isNotNull(this.state.formError[formErrorKey])) {
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
        if (!this.isNotNull(value)) {
            formErrors[name] = 'Please enter a valid value.';
        } else {
            formErrors[name] = '';
        }

        this.setState({ ...this.state, formError: formErrors });
    }

    isNotNull(value) {
        if (value &&
            value != '' &&
            value.length > 0) {
            return true;
        }

        return false;
    }

    render() {
        return (
            <View style={styles.container}>
                <TextInput
                    style={[styles.textInput, styles.marginY10]}
                    placeholder="Firstname *"
                    onChangeText={(text) => this.setState({ firstName: text })} />
                { this.state.formError.firstName != '' ? <Text style={styles.error}>{this.state.formError.firstName}</Text> : null}

                <TextInput
                    style={[styles.textInput, styles.marginY10]}
                    placeholder="Lastname"
                    onChangeText={(text) => this.setState({ lastName: text })} />

                <TextInput
                    style={[styles.textInput, styles.marginY10]}
                    placeholder="Username *"
                    onChangeText={(text) => this.setState({ username: text })} />
                { this.state.formError.username != '' ? <Text style={styles.error}>{this.state.formError.username}</Text> : null}

                <TextInput
                    style={[styles.textInput, styles.marginY10]}
                    secureTextEntry={true}
                    placeholder="Password *"
                    onChangeText={(text) => this.setState({ password: text })} />
                { this.state.formError.password != '' ? <Text style={styles.error}>{this.state.formError.password}</Text> : null}

                <TextInput
                    style={[styles.textInput, styles.marginY10]}
                    secureTextEntry={true}
                    placeholder="Confirm Password *"
                    onChangeText={(text) => this.setState({ confirmPassword: text })} />
                { this.state.formError.confirmPassword != '' ? <Text style={styles.error}>{this.state.formError.confirmPassword}</Text> : null}

                <Button title="Signup" onPress={() => { this.submit() }} />
            </View>
        );
    }
}

const styles = StyleSheet.create({
    container: {
        margin: 10,
        flex: 1,
        alignItems: 'center',
        justifyContent: 'center'
    },
    textInput: {
        height: 40,
        width: '80%',
        borderColor: 'gray',
        borderWidth: 1,
        borderRadius: 5
    },
    marginY10: {
        marginTop: 10,
        marginBottom: 10
    },
    error: {
        color: 'red',
        alignItems: 'flex-start',
        justifyContent: 'flex-start'
    }
});

export default Signup;