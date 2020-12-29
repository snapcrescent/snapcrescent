import axios from 'axios';

const client = axios.create({
    baseURL: 'http://192.168.43.139:8080/',
    headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*'
    },
});

export const getData = (url) => {
    return client.get(url)
        .then(res => {
            return res.data;
        }).catch(error => {
            if (error && error.response.data.message) {
                console.warn(error.response.data.message);
            }
        });
}

export const postData = (url, body) => {
    return client.post(url, body)
        .then(res => {
            return res.data;
        }).catch(error => {
            if (error && error.response.data.message) {
                console.warn(error.response.data.message);
            }
        });
}

export const putData = (url, body) => {
    return client.put(url, body)
        .then(res => {
            return res.data;
        }).catch(error => {
            if (error && error.response.data.message) {
                console.warn(error.response.data.message);
            }
        });
}
