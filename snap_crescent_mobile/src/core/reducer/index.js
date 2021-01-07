import { combineReducers } from 'redux';
import serverUrlReducer from './serverUrlReducer';
import isAuthenticatedReducer from './isAuthenticatedReducer';

const allReducers = combineReducers({
    isAuthenticated: isAuthenticatedReducer,
    serverUrl: serverUrlReducer
});

export default allReducers;