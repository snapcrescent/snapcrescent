import AsyncStorage from '@react-native-async-storage/async-storage';
import axios from 'axios';
import store from '..';

function getClient() {
    const serverUrl = store.getState().serverUrl;
    return axios.create({
        baseURL: 'http://' + serverUrl,
        headers: {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        },
    });

}

export const getData = (url) => {
    return getClient().get(url)
        .then(res => {
            return res.data;
        }).catch(error => {
            console.error(error);
        });
}

export const postData = (url, body) => {
    return getClient().post(url, body)
        .then(res => {
            return res.data;
        }).catch(error => {
            console.error(error);
        });
}

export const putData = (url, body) => {
    return getClient().put(url, body)
        .then(res => {
            return res.data;
        }).catch(error => {
            console.error(error);
        });
}


export const testStorageUrl = (serverUrl) => {
    const client = axios.create({
        baseURL: 'http://' + serverUrl,
        headers: {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
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