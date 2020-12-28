import { getData, postData } from "./ApiUtil";

const SIGNUP_URL = 'sign-up';
const SIGNIN_URL = 'login';
const SIGN_OUT_URL = "logout";
const RESET_PASSWORD_URL = 'reset-password';
const USER_EXISTS_URL = 'user-exists';

export const signup = async (props) => {
    return await postData(SIGNUP_URL, props);
}

export const signin = async (props) => {
    return await postData(SIGNIN_URL, props);
}

export const signOut = async (props) => {
    return await postData(SIGN_OUT_URL, props);
}

export const resetPassword = async (props) => {
    return await postData(RESET_PASSWORD_URL, props);
}
export const doesUserExists = async () => {
    return await getData(USER_EXISTS_URL);
}