import { getData, getImage } from '../utils/ApiUtil';

const PHOTO_URL = 'photo';

export const search = (props) => {
  props = {
    page: 0,
    size: 10,
    ...props
  };
  return getData(PHOTO_URL, props);
}

export const getById = (props) => {
  return getImage(PHOTO_URL + "/" + props);
}