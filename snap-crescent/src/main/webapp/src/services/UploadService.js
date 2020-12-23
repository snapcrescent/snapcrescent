import { postData } from '../utils/ApiUtil';

const UPLOAD_URL = 'upload';

export const upload = (props) => {
  return postData(UPLOAD_URL, props);
}