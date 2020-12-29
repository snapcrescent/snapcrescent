import axios from 'axios';
import { showError } from '../utils/ToastUtil';
import { increment, decrement } from '../actions/LoadingAction';
import { store } from '../index' 

const client = axios.create({
    baseURL: 'http://localhost:8080/',
    headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
        'Authorization': 'Bearer ' + localStorage.getItem("token")
    },
});

export const getData = (url) => {
    ShowLoader();
    return client.get(url)
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

export const multipartData = (url, props) => {
    ShowLoader();
    return client.post(url, props, { headers: getmultipartHeader() })
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