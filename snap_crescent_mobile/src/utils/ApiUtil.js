import React from 'react';

const BASE_URL = "http://192.168.48.139:8080/"
const HEADERS = {
    'Content-Type': 'application/json',
    'Access-Control-Allow-Origin': '*',
    'Authorization': 'Bearer '
};

export const getData = async (url) => {
    let resp = await fetch(BASE_URL + url, {
        method: 'GET',
        headers: HEADERS
    });

    resp = resp.json();
    return resp;
}

export const postData = async (url, body) => {
    console.log('Signup data', body);
    let resp = await fetch(BASE_URL + url, {
        method: 'POST',
        headers: HEADERS,
        body
    });

    resp = resp.json();
    return resp;
}

export const putData = async (url, body) => {
    let resp = await fetch(BASE_URL + url, {
        method: 'PUT',
        headers: HEADERS,
        body
    });

    resp = resp.json();
    return resp;
}
