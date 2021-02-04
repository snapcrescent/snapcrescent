import { getData, getImage, postData } from '../utils/ApiUtil';

const PHOTO_URL = 'photo';

export const search = (props) => {
  props = {
    page: 0,
    size: 100,
    ...props
  };
  return getData(PHOTO_URL, props);
}

export const getById = (props) => {
  return getImage(PHOTO_URL + "/" + props);
}

export const like = (id) => {
  return postData(PHOTO_URL + "/" + id + "/like");
}