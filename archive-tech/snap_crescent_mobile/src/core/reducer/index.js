import { combineReducers } from 'redux';
import serverUrlReducer from './serverUrlReducer';
import isAuthenticatedReducer from './isAuthenticatedReducer';
import authTokenReducer from './authTokenReducer';

const allReducers = combineReducers({
    isAuthenticated: isAuthenticatedReducer,
    authToken: authTokenReducer,
    serverUrl: serverUrlReducer
});

const rootReducer = (state, action) => {
    if (action.type === 'SIGN_OUT') {
        state = undefined;
    }

    return allReducers(state, action);
}

export default rootReducer;