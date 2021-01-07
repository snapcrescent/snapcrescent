import React from 'react';
import { useState } from 'react';
import { Button, Text, TextInput, View } from "react-native";
import store from '../../core';
import { updateServerUrl } from '../../core/action/serverUrl';
import { testStorageUrl } from '../../core/service/ApiService';
import { isNotNull } from '../../utils/CoreUtil';
import FormControlStyle from './formControlStyles';
import FormError from './FormError';

const formControlIntitalState = {
    serverUrl: '',
    formError: {
        serverUrl: ''
    }
};

function ServerUrl() {
    const [formControl, setState] = useState(formControlIntitalState);

    const setStorage = (formControl) => {
        if (validate(formControl)) {
            const serverUrl = formControl.serverUrl;
            testStorageUrl(serverUrl).then(res => {
                if (res) {
                    store.dispatch(updateServerUrl(serverUrl));
                    alert('Whoooo you are now connected.');
                } else {
                    alert('Invalid URL.');
                }
            });
        } else {
            alert('Please fill all the mandatory fields.');
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

        setState({ ...formControl, formError });
    };

    return (
        <View style={FormControlStyle.container}>
            <Text style={{ fontSize: 14 }}>Please enter a Server URL</Text>
            <TextInput
                style={[FormControlStyle.textInput]}
                placeholder="Server URL *"
                onChangeText={(text) => setState({ ...formControl, serverUrl: text })} />
            <FormError errorMessage={formControl.formError.serverUrl} />

            <View style={FormControlStyle.submitButton}>
                <Button title="Set Server" onPress={() => { setStorage(formControl) }} />
            </View>

        </View>
    );
}

export default ServerUrl;