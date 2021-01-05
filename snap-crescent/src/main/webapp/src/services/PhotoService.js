import { getData } from '../utils/ApiUtil';

const PHOTO_URL = 'photo';

export const search = (props) => {
  props = {
    page: 0,
    size: 50,
    ...props
  };
  return getData(PHOTO_URL, props);
}

export const read = (props) => {
  return getData(PHOTO_URL + "/" + props);
}