import { getData } from '../utils/ApiUtil';

const PHOTO_URL = 'photo';

export const search = () => {
  return getData(PHOTO_URL);
}

export const read = (props) => {
  return getData(PHOTO_URL + "/" + props);
}