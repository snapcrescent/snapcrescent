import { getData, postData } from '../utils/ApiUtil';

const Album_URL = 'album';

export const search = (props) => {
  return getData(Album_URL, props);
}

export const create = (props) => {
  return postData(Album_URL, props);
}