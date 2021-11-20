import React, { useEffect, useState } from 'react';
import { Button, ImageBackground, TextInput, View } from 'react-native';
import { Card } from 'react-native-elements';
import store from '../../core';
import { updateServerUrl } from '../../core/action/serverUrl';
import { testServerUrl } from '../../core/service/ApiService';
import { showToast } from '../../core/service/ToastService';
import { isNotNull } from '../../utils/CoreUtil';
import FormControlStyle, { BACKGROUND_IMAGE } from './formControlStyles';
import FormError from './FormError';
import CoreStyles, { THEME_COLORS } from '../../styles/styles';
import { signOut } from '../../core/service/AuthService';
import CloseIcon from '../shared/close-icon/CloseIcon';
import { State } from 'react-native-gesture-handler';

const initialFormState = {
    serverUrl: 'https://demo.snapcrescent.com',
    formError: {
        serverUrl: ''
    }
};

function ServerUrl(props) {

    const { navigation, route, isModalLayout, onModalClose } = props;

    const [formControl, setFormControl] = useState(initialFormState);
    const [navigatedFromAuthScreen, setNavigatedFromAuthScreen] = useState(false);

    useEffect(() => {
        if (route?.params?.isNavigatedFromAuthScreen) {
            setNavigatedFromAuthScreen(true);
        } else {
            setNavigatedFromAuthScreen(false);
        }
    }, [route?.params?.isNavigatedFromAuthScreen]);

    const setServer = (formControl) => {
        if (validate(formControl)) {
            const serverUrl = formControl.serverUrl;
            testServerUrl(serverUrl).then(res => {
                if (res) {
                    successHandler(serverUrl);
                } else {
                    showToast('Invalid URL.');
                }
            });
        } else {
            showToast('Please fill all the mandatory fields.');
        }
    };

    const successHandler = (serverUrl) => {
        const message = 'Whoooo you are now connected to the new Server.';
        if (isModalLayout) {
            signOut().then(() => {
                store.dispatch(updateServerUrl(serverUrl));
                showToast(message);
            });
        } else {
            store.dispatch(updateServerUrl(serverUrl));
            showToast(message);
            if (navigatedFromAuthScreen) {
                navigation.goBack();
            }
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
            <ImageBackground
                source={BACKGROUND_IMAGE}
                style={[FormControlStyle.background, (!isModalLayout ? FormControlStyle.centerAlignContainer : null)]}>
                {
                    isModalLayout
                        ? <View style={CoreStyles.flex1}>
                            <CloseIcon onPress={() => { onModalClose() }} />
                        </View>
                        : null
                }

                <View style={[FormControlStyle.centerAlignContainer, CoreStyles.width100, (isModalLayout ? CoreStyles.flex10 : null)]}>
                    <Card containerStyle={FormControlStyle.cardContainer}>
                        <Card.Title>Please enter a Server URL</Card.Title>
                        <Card.Divider />
                        <TextInput
                            style={[FormControlStyle.textInput]}
                            placeholder="Server URL *"
                            value={formControl.serverUrl}
                            onBlur={() => setErrors(formControl, 'serverUrl', formControl.serverUrl)}
                            onChangeText={(text) => setFormControl({ ...formControl, serverUrl: text })} />
                        <FormError errorMessage={formControl.formError.serverUrl} />

                        <View style={FormControlStyle.submitButton}>
                            <Button
                                title="Set Server"
                                onPress={() => { setServer(formControl) }}
                                color={THEME_COLORS.primary} />
                        </View>
                    </Card>
                </View>
            </ImageBackground>
        </View >
    );
}

export default ServerUrl;