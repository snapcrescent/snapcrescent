import axios from 'axios';
import store from '..';

function getClient() {
    const serverUrl = store.getState().serverUrl;
    const authToken = store.getState().authToken;

    return axios.create({
        baseURL: 'http://' + serverUrl,
        headers: {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
            'Authorization': 'Bearer ' + authToken
        },
    });

}

export const getData = (url, searchParams) => {
    return getClient().get(url, { params: searchParams })
        .then(res => {
            return res.data;
        }).catch(error => {
            errorHandler(error);
        });
}

export const postData = (url, body) => {
    return getClient().post(url, body)
        .then(res => {
            return res.data;
        }).catch(error => {
            errorHandler(error);
        });
}

export const putData = (url, body) => {
    return getClient().put(url, body)
        .then(res => {
            return res.data;
        }).catch(error => {
            errorHandler(error);
        });
}


export const testStorageUrl = (serverUrl) => {
    const client = axios.create({
        baseURL: 'http://' + serverUrl,
        headers: {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
        },
    });

    return client.get('user-exists')
        .then(res => {
            if (res) {
                return true;
            }

            return false;
        }).catch(error => {
            return false;
        });
}

function errorHandler(error) {
    if (error &&
        error.response &&
        error.response.data &&
        error.response.data.message) {
        alert(error.response.data.message);
    }
}