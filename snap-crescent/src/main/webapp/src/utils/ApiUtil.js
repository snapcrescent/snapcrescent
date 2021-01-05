import axios from 'axios';
import { showError } from '../utils/ToastUtil';
import { increment, decrement } from '../actions/LoadingAction';
import { store } from '../index' 

const client = axios.create({
    baseURL: process.env.REACT_APP_BASE_URL,
    headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
        'Authorization': 'Bearer ' + localStorage.getItem("token")
    },
});

export const getData = (url, params) => {
    ShowLoader();
    return client.get(url, {params: {...params}})
        .then(res => {
            HideLoader();
            return res.data;
        }).catch(error => {
            HideLoader();
            if (error && error.response.data.message) {
                showError(error.response.data.message);
            }
        });
}

export const postData = (url, props) => {
    ShowLoader();
    return client.post(url, props)
        .then(res => {
            HideLoader();
            return res.data;
        }).catch(error => {
            HideLoader();
            if (error && error.response.data.message) {
                showError(error.response.data.message);
            }
        });
}

export const multipartData = (url, props, options, showLoader) => {
    if(showLoader) {
        ShowLoader();
    }
    return client.post(url, props, options, { headers: getmultipartHeader() })
        .then(res => {
            if(showLoader) {
                HideLoader();
            }
            return res.data;
        }).catch(error => {
            if(showLoader) {
                HideLoader();
            }
            if (error && error.response.data.message) {
                showError(error.response.data.message);
            }
        });
}

export const putData = (url, props) => {
    ShowLoader();
    return client.put(url, props)
        .then(res => {
            HideLoader();
            return res.data;
        }).catch(error => {
            HideLoader();
            if (error && error.response.data.message) {
                showError(error.response.data.message);
            }
        });
}

const getmultipartHeader = () => {
    return {
        'Content-Type': 'multipart/form-data',
        'Access-Control-Allow-Origin': '*',
        'Authorization': 'Bearer ' + localStorage.getItem("token")
    }
}

const ShowLoader = () => {
    store.dispatch(increment());
}

const HideLoader = () => {
    store.dispatch(decrement());
}