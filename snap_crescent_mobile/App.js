import AsyncStorage from '@react-native-async-storage/async-storage';
import React, { useEffect, useState } from 'react';
import { Image, Text, View } from 'react-native';
import { useSelector } from 'react-redux';
import ServerUrl from './src/component/user-authentication/ServerUrl';
import UserAuthentication from './src/component/user-authentication/UserAuthentication';
import { updateServerUrl } from './src/core/action/serverUrl';
import { isNotNull, isNull } from './src/utils/CoreUtil';
import store from './src/core';
import { updateAuthState, updateAuthToken } from './src/core/action/authentication';
import Tabs from './src/component/tabs/Tabs';
import CoreStyles, { THEME_COLORS } from './src/styles/styles';
import SplashScreen from './src/component/shared/splash-screen/SplashScreen';

const SPLASH_SCREEN_TIMEOUT = 250;

const initialState = {
  dataFetched: false
};

function App() {

  const serverUrl = useSelector(state => state.serverUrl);
  const isUserAuthenticated = useSelector(state => state.isAuthenticated);

  const [state, setState] = useState(initialState);

  useEffect(() => {
    checkServer();
  }, [serverUrl]);

  const checkServer = () => {
    AsyncStorage.getItem('serverUrl').then(serverUrl => {
      if (isNotNull(serverUrl)) {
        store.dispatch(updateServerUrl(serverUrl));
        checkAuthentication();
      } else {
        store.dispatch(updateServerUrl(null));
        store.dispatch(updateAuthToken(null));
        store.dispatch(updateAuthState(false));

        setTimeout(() => {
          setState({ dataFetched: true });
        }, SPLASH_SCREEN_TIMEOUT);
      }
    });
  }

  const checkAuthentication = () => {
    AsyncStorage.getItem('authToken').then(authToken => {
      if (isNotNull(authToken)) {
        store.dispatch(updateAuthToken(authToken));
        store.dispatch(updateAuthState(true));
      } else {
        store.dispatch(updateAuthToken(null));
        store.dispatch(updateAuthState(false));
      }
      setTimeout(() => {
        setState({ dataFetched: true });
      }, SPLASH_SCREEN_TIMEOUT);
    });
  }

  return (
    <View style={CoreStyles.flex1}>
      {
        !state.dataFetched
          ? <SplashScreen />
          : isNull(serverUrl)
            ? <ServerUrl />
            : (!isUserAuthenticated)
              ? <UserAuthentication />
              : <Tabs />
      }
    </View>
  );
}

export default App;