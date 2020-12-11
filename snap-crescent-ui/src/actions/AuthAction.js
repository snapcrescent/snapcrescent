import { postData } from '../utils/ApiUtil';

const SIGNUP_URL = 'sign-up';
const SIGNIN_URL = 'login';

export const signup = (props) => {  
  return postData(SIGNUP_URL, props);
}

export const signin = (props) => {  
  return postData(SIGNIN_URL, props);
}
