import { getImage } from '../utils/ApiUtil';

const THUMBNAIL_URL = 'thumbnail';

export const getById = (props) => {
  return getImage(THUMBNAIL_URL + "/" + props);
}