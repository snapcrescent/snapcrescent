import axios from 'axios';


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
        return res.data;
    });
}

export const postData = (url, props) => {
   return client.post(url, props)
   .then( res=> {
        return res.data;
    }).catch( res =>{
        return res.data;
    });
}