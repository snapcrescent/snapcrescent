import AsyncStorage from '@react-native-async-storage/async-storage';
import React, { useEffect, useState } from 'react';
import { View } from 'react-native';
import { useSelector } from 'react-redux';
import ServerUrl from './src/component/user-authentication/ServerUrl';
import UserAuthentication from './src/component/user-authentication/UserAuthentication';
import { updateServerUrl } from './src/core/action/serverUrl';
import { isNotNull, isNull } from './src/utils/CoreUtil';
import store from './src/core';
import { updateAuthState } from './src/core/action/authentication';
import Loader from './src/component/Loader';
import Tabs from './src/component/tabs/Tabs';

const initialState = {
  dataFetched: false
};

function App() {

  const serverUrl = useSelector(state => state.serverUrl);
  const isUserAuthenticated = useSelector(state => state.isAuthenticated);

  const [state, setState] = useState(initialState);

  useEffect(() => {
    AsyncStorage.getItem('serverUrl').then(serverUrl => {
      if (isNotNull(serverUrl)) {
        store.dispatch(updateServerUrl(serverUrl));
      } else {
        store.dispatch(updateServerUrl(null));
        store.dispatch(updateAuthState(false));
      }

      setState({ ...state, dataFetched: true });
    });
  }, [serverUrl]);

  return (
    <View style={{ flex: 1 }}>
      {
        !state.dataFetched
          ? <Loader />
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