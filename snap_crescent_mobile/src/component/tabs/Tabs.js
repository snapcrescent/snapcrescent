import React from 'react';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import Home from './home/Home';
import Settings from './settings/Settings';
import { NavigationContainer } from '@react-navigation/native';
import FontAwesome5 from 'react-native-vector-icons/FontAwesome5';

const Tab = createBottomTabNavigator();

const tabBarOptions = {
    activeBackgroundColor: '#15c57e',
    activeTintColor: '#000000'
};

function Tabs() {
    return (
        <NavigationContainer>
            <Tab.Navigator tabBarOptions={tabBarOptions} initialRouteName="home">
                <Tab.Screen name="home" component={Home} options={{
                    tabBarIcon: ({ focused, color, size }) => {
                        return <FontAwesome5 name="home" style={{ fontSize: 20 }} />
                    }
                }} />
                <Tab.Screen name="settings" component={Settings} options={{
                    tabBarIcon: ({ focused, color, size }) => {
                        return <FontAwesome5 name="cog" style={{ fontSize: 20 }} />
                    }
                }} />
            </Tab.Navigator>
        </NavigationContainer >
    );
}

export default Tabs;