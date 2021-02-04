import React, { useEffect, useState } from 'react';
import { createStackNavigator } from "@react-navigation/stack";
import { NavigationContainer } from '@react-navigation/native';
import Signin from './Signin';
import Signup from './Signup';
import Loader from '../Loader';
import { doesUserExists } from '../../core/service/AuthService';
import { View } from 'react-native';
import ServerUrl from './ServerUrl';
import { THEME_COLORS } from '../../styles/styles';

const Stack = createStackNavigator();

const initialState = {
    userExists: false,
    dataFecthed: false
};

function UserAuthentication() {
    const [state, setState] = useState(initialState);

    const authenticationScreens = [
        { key: 'signin', routeName: 'signin', title: 'SignIn', component: Signin },
        { key: 'signup', routeName: 'signup', title: 'SignUp', component: Signup },
        { key: 'server-url', routeName: 'server-url', title: 'Server', component: ServerUrl }
    ];

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
        doesUserExists().then(response => {
            setState({ userExists: response, dataFecthed: true });
        });
    }, []);

    return (
        <View style={{ flex: 1 }}>
            {
                !state.dataFecthed
                    ? <Loader />
                    : <NavigationContainer>
                        <Stack.Navigator initialRouteName={state.userExists ? 'signin' : 'signup'}>
                            {
                                authenticationScreens.map(screen => (
                                    <Stack.Screen
                                        key={screen.key}
                                        name={screen.routeName}
                                        component={screen.component}
                                        options={{ title: screen.title, ...headerStyleOptions }}>
                                    </Stack.Screen>
                                ))
                            }
                        </Stack.Navigator>
                    </NavigationContainer>
            }
        </View >

    );
}

export default UserAuthentication;