import React from 'react';
import { createStackNavigator } from '@react-navigation/stack';
import { THEME_COLORS } from '../../../styles/styles';
import PhotoGrid from '../../photo-grid/PhotoGrid';
import PhotoSlide from '../../photo-slide/PhotoSlide';

const HomeStack = createStackNavigator();

function Home() {

    const homeStackScreens = [
        { key: 'photos', title: 'Snap Crescent', routeName: 'photos', component: PhotoGrid },
        { key: 'photo-slide', title: 'Photo', routeName: 'photo-slide', component: PhotoSlide }
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

    return (
        <HomeStack.Navigator initialRouteName='photos'>
            {
                homeStackScreens.map(screen => (
                    <HomeStack.Screen
                        key={screen.key}
                        name={screen.routeName}
                        component={screen.component}
                        options={{
                            title: screen.title,
                            ...headerStyleOptions
                        }} />
                ))
            }
            {/* <HomeStack.Screen name='photos' component={PhotoGrid} options={{ title: 'Snap Crescent', ...headerStyleOptions }} />
            <HomeStack.Screen name='photo-slide' component={PhotoSlide} options={{ title: 'Photo', ...headerStyleOptions }} /> */}
        </HomeStack.Navigator>
    )
}

export default Home;