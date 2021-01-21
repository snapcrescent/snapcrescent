import React, { useEffect, useState } from 'react';
import { createStackNavigator } from "@react-navigation/stack";
import { NavigationContainer } from '@react-navigation/native';
import Signin from './Signin';
import Signup from './Signup';
import Loader from '../Loader';
import { doesUserExists } from '../../core/service/AuthService';
import { View } from 'react-native';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { isNotNull } from '../../utils/CoreUtil';
import store from '../../core';
import { updateAuthState, updateAuthToken } from '../../core/action/authentication';
import ServerUrl from './ServerUrl';
import { THEME_COLORS } from '../../styles/styles';

const Stack = createStackNavigator();

const initialState = {
    userExists: false,
    dataFecthed: false
};

function UserAuthentication() {
    const [state, setState] = useState(initialState);

    const headerStyleOptions = {
        headerStyle: {
            backgroundColor: THEME_COLORS.secondary,
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
                    store.dispatch(updateAuthToken(authToken));
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
                    ? <Loader />
                    : <NavigationContainer>
                        <Stack.Navigator initialRouteName={state.userExists ? 'signin' : 'signup'}>
                            <Stack.Screen
                                name='signin'
                                component={Signin}
                                options={{ title: 'SignIn', ...headerStyleOptions }}>
                            </Stack.Screen>

                            <Stack.Screen
                                name='signup'
                                component={Signup}
                                options={{ title: 'SignUp', ...headerStyleOptions }}>
                            </Stack.Screen>

                            <Stack.Screen
                                name='server-url'
                                component={ServerUrl}
                                options={{ title: 'Server', ...headerStyleOptions }}>
                            </Stack.Screen>
                        </Stack.Navigator>
                    </NavigationContainer>
            }
        </View >

    );
}

export default UserAuthentication;