import React from 'react';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import Home from './home/Home';
import Settings from './settings/Settings';
import { NavigationContainer } from '@react-navigation/native';
import FontAwesome5Icon from 'react-native-vector-icons/FontAwesome5';
import { THEME_COLORS } from '../../styles/styles';
import { StyleSheet } from 'react-native';

const Tab = createBottomTabNavigator();

function Tabs() {

    const tabs = [
        { key: 'home', routeName: 'home', component: Home, tabIcon: 'home' },
        { key: 'settings', routeName: 'settings', component: Settings, tabIcon: 'cog' }
    ];

    const tabBarOptions = {
        activeBackgroundColor: THEME_COLORS.primary,
        activeTintColor: '#000000'
    };

    return (
        <NavigationContainer>
            <Tab.Navigator tabBarOptions={tabBarOptions} initialRouteName="home">
                {
                    tabs.map(tab => (
                        <Tab.Screen
                            key={tab.key}
                            name={tab.routeName}
                            component={tab.component}
                            options={{
                                tabBarIcon: ({ focused, color, size }) => {
                                    return <FontAwesome5Icon name={tab.tabIcon} style={styles.tabIcon} />
                                }
                            }} />
                    ))
                }
            </Tab.Navigator>
        </NavigationContainer >
    );
}

const styles = StyleSheet.create({
    tabIcon: {
        fontSize: 20
    }
});

export default Tabs;