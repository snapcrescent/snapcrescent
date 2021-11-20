import { LoadingReducer } from './LoadingReducer';

import { combineReducers } from 'redux';

export const allReducers = combineReducers({
    loading: LoadingReducer
})