import React from 'react';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import Home from './home/Home';
import Settings from './settings/Settings';
import { NavigationContainer } from '@react-navigation/native';
import FontAwesome5 from 'react-native-vector-icons/FontAwesome5'

const Tab = createBottomTabNavigator();

function Tabs() {
    return (
        <NavigationContainer>
            <Tab.Navigator>
                <Tab.Screen name="Home" component={Home} options={{
                    tabBarIcon: ({ focused, color, size }) => {
                        return <FontAwesome5 name="home" style={{ fontSize: 20 }} />
                    }
                }} />
                <Tab.Screen name="Settings" component={Settings} options={{
                    tabBarIcon: ({ focused, color, size }) => {
                        return <FontAwesome5 name="cog" style={{ fontSize: 20 }} />
                    }
                }} />
            </Tab.Navigator>
        </NavigationContainer>
    );
}

export default Tabs;