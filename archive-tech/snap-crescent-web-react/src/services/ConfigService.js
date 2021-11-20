import { getData } from '../utils/ApiUtil';

const CONFIG_JWT_URL = 'config-jwt';

export const getConfigJWT = () => {
    return getData(CONFIG_JWT_URL);
}