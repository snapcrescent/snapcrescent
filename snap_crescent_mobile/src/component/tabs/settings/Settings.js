import AsyncStorage from '@react-native-async-storage/async-storage';
import React from 'react';
import { Button, Text, View } from 'react-native';
import store from '../../../core';
import { updateAuthState, updateAuthToken } from '../../../core/action/authentication';

function Settings() {

    const signOut = () => {
        AsyncStorage.removeItem('authToken').then(() => {
            store.dispatch(updateAuthState(false));
            store.dispatch(updateAuthToken(null));
        });
    }

    return (
        <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center' }}>
            <Text>Settings!</Text>
            <Button title="Signout" onPress={() => (signOut())} />
        </View>
    );
}

export default Settings;