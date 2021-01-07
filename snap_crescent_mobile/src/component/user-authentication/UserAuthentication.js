import React, { useEffect } from 'react';
import { createStackNavigator } from "@react-navigation/stack";
import { NavigationContainer } from '@react-navigation/native';
import Login from './Login';
import Signup from './Signup';
import Lodder from '../Lodder'
import { useState } from 'react';
import { doesUserExists } from '../../core/service/AuthService';
import { View } from 'react-native';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { isNotNull } from '../../utils/CoreUtil';
import store from '../../core';
import { updateAuthState } from '../../core/action/authentication';

const Stack = createStackNavigator();

const initialState = {
    userExists: false,
    dataFecthed: false
};

function UserAuthentication() {
    const [state, setState] = useState(initialState);

    const headerStyleOptions = {
        headerStyle: {
            backgroundColor: '#15c57e',
        },
        headerTintColor: '#fff',
        headerTitleStyle: {
            fontWeight: 'bold',
        }
    };

    useEffect(() => {
        try {
            AsyncStorage.getItem('authToken').then(authToken => {
                if (isNotNull(authToken)) {
                    store.dispatch(updateAuthState(true));
                } else {
                    doesUserExists().then(response => {
                        setState({ userExists: response, dataFecthed: true });
                    });
                }
            });
        } catch (error) {
            doesUserExists().then(response => {
                setState({ userExists: response, dataFecthed: true });
            });
        }
    }, []);

    return (
        <View style={{ flex: 1 }}>
            {
                !state.dataFecthed
                    ? <Lodder />
                    : <NavigationContainer>
                        <Stack.Navigator initialRouteName={state.userExists ? 'Signin' : 'Signup'}>
                            <Stack.Screen name='Signin' component={Login} options={{ title: 'Sign-In', ...headerStyleOptions }}></Stack.Screen>
                            <Stack.Screen name='Signup' component={Signup} options={{ title: 'Sign-Up', ...headerStyleOptions }}></Stack.Screen>
                        </Stack.Navigator>
                    </NavigationContainer>
            }
        </View>

    );
}

export default UserAuthentication;