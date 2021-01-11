import React, { useEffect, useState } from 'react';
import { ImageBackground } from 'react-native';
import { Button, TextInput, View } from "react-native";
import { Card } from 'react-native-elements';
import store from '../../core';
import { updateServerUrl } from '../../core/action/serverUrl';
import { testServerUrl } from '../../core/service/ApiService';
import { showToast } from '../../core/service/ToastService';
import { isNotNull } from '../../utils/CoreUtil';
import FormControlStyle, { BACKGROUND_IMAGE } from './formControlStyles';
import FormError from './FormError';

const initialFormState = {
    serverUrl: '',
    formError: {
        serverUrl: ''
    }
};

function ServerUrl(props) {
    const [formControl, setFormControl] = useState(initialFormState);
    const [navigatedFromAuthScreen, setNavigatedFromAuthScreen] = useState(false);

    useEffect(() => {
        if (props?.route?.params?.isNavigatedFromAuthScreen) {
            setNavigatedFromAuthScreen(true);
        } else {
            setNavigatedFromAuthScreen(false);
        }
    }, [props?.route?.params?.isNavigatedFromAuthScreen]);

    const setStorage = (formControl) => {
        if (validate(formControl)) {
            const serverUrl = formControl.serverUrl;
            testServerUrl(serverUrl).then(res => {
                if (res) {
                    store.dispatch(updateServerUrl(serverUrl));
                    if (navigatedFromAuthScreen && props.navigation) {
                        showToast('Whoooo you are now connected to the new Server.');
                        props.navigation.goBack();
                    } else {
                        showToast('Whoooo you are now connected.');
                    }
                } else {
                    showToast('Invalid URL.');
                }
            });
        } else {
            showToast('Please fill all the mandatory fields.');
        }
    };

    const validate = (formControl) => {
        let valid = true;

        Object.keys(formControl).forEach(key => {
            if (!['formError'].includes(key)) {
                setErrors(formControl, key, formControl[key]);
            }
        });

        Object.keys(formControl.formError).forEach(formErrorKey => {
            if (isNotNull(formControl.formError[formErrorKey])) {
                valid = false;
            }
        });

        return valid;
    };

    const setErrors = (formControl, key, value) => {
        const formError = formControl.formError;
        if (!isNotNull(value)) {
            formError[key] = 'Please enter a valid ' + key.toUpperCase();
        } else {
            formError[key] = '';
        }

        setFormControl({ ...formControl, formError });
    };

    return (
        <View style={FormControlStyle.container}>
            <ImageBackground source={BACKGROUND_IMAGE} style={FormControlStyle.background}>
                <Card containerStyle={FormControlStyle.cardContainer}>
                    <Card.Title>Please enter a Server URL</Card.Title>
                    <Card.Divider />
                    <TextInput
                        style={[FormControlStyle.textInput]}
                        placeholder="Server URL *"
                        onBlur={() => setErrors(formControl, 'serverUrl', formControl.serverUrl)}
                        onChangeText={(text) => setFormControl({ ...formControl, serverUrl: text })} />
                    <FormError errorMessage={formControl.formError.serverUrl} />

                    <View style={FormControlStyle.submitButton}>
                        <Button title="Set Server" onPress={() => { setStorage(formControl) }} color="#3f51bf" />
                    </View>
                </Card>
            </ImageBackground>
        </View>
    );
}

export default ServerUrl;