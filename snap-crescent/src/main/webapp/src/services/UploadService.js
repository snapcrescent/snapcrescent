import { multipartData } from '../utils/ApiUtil';

const UPLOAD_URL = 'upload';

export const upload = (props) => {
  return multipartData(UPLOAD_URL, props);
}