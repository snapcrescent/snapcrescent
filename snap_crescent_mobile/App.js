import React from 'react';
import 'react-native-gesture-handler';
import { View } from 'react-native';
import Login from './src/component/user-auth/Login';
import Signup from './src/component/user-auth/Signup';
import { NavigationContainer } from '@react-navigation/native';
import { createStackNavigator } from '@react-navigation/stack';
import { doesUserExists } from './src/utils/AuthUtil';

const Stack = createStackNavigator();
class App extends React.Component {

  constructor() {
    super();

    this.state = {
      dataFetched: false,
      userExists: false
    }
  }

  headerOptions = {
    headerStyle: {
      backgroundColor: '#15c57e',
    },
    headerTintColor: '#fff',
    headerTitleStyle: {
      fontWeight: 'bold',
    }
  }

  componentDidMount() {
    this.checkUserExists();
  }

  checkUserExists() {
    doesUserExists().then(resp => {
      this.setState({
        dataFetched: true,
        userExists: resp
      });
    });
  }

  render() {
    if (!this.state.dataFetched) {
      return null;
    } else {
      return (
        <View style={{ flex: 1 }}>
          <NavigationContainer>
            <Stack.Navigator initialRouteName={this.state.userExists ? 'Login' : 'Signup'}>
              <Stack.Screen name="Login" component={Login} options={this.headerOptions}></Stack.Screen>
              <Stack.Screen name="Signup" component={Signup} options={this.headerOptions}></Stack.Screen>
            </Stack.Navigator>
          </NavigationContainer>
        </View>
      );
    }

  }
};

export default App; 