import React, { useState } from 'react';
import { ImageBackground } from 'react-native';
import { TextInput, View, Button, Text, TouchableOpacity } from 'react-native';
import { Card } from 'react-native-elements';
import { signup } from '../../core/service/AuthService';
import { showToast } from '../../core/service/ToastService';
import { THEME_COLORS } from '../../styles/styles';
import { isNotNull } from '../../utils/CoreUtil';
import FormControlStyle, { BACKGROUND_IMAGE } from './formControlStyles';

const initialFormState = {
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
};

function Signup(props) {

    const { navigation } = props;
    const [formControl, setFormControl] = useState(initialFormState);

    const submit = () => {
        if (validate()) {
            const payload = formControl;
            delete payload.confirmPassword;
            delete payload.formError;
            signup(payload).then(res => {
                if (res) {
                    navigation.navigate('Signin');
                }
            });
        } else {
            showToast('Please fill all the mandatory fields.');
        }
    }

    const validate = () => {
        let valid = true;

        Object.keys(formControl).forEach(key => {
            if (!['lastName', 'formError'].includes(key)) {
                setErrors(key, formControl[key]);
            }
        });

        Object.keys(formControl.formError).forEach(formErrorKey => {
            if (isNotNull(formControl.formError[formErrorKey])) {
                valid = false;
            }
        });

        if (formControl.password != formControl.confirmPassword) {
            formControl.formError.confirmPassword = 'Password does not match.';
            valid = false;
        }

        return valid;
    }

    const setErrors = (key, value) => {
        const formErrors = formControl.formError;
        if (!isNotNull(value)) {
            formErrors[key] = 'Please enter a valid ' + key.toUpperCase();
        } else {
            formErrors[key] = '';
        }

        setFormControl({ ...formControl, formError: formErrors });
    }


    return (
        <View style={FormControlStyle.container}>
            <ImageBackground source={BACKGROUND_IMAGE} style={[FormControlStyle.background, FormControlStyle.centerAlignContainer]}>
                <Card containerStyle={FormControlStyle.cardContainer}>
                    <Card.Title>SignUp</Card.Title>
                    <Card.Divider />
                    <TextInput
                        style={[FormControlStyle.textInput]}
                        placeholder="Firstname *"
                        onBlur={() => setErrors('firstName', formControl.firstName)}
                        onChangeText={(text) => setFormControl({ ...formControl, firstName: text })} />
                    {
                        formControl.formError.firstName != ''
                            ? <Text style={FormControlStyle.errorMessage}>{formControl.formError.firstName}</Text>
                            : null
                    }

                    <TextInput
                        style={[FormControlStyle.textInput]}
                        placeholder="Lastname"
                        onChangeText={(text) => setFormControl({ ...formControl, lastName: text })} />

                    <TextInput
                        style={[FormControlStyle.textInput]}
                        placeholder="Username *"
                        onBlur={() => setErrors('username', formControl.username)}
                        onChangeText={(text) => setFormControl({ ...formControl, username: text })} />
                    {
                        formControl.formError.username != ''
                            ? <Text style={FormControlStyle.errorMessage}>{formControl.formError.username}</Text>
                            : null
                    }

                    <TextInput
                        style={[FormControlStyle.textInput]}
                        secureTextEntry={true}
                        placeholder="Password *"
                        onBlur={() => setErrors('password', formControl.password)}
                        onChangeText={(text) => setFormControl({ ...formControl, password: text })} />
                    {
                        formControl.formError.password != ''
                            ? <Text style={FormControlStyle.errorMessage}>{formControl.formError.password}</Text>
                            : null
                    }

                    <TextInput
                        style={[FormControlStyle.textInput]}
                        secureTextEntry={true}
                        placeholder="Confirm Password *"
                        onBlur={() => setErrors('confirmPassword', formControl.confirmPassword)}
                        onChangeText={(text) => setFormControl({ ...formControl, confirmPassword: text })} />
                    {
                        formControl.formError.confirmPassword != ''
                            ? <Text style={FormControlStyle.errorMessage}>{formControl.formError.confirmPassword}</Text>
                            : null
                    }

                    <View style={FormControlStyle.submitButton}>
                        <Button title="Signup" onPress={() => { submit() }} color={THEME_COLORS.primary} />
                    </View>

                    <Card.Divider />

                    <View style={FormControlStyle.navigationLink}>
                        <TouchableOpacity onPress={() => navigation.navigate('signin')}>
                            <Text>Already a User, Go to Login.</Text>
                        </TouchableOpacity>
                    </View>

                    <Card.Divider />

                    <View style={FormControlStyle.navigationLink}>
                        <TouchableOpacity
                            onPress={() =>
                                navigation.navigate(
                                    'server-url',
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

export default Signup;