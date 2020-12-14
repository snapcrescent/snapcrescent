import axios from 'axios';
import { error } from './ToastUtil';

const client = axios.create({
  baseURL: 'http://localhost:8080/',
  headers: {
    'Content-Type': 'application/json',
    'Access-Control-Allow-Origin': '*'
  },
});

export const getData = (url) => {
   return client.get(url)
   .then( res=> {
        return res.data;
    }).catch( res =>{
        error(res.response.data);
    });
}

export const postData = (url, props) => {
   return client.post(url, props)
   .then( res=> {
        return res.data;
    }).catch( res =>{
        error(res.response.data);
    });
}

export const putData = (url, props) => {
   return client.put(url, props)
   .then( res=> {
        return res.data;
    }).catch( res =>{
        error(res.response.data);
    });
}