import axios from 'axios';
import store from '..';

export const getHeaders = (includeAuthHeaders = true) => {
    const authToken = store.getState().authToken;
    const authHeaders = { 'Authorization': 'Bearer ' + authToken };

    return ({
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
        ...(
            includeAuthHeaders
                ? authHeaders
                : {}
        )
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


export const testServerUrl = (serverUrl) => {
    const client = axios.create({
        baseURL: serverUrl,
        headers: { ...getHeaders(false) },
    });

    return client.get('user-exists')
        .then(res => {
            return res ? true : false;
        }).catch(error => {
            return false;
        });
}

export const getImage = (url) => {
    return getClient().get(url, { responseType: 'blob' })
        .then(res => {
            return res.data;
        }).catch(error => {
            errorHandler(error);
        });
}

function getClient() {
    const serverUrl = store.getState().serverUrl;

    return axios.create({
        baseURL: serverUrl,
        headers: { ...getHeaders() },
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