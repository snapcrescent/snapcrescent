import React from 'react';
import { View, Text } from 'react-native';
import FontAwesome5 from 'react-native-vector-icons/FontAwesome5';
import Login from './src/component/user-auth/Login';
import Signup from './src/component/user-auth/Signup';
import { getData } from './src/utils/ApiUtil';

class App extends React.Component {

  constructor() {
    super();
  }

  componentDidMount() {
    this.checkUserExists();
  }

  async checkUserExists() {
    const resp = await getData('user-exists');
    console.warn(resp);
  }

  render() {
    return (
      <View style={{ flex: 1, margin: 10 }}>
        {/* <FontAwesome5 style={{ fontSize: 50 }} name={'comments'} />
        <Text style={{ fontSize: 25 }}>Hello React-Native</Text> */}
        {/* <Login /> */}
        <Signup />
      </View>
    );
  }
};

export default App; 