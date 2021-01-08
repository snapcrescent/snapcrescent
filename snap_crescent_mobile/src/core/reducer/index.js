import { combineReducers } from 'redux';
import serverUrlReducer from './serverUrlReducer';
import isAuthenticatedReducer from './isAuthenticatedReducer';
import authTokenReducer from './authTokenReducer';

const allReducers = combineReducers({
    isAuthenticated: isAuthenticatedReducer,
    authToken: authTokenReducer,
    serverUrl: serverUrlReducer
});

export default allReducers;