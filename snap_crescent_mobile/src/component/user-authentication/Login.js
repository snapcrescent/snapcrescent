import AsyncStorage from '@react-native-async-storage/async-storage';
import React from 'react';
import { useState } from 'react';
import {
    TextInput,
    View,
    Button,
    Text,
    TouchableOpacity
} from 'react-native';
import store from '../../core';
import { updateAuthState } from '../../core/action/authentication';
import { signin } from '../../core/service/AuthService';
import { isNotNull } from '../../utils/CoreUtil';
import FormControlStyle from './formControlStyles';
import FormError from './FormError';

const initialFormState = {
    username: '',
    password: '',
    formError: {
        username: '',
        password: ''
    }
}

function Login(props) {

    const [formControl, setFormControl] = useState(initialFormState);

    const submit = () => {
        if (validate()) {
            const payload = formControl;
            delete payload.formError;
            signin(payload).then(res => {

                if (res && isNotNull(res.token)) {
                    AsyncStorage.setItem('authToken', res.token).then(() => {
                        store.dispatch(updateAuthState(true));
                    });
                } else {
                    alert('Something went wrong. Please try later.');
                }
            });
        } else {
            alert('Please fill all the mandatory fields.');
        }
    }

    const validate = () => {
        let valid = true;

        Object.keys(formControl).forEach(key => {
            if (!['formError'].includes(key)) {
                setErrors(key, formControl[key]);
            }
        });

        Object.keys(formControl.formError).forEach(formErrorKey => {
            if (isNotNull(formControl.formError[formErrorKey])) {
                valid = false;
            }
        });

        return valid;
    }

    const setErrors = (key, value) => {
        const formError = formControl.formError;
        if (!isNotNull(value)) {
            formError[key] = 'Please enter a valid ' + key.toUpperCase();
        } else {
            formError[key] = '';
        }

        setFormControl({ ...formControl, formError });
    }


    return (
        <View style={FormControlStyle.container}>
            <TextInput
                style={[FormControlStyle.textInput]}
                placeholder="Username *"
                onBlur={() => setErrors('username', formControl.username)}
                onChangeText={(text) => setFormControl({ ...formControl, username: text })} />
            <FormError errorMessage={formControl.formError.username} />

            <TextInput
                style={[FormControlStyle.textInput]}
                secureTextEntry={true}
                placeholder="Password *"
                onBlur={() => setErrors('password', formControl.password)}
                onChangeText={(text) => setFormControl({ ...formControl, password: text })} />
            <FormError errorMessage={formControl.formError.password} />

            <View style={FormControlStyle.submitButton}>
                <Button title="Login" onPress={() => { submit() }} />
            </View>

            <View style={FormControlStyle.navigationLinks}>
                <TouchableOpacity onPress={() => props.navigation.navigate('Signup')}>
                    <Text>New User, Got to Signup</Text>
                </TouchableOpacity>
            </View>
        </View>
    );

}

export default Login;