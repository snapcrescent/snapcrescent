import axios from 'axios';
import { showError } from '../utils/ToastUtil';

const client = axios.create({
    baseURL: 'http://localhost:8080/',
    headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
        'Authorization': 'Bearer ' + localStorage.getItem("token")
    },
});

export const getData = (url) => {
    return client.get(url)
        .then(res => {
            return res.data;
        }).catch(error => {
            if (error && error.response.data.message) {
                showError(error.response.data.message);
            }
        });
}

export const postData = (url, props) => {
    return client.post(url, props)
        .then(res => {
            return res.data;
        }).catch(error => {
            if (error && error.response.data.message) {
                showError(error.response.data.message);
            }
        });
}

export const multipartData = (url, props) => {
    return client.post(url, props, { headers: getmultipartHeader() })
        .then(res => {
            return res.data;
        }).catch(error => {
            if (error && error.response.data.message) {
                showError(error.response.data.message);
            }
        });
}

export const putData = (url, props) => {
    return client.put(url, props)
        .then(res => {
            return res.data;
        }).catch(error => {
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