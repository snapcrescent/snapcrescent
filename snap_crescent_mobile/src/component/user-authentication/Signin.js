import AsyncStorage from '@react-native-async-storage/async-storage';
import React, { useState } from 'react';
import { ImageBackground } from 'react-native';
import {
    Button,
    Text,
    TextInput,
    TouchableOpacity,
    View
} from 'react-native';
import { Card } from 'react-native-elements';
import store from '../../core';
import { updateAuthState, updateAuthToken } from '../../core/action/authentication';
import { signin } from '../../core/service/AuthService';
import { showToast } from '../../core/service/ToastService';
import { THEME_COLORS } from '../../styles/styles';
import { isNotNull } from '../../utils/CoreUtil';
import FormControlStyle, { BACKGROUND_IMAGE } from './formControlStyles';
import FormError from './FormError';

const initialFormState = {
    username: '',
    password: '',
    formError: {
        username: '',
        password: ''
    }
}

function Signin(props) {

    const { navigation } = props;
    const [formControl, setFormControl] = useState(initialFormState);

    const submit = () => {
        if (validate()) {
            const payload = formControl;
            delete payload.formError;
            signin(payload).then(res => {
                if (res && isNotNull(res.token)) {
                    AsyncStorage.setItem('authToken', res.token).then(() => {
                        store.dispatch(updateAuthToken(res.token));
                        store.dispatch(updateAuthState(true));
                    });
                }
            });
        } else {
            showToast('Please fill all the mandatory fields.');
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
            <ImageBackground source={BACKGROUND_IMAGE} style={[FormControlStyle.background, FormControlStyle.centerAlignContainer]}>
                <Card containerStyle={FormControlStyle.cardContainer}>
                    <Card.Title>SignIn</Card.Title>
                    <Card.Divider />
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
                        <Button title="Login" onPress={() => { submit() }} color={THEME_COLORS.primary} />
                    </View>

                    <Card.Divider />

                    <View style={FormControlStyle.navigationLink}>
                        <TouchableOpacity onPress={() => navigation.navigate('Signup')}>
                            <Text>New User, Go to Signup</Text>
                        </TouchableOpacity>
                    </View>

                    <Card.Divider />

                    <View style={FormControlStyle.navigationLink}>
                        <TouchableOpacity
                            onPress={() =>
                                navigation.navigate(
                                    'ServerUrl',
                                    { isNavigatedFromAuthScreen: true }
                                )}>
                            <Text>Change Server URL</Text>
                        </TouchableOpacity>
                    </View>
                </Card>
            </ImageBackground>
        </View>
    );

}

export default Signin;